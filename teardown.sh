#!/bin/bash
THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
[[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build" 
[[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
[[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
unset THIS_SCRIPT_ROOT

[[ ! "$BUILD" ]] && echo "Build folder not found. Failed!" && exit 1

. "$BUILD/build-env.sh" RUNTIME

if [ -z "$SERVICE_ACCOUNT" ]; then
	SERVICE_ACCOUNT="fivem"
fi
su "$SERVICE_ACCOUNT" -c "screen -XS 'fivem' quit"
deluser "$SERVICE_ACCOUNT"
if [ -d "/home/$SERVICE_ACCOUNT" ]; then
	rm -rf /home/"${SERVICE_ACCOUNT:?}"
fi
rm -rf /var/software
mysql -e "DROP DATABASE essentialmode;"
