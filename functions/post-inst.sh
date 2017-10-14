#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function setup_passwd() {
	sudo cp $(which qemu-arm-static) rootfs/usr/bin

	sudo chroot rootfs passwd root

	sudo rm rootfs/usr/bin/qemu-arm-static
}

function post_install() {
	if [ "$1" == "none" ]; then
		return
	fi

	sudo cp $(which qemu-arm-static) rootfs/usr/bin
	case "$1" in
	halium)
		sudo rm -f rootfs/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		sudo LANG=C RUNLEVEL=1 chroot rootfs /bin/bash -c "source /etc/environment; dpkg-reconfigure dropbear-run"
		;;
	pm)
		sudo chroot rootfs passwd phablet

		# cant source /etc/environment
		# LD_LIBRARY_ ; QML2_IMPORT_ derps
		# set static path for now
		sudo LANG=C RUNLEVEL=1 PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games" chroot rootfs /bin/bash -c "dpkg-reconfigure openssh-server"
		;;
	esac
	sudo rm rootfs/usr/bin/qemu-arm-static
}
