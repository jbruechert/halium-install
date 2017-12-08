## Alternative Halium installer script

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0c6adc1dd44644b6b688f8fb048434d6)](https://www.codacy.com/app/JBBgameich/halium-install?utm_source=github.com&utm_medium=referral&utm_content=JBBgameich/halium-install&utm_campaign=badger)

The difference to the official script from the halium-scripts repository is that this script will prepare the rootfs on your host system instead of on the device. This will make you independent of problems like old TWRP images, no busybox or not-working busyboxes on some devices.

### Dependencies

* qemu-user-static
* qemu-system-arm
* e2fsprogs
* simg2img

### Usage:
```
./halium-install <rootfs.tar.gz> <system.img> <mode (halium, pm, none)>
```

### Compiling
If you want to use this shell script independently of this folder, create a standalone binary of it by executing `./utils/standalone.sh`. You will find the executable in bin/halium-install.
