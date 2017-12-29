#!/bin/bash

args=($@)

# Find our stuff
if [ -f /usr/share/halium-scripts/halium-install ]; then
    export DATA_PATH="/usr/share/halium-scripts/"
elif [ -f /usr/local/share/halium-scripts/halium-install ]; then
    export DATA_PATH="/usr/local/share/halium-scripts/"
else
    export DATA_PATH="./"
fi

case ${args[0]} in
    install)
    $DATA_PATH/halium-install ${args[@]:1}
    ;;
    twrp)
    $DATA_PATH/download-twrp.py ${args[@]:1}
    ;;
    ssh)
    $DATA_PATH/connect-ssh.sh
    ;;
    telnet)
    $DATA_PATH/connect-telnet.sh
    ;;
    *)
    echo "Supported subcommands are: install, twrp, ssh, telnet"
    ;;
esac
