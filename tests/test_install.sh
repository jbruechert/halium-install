#!/usr/bin/env bash

TEST_LOCATION="$(dirname "$(readlink -f "$0")")"
PATH="${TEST_LOCATION}/../:${PATH}"

TMP_PATH="${TEST_LOCATION}/tmp"
ROOTFS_PATH="${TMP_PATH}/rootfs.tar.gz"
ANDROID_IMG_PATH="${TMP_PATH}/system.img"

# Passed to halium-install
export ROOTFS_DIR="${TMP_PATH}/rootfs"
export IMAGE_DIR="${TMP_PATH}/images"


if [ ! -d "${TMP_PATH}" ]; then
	mkdir "${TMP_PATH}" -p
fi

if [ ! -f "${ROOTFS_PATH}" ]; then
	wget --continue \
		https://archive.kaidan.im/debian-pm/images/halium/minimal/debian-halium-minimal-testing-armhf.tar.gz \
		-O "${ROOTFS_PATH}"
fi

if [ ! -f "${ANDROID_IMG_PATH}" ]; then
	wget --continue \
		https://archive.kaidan.im/halium/hammerhead/system.img \
		-O "${ANDROID_IMG_PATH}"
fi

# Clean up to make test_images_exist and test_dir_exists useful
if [ -d ${ROOTFS_DIR} ]; then
	sudo chown $(whoami) -R ${ROOTFS_DIR}
	rm ${ROOTFS_DIR} -rf
	mkdir -p ${ROOTFS_DIR}
else
	mkdir -p ${ROOTFS_DIR}
fi

if [ -d ${IMAGE_DIR} ]; then
	rm ${IMAGE_DIR} -r
        mkdir -p ${IMAGE_DIR}
else
	mkdir -p ${IMAGE_DIR}
fi


function run_test() {
	echo -n "Running $1... "
	if $1; then
		echo "[PASS]"
	else
		echo "[FAIL]"
	fi
}

# Generic
function test_executable() {
	[ -x "${TEST_LOCATION}/../halium-install" ]
}

function test_syntax() {
	bash -n "${TEST_LOCATION}/../halium-install"
}

# Image mode
function test_img_exit_success() {
	halium-install --mode img --test-mode -v -p debian-pm -u 1234 -r 1234 "${ROOTFS_PATH}" "${ANDROID_IMG_PATH}" > "${TMP_PATH}/log" 2>&1
}

function test_mount() {
	sudo mount "${IMAGE_DIR}/rootfs.img" "${ROOTFS_DIR}"

	[ -f "${ROOTFS_DIR}/bin/sh" ]
}

function test_root_passwd() {
	! sudo grep "root:\*:17904:0:99999:7:::" "${ROOTFS_DIR}/etc/shadow" >/dev/null 2>&1
}

function test_images_exist() {
	[ -f "${IMAGE_DIR}/rootfs.img" ] && [ -f "${IMAGE_DIR}/system.img" ]
}

function test_ssh_hostkey_changed() {
	tar -C "${TMP_PATH}" -xf "${ROOTFS_PATH}" ./etc/dropbear/dropbear_rsa_host_key
	orig_sum=($(sha256sum "${TMP_PATH}/etc/dropbear/dropbear_rsa_host_key"))
	new_sum=($(sudo sha256sum "${ROOTFS_DIR}/etc/dropbear/dropbear_rsa_host_key"))

	[ ${orig_sum[0]} != ${new_sum[0]} ]
}

function test_qemu_not_left() {
	[ ! -d "${ROOTFS_DIR}/usr/bin/qemu-arm-static" ]
}

function test_umount() {
        sudo umount -l "${IMAGE_DIR}/rootfs.img"
}

# Dir mode
function test_dir_exit_success() {
	halium-install --test-mode -v --mode dir -p debian-pm -u 1234 -r 1234 "${ROOTFS_PATH}" "${ANDROID_IMG_PATH}" > "${TMP_PATH}/log" 2>&1
}

function test_dir_files_exist() {
	[ -d "${ROOTFS_DIR}" ] && [ -f "${ROOTFS_DIR}/var/lib/lxc/android/system.img" ]
}

function test_dir_correct_image_path() {
	! grep "/data/system.img" "$ROOTFS_DIR/lib/systemd/system/system.mount"
}

echo "# Generic tests"
run_test test_executable
run_test test_syntax

echo "# Image mode tests"
run_test test_img_exit_success
run_test test_images_exist
run_test test_mount
run_test test_root_passwd
run_test test_ssh_hostkey_changed
run_test test_qemu_not_left
run_test test_umount

echo "# Dir mode tests"
run_test test_dir_exit_success
run_test test_dir_files_exist
run_test test_dir_correct_image_path

trap test_umount EXIT
