#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

case "$ROOTFS_RELEASE" in
halium | reference)
	IMAGE_SIZE=1G
	;;
pm | neon | debian-pm | debian-pm-caf)
	IMAGE_SIZE=4G
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
	user=$1
	pass=$2
	if [ -z "$pass" ] ; then
		echo "Please enter a new password for the user '$user':"
		do_until_success sudo chroot "$ROOTFS_DIR" passwd $user
	else
		echo "I: Setting new password for the user '$user'"
		echo $user:$pass | sudo chroot "$ROOTFS_DIR" chpasswd
	fi
}

function chroot_run() {
	sudo PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" DEBIAN_FRONTEND=noninteractive LANG=C RUNLEVEL=1 chroot "$ROOTFS_DIR" /bin/bash -c "$@"
}

function copy_ssh_key_root() {
	if $DO_COPY_SSH_KEY ; then
		D="$ROOTFS_DIR/root/.ssh"
		echo "I: Copying ssh key to the user 'root'"

		sudo mkdir "$D"
		sudo tee -a "$D/authorized_key"s < $SSH_KEY >/dev/null
		sudo chmod 0700 "$D"
		sudo chmod 0600 "$D/authorized_keys"
	fi
}

function copy_ssh_key_phablet() {
	if $DO_COPY_SSH_KEY ; then
		D="$ROOTFS_DIR/home/phablet/.ssh"
		echo "I: Copying ssh key to the user 'phablet'"

		sudo mkdir "$D"
		sudo tee -a "$D/authorized_keys" < $SSH_KEY >/dev/null
		sudo chown -R 32011:32011 "$D"
		sudo chmod 0700 "$D"
		sudo chmod 0600 "$D/authorized_keys"
	fi
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

	sudo cp $(command -v $qemu) "$ROOTFS_DIR/usr/bin"
	sudo cp /etc/resolv.conf "$ROOTFS_DIR/etc/"
	case "$1" in
	halium | reference)
		setup_passwd root $ROOTPASSWORD
		copy_ssh_key_root

		if chroot_run "id -u phablet" >/dev/null 2>&1; then
			setup_passwd phablet $USERPASSWORD
			copy_ssh_key_phablet
		fi

		sudo rm -f "$ROOTFS_DIR"/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		chroot_run "dpkg-reconfigure dropbear-run"
		;;
	# Dropbear in debian moved from dropbear-run to the dropbear package.
	# TODO: Remove duplication once reference rootfs and debian-pm are on the same state again.
	debian-pm)
		setup_passwd root $ROOTPASSWORD
		copy_ssh_key_root

		if chroot_run "id -u phablet" >/dev/null 2>&1; then
			setup_passwd phablet $USERPASSWORD
			copy_ssh_key_phablet
		fi

		sudo rm -f "$ROOTFS_DIR"/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		chroot_run "dpkg-reconfigure dropbear"
		;;
	debian-pm-caf)
		setup_passwd root $ROOTPASSWORD
		copy_ssh_key_root

		if chroot_run "id -u phablet" >/dev/null 2>&1; then
			setup_passwd phablet $USERPASSWORD
			copy_ssh_key_phablet
		fi

		sudo rm -f "$ROOTFS_DIR"/etc/dropbear/dropbear_{dss,ecdsa,rsa}_host_key
		chroot_run "dpkg-reconfigure dropbear"

		echo "Adding repository for libhybris platform caf"
		chroot_run "echo 'deb https://repo.kaidan.im/debpm testing caf' > /etc/apt/sources.list.d/debian-pm.list"

		chroot_run "apt update && apt full-upgrade -y"
		;;
	pm | neon)
		setup_passwd root $ROOTPASSWORD
		copy_ssh_key_root
		setup_passwd phablet $USERPASSWORD
		copy_ssh_key_phablet

		# cant source /etc/environment
		# LD_LIBRARY_ ; QML2_IMPORT_ derps
		# set static path for now
		chroot_run "dpkg-reconfigure openssh-server"
		;;
	ut)
		# Adapted from rootstock-ng
		echo -n "enabling Mir ... "
		sudo touch "$ROOTFS_DIR/home/phablet/.display-mir"
		echo "[done]"

		echo -n "enabling SSH ... "
		sudo sed -i 's/PasswordAuthentication=no/PasswordAuthentication=yes/g' "$ROOTFS_DIR/etc/init/ssh.override"
		sudo sed -i 's/manual/start on startup/g' "$ROOTFS_DIR/etc/init/ssh.override"
		sudo sed -i 's/manual/start on startup/g' "$ROOTFS_DIR/etc/init/usb-tethering.conf"
		echo "[done]"

		setup_passwd phablet $USERPASSWORD
		copy_ssh_key_phablet

		sudo mkdir -p "$ROOTFS_DIR/android/firmware"
		sudo mkdir -p "$ROOTFS_DIR/android/persist"
		sudo mkdir -p "$ROOTFS_DIR/userdata"
		for link in cache data factory firmware persist system odm product metadata; do
			sudo ln -s /android/$link "$ROOTFS_DIR/$link"
		done
		sudo ln -s /system/lib/modules "$ROOTFS_DIR/lib/modules"
		sudo ln -s /android/vendor "$ROOTFS_DIR/vendor"
		[ -e rootfs/etc/mtab ] && sudo rm "$ROOTFS_DIR/etc/mtab"
		sudo ln -s /proc/mounts "$ROOTFS_DIR/etc/mtab"
		;;
	esac
	sudo rm "$ROOTFS_DIR/usr/bin/$qemu"
}

