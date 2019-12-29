#!/bin/bash

generate () {
	echo "Creating configuration & database scheme..."
	"$SOURCE/build-srvcfg.sh"
}

deploy () {
	if [ -d "$SOURCE/configs" ]; then
		cp -RfT "$SOURCE/configs" "$GAME/configs"
	fi
	cp -RfT "$SOURCE/server.cfg" "$GAME/server.cfg"
	echo "Config deployed."

	LOGO="SplatEarth.png"
	cp -RfT "$SOURCE/__[LOGOS]__/$LOGO" "$GAME/BERP-Logo.png"
	echo "Logo deployed."
}

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	if [ ! -z "$GAME" ] && [ ! -z "$SOURCE" ]; then

		## ---- Generate and Deploy Server Config ---- ##

		generate;
		deploy;

		## ---- Generate and Deploy Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi

elif [ ! -z "$1" ] && [ "$1" == "GENERATE" ]; then

	if [ ! -z "$SOURCE" ]; then

		## ---- Only Generate Server Config ---- ##

		generate;

		## ---- Only Generate Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi

elif [ ! -z "$1" ] && [ "$1" == "DEPLOY" ]; then

	if [ ! -z "$GAME" ] && [ ! -z "$SOURCE" ]; then

		## ---- Only Deploy Server Config ---- ##

		deploy;

		## ---- Only Deploy Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi
else
    echo "This script must be executed by the deployment script"
fi

