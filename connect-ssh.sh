#!/bin/bash

export RNDIS_DEVICE=$(sudo dmesg | grep rndis | grep -oh "\w*enp0\w*" | tail -n 1)
echo "* The device seems to be connected as $RNDIS_DEVICE"

sudo ip address add 10.15.19.100 dev $RNDIS_DEVICE
sudo ip route add 10.15.19.82 dev $RNDIS_DEVICE

echo "* Connecting using ssh"
ssh root@10.15.19.82
