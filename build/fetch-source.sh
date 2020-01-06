#!/bin/bash
if [ -z "$__RUNTIME__" ] ;
then
	if [ ! "$BUILD" ] ;
	then
	  THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
	  [[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build"
	  [[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
	  [[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
	  unset THIS_SCRIPT_ROOT

	  [[ -z "$BUILD" ]] && echo "Build folder not found.  cache-txadmin.sh has failed you!" && exit 1
	  . "$BUILD/build-env.sh" RUNTIME

	  [[ -z "$SOURCE" ]] || [[ "$SOURCE" == "null" ]] && echo "Build folder not found. FAILED!" && exit 1
	fi
fi

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

    ## ---- Deploy Server Source ---- ##

        cd "$SOURCE_ROOT"
        git clone --recurse-submodules git@github.com:BeyondEarthRP/BERP-Repo.git "$SOURCE"

    ## ---- Deploy Server Source ---- ##

else
    echo "This script must be executed by the deployment script"
fi

