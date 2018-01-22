#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	qemu-img create -f raw rootfs.img 2G
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F rootfs.img
	mkdir $ROOTFS_DIR
	sudo mount rootfs.img $ROOTFS_DIR
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_androidimage() {
	simg2img $AND_IMAGE system.img
}

function shrink_images() {
	[ -f system.img ] && sudo e2fsck -fy system.img >/dev/null
	[ -f system.img ] && sudo resize2fs -p -M system.img
}

function unmount() {
	sudo umount $ROOTFS_DIR
}

function adb_shell() {
	adb shell "$@"
}

function flash() {
	echo "compressing images (zip)"
	for image in rootfs.img system.img; do
		if [ -f $image ]; then
			zip -1 $image.zip $image
			adb push $image.zip /data/
			adb_shell unzip /data/$image.zip -d /data
			adb_shell rm /data/$image.zip
		fi
	done
}

function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR -rf

	for file in rootfs.img system.img; do
		if [ -f $file ]; then
			sudo rm $file $file.zip
		fi
	done
}
