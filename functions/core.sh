#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	dd if=/dev/zero of=rootfs.img seek=500K bs=4096 count=0
	sudo mkfs.ext4 -F rootfs.img
	mkdir rootfs
	sudo mount rootfs.img rootfs
	sudo tar -xf $ROOTFS_TAR -C rootfs
}

function convert_androidimage() {
	simg2img $AND_IMAGE system.img
}

function shrink_images() {
	sudo e2fsck -fy system.img > /dev/null
	sudo resize2fs -p -M system.img
}

function unmount() {
	sudo umount rootfs
}

function flash() {
	adb push system.img /data/system.img
	adb push rootfs.img /data/rootfs.img
}

function clean() {
	# Delete created files from last install
	sudo rm rootfs -rf

	sudo rm rootfs.img
	sudo rm system.img
}
