#!/bin/bash

# Generate standalone file
bash utils/standalone.sh

# Download appimagetool
if ! [ -f appimagetool-x86_64.AppImage ]; then
    echo "I: Downloading appimagetool-x86_64.AppImage ..."
    wget --quiet "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod a+x appimagetool-x86_64.AppImage
fi

echo "I: Copying scripts into AppDir ..."
# Create AppImage folder structure
if ! [ -d bin/AppDir ]; then
    mkdir -p bin/AppDir/usr/bin/ bin/AppDir/usr/share/applications/ bin/AppDir/usr/share/icons/hicolor/scalable/apps
fi

# Copy scripts
cp bin/halium-install-standalone.sh bin/AppDir/usr/bin/halium-install
cp connect.py bin/AppDir/usr/bin/connect.py
cp download-twrp.py bin/AppDir/usr/bin/download-twrp.py

# Copy desktop file
cp utils/halium-tool.desktop bin/AppDir/usr/share/applications/
ln bin/AppDir/usr/share/applications/halium-tool.desktop bin/AppDir/halium-tool.desktop

# Copy icon
wget --quiet -O bin/AppDir/halium.svg https://raw.githubusercontent.com/JBBgameich/halium-artwork/master/logo.svg

# AppRun
cp launcher.sh bin/AppDir/AppRun

# Download dependencies
if ! [ -d cache ]; then
    mkdir -p cache
fi

cd cache
echo "I: Downloading dependencies ..."
apt -q=2 download bash qemu-utils python3 python-beautifulsoup curl qemu-user-static qemu-system-arm android-tools-fsutils adb sudo e2fsprogs binfmt-support android-libadb

echo "I: Unpacking dependencies"
for deb in *.deb;
    do dpkg-deb -x $deb ../bin/AppDir
done

echo "I: Creating AppImage"
cd ../bin
./../appimagetool-x86_64.AppImage --exclude-file ../utils/appimage-exclude.txt AppDir
