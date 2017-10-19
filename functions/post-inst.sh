#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function setup_passwd() {
	sudo cp $(command -v qemu-arm-static) rootfs/usr/bin

	sudo chroot rootfs passwd root

	sudo rm rootfs/usr/bin/qemu-arm-static
}

function post_install() {
	sudo cp $(command -v qemu-arm-static) rootfs/usr/bin

	for TASK in post-inst/$ROOTFS_RELEASE/*; do
		echo "I: Running task $TASK"

		cat $TASK | LANG=C RUNLEVEL=1 sudo  chroot rootfs
	done

	sudo rm rootfs/usr/bin/qemu-arm-static
}
