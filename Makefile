all:
	if ! [ -d bin ]; then mkdir bin; fi
	cp halium-install bin/halium-install-standalone.sh
	
	# Insert included files directly to make the script work standalone
	sed -i '/.*misc.sh/ r functions/misc.sh' bin/halium-install-standalone.sh
	sed -i '/.*post-inst.sh/ r functions/post-inst.sh' bin/halium-install-standalone.sh
	sed -i '/.*core.sh/ r functions/core.sh' bin/halium-install-standalone.sh
	
	sed -i 's/.*misc.sh//g' bin/halium-install-standalone.sh
	sed -i 's/.*post-inst.sh//g' bin/halium-install-standalone.sh
	sed -i 's/.*core.sh//g' bin/halium-install-standalone.sh
	
	# Compile
	shc -f bin/halium-install-standalone.sh -o bin/halium-install
	rm bin/halium-install-standalone.sh.x.c

appimage:
	# Download appimagetool
	if ! [ -f appimagetool-x86_64.AppImage ]; then wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"; chmod a+x appimagetool-x86_64.AppImage; fi

	# Move binary into target
	if ! [ -d bin/AppDir ]; then mkdir -p bin/AppDir/usr/bin/ bin/AppDir/usr/share/applications/ bin/AppDir/usr/share/icons/hicolor/scalable/apps; fi
	cp bin/halium-install bin/AppDir/usr/bin/halium-install
	cp halium-install.desktop bin/AppDir
	cp halium-install.desktop bin/AppDir/usr/share/applications/
	wget -O bin/AppDir/usr/share/icons/hicolor/scalable/apps/halium-install.svg https://raw.githubusercontent.com/JBBgameich/halium-artwork/master/logo.svg

	# Download dependencies
	if ! [ -d cache ]; then mkdir -p cache; fi
	cd cache; apt download bash qemu-utils qemu-user-static qemu-system-arm android-tools-fsutils adb sudo e2fsprogs
	cd cache; for deb in *.deb; do dpkg-deb -x $$deb ../bin/AppDir; done
	cd bin; ./../appimagetool-x86_64.AppImage AppDir

clean:
	rm bin cache -r
