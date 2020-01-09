#!/bin/bash
_YAPP="SHORT_DESCRIPTIVE"  #<---- SHORT NAME FOR YOUR APP... JUST DON'T USE MAIN OR APPMAIN (OR ANY THAT I AM USING HAHAHA)
if [ -z "$__RUNTIME__" ] ;      # I USUALLY MAKE THEM THE NAMES OF MY SCRIPTS, UNDERSCORING... FOR INSTANCE BUILD_CONFIG IS ONE.
then				# IT IS ONLY FOR CHANGING EXECUTION ORDER IN THE RUNTIME, SO JUST PUT SOMETHING/ANYTHING UNQUIE.
        if [ -z "$_BUILD" ] ;
        then
          THIS_SCRIPT_ROOT=$(dirname $(readlink -f "$0")) ;
          BUILDCHECK=()
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../../build") ) || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../build") )    || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/build") )       || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}") )             || true
          unset THIS_SCRIPT_ROOT ;
          for cf in "${BUILDCHECK[@]}" ;
          do
            if [ -d "$cf" ] && [ -f "${cf:?}/build-env.sh" ] ;
            then
                _BUILD="$cf"
            fi
          done
        fi
        [[ -z "$_BUILD" ]] && echo "Build folder undefined. Failed." && exit 1
        #-----------------------------------------------------------------------------------------------------------------------------------
        if [ -z "$APPMAIN" ] ;
        then
          APPMAIN="${_YAPP:?}"
          . "$_BUILD/build-env.sh" EXECUTE
        elif [ -z "$__RUNTIME__" ] ;
        then
                echo "Runtime not loaded... I'VE FAILED!"
                exit 1
        fi
        [[ -z "${SOURCE:?}" ]] &&  echo "Source undefined... " && exit 1

        [[ -n "$__INVALID_CONFIG__" ]] && echo "You'll need to run the quick configure before this will work..." && exit 1
fi
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

    ## ---- All code goes below ---- ##



    ## ---- Done with the code? ---- ##

else
    echo "This script must be executed by the deployment script"
fi

