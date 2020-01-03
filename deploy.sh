#!/bin/bash
#       ____________________________________________________________
#]     /
#====% |
#}===% |  Beyond Earth Roleplay (BERP) Server Builder
#===%  |  cFx FiveM :: Grand Theft Auto V Roleplay
##-    |
#-]==% |  Easy (for you!) Automated Deployment Script
#==%   |  By: Jay aka Beyond Earth <djBeyondEarth@gmail.com>
#=\==% |  Tested on Debian 10.2 (Buster) -- cfx artifact 1868
#=/=%  |
#}     \____________________________________________________________
#
#]         IF YOU ARE HAVING PROBLEMS, I GOT A PLAN FOR YOU SON...
#}     (Figure it Out!!) I'VE GOT 99 PROBLEMS BUT YOURS AINT ONE!!
#                              --ps. send me the answer. thx <3
#|
#####################################################################
#
# SUDO CHECK
##
if [ "$EUID" != 0 ]; then
    sudo "$0" "$@"
    exit "$?"
fi

#####################################################################
#
# GENERATE DEPLOYMENT ENVIRONMENT
##
APPMAIN="MAIN" # DONUT TOUCH!

if [ ! "$BUILD" ] ;
then
  THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))" ;
  [[ ! "$_BUILD" ]] && [[ -d "$THIS_SCRIPT_ROOT/build" ]] && _BUILD="$THIS_SCRIPT_ROOT/build"
  [[ ! "$_BUILD" ]] && [[ -d $(dirname "$THIS_SCRIPT_ROOT")/build ]] && _BUILD=$(dirname "$THIS_SCRIPT_ROOT")/build
  [[ ! "$_BUILD" ]] && [[ -d "$THIS_SCRIPT_ROOT" ]] && _BUILD="$THIS_SCRIPT_ROOT"
  unset THIS_SCRIPT_ROOT ;
fi

if [ -d "$_BUILD" ] && [ -f "$_BUILD/build-env.sh" ] ;
then
        BUILD="$_BUILD" ; unset _BUILD ;

	#####################################################################
	#
	# JUST A BANNER
	##
	. "$BUILD/just-a-banner.sh" WELCOME

	color white - bold
	echo -e -n "Building environment...\\n"
	color - - clearAll
	. "$BUILD/build-env.sh" EXECUTE

	if [ -z "$CONFIG" ] ;
	then
	  _FAILED="1"
	  color red - bold
          echo -e -n "FAILED: no config file definition.\\n\\n"
	  color - - clearAll
          exit 1
        fi


	if [ "$__status" != "NO_CONFIG" ] ;
	then
		color white - bold
		echo "$__status"
		color - - clearAll
	fi

else
	echo "FAILED: Build folder undefined."
fi

if [ "$_FAILED" == "1" ] ;
then
	exit 1
fi
echo -e "\\n"
#####################################################################
#. "$BUILD/build-env.sh" RUNTIME  # This time for deployment execution
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
### BEGIN TO DO THINGS WITH STUFF ###################################
#####################################################################
#
# ACCOUNT CREATION
##
. "$BUILD/create-srvaccount.sh" EXECUTE

#####################################################################
#
# DO THE DEED - WAIT, IS THIS A NEW INSTALL, REDEPLOY, REBUILD, OR RESTORE?
##
if [ -z "$1" ]; then
	#\> NEW INSTALLATION
	. "$BUILD/just-a-banner.sh" NEW_INSTALL
	sleep 15

	### SAVING THIS BIT FOR ANOTHER SCRIPT ######
	#if is_mysql_root_password_set; then
	#	echo "Database root password already set"
	#	exit 0
	#fi

	. "$BUILD/build-dependancies.sh" EXECUTE
	echo -e "DEPENDANCIES BUILT!\\n"

	####
	# CHECK FOR MYSQL
	check_for_mysql

	. "$BUILD/build-fivem.sh" EXECUTE
	echo -e "FIVEM BUILT!\\n"

	. "$BUILD/build-txadmin.sh" EXECUTE
	echo -e "TXADMIN BUILT!\\n"

	. "$BUILD/fetch-source.sh" EXECUTE
	echo -e "SOURCES FETCHED!\\n"

	. "$BUILD/create-database.sh" EXECUTE
	echo -e "DATABASE CREATED!\\n"

	. "$BUILD/build-config.sh" EXECUTE
	echo -e "CONFIG BUILT AND DEPLOYED!\\n"

	. "$BUILD/build-resources.sh" EXECUTE
	echo -e "RESOURCES BUILT!\\n"

	. "$BUILD/build-vmenu.sh" EXECUTE
	echo -e "VMENU BUILT!\\n"

elif [ ! -z "$1" ]; then

	####
	# CHECK FOR MYSQL
	check_for_mysql;

	if [ "$1" == "--redeploy" ] || [ "$1" == "-r" ]; then
		#\> REDEPLOY
		. "$BUILD/just-a-banner.sh" REDEPLOY
		sleep 15

		#\
		##\
		###\
		####\    this assumes you've used my teardown script.
		#####>   if you've done this on your own. sorry...
		####/    Use my script to tear down, next time.
		###/
		##/
		#/

		####
		# STOP THE SCREEN SESSION
		stop_screen

		. "$BUILD/build-fivem.sh" EXECUTE
		echo -e "FIVEM REBUILT!\\n"

		. "$BUILD/build-txadmin.sh" EXECUTE
		echo -e "TXADMIN REBUILT!\\n"

		. "$BUILD/create-database.sh" EXECUTE
		echo -e "FRESH DATABASE RECREATED!\\n"

		. "$BUILD/build-config.sh" EXECUTE
		echo -e "CONFIG BUILT AND DEPLOYED!\\n"

		. "$BUILD/build-resources.sh" EXECUTE
		echo -e "RESOURCES REBUILT!\\n"

		. "$BUILD/build-vmenu.sh" EXECUTE
		echo -e "VMENU REBUILT!\\n"

	elif [ "$1" == "--rebuild" ] || [ "$1" == "-b" ]; then
		#\> REBUILD
		. "$BUILD/just-a-banner.sh" REBUILD
		sleep 15
		###
		##### THIS IS GOING TO OVER WRITE STUFF
		##### YOU'VE BEEN (KIND OF) WARNED.
		###

		####
		# STOP THE SCREEN SESSION
		stop_screen; #STOP THE SCREEN SESSION

		. "$BUILD/build-config.sh" DEPLOY
		echo -e "CONFIG REDEPLOYED!\\n"

		. "$BUILD/build-resources.sh" EXECUTE
		echo -e "RESOURCES REBUILT!\\n"

		. "$BUILD/build-vmenu.sh" EXECUTE
		echo -e "VMENU REBUILT!\\n"

	elif [ "$1" == "--restore" ] || [ "$1" == "-oof" ]; then
		#\> RESTORE
		. "$BUILD/just-a-banner.sh" RESTORE
		###
		##### THIS IS GOING TO OVER WRITE STUFF
		##### YOU'VE BEEN (KIND OF) WARNED.
		###
		echo -e "THIS IS NOT YET IMPLEMENTED. -sry!\\n"
		exit 1
		####
		# STOP THE SCREEN SESSION
		#stop_screen; #STOP THE SCREEN SESSION
		#$BUILD/build-config.sh DEPLOY
		#echo -e "CONFIG REDEPLOYED!\\n"

		#$BUILD/build-resources.sh EXECUTE
		#echo -e "RESOURCES REBUILT!\\n"

		#$BUILD/build-vmenu.sh EXECUTE
		#echo -e "VMENU REBUILT!\\n"

		#echo -e "Importing last database backup...\\n"
		#mysql essentialmode -e "SOURCE $PATH_TO_DB"

		#echo -e "backup imported.\\n"
	else
	   echo "Valid options are:

	           redeploy = ./${0} --redeploy | -r
			    rebuild = ./${0} --rebuild  | -b
			    restore = ./${0} --restore  | -oof

			example:

		      ./${0} -r
			     ^--this will redeploy.

		"
		exit 1
	fi
fi

#####################################################################
############ THIS SHOULD BE AT THE END STAGES #######################
#####################################################################
#
# INJECT PERSONAL CREDENTIALS INTO THE CONFIGURATION FILE
##
personalize # the server.cfg with your personables and such.

#####################################################################
#
# GENERATE THE START SCRIPT
##
STARTUP_SCRIPT="$MAIN/start-fivem.sh"

# MAKEY ANITY BITTY SRIP TO TAR TINGS!
cat <<EOF > "$STARTUP_SCRIPT"
#!/bin/bash
echo "Starting FiveM..."
screen -dmS "fivem" bash -c "trap 'echo gotsigint' INT; cd ${MAIN}/txAdmin; /usr/bin/node ${MAIN}/txAdmin/src/index.js default;  bash"
#cd ${GAME} && bash ${MAIN}/run.sh +exec ${GAME}/server.cfg
EOF
chmod +x "$STARTUP_SCRIPT" # GIVE IT LIFE!!!

######################################################################
#
# THIS NEEDS TO BE (PRETTY MUCH) LAST! -- OWNING! ALL THE THINGS!
##
chown -R "$SERVICE_ACCOUNT:$SERVICE_ACCOUNT" "$MAIN"

#####################################################################
#
# STARTING THE SERVER
##
su "$SERVICE_ACCOUNT" -c "${STARTUP_SCRIPT}"
