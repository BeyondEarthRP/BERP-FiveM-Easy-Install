#!/bin/bash
if [ ! "$BUILD" ] ;
then
  THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
  [[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build"
  [[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
  [[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
  unset THIS_SCRIPT_ROOT

  [[ ! "$BUILD" ]] && echo "Build folder not found.  cache-txadmin.sh has failed you!" && exit 1
  . "$BUILD/build-env.sh" RUNTIME

  [[ ! "$MAIN" ]] && echo "Main folder not found.  cache-txadmin.sh has failed you!" && exit 1
  [[ ! "$PRIVATE" ]] && echo "Privly folder not found.  cache-txadmin.sh has failed you!" && exit 1
fi


if [ -z $SERVICE_ACCOUNT ]; then
        # Hey, I'm tryin here!! this is the account used for fivem
        SERVICE_ACCOUNT="fivem"  # Probably shouln't be happening (but okay)
fi # just a catch all in case we dumb!
if [ -z $MAIN ]; then
        MAIN="/home/${SERVICE_ACCOUNT}"
fi
echo ""
echo "Backing up the txAdmin settings..."
echo "cp -RfT \"${MAIN}/txAdmin/data\" \"${PRIVATE}/txAdmin_data\""
cp -RfT "${MAIN}/txAdmin/data" "${SCRIPT_ROOT}/txAdmin_data"
echo "Done."
echo ""

