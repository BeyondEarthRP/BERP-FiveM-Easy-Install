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
    exit $?
fi

#####################################################################
#
# BUILD DEPLOYMENT ENVIRONMENT
##
APPMAIN="APPMAIN" # DONUT TOUCH!

if [ ! "$BUILD" ] ;
then
  _BUILD="build" # If you changed this.... why?! btw, it is also hard coded in some of the files at the top (similar to this).
  _BUILD_ENV="build-env.sh"  # If this is different... why the heck are you changing my file names?!

  THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
  [[ -d "$THIS_SCRIPT_ROOT/$_BUILD" ]] && _BUILD="$THIS_SCRIPT_ROOT/$_BUILD"
  [[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "$_BUILD" ]] && _BUILD="$THIS_SCRIPT_ROOT"
  [[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "$_BUILD" ]] && _BUILD="$(dirname $THIS_SCRIPT_ROOT)"
  unset THIS_SCRIPT_ROOT
fi

if [ -d "$_BUILD" ] && [ -f "$_BUILD/$_BUILD_ENV" ] ; then

	. "$_BUILD/$_BUILD_ENV" EXECUTE

	[[ ! $CONFIG ]] && _FAILED=1 && echo "Config not found by deploy script. I'VE FAILED!" && exit 1

        BUILD="$_BUILD"

	[[ "$_BUILD" ]] && unset _BUILD
	[[ "$_BUILD_ENV" ]] && unset _BUILD_ENV
else
    while [ ! -d "$_BUILD" ] && [ ! -f "$_BUILD/$_BUILD_ENV" ];
    do
	read -p "Where is the build folder located? [$_BUILD] " _BUILD
	if [ -d "$_BUILD" ] && [ -f "$_BUILD/$_BUILD_ENV" ]; then
		echo "Config found... You changed the build folder.  You need to change 'deploy.sh' as well, unless you like this prompt and want to see it always... I'm guessing you don't want that though."
		echo ""
		_FAILED=1
	elif [ -d "$_BUILD" ]; then
		echo "Could not find the folder: $_BUILD"
		echo "Please verify the location and try again."
		echo ""
		_FAILED=1
	elif [ -d "$_BUILD" ] && [ ! -f "$_BUILD/$_BUILD_ENV" ]; then
		echo "Could not find the file '$_BUILD_ENV' in the folder: $_BUILD"
		echo "Please verify that the file exists and you are entering the correct folder name."
		echo ""
		echo "If you've changed this for some crazy reason, you should consult 'deploy.sh' and change appropriately"
		echo ""
		_FAILED=1
	fi
    done
fi

if [ "$_FAILED" == "1" ] ; then
	exit 1
fi

#####################################################################
#
# JUST A BANNER
##
. "$BUILD/just-a-banner.sh"

#####################################################################
#
# ACCOUNT CREATION
##
. "$BUILD/create-srvaccount.sh" EXECUTE

#####################################################################
#
# A BIT OF FUNCTION
##
#### THE DATABASE STUFF BELOW CAME FROM BERT VAN VRECKEM... TY! VERY GOOD WORK!!
#### Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#### A non-interactive replacement for mysql_secure_installation
####
# Predicate that returns exit status 0 if the database root password
# is set, a nonzero exit status otherwise.
is_mysql_root_password_set() {
  ! mysqladmin --user=root status > /dev/null 2>&1
}

####
# Predicate that returns exit status 0 if the mysql(1) command is available,
# nonzero exit status otherwise.
is_mysql_command_available() {
  which mysql > /dev/null 2>&1
}

####
# CHECK FOR MYSQL
check_for_mysql() {
  if [ ! is_mysql_command_available ]; then
    echo "The MySQL/MariaDB client mysql(1) is not installed."
    exit 1
  fi
}

####
# OKAY, THESE MINE!
##
###
# THIS STOPS A SCREEN SESSION.
stop_screen() {
  SCREEN_SESSION_NAME="fivem"
  echo "Quiting screen session '$SCREEN_SESSION_NAME' for FiveM (if applicable)"
  su "$SERVICE_ACCOUNT" -c "screen -XS '$SCREEN_SESSION_NAME' quit"
}
###
# SLEEP ... nuf'said
sleep() {
# Hold up N seconds
# Default (no args) is 10 seconds-ish
#
# usage:
#   sleep 5
#   sleep
#
  if [ -z "$1" ]; then
    count="10"
  else
    count="$1"
  fi
  ping -c "$count" 127.0.0.1 > /dev/null
}
#
###
# invert (if set, unset // if unset, set to 1)
#   BASH BOOLEAN
invert() {
  local __result="$1"
  if [ "${!__result}" ]; then
    eval unset "$__result"
    #FALSE
  else
    eval "$__result"=1
    #TRUE
  fi
}


#####################################################################
#
# DO THE DEED - WAIT, IS THIS A NEW INSTALL, REDEPLOY, REBUILD, OR RESTORE?
##
if [ -z "$1" ]; then
	#\> NEW INSTALLATION
	echo "                                                                                      ";
	echo "                                                                                      ";
	echo "███╗   ██╗███████╗██╗    ██╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ";
	echo "████╗  ██║██╔════╝██║    ██║    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ";
	echo "██╔██╗ ██║█████╗  ██║ █╗ ██║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ";
	echo "██║╚██╗██║██╔══╝  ██║███╗██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ";
	echo "██║ ╚████║███████╗╚███╔███╔╝    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗";
	echo "╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝";
	echo "                                                                                      ";
	echo "    you've got about 10 seconds to cancel this script (hit control-c two times!)      ";
	echo "                                                                                      ";
	echo "                                                                                      ";
	sleep 15

	### SAVING THIS BIT FOR ANOTHER SCRIPT ######
	#if is_mysql_root_password_set; then
	#	echo "Database root password already set"
	#	exit 0
	#fi


	. "$BUILD/build-dependancies.sh" EXECUTE
	echo "DEPENDANCIES BUILT!"
	echo ""

	####
	# CHECK FOR MYSQL
	check_for_mysql

	. "$BUILD/build-fivem.sh" EXECUTE
	echo "FIVEM BUILT!"
	echo ""
	. "$BUILD/build-txadmin.sh" EXECUTE
	echo "TXADMIN BUILT!"
	echo ""
	. "$BUILD/fetch-source.sh" EXECUTE
	echo "SOURCES FETCHED!"
	echo ""
	. "$BUILD/create-database.sh" EXECUTE
	echo "DATABASE CREATED!"
	echo ""
	. "$BUILD/build-config.sh" EXECUTE
	echo "CONFIG BUILT AND DEPLOYED!"
	echo ""
	. "$BUILD/build-resources.sh" EXECUTE
	echo "RESOURCES BUILT!"
	echo ""
	. "$BUILD/build-vmenu.sh" EXECUTE
	echo "VMENU BUILT!"
	echo ""
elif [ ! -z "$1" ]; then

	####
	# CHECK FOR MYSQL
	check_for_mysql;

	if [ "$1" == "--redeploy" ] || [ "$1" == "-r" ]; then
		#\> REDEPLOY
		echo "                                                                  ";
		echo "██████╗ ███████╗██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗";
		echo "██╔══██╗██╔════╝██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝";
		echo "██████╔╝█████╗  ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ ";
		echo "██╔══██╗██╔══╝  ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ";
		echo "██║  ██║███████╗██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ";
		echo "╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ";
		echo "                                                                  ";
		echo "        you've got about 10 seconds to cancel this script         ";
		echo "                  (hit control-c two times!)                      ";
		echo "                                                                  ";
		echo "                                                                  ";
		ping -c 15 127.0.0.1 > /dev/null
		###
		##### this assumes you've used my teardown script.
		##### if you've done this on your own. sorry...
		##### Use my script to tear down, next time.
		###

		####
		# STOP THE SCREEN SESSION
		stop_screen

		. "$BUILD/build-fivem.sh" EXECUTE
		echo "FIVEM REBUILT!"
		echo ""
		. "$BUILD/build-txadmin.sh" EXECUTE
		echo "TXADMIN REBUILT!"
		echo ""
		. "$BUILD/create-database.sh" EXECUTE
		echo "FRESH DATABASE RECREATED!"
		echo ""
		. "$BUILD/build-config.sh" EXECUTE
		echo "CONFIG BUILT AND DEPLOYED!"
		echo ""
		. "$BUILD/build-resources.sh" EXECUTE
		echo "RESOURCES REBUILT!"
		echo ""
		. "$BUILD/build-vmenu.sh" EXECUTE
		echo "VMENU REBUILT!"
		echo ""
	elif [ "$1" == "--rebuild" ] || [ "$1" == "-b" ]; then
		#\> REBUILD
		echo "                                                    ";
		echo "██████╗ ███████╗██████╗ ██╗   ██╗██╗██╗     ██████╗ ";
		echo "██╔══██╗██╔════╝██╔══██╗██║   ██║██║██║     ██╔══██╗";
		echo "██████╔╝█████╗  ██████╔╝██║   ██║██║██║     ██║  ██║";
		echo "██╔══██╗██╔══╝  ██╔══██╗██║   ██║██║██║     ██║  ██║";
		echo "██║  ██║███████╗██████╔╝╚██████╔╝██║███████╗██████╔╝";
		echo "╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ";
		echo "                                                    ";
		echo " you've got about 10 seconds to cancel this script  ";
		echo "           (hit control-c two times!)               ";
		echo "                                                    ";
		echo "                                                    ";
		sleep 15
		###
		##### THIS IS GOING TO OVER WRITE STUFF
		##### YOU'VE BEEN (KIND OF) WARNED.
		###

		####
		# STOP THE SCREEN SESSION
		stop_screen; #STOP THE SCREEN SESSION

		. "$BUILD/build-config.sh" DEPLOY
		echo "CONFIG REDEPLOYED!"
		echo ""
		. "$BUILD/build-resources.sh" EXECUTE
		echo "RESOURCES REBUILT!"
		echo ""
		. "$BUILD/build-vmenu.sh" EXECUTE
		echo "VMENU REBUILT!"
		echo ""
	elif [ "$1" == "--restore" ] || [ "$1" == "-oof" ]; then
		#\> RESTORE
		echo "                                                          ";
		echo "██████╗ ███████╗███████╗████████╗ ██████╗ ██████╗ ███████╗";
		echo "██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝";
		echo "██████╔╝█████╗  ███████╗   ██║   ██║   ██║██████╔╝█████╗  ";
		echo "██╔══██╗██╔══╝  ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  ";
		echo "██║  ██║███████╗███████║   ██║   ╚██████╔╝██║  ██║███████╗";
		echo "╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝";
		echo "                                                          ";
		echo "    you've got about 10 seconds to cancel this script     ";
		echo "              (hit control-c two times!)                  ";
		echo "                                                          ";
		echo "                                                          ";
		###
		##### THIS IS GOING TO OVER WRITE STUFF
		##### YOU'VE BEEN (KIND OF) WARNED.
		###
		echo "THIS IS NOT YET IMPLEMENTED. -sry!"
		exit 1
		####
		# STOP THE SCREEN SESSION
		#stop_screen; #STOP THE SCREEN SESSION
		#$BUILD/build-config.sh DEPLOY
		#echo "CONFIG REDEPLOYED!"
		#echo ""
		#$BUILD/build-resources.sh EXECUTE
		#echo "RESOURCES REBUILT!"
		#echo ""
		#$BUILD/build-vmenu.sh EXECUTE
		#echo "VMENU REBUILT!"
		#echo ""
		#echo "Importing last database backup"
		#mysql essentialmode -e "SOURCE $PATH_TO_DB"
		#echo "backup imported."
		#echo ""
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
if [ ! -f "$GAME/server.cfg" ]; then
    echo "Server configuration not found! Woopsie... FAILED!"
	exit 1
fi
mv "$GAME/server.cfg" "$GAME/server.cfg.orig" #--> Renaming file to be processed

#-RCON Password Creation
echo "Generating RCON Password."
    Pass=`date +%s | sha256sum | base64 | head -c 64 ; echo`
    DateStamp=`date +"@%B#%Y"`
    rcon_password="$Pass$DateStamp"
    echo "RCON: $rcon_password"
    echo ""
    rcon_placeholder="#rcon_password changeme"
    rcon_actual="rcon_password \"${rcon_password}\""
echo "Accepting original configuration; Injecting RCON configuration..."
    sed "s/${rcon_placeholder}/${rcon_actual}/" "$GAME/server.cfg.orig" > "$GAME/server.cfg.rconCfg"
    rm -f "$GAME/server.cfg.orig"  #--> cleaning up; handing off a .rconCfg

#-mySql Configuration
echo "Accepting RCON config handoff; Injecting MySQL Connection String..."
    db_conn_placeholder="set mysql_connection_string \"server=localhost;database=essentialmode;userid=username;password=YourPassword\""
    db_conn_actual="set mysql_connection_string \"server=localhost;database=essentialmode;userid=$mysql_user;password=$mysql_password\""
    sed "s/$db_conn_placeholder/$db_conn_actual/" "$GAME/server.cfg.rconCfg" > "$GAME/server.cfg.dbCfg"
    rm -f "$GAME/server.cfg.rconCfg" #--> cleaning up; handing off a .dbCfg

#-Steam Key Injection into Config
echo "Accepted MySql config handoff; Injecting Steam Key into config..."
    steamKey_placeholder="set steam_webApiKey \"SteamKeyGoesHere\""
    steamKey_actual="steam_webApiKey  \"${steam_webApiKey}\""
    sed "s/${steamKey_placeholder}/${steamKey_actual}/" "$GAME/server.cfg.dbCfg" > "$GAME/server.cfg.steamCfg"
    rm -f "$GAME/server.cfg.dbCfg" #--> cleaning up; handing off a .steamCfg

#-FiveM License Key Injection into Config
echo "Accepting Steam config handoff; Injecting FiveM License into config..."
    sv_licenseKey_placeholder="sv_licenseKey LicenseKeyGoesHere"
    sv_licenseKey_actual="sv_licenseKey ${sv_licenseKey}"
    sed "s/${sv_licenseKey_placeholder}/${sv_licenseKey_actual}/" "$GAME/server.cfg.steamCfg" > "$GAME/server.cfg"
    rm -f "$GAME/server.cfg.steamCfg" #--> cleaning up; handing off a server.cfg

if [ -f "$GAME/server.cfg" ]; then
    echo "Server configuration file found."
else
    echo "ERROR: Something went wrong during the configuration personalization..."
fi

#####################################################################
#
# GENERATE THE START SCRIPT
##
STARTUP_SCRIPT="$MAIN/start-fivem.sh"
cat <<EOF > "$STARTUP_SCRIPT"
#!/bin/bash
echo "Starting FiveM..."
screen -dmS "fivem" bash -c "trap 'echo gotsigint' INT; cd ${MAIN}/txAdmin; /usr/bin/node ${MAIN}/txAdmin/src/index.js default;  bash"
#cd ${GAME} && bash ${MAIN}/run.sh +exec ${GAME}/server.cfg
EOF
chmod +x "$STARTUP_SCRIPT"

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
