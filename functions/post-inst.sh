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
	ut)
		# Adapted from rootstock-ng
		echo -n "enabling Mir ... "
		sudo touch rootfs/home/phablet/.display-mir
		echo "[done]"

		echo "enabling SSH ... "
		sudo sed -i 's/PasswordAuthentication=no/PasswordAuthentication=yes/g' rootfs/etc/init/ssh.override
		sudo sed -i 's/manual/start on startup/g' rootfs/etc/init/ssh.override
		sudo chroot rootfs /bin/bash -c '/usr/bin/passwd phablet'
		echo "[done]"

		sudo mkdir -p rootfs/android/firmware
		sudo mkdir -p rootfs/android/persist
		sudo mkdir -p rootfs/userdata
		for link in cache data factory firmware persist system; do
			sudo ln -s /android/$link rootfs/$link
		done
		sudo ln -s /system/lib/modules rootfs/lib/modules
		sudo ln -s /android/system/vendor rootfs/vendor
		[ -e rootfs/etc/mtab ] && sudo rm rootfs/etc/mtab
		sudo ln -s /proc/mounts rootfs/etc/mtab

		# Remove or add globally after decison
		# After the switch to halium-boot (initramfs-tools) this code is not needed for Ubuntu Touch anymore
		echo -n "adding android system image to installation ... "
		ANDROID_DIR="/var/lib/lxc/android/"
		sudo mv system.img rootfs/$ANDROID_DIR
		echo "[done]"
		;;
	esac
	sudo rm rootfs/usr/bin/qemu-arm-static
}
