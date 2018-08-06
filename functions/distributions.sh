#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

case "$ROOTFS_RELEASE" in
halium)
	IMAGE_SIZE=1G
	;;
pm)
	IMAGE_SIZE=2G
	;;
ut)
	IMAGE_SIZE=3G
	;;
none)
	IMAGE_SIZE=2G
	;;
esac

do_until_success() {
	while ! "$@"; do
		echo "Failed, please try again"
	done
}

function setup_passwd() {
	echo "Please enter a new password for the '$1' user:"
	do_until_success sudo chroot $ROOTFS_DIR passwd $1
}

function post_install() {
	if [ "$1" == "none" ]; then
		return
	fi

	architecture="$(readelf -h $ROOTFS_DIR/bin/sh | grep Machine | sed -e 's/^.*Machine: //' | xargs)"

	case $architecture in
	"ARM") qemu="qemu-arm-static" ;;
	"AArch64") qemu="qemu-aarch64-static" ;;
	*) qemu="qemu-arm-static" ;;
	esac

	sudo cp $(command -v $qemu) $ROOTFS_DIR/usr/bin
	case "$1" in
	halium)
		setup_passwd root

		sudo rm -f $ROOTFS_DIR/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		sudo DEBIAN_FRONTEND=noninteractive LANG=C RUNLEVEL=1 chroot $ROOTFS_DIR /bin/bash -c "source /etc/environment; dpkg-reconfigure dropbear-run"
		;;
	pm)
		setup_passwd root
		setup_passwd phablet

		# cant source /etc/environment
		# LD_LIBRARY_ ; QML2_IMPORT_ derps
		# set static path for now
		sudo DEBIAN_FRONTEND=noninteractive LANG=C RUNLEVEL=1 chroot $ROOTFS_DIR /bin/bash -c "dpkg-reconfigure openssh-server"
		;;
	ut)
		# Adapted from rootstock-ng
		echo -n "enabling Mir ... "
		sudo touch $ROOTFS_DIR/home/phablet/.display-mir
		echo "[done]"

		echo "enabling SSH ... "
		sudo sed -i 's/PasswordAuthentication=no/PasswordAuthentication=yes/g' $ROOTFS_DIR/etc/init/ssh.override
		sudo sed -i 's/manual/start on startup/g' $ROOTFS_DIR/etc/init/ssh.override
		sudo sed -i 's/manual/start on startup/g' $ROOTFS_DIR/etc/init/usb-tethering.conf
		setup_passwd phablet
		echo "[done]"

		sudo mkdir -p $ROOTFS_DIR/android/firmware
		sudo mkdir -p $ROOTFS_DIR/android/persist
		sudo mkdir -p $ROOTFS_DIR/userdata
		for link in cache data factory firmware persist system; do
			sudo ln -s /android/$link $ROOTFS_DIR/$link
		done
		sudo ln -s /system/lib/modules $ROOTFS_DIR/lib/modules
		sudo ln -s /android/system/vendor $ROOTFS_DIR/vendor
		[ -e rootfs/etc/mtab ] && sudo rm $ROOTFS_DIR/etc/mtab
		sudo ln -s /proc/mounts $ROOTFS_DIR/etc/mtab
		;;
	esac
	sudo rm $ROOTFS_DIR/usr/bin/$qemu
}
