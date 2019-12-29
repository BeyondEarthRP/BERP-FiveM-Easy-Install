#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- CREATE FIVEM SERVICE ACCOUNT ---- ##

	#####################################################################
	#
	# ACCOUNT CREATION
	##
	echo "checking for local account: $SERVICE_ACCOUNT"
	account=$(id -u "${SERVICE_ACCOUNT}")
	if [ -z "$account" ]; then
	        echo "creating server account..."
	        adduser --home "/home/$SERVICE_ACCOUNT" --shell /bin/bash --gecos "FiveM Server, , ,  " --disabled-password "$SERVICE_ACCOUNT"
	        echo "$SERVICE_ACCOUNT:$srvPassword" | chpasswd

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

