#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

do_until_success() {
	while ! "$@"; do
		echo "Failed, trying again"
	done
}

function setup_passwd() {
	sudo cp $(command -v qemu-arm-static) $ROOTFS_DIR/usr/bin

	do_until_success sudo chroot $ROOTFS_DIR passwd root

	sudo rm $ROOTFS_DIR/usr/bin/qemu-arm-static
}

function post_install() {
	if [ "$1" == "none" ]; then
		return
	fi

	sudo cp $(command -v qemu-arm-static) $ROOTFS_DIR/usr/bin
	case "$1" in
	halium)
		sudo rm -f $ROOTFS_DIR/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		sudo LANG=C RUNLEVEL=1 chroot $ROOTFS_DIR /bin/bash -c "source /etc/environment; dpkg-reconfigure dropbear-run"
		;;
	pm)
		do_until_success sudo chroot $ROOTFS_DIR passwd phablet

		# cant source /etc/environment
		# LD_LIBRARY_ ; QML2_IMPORT_ derps
		# set static path for now
		sudo LANG=C RUNLEVEL=1 chroot $ROOTFS_DIR /bin/bash -c "dpkg-reconfigure openssh-server"
		;;
	ut)
		# Adapted from rootstock-ng
		echo -n "enabling Mir ... "
		sudo touch $ROOTFS_DIR/home/phablet/.display-mir
		echo "[done]"

		echo "enabling SSH ... "
		sudo sed -i 's/PasswordAuthentication=no/PasswordAuthentication=yes/g' $ROOTFS_DIR/etc/init/ssh.override
		sudo sed -i 's/manual/start on startup/g' $ROOTFS_DIR/etc/init/ssh.override
		sudo chroot $ROOTFS_DIR /bin/bash -c '/usr/bin/passwd phablet'
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

		# Remove or add globally after decison
		# After the switch to halium-boot (initramfs-tools) this code is not needed for Ubuntu Touch anymore
		echo -n "adding android system image to installation ... "
		ANDROID_DIR="/var/lib/lxc/android/"
		sudo mv system.img $ROOTFS_DIR/$ANDROID_DIR
		echo "[done]"
		;;
	esac
	sudo rm $ROOTFS_DIR/usr/bin/qemu-arm-static
}
