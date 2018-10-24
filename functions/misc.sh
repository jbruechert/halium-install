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
	# This is only ran if the update-binfmts command is available
	if sudo bash -c "command -v update-binfmts" >/dev/null 2>&1; then
		if ! sudo update-binfmts --display qemu-arm | grep -q "qemu-arm (enabled)"; then
			sudo update-binfmts --enable qemu-arm
		fi
	fi

	return 0
}

function usage() {
	cat <<-EOF

	Usage: $0 [-p POSTINSTALL] [-v] rootfs.tar[.gz] system.img

	Options:
	    -p POSTINSTALL  run common post installation tasks for release.
	                    supported: none, halium, pm, ut
	                    default: none

	    -v              verbose output.

	Positional arguments:
	    rootfs.tar[.gz]
	    system.img

	EOF
}

