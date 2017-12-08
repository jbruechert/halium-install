#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function spinner() {
	local pid=$1
	local delay=0.75
	local spinstr='|/-\'
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		local temp=${spinstr#?}
		printf " [%c]  " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "\b\b\b\b"
}

function init_checks() {
	DEPENDENCIES=(qemu binfmt-support qemu-user-static e2fsprogs sudo simg2img)
	BINARIES=(sudo simg2img qemu-arm-static mkfs.ext4 update-binfmts qemu-img)

	if [ -f ../AppRun ] && ! [ $(whoami) == "root" ]; then
		echo "The AppImage can only be run as root, because we can't use sudo inside otherwise!"
		exit 1
	fi

	for bin in ${BINARIES[@]}; do
		if ! sudo bash -c "command -v $bin" > /dev/null 2>&1 ; then
			echo "$bin not found in \$PATH"
			echo
			echo "make sure you have all dependencies installed."
			echo "dependencies: ${DEPENDENCIES[*]}"
			return 1
		fi
	done

	# if qemu-arm-static exists, a sanely installed update-binfmts
	# -should- have qemu-arm. try to enable it in case it isnt.
	if ! sudo update-binfmts --display qemu-arm | grep -q "qemu-arm (enabled)" ; then
		sudo update-binfmts --enable qemu-arm
	fi

	return 0
}

function usage() {
	cat <<- EOF
	usage: $0 rootfs.tar[.gz] system.img [release]

	positional arguments:
	    rootfs.tar[.gz]
	    system.img

	optional arguments:
	    release: run common post installation tasks for release.
	             supported: none, halium, pm
	             defaults : none
	EOF
}
