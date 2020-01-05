#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then
_BUILD="/root/BERP-Builder/build"
. "$_BUILD/build-env.sh" RUNTIME

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


    echo "FiveM - CitizenFX"
        git clone https://github.com/BeyondEarthRP/cfx-server-data.git "${GAME:?}"

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
