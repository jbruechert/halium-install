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

function shrink_images() {
	[ -f system.img ] && sudo e2fsck -fy system.img >/dev/null
	[ -f system.img ] && sudo resize2fs -p -M system.img
}

function unmount() {
	sudo umount rootfs
}

function flash() {
	# system.img is pushed inside the rootfs on ubuntu touch
	[ -f system.img ] && adb push system.img /data/system.img
	adb push rootfs.img /data/rootfs.img
}

function clean() {
	# Delete created files from last install
	sudo rm rootfs -rf

	sudo rm rootfs.img
	[ -f system.img ] && sudo rm system.img
}
