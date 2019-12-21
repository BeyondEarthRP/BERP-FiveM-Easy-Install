#!/bin/bash

if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then
    ## ---- Deploy Server Source ---- ##
        cd ~
        git clone --recurse-submodules git@github.com:BeyondEarthRP/BERP-Repo.git $SOURCE
    ## ---- Deploy Server Source ---- ##

else
    echo "This script must be executed by the deployment script"
fi

