#!/bin/bash
# -ex
#\
#>\___________________
#>> THESE ARE MINE
#>>>>>>>>>>>>>>>>>>>>>
# FUNCTIONS TO BUILD OUT THE RUN TIME ENVIRONMENT
initialize() {
  [[ "$1" == "QUIETLY" ]] && loading 1 || echo "Initializing..."
  ####
  # THIS BIT IS NEEDED TO GET THE JSON CONFIG TO WORK
  jqGreet=$( dpkg-query -W -f='${Version}\n' jq ) # check for jq
  if [ -z "$jqGreet" ]; then # if not found
    apt update && apt -y upgrade && apt -y install jq # install it!
  fi
  jqGreet=$( dpkg-query -W -f='${Version}\n' jq ) # check for jq
  if [ -z "$jqGreet" ]; then # if not found
	echo "Failed to discover jq and the installation attempt also failed."
  fi
}

define_runtime_env() {
	[[ "$1" != "QUIETLY" ]] && echo "Generating runtime environment..."
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
	if [ -d "$DB_BACKUPS" ];
	then
		DB="$(ls -Art $DB_BACKUPS/ | tail -n 1)"
		DB_BACKUPS="$DB_BACKUPS/$DB"
	else
		DB="null"
		DB_BACKUPS="null"
	fi
	# END DATABASE BACKUP DISCOVERY

	__RUNTIME__="1"
}


check_configuration() {
	#####################################################################
	#
	# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
	##
	[[ -z "__RUNTIME__" ]] && echo "runtime environment not loaded. failed!" && exit 1
	[[ "$1" != "QUIETLY" ]] && echo "Looking for a configuration..."

	local _content=$(cat "$CONFIG" 2> /dev/null)
	if [ -n "$CONFIG" ] && [ -f "$CONFIG" ] && [ -n "$_content" ] ;
	then
		__CONFIG__="Config file defined."
		if [ -f "$CONFIG" ] ;
        	then
			__CONFIG__="Config file identified in file system."
			if [ -z "${_content}" ] ;
			then
				rm "$CONFIG" && unset __CONFIG__
				__INVALID_CONFIG__="Zero length config discovered"
				[[ "$1" != "QUIETLY" ]] && echo "$__INVALID_CONFIG__"

			else
				__CONFIG__="Configuration discovered @ ${CONFIG}"
				unset __INVALID_CONFIG__
			        [[ "$1" != "QUIETLY" ]] && echo "$__CONFIG__"
			fi
	        else
			unset __CONFIG__
                      	__INVALID_CONFIG__="No configuration file was discovered..."
		        [[ "$1" != "QUIETLY" ]] && echo "$__INVALID_CONFIG__"
	        fi
	else
		unset __CONFIG__
                __INVALID_CONFIG__="No configuration file defined..."
                [[ "$1" != "QUIETLY" ]] && echo "$__INVALID_CONFIG__"

	fi
	unset _content
}


collect_figs() {
	[[ "$1" != "QUIETLY" ]] && echo -e "\nCollecting configuration..."
	#####################################################################
	#
	# IMPORT THE DEPLOYMENT SCRIPT CONFIGURATION
	##

	BELCH_TITLE="B.E.R.P Belcher (FiveM Deployment Tool by Beyond Earth)"
	BELCH_VERSION="version 1.0"
	INSTALL_DATE="${_INSTALL_DATE:=$(date '+%d/%m/%Y %H:%M:%S')}"
	CONFIG_TIMESTAMP="${_CONFIG_TIMESTAMP:=$(date '+%d/%m/%Y %H:%M:%S')}"


	local ALLFIGS=(                                                               \
		BELCH_TITLE             BELCH_VERSION           INSTALL_DATE          \
		SERVICE_ACCOUNT         SERVICE_PASSWORD        MYSQL_USER            \
		MYSQL_PASSWORD          RCON_ENABLE             RCON_PASSWORD         \
		STEAM_WEBAPIKEY         SV_LICENSEKEY           BLOWFISH_SECRET       \
		DB_ROOT_PASSWORD        RCON_PASSWORD_GEN       RCON_PASSWORD_LENGTH  \
                RCON_ASK_TO_CONFIRM     SERVER_NAME             ARTIFACT_BUILD        \
		REPO_NAME SOURCE_ROOT   SOURCE TXADMIN_BACKUP   DB_BACKUPS            \
		SOFTWARE_ROOT           TFIVEM                  TCCORE                \
		MAIN                    GAME                    RESOURCES             \
		GAMEMODES               MAPS                    ESX                   \
		ESEXT                   ESUI                    ESSENTIAL             \
		ESMOD                   VEHICLES                TXADMIN_BACKUP_FOLDER \
		DB_BACKUP_FOLDER        CONFIG_TIMESTAMP                              \
	) ;

	identify_branches
	load_static_defaults
	[[ "$1" == "QUIETLY" ]] && __QUIET_MODE__="1"
	read_figs "${ALLFIGS[@]}"
	[[ "$1" == "QUIETLY" ]] && unset __QUIET_MODE__
	load_user_defaults
}

identify_branches() {
	# .sys
	jq_BELCH_TITLE=".sys.belch"
	jq_BELCH_VERSION=".sys.version"
	jq_INSTALL_DATE=".sys.installed"
	jq_CONFIG_TIMESTAMP=".sys.configTimestamp"

	# .sys.acct
	jq_SERVICE_ACCOUNT=".sys.acct.user"
	jq_SERVICE_PASSWORD=".sys.acct.password"

	# .sys.mysql
	jq_MYSQL_USER=".sys.mysql.user"
	jq_MYSQL_PASSWORD=".sys.mysql.password"
	jq_DB_ROOT_PASSWORD=".sys.mysql.rootPassword"

	# .sys.rcon
	jq_RCON_ENABLE=".sys.rcon.enable"
	jq_RCON_PASSWORD=".sys.rcon.password"
	jq_RCON_PASSWORD_GEN=".sys.rcon.pref.randomlyGenerate"
	jq_RCON_PASSWORD_LENGTH=".sys.rcon.pref.length"
	jq_RCON_ASK_TO_CONFIRM=".sys.rcon.pref.confirm"

	# .sys.php
	jq_BLOWFISH_SECRET=".sys.php.blowfishSecret"

	# .sys.keys
	jq_SV_LICENSEKEY=".sys.keys.fivemLicenseKey"
	jq_STEAM_WEBAPIKEY=".sys.keys.steamWebApiKey"

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
}

# READS IN MY CONFIGURATION
read_figs() {
	__CONFIG_UNFINISHED__=()
	for _fig in "$@" ;
	do
		hush=( 										\
			BELCH_TITLE	BELCH_VERSION	INSTALL_DATE	CONFIG_TIMESTAMP 	\
		) ;

		# hush the above figs from displaying on screen (they are always set)
		[[ "${hush[@]}" =~ "${_fig}" ]] && local __SILENT__="1" || unset __SILENT__

		if [ -z "$__SILENT__" ] && [ -z "$__QUIET_MODE__" ] ;
		then
			color white - bold
			[[ -f "$CONFIG" ]] && echo -n "Importing ${_fig} configuration"
			color - - clearAll
		fi

		[[ -n "$__QUIET_MODE__" ]] && loading 1 CONTINUE

                if [ -z "${!_fig}" ];
                then
			# identify branch name
                        local _jq="$(eval echo \$jq_${_fig})"

			[[ "$__INVALID__" ]] && unset __INVALID__  # CYA- PROBABLY REDUNDANT

			# if config is not defined, skip this and data is invalid
                        [[ ! -f "$CONFIG" ]] && __INVALID__="1" || local _jsData="$(jq -r $_jq $CONFIG)"

			# if data is null or blank, it is invalid
			[[ "$_jsData" == "null" ]] || [[ -z "$_jsData" ]] && __INVALID__="1"

			# track invalid figs in __CONFIG_UNFINISHED__ or write the configuration
			[[ -n "$__INVALID__" ]] && __CONFIG_UNFINISHED__+=("$_fig") || printf -v "$_fig" '%s' "${_jsData}"

                fi

		if [ -z "$__SILENT__" ] && [ -z "$__QUIET_MODE__" ] ;  # If this fig is not hushed
		then
			color white - bold
                        [[ "$__TEST__" ]] && [[ "${!_fig}" ]] && local __val="${!_fig}" || local __val="\"\""
			[[ "$__TEST__" ]] &&  echo -e -n " => $_fig == $__val => " && unset __val \
			  || [[ -f "$CONFIG" ]] && echo -e -n "... " # DO OR DO NOT DISPLAY ON SCREEN
			color - - clearAll
	                if [ ! -z "${!_fig}" ];
	                then
	                        color green - bold
	                        [[ -f "$CONFIG" ]] && echo "Done."
	                        color - - clearAll
	                else
	                        color red - bold
	                        [[ -f "$CONFIG" ]] && echo "Nothing set!"
	                        color - - clearAll
	                fi
		fi	# OTHERWISE, THIS FIGLET IS ALWAYS SET AT LOAD AND (AS SUCH) IS SILENT AT LOAD

		unset __LOAD_QUIETLY__ ; unset __SILENT__ ; unset __INVALID__ ; unset _jsData ; unset _jq # clean up
        done
}
