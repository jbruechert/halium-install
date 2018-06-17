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
source $LOCATION/functions/misc.sh

function usage() {
	cat <<-EOF
	usage: $0 rootfs.tar[.gz] system.img boot.img distribution

	positional arguments:
	    rootfs.tar[.gz]
	    system.img
	    boot.img
	EOF
}

# opts parser
if [ "$#" -ne 4 ]; then
	usage
	exit
fi

# Check for missing dependencies
DEPENDENCIES=(qemu binfmt-support qemu-user-static e2fsprogs sudo simg2img abootimg)
BINARIES=(simg2img img2simg qemu-arm-static mkfs.ext4 update-binfmts qemu-img e2label abootimg)

init_checks

# Essential pathes
export ROOTFS_DIR="$(mktemp -d .halium-install-rootfs.XXXXX)"
export IMAGE_DIR="$(readlink -f out/)"

# Create output folder if neccesary
! [ -d $IMAGE_DIR ] && mkdir -p $IMAGE_DIR

# Opts
export ROOTFS_TAR="$(readlink -f $1)"
export AND_IMAGE="$(readlink -f $2)"
export BOOT_IMAGE="$(readlink -f $3)"
export DISTRIBUTION="$4"

# Functions
function label_rootfs {
	sudo e2label $IMAGE_DIR/rootfs.img "system"
}

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

function boot_append_cmdline() {
	# Update the kernel cmdline, so the initrd is able to detect the system partition
	OLDCMDLINE="$(abootimg -i $IMAGE_DIR/boot.img | grep cmdline | sed -e 's/^.*cmdline = //') "
	echo $OLDCMDLINE | grep -q "empty cmdline" && OLDCMDLINE=""
	NEWCMDLINE="${OLDCMDLINE}${1}"

	abootimg -u $IMAGE_DIR/boot.img -c "cmdline=$NEWCMDLINE"
}

# Actual start of script
echo "I: Writing rootfs into image"
convert_rootfs 2G
label_rootfs
echo "I: Writing android adaptions into image"
convert_androidimage
echo "I: Shrinking android image"
shrink_images
# Merge images into one
echo "I: Moving android image into rootfs"
sudo mv "$IMAGE_DIR/system.img" "$(sudo readlink -f $ROOTFS_DIR/var/lib/lxc/android/)"
echo "I: Running post-install tasks"
post_install $DISTRIBUTION
echo "I: including new initrd"
boot_inject_initrd
boot_append_cmdline "root=LABEL=system"
clean
echo "I: Creating fastboot image from rootfs image"
make_flashable
