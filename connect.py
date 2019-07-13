#!/usr/bin/env python3
import re
import subprocess
import sys
import argparse

def get_rndis_device():
    rndis_device = subprocess.check_output("sudo dmesg | grep rndis | grep -oh '\w*enp0\w*' | tail -n 1 | tr -d '\n'", shell=True).decode()

    if not rndis_device == "":
        print("* The device seems to be connected as " + rndis_device)
        return rndis_device
    else:
        print("Is the device connected?")
        sys.exit(1)

def connect_ssh(rndis_device):
    ssh_local_ip = "10.15.19.100"
    ssh_ip = "10.15.19.82"

    subprocess.call(["sudo", "ip", "address", "add", ssh_local_ip, "dev", rndis_device])
    subprocess.call(["sudo", "ip", "route", "add", ssh_ip, "dev", rndis_device])

    print("* Connecting using ssh")
    subprocess.call(["ssh", args.username + "@" + ssh_ip])

def connect_telnet(rndis_device):
    telnet_local_ip = "192.168.2.1"
    telnet_ip = "192.168.2.15"

    subprocess.call(["sudo", "ip", "address", "add", telnet_local_ip, "dev", rndis_device])
    subprocess.call(["sudo", "ip", "route", "add", telnet_ip, "dev", rndis_device])

    print("* Connecting using telnet")
    subprocess.call(["telnet", telnet_ip])


parser = argparse.ArgumentParser(description="Connect to Halium powered devices")
parser.add_argument("-p", "--protocol", help="Protocol to use for connecting to the device")
parser.add_argument("-u", "--username", help="Username to use. Usually root or phablet")

args = parser.parse_args()

if not args.protocol:
    print("You need to supply a protocol to use")
    sys.exit(1)
elif not args.username:
    print("You did not supply a username to use")
    sys.exit(1)
elif args.protocol == "ssh":
    connect_ssh(get_rndis_device())
elif args.protocol == "telnet":
    connect_telnet(get_rndis_device())
