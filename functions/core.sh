#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	SIZE=$(gzsize $ROOTFS_TAR)
	IMG_SIZE=$(( $SIZE + 100000000 ))
	qemu-img create -f raw $IMAGE_DIR/rootfs.img $IMG_SIZE
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F $IMAGE_DIR/rootfs.img
	sudo mount $IMAGE_DIR/rootfs.img $ROOTFS_DIR
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_androidimage() {
	if file $AND_IMAGE | grep "ext4 filesystem"; then
		cp system.img $IMAGE_DIR
	else
		simg2img $AND_IMAGE $IMAGE_DIR/system.img
	fi
}

function shrink_images() {
	[ -f system.img ] && sudo e2fsck -fy $IMAGE_DIR/system.img >/dev/null
	[ -f system.img ] && sudo resize2fs -p -M $IMAGE_DIR/system.img
}

function unmount() {
	sudo umount $ROOTFS_DIR
}

function flash() {
	for image in rootfs.img system.img; do
		if [ -f $IMAGE_DIR/$image ]; then
			adb push $IMAGE_DIR/$image /data/$image
		fi
	done

	if [ "$1" == "ut" ]; then
		adb shell ln /data/rootfs.img /data/system.img
	fi
}

function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR $IMAGE_DIR -rf
}
