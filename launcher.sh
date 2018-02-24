#!/bin/bash

args=($@)

# Check if we are running in an AppImage
if readlink -f "${0}" | grep "AppRun" >/dev/null; then
    APPIMAGE_ROOT=$(dirname "$(readlink -f "${0}")")
fi

# Find our stuff
if [ -f $APPIMAGE_ROOT/usr/share/halium-scripts/halium-install ]; then
    export DATA_PATH="$APPIMAGE_ROOT/usr/share/halium-scripts/"
elif [ -f /usr/share/halium-scripts/halium-install ]; then
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
