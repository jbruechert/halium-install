## Alternative Halium installer script

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0c6adc1dd44644b6b688f8fb048434d6)](https://www.codacy.com/app/JBBgameich/halium-install?utm_source=github.com&utm_medium=referral&utm_content=JBBgameich/halium-install&utm_campaign=badger)
[![Build Status](https://travis-ci.org/JBBgameich/halium-install.svg?branch=appimage)](https://travis-ci.org/JBBgameich/halium-install)

The difference to the official script from the halium-scripts repository is that this script will prepare the rootfs on your host system instead of on the device. This will make you independent of problems like old TWRP images, no busybox or not-working busyboxes on some devices.

A prebuilt standalone version available [here](https://github.com/JBBgameich/halium-install/releases). Alternatively you can just clone this repository and directly use the script.

### Dependencies

* qemu-user-static
* qemu-system-arm
* e2fsprogs
* simg2img

### Usage:

Download TWRP:
`./download-twrp.py $device`

Install a halium rootfs and systemimage:
`halium-install -p <mode (reference, neon, ut, debian-pm, debian-pm-caf, none)> <rootfs.tar.gz> <system.img>`

Connect to the device:
`./connect.py -p $protocol -u $username`

### Standalone version
If you want to use this shell script independently of this folder, create a standalone script of it by executing `bash utils/standalone.sh`. You will find the executable in bin/halium-install-standalone.sh.
