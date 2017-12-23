#!/usr/bin/python3

import requests
import subprocess
import sys
from bs4 import BeautifulSoup

device = sys.argv[1]

dlpagerequest = requests.get("https://eu.dl.twrp.me/" + device)

dlpage = BeautifulSoup(dlpagerequest.content, 'html.parser')

dllinks = dlpage.table.find_all("a")

dlurl = "https://eu.dl.twrp.me" + dllinks[0]["href"].replace(".html", "")

imgname = dlurl.split("/")[-1]

subprocess.call(["curl", "--referer", dlurl + ".html", dlurl, "-o", imgname])
