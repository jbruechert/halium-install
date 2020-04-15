#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function init_checks() {
	DEPENDENCIES=(qemu-utils binfmt-support qemu-user-static e2fsprogs sudo simg2img binutils)
	BINARIES=(simg2img qemu-arm-static mkfs.ext4 qemu-img readelf)

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

	Usage: $0 [-p POSTINSTALL] [-v] [-u USERPASSWORD] [-r ROOTPASSWORD] [-i] [-z] rootfs.tar[.gz] system.img

	Options:
	    -p POSTINSTALL  run common post installation tasks for release.
	                    supported: reference, neon, ut, debian-pm, debian-pm-caf, none
	                    default: none

	    -v              verbose output.

	    -u USERPASSWORD set this password for user phablet instead of
	                    interactively asking for a password (does not apply to
	                    all POSTINSTALL selections)

	    -r ROOTPASSWORD set this passowrd for root user instead of interactively
	                    asking for a password (does not apply to all POSTINSTALL
	                    selections).

	    -i              copy your ssh public key into the image for password
	                    less login (depending on POSTINSTALL selection for user
	                    root or phablet or both)

	    -z              compress images before pushing them to the device

	    -m mode
	    --mode mode

	                    "dir":
	                        install to a directory on the target device instead of an image.
	                        This is useful if you want to make full use of the space
	                        available on the partition.
	                        Note: This requires support in the initramfs.

	                    "img":
	                        install to an image on /data. This file system layout is supported
	                        by all known halium reference initramfs implementations.

	    -s
	    --system-as-root
	                    install the system image as system-as-root compatible.
	                    This requires support in the initramfs implementation.

	Positional arguments:
	    rootfs.tar[.gz]
	    system.img

	EOF
}

