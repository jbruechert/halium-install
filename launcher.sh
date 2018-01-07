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
    connect)
    $DATA_PATH/connect.py ${args[@]:1}
    ;;
    *)
    echo "Supported subcommands are: install, twrp, connect"
    echo "Each subcommand has it's own extra arguments and help page"
    ;;
esac
