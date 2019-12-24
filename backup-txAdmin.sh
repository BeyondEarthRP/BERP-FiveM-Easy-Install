#!/bin/bash
if [ -z $srvAcct ]; then
	# account used for fivem
	srvAcct="fivem"
fi
if [ -z $SOURCE_ROOT ]; then
	SOURCE_ROOT=$(cd ~ && pwd)
fi
if [ -z $MAIN ]; then
	MAIN="/home/${srvAcct}"
fi
echo ""
echo "Backing up the txAdmin settings..."
echo "cp -RfT \"${MAIN}/txAdmin/data\" \"${SOURCE_ROOT}/txAdmin_data\""
cp -RfT "${MAIN}/txAdmin/data" "${SOURCE_ROOT}/txAdmin_data"
echo "Done."
echo ""