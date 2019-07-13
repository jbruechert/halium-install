#!/usr/bin/env python3

import requests
import subprocess
import sys
from bs4 import BeautifulSoup

device = sys.argv[1]

dlpagerequest = requests.get("https://eu.dl.twrp.me/" + device)

dlpage = BeautifulSoup(dlpagerequest.content, 'html.parser')

try:
	dllinks = dlpage.table.find_all("a")
except:
	print("E: Couldn't find a TWRP image for " + device)
	sys.exit(1)

dlurl = "https://eu.dl.twrp.me" + dllinks[0]["href"].replace(".html", "")

imgname = dlurl.split("/")[-1]

print("I: Downloading " + dlurl)
subprocess.call(["curl", "--progress-bar", "--referer", dlurl + ".html", dlurl, "-o", imgname])

print("I: verifying checksum ...")
validmd5sum = requests.get(dlurl + ".md5").content.decode()
localmd5sum = subprocess.check_output(["md5sum", imgname]).decode().rstrip()

if localmd5sum == validmd5sum:
    print("I: Checksum matches")
else:
    print("I: Download failed, file is corrupted")
    sys.exit(1)
