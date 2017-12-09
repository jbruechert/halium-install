#!/bin/bash

# Download appimagetool
if ! [ -f appimagetool-x86_64.AppImage ]; then
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod a+x appimagetool-x86_64.AppImage
fi

# Move binary into target
if ! [ -d bin/AppDir ]; then
    mkdir -p bin/AppDir/usr/bin/ bin/AppDir/usr/share/applications/ bin/AppDir/usr/share/icons/hicolor/scalable/apps
fi

cp bin/halium-install-standalone.sh bin/AppDir/usr/bin/halium-install
cp utils/halium-install.desktop bin/AppDir
cp utils/halium-install.desktop bin/AppDir/usr/share/applications/

wget -O bin/AppDir/halium-install.svg https://raw.githubusercontent.com/JBBgameich/halium-artwork/master/logo.svg

# AppRun
ln bin/AppDir/usr/bin/halium-install bin/AppDir/AppRun

# Download dependencies
if ! [ -d cache ]; then
    mkdir -p cache
fi

cd cache
apt download bash qemu-utils qemu-user-static qemu-system-arm android-tools-fsutils adb sudo e2fsprogs binfmt-support android-libadb

for deb in *.deb;
    do dpkg-deb -x $deb ../bin/AppDir
done

cd ../bin
./../appimagetool-x86_64.AppImage --exclude-file ../utils/appimage-exclude.txt AppDir
