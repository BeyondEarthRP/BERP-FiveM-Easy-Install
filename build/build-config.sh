#!/bin/bash
if [ -z "$__RUNTIME__" ] ;
then
	if [ -z "$BUILD" ] ;
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
	        BUILD="$cf"
	    fi
	  done
	fi
	[[ -z "$BUILD" ]] && echo "Build folder undefined. Failed." && exit 1
	#-----------------------------------------------------------------------------------------------------------------------------------
	if [ -z "$APPMAIN" ] ;
	then
	  APPMAIN="BUILD_CONFIG"
	  . "$BUILD/build-env.sh" EXECUTE
	elif [ -z "$__RUNTIME__" ] ;
	then
	        echo "Runtime not loaded... I'VE FAILED!"
	        exit 1
	fi
	[[ -z "${SOURCE:?}" ]] &&  echo "Source undefined... " && exit 1

	[[ -n "$__INVALID_CONFIG__" ]] && echo "You'll need to run the quick configure before this will work..." && exit 1
fi
####################################################################################################################################

generate () {

	color red - bold
	echo "${SOURCE:?}/belch.co2"
	[[ ! -f "$SOURCE/belch.co2" ]] \
	  && echo -e "The belch.co2 is missing... If it's gone, the source is corrupt.\\e[0m" && exit 1

	echo "Creating configuration & database scheme..."
	. "${SOURCE:?}/Belcher.sh"
}

deploy () {
	LOGO="SplatEarth.png"

	cp -RfT "${SOURCE:?}/__[LOGOS]__/$LOGO" "${GAME:?}/BERP-Logo.png"
	color gray
	echo "Logo deployed."

	if [ -d "${SOURCE:?}/configs" ]; then
		cp -RfT "${SOURCE:?}/configs" "${GAME:?}/configs"
		local __sub_configs__=1
	fi

	cp -RfT "${SOURCE:?}/server.cfg" "${GAME:?}/server.cfg"

	if [ -f "${GAME:?}/server.cfg" ] && [ -z "$__sub_configs__" ] ;
	then
		color yellow - bold
		echo -e "Config deployed. (no sub configs?)\\e[0m"
		# only a single config... no subconfigs found (this is probably bad actually.  I use subconfigs.

	elif [ -f "${GAME:?}/server.cfg" ] && [ -d "${GAME:?}/configs" ] ;
	then
		color green - bold
		echo -e "Config and subconfigs have been deployed.\\e[0m"
	else
		color yellow red bold
		echo "Well, this isn't good. Has belcher done it's thing yet? No configs... or I had a write failure.  Crap!.\\e[0m" && exit 1
	fi
}

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	if [ ! -z "${GAME:?}" ] && [ ! -z "${SOURCE:?}" ]; then

		## ---- Generate and Deploy Server Config ---- ##

		generate ;
		deploy ;
		personalize ;

		## ---- Generate and Deploy Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi

elif [ ! -z "$1" ] && [ "$1" == "GENERATE" ] ; then

	if [ ! -z "${SOURCE:?}" ]; then

		## ---- Only Generate Server Config ---- ##

		generate ;

		## ---- Only Generate Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi

elif [ ! -z "$1" ] && [ "$1" == "DEPLOY" ] ; then

	if [ ! -z "${GAME:?}" ] && [ ! -z "${SOURCE:?}" ]; then

		## ---- Only Deploy Server Config ---- ##

		deploy ;

		## ---- Only Deploy Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi
elif [ ! -z "$1" ] && [ "$1" == "PERSONALIZE" ]; then

	if [ ! -z "${GAME:?}" ] && [ ! -z "${SOURCE:?}" ]; then

		## ---- Only Deploy Server Config ---- ##

		personalize ;

		## ---- Only Deploy Server Config ---- ##

	else
		echo "ERROR: Exports not found. I'VE FAILED!"
	fi
else
    echo "This script must be executed by the deployment script"
fi

