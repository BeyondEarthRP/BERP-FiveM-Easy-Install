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
#]     IF YOU ARE HAVING PROBLEMS, I GOT A PLAN FOR YOU SON...
#} (Figure it Out!!) I'VE GOT 99 PROBLEMS BUT YOURS AINT ONE!!
#                          --ps. send me the answer. thx <3
#
####################################################################
# BASIC DETAILS --- do not touch (unless you know how.)
#  CFX ARTIFACT BUILD:

cfx_build=1868
artifact_build="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"

#####################################################################
#
# JUST A BANNER
##
echo "                                                            ";
echo "                                                            ";
echo " ▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄ ";
echo "▐░░░░░░░░░░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌";
echo "▐░█▀▀▀▀▀▀▀█░▌  ▐░█▀▀▀▀▀▀▀▀▀    ▐░█▀▀▀▀▀▀▀█░▌   ▐░█▀▀▀▀▀▀▀█░▌";
echo "▐░▌       ▐░▌  ▐░▌             ▐░▌       ▐░▌   ▐░▌       ▐░▌";
echo "▐░█▄▄▄▄▄▄▄█░▌  ▐░█▄▄▄▄▄▄▄▄▄    ▐░█▄▄▄▄▄▄▄█░▌   ▐░█▄▄▄▄▄▄▄█░▌";
echo "▐░░░░░░░░░░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌";
echo "▐░█▀▀▀▀▀▀▀█░▌  ▐░█▀▀▀▀▀▀▀▀▀    ▐░█▀▀▀▀█░█▀▀    ▐░█▀▀▀▀▀▀▀▀▀ ";
echo "▐░▌       ▐░▌  ▐░▌             ▐░▌     ▐░▌     ▐░▌          ";
echo "▐░█▄▄▄▄▄▄▄█░▌▄ ▐░█▄▄▄▄▄▄▄▄▄  ▄ ▐░▌      ▐░▌  ▄ ▐░▌          ";
echo "▐░░░░░░░░░░▌▐░▌▐░░░░░░░░░░░▌▐░▌▐░▌       ▐░▌▐░▌▐░▌          ";
echo " ▀▀▀▀▀▀▀▀▀▀  ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀  ▀         ▀  ▀  ▀           ";
echo "     __                 __             __                   ";
echo "    |__) _   _  _  _|  |_  _  _|_|_   |__)_ | _ _ | _       ";
echo "    |__)(-\/(_)| )(_|  |__(_|| |_| )  | \(_)|(-|_)|(_|\/    ";
echo "          /                                    |      /     ";
echo "                                                            ";
echo "         EASY (FOR YOU!) FIVEM DEPLOYMENT SCRIPT            ";
echo "                                                            ";
echo "                                                            ";
#####################################################################
#
# SUDO CHECK
##
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
export cfx_build
export artifact_build


#####################################################################
#
# THIS BIT IS NEEDED TO GET THE JSON CONFIG TO WORK
##
apt update && apt -y upgrade && apt -y install jq
set -a  # exporting these variables for other scripts
	SCRIPT=$(echo $0 | rev | cut -f1 -d/ | rev)
	SCRIPT_ROOT=`dirname "$(readlink -f "$0")"`
		SCRIPT_FULLPATH=$SCRIPT_ROOT/$SCRIPT
set +a

#####################################################################
#
# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
##
echo "Looking for a config file..."
while [ -z $CONFIG ];
do
	if [ -f "$SCRIPT_ROOT/config.json" ]; then
		echo "Config found!"
		CONFIG="$SCRIPT_ROOT/config.json"
	else
		echo "No config found... "
		$SCRIPT_ROOT/quick-config.sh	
	fi
done
echo ""

#####################################################################
#
# IMPORT THE DEPLOYMENT SCRIPT CONFIGURATION
##
echo "Reading config..."
ALLFIGS=( srvAcct srvPassword mysql_user mysql_password steam_webApiKey sv_licenseKey blowfish_secret DBPSWD )
for _fig in "${ALLFIGS[@]}";
do
    echo -n "Importing ${_fig} configuration"
	if [ -z ${!_fig} ];
	then
		eval "$_fig"="$(jq .[\"$_fig\"] $CONFIG)"
		
		#echo -n " => $_fig = ${!_fig} => "  # DISPLAY ON SCREEN
		echo " ... " # DO NOT DISPLAY ON SCREEN
		
	fi
	export ${_fig}
	if [ ! -z ${!_fig} ];
	then
		echo "Done."
	else
		echo "FAILED!."
		exit 1
	fi
done
echo ""

#####################################################################
#
# ACCOUNT CREATION
##
echo "checking for local account: $srvAcct"
account=$(id -u ${srvAcct})
if [ -z $account ]; then
	echo "creating server account..."
	adduser --home /home/$srvAcct --shell /bin/bash --gecos "FiveM Server, , ,  " --disabled-password "$srvAcct"
	echo "$srvAcct:$srvPassword" | chpasswd
	
	account=$(id -u ${srvAcct})
	if [ ! -z $account ]; then
		echo "$srvAcct found. Good. Let's continue..."
	else
		echo "FAILED to create account: $srvAcct!"
		exit 1
	fi
else
	echo ""
	echo "Account already exists! Skipping account creation (this is probably bad)..."
	echo ""
fi

#####################################################################
#
# DEFINE VARIABLES TO EXPORT
##
set -a
SOURCE_ROOT="$(cd ~ && pwd)"
	SOURCE="$SOURCE_ROOT/REPO"
		DB_BKUP_PATH="$SOURCE/mysql-backups"
			DB="$(ls -Art $DB_BKUP_PATH/ | tail -n 1)"
		PATH_TO_DB="$DB_BKUP_PATH/$DB"


SOFTWARE="/var/software"
	TFIVEM="$SOFTWARE/fivem"
		TCCORE="$TFIVEM/citizenfx.core.server"

MAIN="/home/$srvAcct"
	GAME="$MAIN/server-data"
		RESOURCES="$GAME/resources"

			GAMEMODES="$RESOURCES/[gamemodes]"
				MAPS="$GAMEMODES/[maps]"

			ESX="$RESOURCES/[esx]"
				ESEXT="$ESX/es_extended"
				ESUI="$ESX/[ui]"

			ESSENTIAL="$RESOURCES/[essential]"
				ESMOD="$ESSENTIAL/essentialmode"

			MODS="$RESOURCES/[mods]"
			VEHICLES="$RESOURCES/[vehicles]"
set +a

#####################################################################
#
# A BIT OF FUNCTION
##
#### THE DATABASE STUFF BELOW CAME FROM THIS GUY! TY! VERY GOOD WORK!!
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
# OKAY, THESE MINE!
stopScreen () {
	echo "Quiting screen session for FiveM (if applicable)"
	su $srvAcct -c "screen -XS 'fivem' quit"
}
#####################################################################
#
# DO THE DEED - WAIT, IS THIS A NEW INSTALL, REDEPLOY, REBUILD, OR RESTORE?
##
if [ -z $1 ]; then
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
	ping -c 15 127.0.0.1 > /dev/null
	### SAVING THIS BIT FOR ANOTHER SCRIPT ######
	#if is_mysql_root_password_set; then
	#	echo "Database root password already set"
	#	exit 0
	#fi
	
	$SCRIPT_ROOT/build-dependancies.sh EXECUTE
	echo "DEPENDANCIES BUILT!"
	echo ""
	#####################################################################
	# 
	# CHECK FOR MYSQL
	##
	if [ ! is_mysql_command_available ]; then
	  echo "The MySQL/MariaDB client mysql(1) is not installed."
	  exit 1
	fi
	$SCRIPT_ROOT/build/build-fivem.sh EXECUTE
	echo "FIVEM BUILT!"
	echo ""
	$SCRIPT_ROOT/build/build-txadmin.sh EXECUTE
	echo "TXADMIN BUILT!"
	echo ""
	$SCRIPT_ROOT/build/fetch-source.sh EXECUTE
	echo "SOURCES FETCHED!"
	echo ""
	$SCRIPT_ROOT/build/create-database.sh EXECUTE
	echo "DATABASE CREATED!"
	echo ""
	$SCRIPT_ROOT/build/build-config.sh EXECUTE
	echo "CONFIG BUILT AND DEPLOYED!"
	echo ""
	$SCRIPT_ROOT/build/build-resources.sh EXECUTE
	echo "RESOURCES BUILT!"
	echo ""
	$SCRIPT_ROOT/build/build-vmenu.sh EXECUTE
	echo "VMENU BUILT!"
	echo ""
elif [ ! -z $1 ]; then
	#####################################################################
	# 
	# CHECK FOR MYSQL
	##
	if [ ! is_mysql_command_available ]; then
	  echo "The MySQL/MariaDB client mysql(1) is not installed."
	  exit 1
	fi
	if [ "$1"=="--redeploy" ] || [ "$1"=="-r" ]; then
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
		###
		##### this assumes you've used my teardown script.
		##### if you've done this on your own. sorry...
		##### Use my script to tear down, next time.
		###
		stopScreen # STOP THE SCREEN SESSION
		$SCRIPT_ROOT/build/build-fivem.sh EXECUTE
		echo "FIVEM REBUILT!"
		echo ""
		$SCRIPT_ROOT/build/build-txadmin.sh EXECUTE
		echo "TXADMIN REBUILT!"
		echo ""
		$SCRIPT_ROOT/build/create-database.sh EXECUTE
		echo "FRESH DATABASE RECREATED!"
		echo ""
		$SCRIPT_ROOT/build/build-config.sh EXECUTE
		echo "CONFIG BUILT AND DEPLOYED!"
		echo ""
		$SCRIPT_ROOT/build/build-resources.sh EXECUTE
		echo "RESOURCES REBUILT!"
		echo ""
		$SCRIPT_ROOT/build/build-vmenu.sh EXECUTE
		echo "VMENU REBUILT!"
		echo ""	
	elif [ "$1"=="--rebuild" ] || [ "$1"=="-b" ]; then
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
		###
		##### THIS IS GOING TO OVER WRITE STUFF
		##### YOU'VE BEEN (KIND OF) WARNED.
		###
		stopScreen #STOP THE SCREEN SESSION
		$SCRIPT_ROOT/build/build-config.sh DEPLOY
		echo "CONFIG REDEPLOYED!"
		echo ""
		$SCRIPT_ROOT/build/build-resources.sh EXECUTE
		echo "RESOURCES REBUILT!"
		echo ""
		$SCRIPT_ROOT/build/build-vmenu.sh EXECUTE
		echo "VMENU REBUILT!"
		echo ""	
	elif [ "$1"=="--restore" ] || [ "$1"=="-oof" ]; then
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
		#stopScreen
		#$SCRIPT_ROOT/build/build-config.sh DEPLOY
		#echo "CONFIG REDEPLOYED!"
		#echo ""
		#$SCRIPT_ROOT/build/build-resources.sh EXECUTE
		#echo "RESOURCES REBUILT!"
		#echo ""
		#$SCRIPT_ROOT/build/build-vmenu.sh EXECUTE
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
if [ ! -f $GAME/server.cfg ]; then
    echo "Server configuration not found! Woopsie... FAILED!"
	exit 1
fi
mv $GAME/server.cfg{,.orig} #--> Renaming file to be processed

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
    rm -f $GAME/server.cfg.orig  #--> cleaning up; handing off a .rconCfg

#-mySql Configuration
echo "Accepting RCON config handoff; Injecting MySQL Connection String..."
    db_conn_placeholder="set mysql_connection_string \"server=localhost;database=essentialmode;userid=username;password=YourPassword\""
    db_conn_actual="set mysql_connection_string \"server=localhost;database=essentialmode;userid=$mysql_user;password=$mysql_password\""
    sed "s/$db_conn_placeholder/$db_conn_actual/" "$GAME/server.cfg.rconCfg" > "$GAME/server.cfg.dbCfg"
    rm -f $GAME/server.cfg.rconCfg #--> cleaning up; handing off a .dbCfg

#-Steam Key Injection into Config
echo "Accepted MySql config handoff; Injecting Steam Key into config..."
    steamKey_placeholder="set steam_webApiKey \"SteamKeyGoesHere\""
    steamKey_actual="steam_webApiKey  \"${steam_webApiKey}\""
    sed "s/${steamKey_placeholder}/${steamKey_actual}/" "$GAME/server.cfg.dbCfg" > "$GAME/server.cfg.steamCfg"
    rm -f $GAME/server.cfg.dbCfg #--> cleaning up; handing off a .steamCfg

#-FiveM License Key Injection into Config
echo "Accepting Steam config handoff; Injecting FiveM License into config..."
    sv_licenseKey_placeholder="sv_licenseKey LicenseKeyGoesHere"
    sv_licenseKey_actual="sv_licenseKey ${sv_licenseKey}"
    sed "s/${sv_licenseKey_placeholder}/${sv_licenseKey_actual}/" "$GAME/server.cfg.steamCfg" > "$GAME/server.cfg"
    rm -f $GAME/server.cfg.steamCfg #--> cleaning up; handing off a server.cfg

if [ -f $GAME/server.cfg ]; then
    echo "Server configuration file found."
else
    echo "ERROR: Something went wrong during the configuration personalization..."
fi

#####################################################################
#
# GENERATE THE START SCRIPT
##
STARTUP_SCRIPT="$MAIN/start-fivem.sh"
cat <<EOF > $STARTUP_SCRIPT
#!/bin/bash
echo "Starting FiveM..."
screen -dmS "fivem" bash -c "trap 'echo gotsigint' INT; cd ${MAIN}/txAdmin; /usr/bin/node ${MAIN}/txAdmin/src/index.js default;  bash"
#cd ${GAME} && bash ${MAIN}/run.sh +exec ${GAME}/server.cfg
EOF
chmod +x $STARTUP_SCRIPT

######################################################################
#
# THIS NEEDS TO BE (PRETTY MUCH) LAST -- OWNING!
##
chown -R $srvAcct:$srvAcct $MAIN

#####################################################################
#
# STARTING THE SERVER
##
echo "Starting FiveM..."
su $srvAcct -c "${STARTUP_SCRIPT}"