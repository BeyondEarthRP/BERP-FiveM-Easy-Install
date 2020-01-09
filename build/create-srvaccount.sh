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
          APPMAIN="CREATE_SERVER_ACCOUNT"
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
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- CREATE FIVEM SERVICE ACCOUNT ---- ##

	#####################################################################
	#
	# ACCOUNT CREATION
	##
	[[ ! "$SERVICE_ACCOUNT" ]] && echo "Service account not found! I'VE FAILED!" && exit 1

	echo "SERVICE ACCOUNT: $SERVICE_ACCOUNT"
	echo "checking for local account: $SERVICE_ACCOUNT"

	account=$(id -u "${SERVICE_ACCOUNT}")
	if [ -z "$account" ]; then
	        echo "creating server account..."
	        adduser --home "/home/$SERVICE_ACCOUNT" --shell /bin/bash --gecos "FiveM Server, , ,  " --disabled-password "$SERVICE_ACCOUNT" -u 1142
	        echo "$SERVICE_ACCOUNT:$SERVICE_PASSWORD" | chpasswd

	        account=$(id -u "${SERVICE_ACCOUNT}")
	        if [ ! -z "$account" ]; then
	                echo ""
	                echo "'$SERVICE_ACCOUNT' account found. Good. Let's continue..."
	                echo ""
        	else
	                echo ""
	                echo "FAILED to create account '$SERVICE_ACCOUNT!'"
	                exit 1
	        fi
	else
	        echo ""
	        echo "Account already exists! Skipping account creation (this is probably bad)..."
	        echo ""
	        ping -c 5 127.0.0.1 > /dev/null  # giving some time to see this.
	fi

	## ---- CREATE FIVEM SERVICE ACCOUNT ---- #

else
    echo "This script must be executed by the deployment script"
fi

