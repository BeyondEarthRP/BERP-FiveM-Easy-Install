#!/bin/bash
THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
[[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] \
&& BUILD="$THIS_SCRIPT_ROOT" ||  BUILD="$(dirname $THIS_SCRIPT_ROOT)"

. "$BUILD/build-env" RUNTIME

if [ -z "$SERVICE_ACCOUNT" ]; then
	srvAcct="fivem"
fi
su "$SERVICE_ACCOUNT" -c "screen -XS 'fivem' quit"
deluser "$SERVICE_ACCOUNT"
if [ -d "/home/$SERVICE_ACCOUNT" ]; then
	rm -rf /home/"$SERVICE_ACCOUNT"
fi
rm -rf /var/software
mysql -e "DROP DATABASE essentialmode;"
