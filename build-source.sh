#!/bin/bash

if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then
    ## ---- Deploy Server Source ---- ##
        cd ~
        git clone --recurse-submodules git@github.com:BeyondEarthRP/BERP-Repo.git $SOURCE
        LOGO="SplatEarth.png"
        cp -rfup $SOURCE/__\[LOGOS\]__/$LOGO $GAME/BERP-Logo.png
        if [ ! -d $RESOURCES ]; then
            mkdir $RESOURCES
        fi
        if [ ! -d $ESX ]; then
            mkdir $ESX
        fi
        if [ ! -d $ESUI ]; then
            mkdir $ESUI
        fi
        if [ ! -d $ESSENTIAL ]; then
            mkdir $ESSENTIAL
        fi
    ## ---- Deploy Server Source ---- ##
else
    echo "This script must be executed by the deployment script"
fi

