#!/bin/bash
#
# Script for creating debian-pm flashable images
# ==============================================
#
# Copyright (C) 2018 JBBgameich
#
# License: GPLv3
#
# dependencies: qemu binfmt-support qemu-user-static e2fsprogs sudo simg2img img2simg

LOCATION="$(dirname "$(readlink -f "$0")")"

# Includes
source $LOCATION/functions/core.sh
source $LOCATION/functions/distributions.sh

# Essential pathes
export ROOTFS_DIR="$(mktemp -d .halium-install-rootfs.XXXXX)"
export IMAGE_DIR="$(readlink -f out/)"

# Create output folder if neccesary
! [ -d $IMAGE_DIR ] && mkdir -p $IMAGE_DIR

# Opts
export ROOTFS_TAR="$(readlink -f $1)"
export AND_IMAGE="$(readlink -f $2)"
export BOOT_IMAGE="$(readlink -f $3)"

# Functions
function make_flashable() {
	img2simg "$IMAGE_DIR/rootfs.img" "$IMAGE_DIR/rootfs.sparse.img"
}

function clean() {
	unmount && rm "$ROOTFS_DIR" -r
}

function boot_inject_initrd() {
	ARCH=$(sudo chroot "$ROOTFS_DIR" dpkg --print-architecture)
	INITRD="$(readlink -f $IMAGE_DIR/initrd.img)"

	cp "$BOOT_IMAGE" "$IMAGE_DIR/boot.img"

	wget -O "$INITRD" https://github.com/debian-pm-tools/generic-initrd/releases/download/continuous/initrd.img-generic-$ARCH
	abootimg -u "$IMAGE_DIR/boot.img" -r "$INITRD" -c "bootsize="
}

# Actual start of script
convert_rootfs 5G
convert_androidimage
shrink_images
# Merge images into one
sudo mv "$IMAGE_DIR/system.img" "$(readlink -f $ROOTFS_DIR/var/lib/lxc/android/)"
post_install halium
boot_inject_initrd
clean
make_flashable
