## Alternative Halium installer script

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0c6adc1dd44644b6b688f8fb048434d6)](https://www.codacy.com/app/JBBgameich/halium-install?utm_source=github.com&utm_medium=referral&utm_content=JBBgameich/halium-install&utm_campaign=badger)
[![Build Status](https://travis-ci.org/JBBgameich/halium-install.svg?branch=appimage)](https://travis-ci.org/JBBgameich/halium-install)

The difference to the official script from the halium-scripts repository is that this script will prepare the rootfs on your host system instead of on the device. This will make you independent of problems like old TWRP images, no busybox or not-working busyboxes on some devices.

A prebuilt standalone version and AppImage is available [here](https://github.com/JBBgameich/halium-install/releases). Alternatively you can just clone this repository and directly use the script.

### Dependencies

* qemu-user-static
* qemu-system-arm
* e2fsprogs
* simg2img

### Usage:

If you installed from a package, you will have the halium-tool command. The source file for it is called launcher.sh. If you don't want to install this, swap out halium-tool with launcher.sh in the following commands.

Download TWRP:
`halium-tool twrp $device`

Install a halium rootfs and systemimage:
`halium-tool install <rootfs.tar.gz> <system.img> <mode (halium, pm, none)>`

Connect to the device:
`halium-tool connect -p $protocol -u $username`

### Standalone version
If you want to use this shell script independently of this folder, create a standalone script of it by executing `bash utils/standalone.sh`. You will find the executable in bin/halium-install-standalone.sh.

You can also generate an AppImage with most dependencies included (experimental) by running `bash utils/appimage.sh`.
