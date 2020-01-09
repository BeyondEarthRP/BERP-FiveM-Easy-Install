#!/bin/bash
if [ -z "$__RUNTIME__" ] ;
then
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
          APPMAIN="BUILD_DEPENDENCIES"
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
    [[ -z "$DB_ROOT_PASSWORD" ]] \
        && echo "Root password not yet entered.  This should have already been done. Failed!" \
        && exit 1

    [[ -z "$SOFTWARE_ROOT" ]] && echo "software folder location not defined." && exit 1
    [[ -z "$TFIVEM" ]] && echo "tfivem folder location not defined." && exit 1
    [[ -z "$TCCORE" ]] && echo "tccore folder location not defined." && exit 1

    # TEMP DIRECTORIES
    [[ ! -d "$SOFTWARE_ROOT" ]] && mkdir "$SOFTWARE_ROOT"
    [[ ! -d "$TFIVEM" ]] && mkdir "$TFIVEM"
    [[ ! -d "$TCCORE" ]] && mkdir "$TCCORE"

    # Dependancies
    ########################
    echo "Linux Software & Configuration"
	echo "--> Fetch Updates"
	sudo apt update && sudo apt -y upgrade
	echo ""

	echo "--> INSTALLING: unzip, unrar, wget, git, screen"
	sudo apt-get -y install unzip
	sudo apt-get -y install unrar-free
	sudo apt-get -y install git
	sudo apt-get -y install wget
	sudo apt-get -y install xz-utils
	echo ""

else
    echo "This script must be executed by the deployment script"
fi

