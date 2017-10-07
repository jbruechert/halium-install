## Alternative Halium installer script

The difference to the official script from the halium-scripts repository is that this script will prepare the rootfs on your host system instead of on the device. This will make you independent of problems like old TWRP images, no busybox or not-working busyboxes on some devices.

### Dependencies

* qemu-user-static
* qemu-system-arm
* e2fsprogs
* simg2img

### Usage:
```
./halium-install <rootfs.tar.gz> <system.img>
```
