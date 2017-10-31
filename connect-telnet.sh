#/bin/bash

export RNDIS_DEVICE=$(sudo dmesg | grep rndis | grep -oh "\w*enp0\w*" | tail -n 1)
echo "* The device seems to be connected as $RNDIS_DEVICE"

sudo ip address add 192.168.2.1 dev $RNDIS_DEVICE
sudo ip route add 192.168.2.15 dev $RNDIS_DEVICE

echo "* Connecting using telnet"
telnet 192.168.2.15
