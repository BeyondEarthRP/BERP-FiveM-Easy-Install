#!/bin/bash
if [ -z $srvAcct ]; then
        # account used for fivem
        srvAcct="fivem"
fi
if [ -z $SCRIPT_ROOT ]; then
        SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
if [ -z $MAIN ]; then
        MAIN="/home/${srvAcct}"
fi
echo ""
echo "Backing up the txAdmin settings..."
echo "cp -RfT \"${MAIN}/txAdmin/data\" \"${SCRIPT_ROOT}/txAdmin_data\""
cp -RfT "${MAIN}/txAdmin/data" "${SCRIPT_ROOT}/txAdmin_data"
echo "Done."
echo ""

