#!/usr/bin/make

TARGET = $(DESTDIR)/usr

install:
	mkdir -p $(TARGET)/bin/
	mkdir -p $(TARGET)/share/halium-scripts/

	cp launcher.sh $(TARGET)/bin/halium-tool

	bash utils/standalone.sh
	cp bin/halium-install-standalone.sh $(TARGET)/share/halium-scripts/halium-install
	cp connect-ssh.sh $(TARGET)/share/halium-scripts/connect-ssh.sh
	cp connect-telnet.sh $(TARGET)/share/halium-scripts/connect-telnet.sh
	cp download-twrp.py $(TARGET)/share/halium-scripts/download-twrp.py

appimage:
	bash utils/appimage.sh

clean:
	if [ -d bin ];then rm bin -r; fi
