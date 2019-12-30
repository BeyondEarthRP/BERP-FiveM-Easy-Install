#!/bin/bash
# -ex
#\
#>\___________________
#>> THESE ARE MINE
#>>>>>>>>>>>>>>>>>>>>>
# FUNCTIONS TO BUILD OUT THE RUN TIME ENVIRONMENT
initialize() {
  ####
  # THIS BIT IS NEEDED TO GET THE JSON CONFIG TO WORK
  jqGreet=$( dpkg-query -W -f='${Version}\n' jq ) # check for jq
  if [ -z "$jqGreet" ]; then # if not found
    apt update && apt -y upgrade && apt -y install jq # install it!
  fi
}

define_runtime_env() {
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  PRIVLY_NAME  ::  CONFIG_NAME  ::  REPO_NAME  #
	#///////////////////////////////////////////////#
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  SCRIPT  ::  SCRIPT_ROOT  ::  SCRIPT_FULLPATH  ::  DB  ::  DB_BKUP_PATH  #
	#//////////////////////////////////////////////////////////////////////////#
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  SOURCE_ROOT  ::  SOURCE  ::  PRIVATE  ::  CONFIG  ::  TXADMIN_CACHE  ::  DB_BKUP_PATH  #
	#/////////////////////////////////////////////////////////////////////////////////////////#

	##########################################################################
	# ALTER AT YOUR OWN RISK -- CONFIGURABLE (TECHNICALLY, BUT UNTESTED)
	# If you change this and it doesn't work... sorry.  All up to you now!
	PRIVLY_NAME="BERP-Privly"
	CONFIG_NAME="config.json"
	REPO_NAME="BERP-Source"

	##########################################################################
	# WHO THE HECK AM I?!
	# GENERATE RUNTIME VARIABLES - NEEDS TO RUN EACH LOAD
	SCRIPT=$(echo "$0" | rev | cut -f1 -d/ | rev)
	if [ ! "$BUILD" ] ;
	then
		THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
		[[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build"
		[[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
		[[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
		unset THIS_SCRIPT_ROOT
	fi

	SCRIPT_ROOT="$(dirname $0)"
	SCRIPT_FULLPATH="$0"
	BUILD="$BUILD"

        [[ ! -d "$BUILD" ]] && \
          echo "Could not find the build folder.  It should be right here next to me..." && exit 1

	##########################################################################
	# WHERE THE HECK AM I?!!
	_whereAmI="$( echo $SCRIPT_ROOT | rev | cut -f1 -d/ | rev )"
	if [ "$_whereAmI" == "build" ];
	then
		SOURCE_ROOT="$( dirname $SCRIPT_ROOT )"
	else
		SOURCE_ROOT="$SCRIPT_ROOT"
	fi
	SOURCE_ROOT="$SOURCE_ROOT"  # I just did this to keep my structure below.  Its for me, shut up!
		SOURCE="$SOURCE_ROOT/$REPO_NAME"
		PRIVATE="$SOURCE_ROOT/$PRIVLY_NAME"
			CONFIG="$PRIVATE/$CONFIG_NAME"

	##########################################################################
	# DISCOVER DATABASE BACKUPS
	# THIS WILL FIND THE MOST RECENT BACKUP
	# NEEDS TO RUN EACH ENVIRONMENT LOAD.
	if [ -d "$DB_BKUP_PATH" ]; then
		DB="$(ls -Art $DB_BKUP_PATH/ | tail -n 1)"
		PATH_TO_DB="$DB_BKUP_PATH/$DB"
	else
		DB="null"
		PATH_TO_DB="null"
	fi
	# END DATABASE BACKUP DISCOVERY
}


check_for_config() {
	#####################################################################
	#
	# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
	##
	echo "Looking for a BERP ingest config file..."
	_CONFIG="$CONFIG"
	_valid="$(cat $_CONFIG)"
	while [ -z "$CONFIG" ]; do
	        if [ -f "$_CONFIG" ] && [ ! -z "$_valid" ] ;
                then
					echo "BERP injestion config found @ ${_CONFIG}"
					echo "Preparing BERP to be deployed..."
	                CONFIG="$_CONFIG"
					[[ ! $BUILD ]] && echo "I tried to find my config, but I ended up with it stuck in a ceiling fan." && exit 1
					. "$BUILD/quick-config.sh"
	        else
	       	        echo "No BERP ingestion config found..."
					[[ ! $BUILD ]] && echo "I tried to find my config, but I ended up with it stuck in a ceiling fan." && exit 1
					. "$BUILD/quick-config.sh" CONFIGURE					
			if [ -z "$1" ] ;
                        then
				# EXECUTION LIKELY CAME FROM DEPLOY
				echo -e "Entering quick configuration tool...\n"
				echo "Welcome to the BERP deployer!"
				echo "Let's create a new BERP injest config..."
				. "$BUILD/quick-config.sh"
			else
                        	# OTHERWISE, WE PASSED IT RUNTIME ONLY
                        	__INVALID_CONFIG__="1"
				break ;
			fi
	        fi
	done
}


import_system_config() {

	#####################################################################
	#
	# IMPORT THE DEPLOYMENT SCRIPT CONFIGURATION
	##
	echo "Reading config..."

	local ALLFIGS=( \
	SERVICE_ACCOUNT SERVICE_PASSWORD MYSQL_USER MYSQL_PASSWORD RCON RCON_PASSWORD \
	STEAM_WEBAPIKEY SV_LICENSEKEY BLOWFISH_SECRET DB_ROOT_PASSWORD RCON_PASSWORD_GEN \
    RCON_PASSWORD_LENGTH RCON_ASK_TO_CONFIRM \
	)

    # This is taking the above, appending jq_ to it... then reading it from below through the working part
    # everything found is loading into memory.  this loads all my environment variables (figs)

	jq_SERVICE_ACCOUNT=".sys.acct.user"
    jq_SERVICE_PASSWORD=".sys.acct.password"
    jq_MYSQL_USER=".sys.mysql.user"
    jq_MYSQL_PASSWORD=".sys.mysql.password"
    jq_DB_ROOT_PASSWORD=".sys.mysql.rootPassword"
    jq_RCON=".sys.rcon.pref.enable"
    jq_RCON_PASSWORD=".sys.rcon.password"
    jq_RCON_PASSWORD_GEN=".sys.rcon.pref.randomlyGenerate"
    jq_RCON_PASSWORD_LENGTH=".sys.rcon.pref.length"
    jq_RCON_ASK_TO_CONFIRM=".sys.rcon.pref.confirm"
    jq_BLOWFISH_SECRET=".sys.php.blowfishSecret"
    jq_SV_LICENSEKEY=".sys.keys.fivemLicenseKey"
    jq_STEAM_WEBAPIKEY=".sys.keys.steamWebApiKey"


	read_figs "${ALLFIGS[@]}"

	# TEMPORARY FOR COMPATABIBLITY (CONVERTING THESE TO UPPERS)
	srvPassword="$SERVICE_PASSWORD" # ditto.
	mysql_user="$MYSQL_USER" # i'm not going to continue typing ditto.
	mysql_password="$MYSQL_PASSWORD"
	steam_webApiKey="$STEAM_WEBAPIKEY"
	sv_licenseKey="$SV_LICENSEKEY"
	blowfish_secret="$BLOWFISH_SECRET"
	rcon_password="$RCON_PASSWORD"
	DBPSWD="$DB_ROOT_PASSWORD" # this one just needs to be more litteral
    ASK_TO_CONFIRM="$RCON_ASK_TO_CONFIRM"

}

import_env_config() {

	local ALLFIGS=( \
	SERVER_NAME ARTIFACT_BUILD REPO_NAME SOURCE_ROOT SOURCE TXADMIN_BACKUP \
    DB_BACKUPS SOFTWARE_ROOT TFIVEM TCCORE MAIN GAME RESOURCES GAMEMODES \
    MAPS ESX ESEX ESUI ESSENTIAL ESMOD VEHICLES TXADMIN_BACKUP_FOLDER DB_BACKUP_FOLDER \
    ) ;

	# .pref
	jq_SERVER_NAME=".pref.serverName"
	jq_ARTIFACT_BUILD=".pref.artifactBuild"
	jq_REPO_NAME=".pref.repoName"

	# .env
	jq_SOURCE_ROOT=".env.sourceRoot"
	jq_SOURCE=".env.source"

    # .env.private
	jq_TXADMIN_BACKUP=".env.private.txadminCache"
	jq_TXADMIN_BACKUP_FOLDER=".env.private.txadminCacheFolder"	
	jq_DB_BACKUPS=".env.private.dbBkupPath"
	jq_DB_BACKUP_FOLDER=".env.private.dbBkupFolder"

	# .env.software
	jq_SOFTWARE_ROOT=".env.software.softwareRoot"
	jq_TFIVEM=".env.software.tfivem"
	jq_TCCORE=".env.software.tccore"

	# .env.install
	jq_MAIN=".env.install.main"
	jq_GAME=".env.install.game"
	jq_RESOURCES=".env.install.resources"
	jq_GAMEMODES=".env.install.gamemodes"
	jq_MAPS=".env.install.maps"
	jq_ESX=".env.install.esx"
	jq_ESEX=".env.install.esext"
	jq_ESUI=".env.install.esui"
	jq_ESSENTIAL=".env.install.essential"
	jq_ESMOD=".env.install.esmod"
	jq_VEHICLES=".env.install.vehicles"

	read_figs "${ALLFIGS[@]}"

	
	# TEMPORARY FOR COMPATABILITY
	DB_BKUP_PATH="$DB_BACKUPS"
	TXADMIN_CACHE="$TXADMIN_BACKUP"
	artifact_build="$ARTIFACT_BUILD"

}

# READS IN MY CONFIGURATION
read_figs() {
#	for _fig in "${ALLFIGS[@]}";
    for _fig in "$@";
    do
	[[ ! "$CONFIG" ]] && echo "no config found by read_figs()... exiting" && exit 1

            echo -n "Importing ${_fig} configuration"
                if [ -z "${!_fig}" ];
                then
                        local _jq="$(eval echo \$jq_${_fig})"
                        local _jsData="$(jq -r $_jq $CONFIG)"

			[[ "$__invalid__" ]] && unset __invalid__

			[[ "$_jsData" == "null" ]] && local __invalid__="1"
			[[ -z "$_jsData" ]] && local __invalid__="1"

			[[ -z "$__invalid__" ]] && printf -v "$_fig" '%s' "${_jsData}"
			[[ "$__invalid__" ]] && unset __invalid__
                        unset _jsData ; unset _jq

			color yellow - bold
                        [[ "$__TEST__" ]] && [[ "${!_fig}" ]] && local __val="${!_fig}" || local __val="\"\""
			[[ "$__TEST__" ]] &&  echo -e -n " => $_fig == $__val => "; unset __val || echo -e -n "... " # DO OR DO NOT DISPLAY ON SCREEN
			color - - clearAll

                fi

                if [ ! -z "${!_fig}" ];
                then
                        color green - bold
                        echo "Done."
                        color - - clearAll
                else
                        color red - bold
                        echo "Nothing set!"
                        color - - clearAll
                fi
        done
        echo ""
}
