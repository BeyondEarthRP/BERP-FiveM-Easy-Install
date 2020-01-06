#!/bin/bash
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

	echo "--> INSTALLING: OTHER REQUIRED PACKAGES"
	sudo apt-get -y install screen
	echo ""

	echo "--> Installing: NodeJS"
	sudo apt update
	sudo apt -y install nodejs npm -y
	sudo apt -y install build-essential -y

	nodejs --version
	npm --version

else
    echo "This script must be executed by the deployment script"
fi

