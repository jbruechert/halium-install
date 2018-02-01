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

function flash() {
	for image in rootfs.img system.img; do
		if [ -f $image ]; then
			adb push $image /data/$image
		fi
	done

	if [ "$1" == "ut" ]; then
		adb shell ln /data/rootfs.img /data/system.img
	fi
}

function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR -rf

	for file in rootfs.img system.img; do
		if [ -f $file ]; then
			sudo rm $file
		fi
	done
}
