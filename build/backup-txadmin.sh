#!/bin/bash
if [ -z "$BUILD" ] ;
then
	APPMAIN="CACHE_TXADMIN" # DONUT TOUCH!

	if [ ! "$BUILD" ] ;
	then
		THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))" ;
		[[ ! "$_BUILD" ]] && [[ -d "$THIS_SCRIPT_ROOT/build" ]] && _BUILD="$THIS_SCRIPT_ROOT/build"
		[[ ! "$_BUILD" ]] && [[ -d "$(dirname $THIS_SCRIPT_ROOT)/build" ]] && _BUILD="$(dirname $THIS_SCRIPT_ROOT)/build"
		[[ ! "$_BUILD" ]] && [[ -d "$THIS_SCRIPT_ROOT" ]] && _BUILD="$THIS_SCRIPT_ROOT"
		unset THIS_SCRIPT_ROOT ;
	fi

	if [ -d "$_BUILD" ] && [ -f "$_BUILD/build-env.sh" ] ; then
		BUILD="$_BUILD"
		unset _BUILD ;
		. "$BUILD/build-env.sh" RUNTIME
	else
		echo "build folder not found by $APPMAIN.  FAILED!"
		exit 1
	fi
fi

if [ -z "$SERVICE_ACCOUNT" ] ; 
then
        echo "SERVICE_ACCOUNT not defined. FAILED."
		exit 1
fi # just catch in case we dumb!


if [ -z $MAIN ]; then
        MAIN="/home/${SERVICE_ACCOUNT}"
fi

echo ""
echo "Backing up the txAdmin settings..."
echo "cp -RfT \"${MAIN}/txAdmin/data\" \"${TXADMIN_BACKUP}\""
cp -RfT "${MAIN}/txAdmin/data" "${TXADMIN_BACKUP}"
echo "Done."
echo ""

