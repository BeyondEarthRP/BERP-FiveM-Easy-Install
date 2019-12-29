#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

    ## ---- FiveM ---- ##

    echo "FiveM - Base"
        echo "Get Packages"
            artifact="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${artifact_build}/fx.tar.xz"

            wget -P "$TFIVEM" "$artifact"

        echo "Extract Package"
            tar -xf "$TFIVEM/fx.tar.xz" --directory "$MAIN/"


    echo "FiveM - CitizenFX"
        git clone https://github.com/BeyondEarthRP/cfx-server-data.git "$GAME"

    echo "CitizenFX Module Update"
        wget -P "$TCCORE" https://d.fivem.dev/CitizenFX.Core.Server.zip
        unzip "$TCCORE/CitizenFX.Core.Server.zip" -d "$TCCORE/CCORE"

        cp -RfT "$TCCORE/CCORE/CitizenFX.Core.sym" "$MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.sym"
        cp -RfT "$TCCORE/CCORE/CitizenFX.Core.Server.dll" "$MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.dll"
        cp -RfT "$TCCORE/CCORE/CitizenFX.Core.Server.sym" "$MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.sym"

    ## ---- FiveM ---- ##

else
    echo "This script must be executed by the deployment script"
fi
