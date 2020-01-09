#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

####################################################################################################################################
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
          APPMAIN="BUILD_FIVEM"
          . "$_BUILD/build-env.sh" EXECUTE
        elif [ -z "$__RUNTIME__" ] ;
        then
                echo "Runtime not loaded... I'VE FAILED!"
                exit 1
        fi
        [[ -z "${SOURCE:?}" ]] &&  echo "Source undefined... " && exit 1

        [[ -n "$__INVALID_CONFIG__" ]] && echo "You'll need to run the quick configure before this will work..." && exit 1
fi
####################################################################################################################################


    ## ---- FiveM ---- ##

	printf "\\e[91m\\e[1m"
    [[ -z "$TFIVEM" ]] && echo -e "tfivem folder location not defined.\\e[0m" && exit 1
    [[ -z "$TCCORE" ]] && echo -e "tccore folder location not defined.\\e[0m" && exit 1
    [[ -z "$MAIN" ]] && echo -e "main folder location not defined.\\e[0m" && exit 1
    [[ -z "$GAME" ]] && echo -e "game folder location not defined.\\e[0m" && exit 1
	printf "\\e[0m"

    echo "FiveM - Base"
        echo "Get Packages"
            artifact="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${ARTIFACT_BUILD:?}/fx.tar.xz"

            wget -P "${TFIVEM:?}" "$artifact"

        echo "Extract Package"
            tar -xf "$TFIVEM/fx.tar.xz" --directory "${MAIN:?}/"

    . "${BUILD:?}/build-fivem-resources.sh" EXECUTE

    echo "CitizenFX Module Update"
        wget -P "${TCCORE:?}" https://d.fivem.dev/CitizenFX.Core.Server.zip
        unzip "${TCCORE:?}/CitizenFX.Core.Server.zip" -d "${TCCORE:?}/CCORE"

        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.sym" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.sym"
        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.Server.dll" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.dll"
        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.Server.sym" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.sym"

    ## ---- FiveM ---- ##

else
    echo "This script must be executed by the deployment script"
fi
