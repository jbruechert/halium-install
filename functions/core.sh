#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs_to_img() {
	image_size=$1

	qemu-img create -f raw "$IMAGE_DIR/rootfs.img" $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F "$IMAGE_DIR/rootfs.img"
	sudo mount "$IMAGE_DIR/rootfs.img" "$ROOTFS_DIR"
	sudo tar --numeric-owner -xpf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
}

function convert_rootfs_to_dir() {
	sudo tar --numeric-owner -xpf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
}

function convert_androidimage() {
	if file "$AND_IMAGE" | grep "ext[2-4] filesystem"; then
		cp "$AND_IMAGE" "$IMAGE_DIR/system.img"
	else
		simg2img "$AND_IMAGE" "$IMAGE_DIR/system.img"
	fi
}

function shrink_images() {
	[ -f "$IMAGE_DIR/system.img" ] && sudo e2fsck -fy "$IMAGE_DIR/system.img" >/dev/null || true
	[ -f "$IMAGE_DIR/system.img" ] && sudo resize2fs -p -M "$IMAGE_DIR/system.img"
}

function inject_androidimage() {
	# Move android image into rootfs location (https://github.com/Halium/initramfs-tools-halium/blob/halium/scripts/halium#L259)
	sudo mv "$IMAGE_DIR/system.img" "$ROOTFS_DIR/var/lib/lxc/android/"

	# Make sure the mount path is correct
	if chroot_run "command -v dpkg-divert"; then # On debian distros, use dpkg-divert
		chroot_run "dpkg-divert --add --rename --divert /lib/systemd/system/system.mount.image /lib/systemd/system/system.mount"
		sed 's,/data/system.img,/var/lib/lxc/android/system.img,g' "$ROOTFS_DIR/lib/systemd/system/system.mount.image" | sudo tee -a "$ROOTFS_DIR/lib/systemd/system/system.mount" >/dev/null 2>&1
	else # Else just replace the path directly (not upgrade safe)
		sed -i 's,/data/system.img,/var/lib/lxc/android/system.img,g' "$ROOTFS_DIR/lib/systemd/system/system.mount.image"
	fi
}

function unmount() {
	sudo umount "$ROOTFS_DIR"
}

function flash_img() {
	if $DO_ZIP ; then
		echo "I:    Compressing rootfs on host"
		pigz --fast "$IMAGE_DIR/rootfs.img"
		echo "I:    Pushing rootfs to /data via ADB"
		adb push "$IMAGE_DIR/rootfs.img.gz" /data/
		echo "I:    Decompressing rootfs on device"
		adb shell "gunzip -f /data/rootfs.img.gz"

		echo "I:    Compressing android image on host"
		pigz --fast "$IMAGE_DIR/system.img"
		echo "I:    Pushing android image to /data via ADB"
		adb push "$IMAGE_DIR/system.img.gz" /data/
		echo "I:    Decompressing android image on device"
		adb shell "gunzip -f /data/system.img.gz"
	else
		echo "I:    Pushing rootfs to /data via ADB"
		adb push "$IMAGE_DIR/rootfs.img" /data/
		echo "I:    Pushing android image to /data via ADB"
		adb push "$IMAGE_DIR/system.img" /data/
	fi

	if $SYSTEM_AS_ROOT; then
		echo "I:    Renaming to system-as-root compatible system image"
		adb shell "mv /data/system.img /data/android-rootfs.img"
	fi
}

function flash_dir() {
	adb push "$ROOTFS_DIR"/* /data/halium-rootfs/
}

function clean() {
	sudo rm "$ROOTFS_DIR" "$IMAGE_DIR" -rf
}

function clean_device() {
	# Make sure the device is in a clean state
	adb shell sync
}

function clean_exit() {
	echo "I: Cleaning up"
	unmount || true
	clean || true
	clean_device || true
}
