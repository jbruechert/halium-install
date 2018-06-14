#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	image_size=$1

	qemu-img create -f raw $IMAGE_DIR/rootfs.img $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F $IMAGE_DIR/rootfs.img
	sudo mount $IMAGE_DIR/rootfs.img $ROOTFS_DIR
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_androidimage() {
	if file $AND_IMAGE | grep "ext4 filesystem"; then
		cp system.img $IMAGE_DIR
	else
		simg2img $AND_IMAGE $IMAGE_DIR/system.img
	fi
}

function shrink_images() {
	[ -f $IMAGE_DIR/system.img ] && sudo e2fsck -fy $IMAGE_DIR/system.img >/dev/null
	[ -f $IMAGE_DIR/system.img ] && sudo resize2fs -p -M $IMAGE_DIR/system.img
}

function unmount() {
	sudo umount $ROOTFS_DIR
}

function flash_adb() {
	adb push $IMAGE_DIR/rootfs.img /data/
	adb push $IMAGE_DIR/system.img /data/
}

function flash_rsync() {
	TARGET_ARCH="arm"
	# TODO Make $(adb shell uname -m) work

	# Download prebuilt rsync
	echo "[install] Installing rsync on the device ..."
	! [ -f $IMAGE_DIR/rsync.bin ] && wget -O $IMAGE_DIR/rsync.bin --continue -q "https://github.com/JBBgameich/rsync-static/releases/download/continuous/rsync-$TARGET_ARCH"
	! [ -f $IMAGE_DIR/rsyncd.conf ] && wget -O $IMAGE_DIR/rsyncd.conf --continue -q "https://raw.githubusercontent.com/JBBgameich/rsync-static/master/rsyncd.conf"

	# Push rsync
	adb push $IMAGE_DIR/rsync.bin /data/rsync >/dev/null
	adb push $IMAGE_DIR/rsyncd.conf /data/rsyncd.conf >/dev/null
	adb shell chmod +x /data/rsync

	# Start rsync daemon on the device
	adb shell '/data/rsync --daemon --config=/data/rsyncd.conf &'
	adb forward tcp:6010 tcp:1873

	echo "[install] Transferring files ..."
	rsync -avz --progress $IMAGE_DIR/rootfs.img rsync://localhost:6010/root/data/rootfs.img
	rsync -avz --progress $IMAGE_DIR/system.img rsync://localhost:6010/root/data/system.img

	# Kill running rsync instances
	adb shell killall rsync
}

function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR $IMAGE_DIR -rf
}

function clean_device() {
	# Make sure the device is in a clean state
	adb shell sync
}
