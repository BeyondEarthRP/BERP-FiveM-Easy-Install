#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	if [ -z "$SCRIPT_ROOT" ] || [ -z "$PRIVATE" ]; then
		echo "ERROR: Exports not found.  I'VE FAILED!"
		exit 1
	fi

    ## ---- txAdmin ---- ##

    echo "--> Installing: txAdmin"
        # Download txAdmin, Enter folder and Install dependencies
        git clone https://github.com/tabarra/txAdmin "$MAIN/txAdmin"
        cd "$MAIN/txAdmin"
        npm i

		if [ ! -d "$PRIVATE/txAdmin_data" ];
		then
			# Add admin
			node src/scripts/admin-add.js

			# Setup default server profile
			node src/scripts/setup.js default
		elif [ ! -f "$PRIVATE/txAdmin_data/admins.json" ];
		then
			cp -RfT "$PRIVATE/txAdmin_data" "$MAIN/txAdmin/data"

			# Add admin
			node src/scripts/admin-add.js
		elif [ -d "$PRIVATE/txAdmin_data" ] && [ -f "$PRIVATE/txAdmin_data/admins.json" ];
		then
			cp -RfT "$PRIVATE/txAdmin_data" "$MAIN/txAdmin/data"
		else
			###> NOT SURE WHAT HAPPENED HERE... YOU SHOULDN'T GET AN ELSE.
			###> BUT IF YOU DO.... WELL I NEED TO JUST MAKE THE FILE, SORRY.
			###>             LET'S GET HANDSY!!!

			# Add admin
			node src/scripts/admin-add.js

			# Setup default server profile
			node src/scripts/setup.js default
		fi

    ## ---- txAdmin ---- ##

else
    echo "This script must be executed by the deployment script"
fi
