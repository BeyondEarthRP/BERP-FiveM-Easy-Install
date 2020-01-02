#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

    [[ -z "$__RUNTIME__" ]] \
      && printf "\nRuntime not loaded. This script requires Belch Runtime.\n$0...failed.\n\n" \
      && exit 1

    VMENU_ROOT="$SOURCE/vMenu"
    VMENU_FILE="$VMENU_ROOT/vmenu-version.sh"
    VMENU_PKG="vMenu-${VMENU_FILE}.zip"
    VMENU="$VMENU_ROOT/$VMENU_PKG"

    if [ -f "$VMENU" ]; then
        if [ -d "$RESOURCES/vMenu" ]; then
            rm -rf "$RESOURCES/vMenu"
        fi
        if [ -f "$GAME/permissions.cfg" ]; then
            rm -f "$GAME/permissions.cfg"
        fi
        unzip "$VMENU" -d "$RESOURCES/vMenu"
        cp -rfup "$VMENU_ROOT/vmenu-permissions.cfg" "$GAME/permissions.cfg"
    else
        echo "ERROR: Could not find the vmenu package."
    fi
else
    echo "This script must be executed by the deployment script"
fi


