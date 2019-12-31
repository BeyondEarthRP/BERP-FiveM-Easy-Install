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
	##########################################################################
	# ALTER AT YOUR OWN RISK -- CONFIGURABLE (TECHNICALLY, BUT UNTESTED)
	# If you change this and it doesn't work... sorry.  All up to you now!
	PRIVLY_NAME="BERP-Privly"
	CONFIG_NAME="config.json"
	REPO_NAME="BERP-Source"

	##########################################################################
	# WHO THE HECK AM I?!
	# GENERATE RUNTIME VARIABLES - NEEDS TO RUN EACH LOAD
	if [ ! "$BUILD" ] ;
	then
		THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
		[[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build"
		[[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
		[[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
		unset THIS_SCRIPT_ROOT
	fi

        if [ ! -z "$BUILD" ] ;
	then
		SCRIPT=$(echo "$0" | rev | cut -f1 -d/ | rev)
		SCRIPT_FULLPATH="$(readlink -f $0)"
		SCRIPT_ROOT="$(dirname $(readlink -f ${BUILD}))"

		FIGTREE="${BUILD}/figtree.json"  && touch "$FIGTREE"
	else
        	echo "Could not find the build folder.  It should be right here next to me..."
		exit 1
	fi

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
	if [ -d "$DB_BACKUPS" ]; then
		DB="$(ls -Art $DB_BACKUPS/ | tail -n 1)"
		DB_BACKUPS="$DB_BACKUPS/$DB"
	else
		DB="null"
		DB_BACKUPS="null"
	fi
	# END DATABASE BACKUP DISCOVERY
}


check_for_config() {
	#####################################################################
	#
	# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
	##
	[[ ! "$APPMAIN" == "MAIN" ]] && echo "Looking for a BERP ingestion config file..."
	_CONFIG="$CONFIG" ; unset CONFIG
	[[ -f "$_CONFIG" ]] && _valid="$(cat $_CONFIG)"
	while [ -z "$CONFIG" ]; do
	        if [ -f "$_CONFIG" ] && [ ! -z "$_valid" ] ;
                then
			__status="BERP injestion config found @ ${_CONFIG}"
			[[ ! "$APPMAIN" == "MAIN" ]] && echo __status && echo "Preparing to deploy BERP..."

			CONFIG="$_CONFIG"

			[[ ! "$APPMAIN" == "MAIN" ]] && [[ ! "$BUILD" ]] && echo "I tried to find my config, but I ended up with it stuck in a ceiling fan." && exit 1
			#[[ "$APPMAIN" == "MAIN" ]] && . "$BUILD/quick-config.sh"
	        else
			color lightYellow - bold
	       	        echo "no BERP ingestion config... starting configurator!"
			color - - clearAll

			__status="NO_CONFIG"

			[[ ! "$APPMAIN" == "MAIN" ]] && [[ ! "$BUILD" ]] && echo "I tried to find my config, but I ended up with it stuck in a ceiling fan." && exit 1

			[[ "$APPMAIN" == "TEST-CONFIGURES" ]] && . "$BUILD/quick-config.sh" CONFIGURE
			if [ "$APPMAIN" == "MAIN" ] && [ ! "$1" ] ;
                        then
				# EXECUTION CAME FROM DEPLOY
				echo -e "Entering quick configuration tool...\n"
				echo -e "Welcome to the BERP deployer!"
				echo -e "Let's create a new BERP injest config..."
				[[ "$APPMAIN" == "MAIN" ]] && . "$BUILD/quick-config.sh" CONFIGURE
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
	SERVICE_ACCOUNT SERVICE_PASSWORD MYSQL_USER MYSQL_PASSWORD RCON_ENABLE RCON_PASSWORD \
	STEAM_WEBAPIKEY SV_LICENSEKEY BLOWFISH_SECRET DB_ROOT_PASSWORD RCON_PASSWORD_GEN \
	RCON_PASSWORD_LENGTH RCON_ASK_TO_CONFIRM \
	) ;

	# This is taking the above, appending jq_ to it... then reading it from below through the working part
	# everything found is loading into memory.  this loads all my environment variables (figs)

	jq_SERVICE_ACCOUNT=".sys.acct.user"
	jq_SERVICE_PASSWORD=".sys.acct.password"
	jq_MYSQL_USER=".sys.mysql.user"
	jq_MYSQL_PASSWORD=".sys.mysql.password"
	jq_DB_ROOT_PASSWORD=".sys.mysql.rootPassword"
	jq_RCON_ENABLE=".sys.rcon.enable"
	jq_RCON_PASSWORD=".sys.rcon.password"
	jq_RCON_PASSWORD_GEN=".sys.rcon.pref.randomlyGenerate"
	jq_RCON_PASSWORD_LENGTH=".sys.rcon.pref.length"
	jq_RCON_ASK_TO_CONFIRM=".sys.rcon.pref.confirm"
	jq_BLOWFISH_SECRET=".sys.php.blowfishSecret"
	jq_SV_LICENSEKEY=".sys.keys.fivemLicenseKey"
	jq_STEAM_WEBAPIKEY=".sys.keys.steamWebApiKey"

	read_figs "${ALLFIGS[@]}"
}

import_env_config() {

	local ALLFIGS=( \
	SERVER_NAME ARTIFACT_BUILD REPO_NAME SOURCE_ROOT SOURCE TXADMIN_BACKUP \
	DB_BACKUPS SOFTWARE_ROOT TFIVEM TCCORE MAIN GAME RESOURCES GAMEMODES \
	MAPS ESX ESEXT ESUI ESSENTIAL ESMOD VEHICLES TXADMIN_BACKUP_FOLDER DB_BACKUP_FOLDER \
	) ;

	# .pref
	jq_SERVER_NAME=".pref.serverName"
	jq_ARTIFACT_BUILD=".pref.artifactBuild"
	jq_REPO_NAME=".pref.repoName"

	# .env
	jq_SOURCE_ROOT=".env.sourceRoot"
	jq_SOURCE=".env.source"

	# .env.private
	jq_TXADMIN_BACKUP=".env.private.txadminBackup"
	jq_TXADMIN_BACKUP_FOLDER=".env.private.txadminBackupFolder"
	jq_DB_BACKUPS=".env.private.dbBackups"
	jq_DB_BACKUP_FOLDER=".env.private.dbBackupFolder"

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
	jq_ESEXT=".env.install.esext"
	jq_ESUI=".env.install.esui"
	jq_ESSENTIAL=".env.install.essential"
	jq_ESMOD=".env.install.esmod"
	jq_VEHICLES=".env.install.vehicles"

	read_figs "${ALLFIGS[@]}"

	artifact_build="$ARTIFACT_BUILD"

}

# READS IN MY CONFIGURATION
read_figs() {
    __CONFIG_UNFINISHED__=()
    for _fig in "$@";
    do
	[[ ! "$CONFIG" ]] && echo "no config found by read_figs()... exiting" && exit 1

            echo -n "Importing ${_fig} configuration"
                if [ -z "${!_fig}" ];
                then
                        local _jq="$(eval echo \$jq_${_fig})"
                        local _jsData="$(jq -r $_jq $CONFIG)"

			[[ "$__invalid__" ]] && unset __invalid__

			[[ "$_jsData" == "null" ]] && __invalid__="1"
			[[ -z "$_jsData" ]] && __invalid__="1"
			[[ ! "$_jsData" ]] && __invalid__="1"

			[[ "$__invalid__" ]] && __CONFIG_UNFINISHED__+=("$_fig")
			[[ "$__invalid__" ]] && unset __invalid__


			[[ ! "$__invalid__" ]] && printf -v "$_fig" '%s' "${_jsData}"
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
			#unset "${!_fig}"
                        color - - clearAll
                fi
        done
        echo ""
}
