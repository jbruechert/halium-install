#!/usr/bin/make

TARGET = $(DESTDIR)/usr

install:
	mkdir -p $(TARGET)/bin/
	mkdir -p $(TARGET)/share/halium-scripts/

	cp launcher.sh $(TARGET)/bin/halium-tool

	bash utils/standalone.sh
	cp bin/halium-install-standalone.sh $(TARGET)/share/halium-scripts/halium-install
	cp connect.py $(TARGET)/share/halium-scripts/connect.py
	cp download-twrp.py $(TARGET)/share/halium-scripts/download-twrp.py

appimage:
	bash utils/appimage.sh

clean:
	if [ -d bin ];then rm bin -r; fi
