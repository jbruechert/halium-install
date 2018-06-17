#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function init_checks() {
	DEPENDENCIES=(qemu binfmt-support qemu-user-static e2fsprogs sudo simg2img)
	BINARIES=(simg2img qemu-arm-static mkfs.ext4 update-binfmts qemu-img)

	for bin in ${BINARIES[@]}; do
		if ! sudo bash -c "command -v $bin" >/dev/null 2>&1; then
			echo "$bin not found in \$PATH"
			echo
			echo "make sure you have all dependencies installed."
			echo "dependencies: ${DEPENDENCIES[*]}"
			return 1
		fi
	done

	# if qemu-arm-static exists, a sanely installed update-binfmts
	# -should- have qemu-arm. try to enable it in case it isnt.
	if ! sudo update-binfmts --display qemu-arm | grep -q "qemu-arm (enabled)"; then
		sudo update-binfmts --enable qemu-arm
	fi

	return 0
}

function usage() {
	cat <<-EOF
	usage: $0 [-p POSTINSTALL] rootfs.tar[.gz] system.img

	options:
	    -p POSTINSTALL  run common post installation tasks for release.
	                    supported: none, halium, pm, ut
	                    default: none

	positional arguments:
	    rootfs.tar[.gz]
	    system.img

	EOF
}

