#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	qemu-img create -f raw rootfs.img 2G
	sudo mkfs.ext4 -F rootfs.img
	mkdir rootfs
	sudo mount rootfs.img rootfs
	sudo tar -xf $ROOTFS_TAR -C rootfs
}

function convert_androidimage() {
	simg2img $AND_IMAGE system.img
}

function rootfs_sparse() {
	img2simg rootfs.img rootfs.sparse.img
}

function shrink_images() {
	sudo e2fsck -fy system.img >/dev/null
	sudo resize2fs -p -M system.img
}

function unmount() {
	sudo umount rootfs
}

function flash() {
	adb push system.img /data/system.img

	if [ -f rootfs.sparse.img ]; then
		adb reboot bootloader
		fastboot flash rootfs.sparse.img
	else
		adb push rootfs.img /data/rootfs.img
	fi
}

function clean() {
	# Delete created files from last install
	sudo rm rootfs -rf

	sudo rm rootfs.img
	if [ -f rootfs.sparse.img ]; then rm rootfs.sparse.img; fi
	sudo rm system.img
}
