#!/bin/bash

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# INITIALIZE JQ (REQUIRED DEPENDANCY)
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
###############################################################################################
#-----[ ECO SYSTEM ]-----######################################################################

load_static_defaults() {
#################################################################
# DEFAULTS
	_SERVICE_ACCOUNT="fivem"
	_MYSQL_USER="admin"

	_STEAM_WEBAPIKEY=""
	_SV_LICENSEKEY=""

	_RCON="true"
	_RCON_PASSWORD_GEN="true"
	_RCON_PASSWORD_LENGTH="64"
	_RCON_ASK_TO_CONFIRM="false"

	_TXADMIN_BACKUP_FOLDER="data-txadmin"
	_DB_BACKUP_FOLDER="data-mysql"
	_ARTIFACT_BUILD="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"
	_SOFTWARE_ROOT="/var/software"
	_REPO_NAME="BERP-Source"

	_SERVER_NAME="Beyond Earth Roleplay (BERP)"
	
	_BELCH_TITLE="B.E.R.P Belcher (FiveM Deployment Tool by Beyond Earth)"
	_BELCH_VERSION="version 1.0"
}

load_user_defaults() {

	# PASSWORDS REMOVED FROM DEFAULTS (YOU CAN ADD THEM IF YOU LIKE
	
	INCLUDE_PASSWORDS="false"  # I WOULDN'T, BUT YOUR CALL.
	
	[[ "$INCLUDE_PASSWORDS"="false" ]] || [[ -z "$INCLUDE_PASSWORDS" ]] 	&&	\
	local DEFFIGS=(																\
		SERVICE_ACCOUNT         MYSQL_USER				RCON_ENABLE				\
		STEAM_WEBAPIKEY         SV_LICENSEKEY			DB_BACKUP_FOLDER		\
		RCON_PASSWORD_GEN       RCON_PASSWORD_LENGTH							\
		RCON_ASK_TO_CONFIRM     SERVER_NAME             ARTIFACT_BUILD			\
		REPO_NAME				SOURCE_ROOT				SOURCE					\
		TXADMIN_BACKUP			DB_BACKUPS										\
		SOFTWARE_ROOT           TFIVEM                  TCCORE					\
		MAIN                    GAME                    RESOURCES				\
		GAMEMODES               MAPS                    ESX						\
		ESEXT                   ESUI                    ESSENTIAL				\
		ESMOD                   VEHICLES                TXADMIN_BACKUP_FOLDER	\
		REVIEW_CONFIGS			SHOW_ADVANCED									\
	) ;
	
	[[ "$INCLUDE_PASSWORDS"="true" ]] 										&& 	\
	local DEFIGS=(																\
		SERVICE_ACCOUNT         SERVICE_PASSWORD        MYSQL_USER				\
		MYSQL_PASSWORD          RCON_ENABLE             RCON_PASSWORD			\
		STEAM_WEBAPIKEY         SV_LICENSEKEY           BLOWFISH_SECRET			\
		DB_ROOT_PASSWORD        RCON_PASSWORD_GEN       RCON_PASSWORD_LENGTH	\
		RCON_ASK_TO_CONFIRM     SERVER_NAME     		ARTIFACT_BUILD			\
		REPO_NAME 				SOURCE_ROOT   			SOURCE					\
		SOFTWARE_ROOT           TFIVEM                  TCCORE					\
		MAIN                    GAME                    RESOURCES				\
		GAMEMODES               MAPS                    ESX						\
		ESEXT                   ESUI                    ESSENTIAL				\
		ESMOD                   VEHICLES                TXADMIN_BACKUP_FOLDER	\
		TXADMIN_BACKUP			DB_BACKUP_FOLDER        DB_BACKUPS				\
		REVIEW_CONFIGS			SHOW_ADVANCED									\
	) ;
		

	for _deffig in "${DEFFIGS[@]}" ;
	do
		if [ -n "${!_deffig}" ] ;
		 then
			#echo "Loading ${_deffig} => ${!_deffig}"
			local _defname="$(echo _${_deffig})"
			printf -v "$_defname" '%s' "${!_deffig}"
		fi
	done

}

collect_figs() {
	[[ "$1" != "QUIETLY" ]] && echo -e "\nCollecting configuration..."
	#####################################################################
	#
	# IMPORT THE DEPLOYMENT SCRIPT CONFIGURATION
	##

	_INSTALL_DATE="${_INSTALL_DATE:=$(date '+%d/%m/%Y %H:%M:%S')}"
	_CONFIG_TIMESTAMP="${_CONFIG_TIMESTAMP:=$(date '+%d/%m/%Y %H:%M:%S')}"


	local ALLFIGS=(																\
		BELCH_TITLE             BELCH_VERSION           INSTALL_DATE			\
		SERVICE_ACCOUNT         SERVICE_PASSWORD        MYSQL_USER				\
		MYSQL_PASSWORD          RCON_ENABLE             RCON_PASSWORD			\
		STEAM_WEBAPIKEY         SV_LICENSEKEY           BLOWFISH_SECRET			\
		DB_ROOT_PASSWORD        RCON_PASSWORD_GEN       RCON_PASSWORD_LENGTH	\
        RCON_ASK_TO_CONFIRM     SERVER_NAME     		ARTIFACT_BUILD			\
		REPO_NAME 				SOURCE_ROOT   			SOURCE					\
		SOFTWARE_ROOT           TFIVEM                  TCCORE					\
		MAIN                    GAME                    RESOURCES				\
		GAMEMODES               MAPS                    ESX						\
		ESEXT                   ESUI                    ESSENTIAL				\
		ESMOD                   VEHICLES                TXADMIN_BACKUP_FOLDER	\
		TXADMIN_BACKUP			DB_BACKUP_FOLDER        DB_BACKUPS				\
		CONFIG_TIMESTAMP		REVIEW_CONFIGS			SHOW_ADVANCED			\
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
	jq_REVIEW_CONFIGS=".pref.reviewConfigs"
	jq_SHOW_ADVANCED=".pref.showAdvancedOptions"

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

#-----[ ECO SYSTEM ]-----######################################################################
###############################################################################################

###############################################################################################
#-----[ CONFIGURES ]-----######################################################################

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

harvest() {
	# COLLECT ALL FIGS FROM USER AND PREPARE TO WRITE

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
	# FIG  dialog:default/display random MIN  MAX #
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

	load_static_defaults
	load_user_defaults

	[[ "$_all_new_" ]] && unset _all_new_ ; _all_new_=()

	PROMPT="Would you like to see advanced configuration options? (probably not)"
	pluck_fig "SHOW_ADVANCED" 11 false
	_all_new_+=("SHOW_ADVANCED")

	# SERVER_NAME
	if [ "$__CONFIGURE__" ] || [ -z "$SERVER_NAME" ] ;
	then
		PROMPT="What would you like to name the FiveM server?"
		pluck_fig "SERVER_NAME" 0
		_all_new_+=("SERVER_NAME")
	fi

	# SERVICE ACCOUNT
	if [ "$__CONFIGURE__" ] || [ -z "$SERVICE_ACCOUNT" ] ;
	then
		PROMPT="Enter the linux account to be used for FiveM"
		pluck_fig "SERVICE_ACCOUNT" "0" -
		_all_new_+=("SERVICE_ACCOUNT")
	fi
        [[ -z "$MAIN" ]] &&  MAIN="/home/${SERVICE_ACCOUNT}" && _all_new_+=("MAIN")
        [[ -z "$GAME" ]] &&  GAME="${MAIN}/server-data" && _all_new_+=("GAME")
        [[ -z "$RESOURCES" ]] &&  RESOURCES="${GAME}/resources" && _all_new_+=("RESOURCES")
        [[ -z "$GAMEMODES" ]] &&  GAMEMODES="${RESOURCES}/[gamemodes]" && _all_new_+=("GAMEMODES")
        [[ -z "$MAPS" ]] &&  MAPS="${GAMEMODES}/[maps]" && _all_new_+=("MAPS")
        [[ -z "$ESX" ]] &&  ESX="${RESOURCES}/[esx]" && _all_new_+=("ESX")
        [[ -z "$ESEXT" ]] &&  ESEXT="${ESX}/es_extended" && _all_new_+=("ESEXT")
        [[ -z "$ESUI" ]] &&  ESUI="${ESX}/[ui]" && _all_new_+=("ESUI")
        [[ -z "$ESSENTIAL" ]] &&  ESSENTIAL="${RESOURCES}/[essential]" && _all_new_+=("ESSENTIAL")
        [[ -z "$ESMOD" ]] &&  ESMOD="${ESSENTIAL}/essentialmode" && _all_new_+=("ESMOD")
        [[ -z "$VEHICLES" ]] &&  VEHICLES="${RESOURCES}/[vehicles]" && _all_new_+=("VEHICLES")

	# SERVICE_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$SERVICE_PASSWORD" ] ;
	then
		PROMPT=$(echo "Enter a password for '$SERVICE_ACCOUNT' service account")
		pluck_fig "SERVICE_PASSWORD" "s:n/y" true 9
		_all_new_+=("SERVICE_PASSWORD")
	fi

	# DB_ROOT_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$DB_ROOT_PASSWORD" ] ;
	then
		PROMPT="Enter a password for the MySQL 'root' account"
		pluck_fig "DB_ROOT_PASSWORD" "s:n/y" true 16
		_all_new_+=("DB_ROOT_PASSWORD")
	fi

	# MYSQL_USER
	if [ "$__CONFIGURE__" ] || [ -z "$MYSQL_USER" ] ;
	then
		echo -e "\e[91mThis should never be set to 'root' (it may not even work that way)\e[0m\n"
		PROMPT="Enter a username for MySQL, that will own the essentialmode database"
		pluck_fig "MYSQL_USER" "0" 0
		_all_new_+=("MYSQL_USER")
	fi

	# MYSQL_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$MYSQL_PASSWORD" ] ;
	then
		PROMPT=$(echo "Enter a password for '$MYSQL_USER' to access MySQL")
		pluck_fig "MYSQL_PASSWORD" "s:n/y" true 16 128
		_all_new_+=("MYSQL_PASSWORD")
	fi

	# BLOWFISH_SECRET
	if [ "$__CONFIGURE__" ] || [ -z "$BLOWFISH_SECRET" ] ;
	then
		PROMPT="Enter a Blowfish Secret for the PHP config"
		pluck_fig "BLOWFISH_SECRET" "s:n/y" true 16
		_all_new_+=("BLOWFISH_SECRET")
	fi

	# STEAM_WEBAPIKEY
	if [ "$__CONFIGURE__" ] || [ -z "$STEAM_WEBAPIKEY" ] ;
	then
		PROMPT="Enter your Steam Web-API key"
		pluck_fig "STEAM_WEBAPIKEY" 0 false
		_all_new_+=("STEAM_WEBAPIKEY")
	fi

	# SV_LICENSEKEY
	if [ "$__CONFIGURE__" ] || [ -z "$SV_LICENSEKEY" ] ;
	then
		PROMPT="Enter your Cfx FiveM license key"
		pluck_fig "SV_LICENSEKEY" 0 false
		_all_new_+=("SV_LICENSEKEY")
	fi

	##########################################################################################
	# RCON DETAILS
	## THESE ARE NOT SETTINGS TO BE CHANGED- DOING SO WILL VOID THE MANUFACTURERS WARRANTY!

	# RCON
	if [ "$__CONFIGURE__" ] || [ -z "$RCON_ENABLE" ] ;
	then
		PROMPT="Enable RCON (probably not needed)?"
		pluck_fig "RCON_ENABLE" 10 false
		_all_new_+=("RCON_ENABLE")
	fi
	if [ "$RCON_ENABLE" == "true" ] ;
        then
		# RCON_PASSWORD_GEN
		if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD_GEN" ] ;
		then
			PROMPT="(recommended) Allow RCON Passwords to be randomly generated?"
			pluck_fig "RCON_PASSWORD_GEN" 10 false
			_all_new_+=("RCON_PASSWORD_GEN")
		fi
		if [ "$RCON_PASSWORD_GEN" == "true" ] ;
		then

			if [ "$SHOW_ADVANCED" == "true" ] ;
			then
				# RCON_PASSWORD_LENGTH
				if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD_LENGTH" ] ;
				then
					PROMPT="Number of characters to generate?"
					pluck_fig "RCON_PASSWORD_LENGTH" 20 false 20 128
					_all_new_+=("RCON_PASSWORD_LENGTH")
				fi
			else
				[ -z "$RCON_PASSWORD_LENGTH" ] && RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH" && _all_new_+=("RCON_PASSWORD_LENGTH")
			fi

			# RCON_ASK_TO_CONFIRM
			if [ "$__CONFIGURE__" ] || [ -z "$RCON_ASK_TO_CONFIRM" ] ;
			then
				PROMPT="(not recommended) Require manual approval of each randomly generated password"
				pluck_fig "RCON_ASK_TO_CONFIRM" 11 false
				_all_new_+=("RCON_ASK_TO_CONFIRM")

			fi

			RCON_PASSWORD="random"
			_all_new_+=("RCON_PASSWORD")

		else
	                RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH"
	                RCON_ASK_TO_CONFIRM="$_RCON_ASK_TO_CONFIRM"

			# RCON_PASSWORD
			if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD" ] ;
			then
				PROMPT="Enter the password for RCON access:"
				pluck_fig "RCON_PASSWORD" "s:n/y" true 30 128
				_all_new_+=("RCON_PASSWORD")
			fi
	        fi
	else  # RCON_ENABLE=false
		[ -z "$RCON_PASSWORD_GEN" ] && RCON_PASSWORD_GEN="$_RCON_PASSWORD_GEN" && _all_new_+=("RCON_PASSWORD_GEN")
		[ -z "$RCON_PASSWORD_LENGTH" ] && RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH" && _all_new_+=("RCON_PASSWORD_LENGTH")
		[ -z "$RCON_ASK_TO_CONFIRM" ] && RCON_ASK_TO_CONFIRM="$_RCON_ASK_TO_CONFIRM" && _all_new_+=("RCON_ASK_TO_CONFIRM")
	fi

	# TXADMIN_BACKUP_FOLDER
	if [ "$__CONFIGURE__" ] || [ -z "$TXADMIN_BACKUP_FOLDER" ] ;
	then
		PROMPT="Did you want an option to review changes to config.json before commiting them?"
		pluck_fig "REVIEW_CONFIGS" 11
		_all_new_+=("REVIEW_CONFIGS")

	fi

	if [ "$SHOW_ADVANCED" == "true" ] ;
	then
		# TXADMIN_BACKUP_FOLDER
		if [ "$__CONFIGURE__" ] || [ -z "$TXADMIN_BACKUP_FOLDER" ] ;
		then
			PROMPT="What name would you like for the txAdmin backup folder?"
			pluck_fig "TXADMIN_BACKUP_FOLDER" 0
			_all_new_+=("TXADMIN_BACKUP_FOLDER")

		fi

		# DB_BACKUP_FOLDER
		if [ "$__CONFIGURE__" ] || [ -z "$DB_BACKUP_FOLDER" ] ;
		then
			PROMPT="What name would you like for the MySQL backup folder?"
			pluck_fig "DB_BACKUP_FOLDER" "s:y/n"
			_all_new_+=("DB_BACKUP_FOLDER")
		fi

		# ARTIFACT_BUILD
		if [ -n "$__CONFIGURE__" ] || [ -z "$ARTIFACT_BUILD" ] ;
		then
			printf "\n" ; color red - bold ; color - - underline
			echo -e -n "**ONLY DO THIS IF YOU KNOW HOW! OTHERWISE, JUST HIT ENTER**\e[0m\n\n"
			color white - bold ; echo -e "What CFX Artifact Build would you like to use?" ; color - - clearAll

			PROMPT="Enter CFX Build Artifact"
			pluck_fig "ARTIFACT_BUILD" 0
			_all_new_+=("ARTIFACT_BUILD")
		fi

		# SOFTWARE_ROOT
		if [ "$__CONFIGURE__" ] || [ -z "$SOFTWARE_ROOT" ] ;
		then
			printf "\n" ; color yellow - bold ; color - - underline
			echo -e -n "NOTE: This is not the repo.  It's essentially just a cache of temporary downloads.\e[0m\n\n"

			PROMPT="Where would you like to store the downloaded files?"
			pluck_fig "SOFTWARE_ROOT" 0
			_all_new_+=("SOFTWARE_ROOT")
		fi


		# REPO_NAME
		if [ "$__CONFIGURE__" ] || [ -z "$REPO_NAME" ] ;
		then
			PROMPT="What would you like to name the B.E.R.P. Source Repository?"
			pluck_fig "REPO_NAME" 0
			_all_new_+=("REPO_NAME")
		fi
	else
		[ -z "$TXADMIN_BACKUP_FOLDER" ] && TXADMIN_BACKUP_FOLDER="$_TXADMIN_BACKUP_FOLDER" && _all_new_+=("TXADMIN_BACKUP_FOLDER")
		[ -z "$DB_BACKUP_FOLDER" ] && DB_BACKUP_FOLDER="$_DB_BACKUP_FOLDER" &&  _all_new_+=("DB_BACKUP_FOLDER")
		[ -z "$ARTIFACT_BUILD" ] && ARTIFACT_BUILD="$_ARTIFACT_BUILD" &&  _all_new_+=("ARTIFACT_BUILD")
		[ -z "$SOFTWARE_ROOT" ] && SOFTWARE_ROOT="$_SOFTWARE_ROOT" &&  _all_new_+=("SOFTWARE_ROOT")
		[ -z "$REPO_NAME" ] && REPO_NAME="$_REPO_NAME" &&  _all_new_+=("REPO_NAME")
	fi
	[[ -z "$TFIVEM" ]] && TFIVEM="${SOFTWARE_ROOT}/fivem" && _all_new_+=("TFIVEM")
        [[ -z "$TCCORE"  ]] && TCCORE="${TFIVEM}/citizenfx.core.server" && _all_new_+=("TCCORE")
        [[ -z "$TCCORE"  ]] && TCCORE="${TFIVEM}/citizenfx.core.server" && _all_new_+=("TCCORE")

	# TXADMIN_BACKUP
	if [ "$__CONFIGURE__" ] || [ "$TXADMIN_BACKUP" != "$PRIVATE/$TXADMIN_BACKUP_FOLDER" ] ;
	then
		TXADMIN_BACKUP="$PRIVATE/$TXADMIN_BACKUP_FOLDER"
		_all_new_+=("TXADMIN_BACKUP")
	fi

	# DB_BACKUPS
	if [ "$__CONFIGURE__" ] || [ "$DB_BACKUPS" != "$PRIVATE/$DB_BACKUP_FOLDER" ] ;
	then
		DB_BACKUPS="$PRIVATE/$DB_BACKUP_FOLDER"
		_all_new_+=("DB_BACKUPS")
	fi

	CFX_BUILD="$(echo $ARTIFACT_BUILD | cut -f1 -d-)"

}

pluck_fig() { # fig // prompt // confirm => 0/1
  local __cached_prompt="$PROMPT"
  local __prompt="$PROMPT" ; unset PROMPT
  local __fig_key="$1" ;
  local __verbose="$2" ;
  local __random="$3" ;
  local __min_len="$4" ;
  local __max_len="$5" ;

  if [ "$__random" == "true" ] ;
  then
	# if the random password was not generated externally, generate it
	[[ -z "$__RANDOM_PASSWORD__" ]] && local _pass="$(add_salt 64 1 date)" \
	  || local _pass="$__RANDOM_PASSWORD__"       # otherwise, use the one externally generated.
	printf -v "_${__fig_key}" '%s' "$_pass"	      # Assign it for use later
  fi
                                                   # I got this working then realized i didn't need it/ or the above function. derp.
                                                 # declare -a local __prompt=("${!2}")  ## Just saving it here for future reference.
                                                                                         # arg_constructor __prompt  __default_input
											# __verbose 20 switches these values below
  if [ ! -z "$__min_len" ] && [ ! -z "$__max_len" ] && [ ! "$__verbose" == 20 ] ;  # if there both a min and max length
  then                                        # it has a minimum & maximum length required- update the prompt to reflect requirement
    __prompt=$(echo -e "$__prompt (\e[93m\e[4mlength: $__min_len \e[2mto\e[22m $__max_len\e[24m\e[39m)")
                                                                                 # 20 will mean they are actually for somthing else.
  elif [ ! -z "$__min_len" ] && [ -z "$__max_len" ] && [ ! "__verbose" == 20 ] ;                     # if there is only a min length
  then                                                 # it has a minimum length required- update the prompt to reflrect requirement
    __prompt=$(echo -e "$__prompt (\e[93m\e[4mmin length: $__min_len\e[24m\e[39m)")
    unset __max_len
  elif [ "$__verbose" != 20 ];                                       # I don't wan to clean these up, if they belong to someone else
  then                                                         # otherwise, do nothing but clean up
    [[ "$__min_len" ]] && unset __min_len ;
    [[ "$__max_len" ]] && unset __max_len ;
  fi

                                                     # Pull the default and update the prompt (if applicable)- otherwise, do nothing
  local __default="$(eval echo \$_${__fig_key})"                                                         # Pick up the default value
                                                                   # if it is blank, unset the var ; otherwise, add it to the prompt

  [[ ! -z "$__default" ]] && [[ ! "$__random" == "true" ]] && [[ "$__verbose" != 10 ]] && [[ "$__verbose" != 11 ]] \
  && local __prompt__=$(echo -e "$__prompt \e[32m[$__default]\e[39m")

  [[ -z "$__default" ]] && unset __default

                                                                  # Assign the prompt (with or without default value)- then clean up
  [[ "${__prompt__:=$__prompt}"  ]] && unset __prompt
				# I store the previous prompt for use later if i need to reform a confirm questions with it.
  if [ ! -z "$__verbose" ] ;                                       # If the confirmation is enabled
  then                                         # check if the setting is a valid int (1 = on / 2 = off)
    if [[ "$__verbose" =~ '^[0-9]+$' ]] ;                                                     # If this validation checks out okay
    then                                          # this is a number, not a defininition string; Using the on/off assignment
      if [ "$__verbose" -eq 1 ] ;
      then                                         # if it is set to 1, use quick settings- C:N
		local __verbose_prompt="C:N"
      elif [ "$__verbose" -eq 10 ] || [ "$__verbose" -eq 11 ] ;
      then
        unset __verbose_prompt
        unset __verbose_display
      else
        unset __verbose_prompt
        unset __verbose_display
        unset __verbose
      fi
    else 								# because this is not a valid int, this prompt has param settings
      local __verbose_prompt=$(echo "$__verbose" | cut -f1 -d/) # collect the prompt params
    fi

    if [ "$__verbose" == 10 ] || [ "$__verbose" == 11 ] || [ "$__verbose" == 20 ] ;
    then

      local __prompt="$__prompt__"   # temporarily reassign the current ongoing prompt building
      unset __prompt__    # unset for reassignment

      if [ "$__verbose" == 20 ] ;
      then
        if [ ! -z "$__min_len" ] && [ ! -z "$__max_len" ] ; then
          local _i="($__min_len to $__max_len)"  # build the prompt addition
          local __i1="$__min_len"  # build a default value (using the min val)
          local __i2="$__max_len"  # I guess this is redundant... oh well. easier to be consistent (i use this later)
          local __i3=$(expr length "$__max_len")
        fi
        local __prompt__="$__prompt $_i"  # build the new prompt and assign to prompt
      fi

      if [ "$__verbose" == 10 ] || [ "$__verbose" == 11 ] ;
      then
	[[ "$__default" == "true" ]] && __verbose=10
	[[ "$__default" == "false" ]] && __verbose=11

        case "$__verbose" in   # if verbose
          10 ) local _q="\e[93m[Y/\e[2mn\e[22m]\e[39m" ; local __q=y ;;  # is 10, make Yes the default
          11 ) local _q="\e[93m[N/\e[2my\e[22m]\e[39m" ; local __q=n ;;  # is 11, make No the default
        esac;
        local __prompt__="$__prompt $_q"  # build the new prompt and assign to prompt
      fi
      [[ "${__prompt__:=$__prompt}" ]]   # if for some reason, this didn't work... take the previous prompt back
      unset __prompt    # clean up

    elif [ "$__verbose_prompt" != 0 ] || [ "$__verbose" != 0 ] ;
    then
      # string interpetation for verbose:
      # can be configured using the following syntax:
      #        (pos1=Ss/Cc):(pos2=Yy/Nn)/(pos3=Yy/Nn)

      # examples:  s:y/y   c:n/y   ... etc

      # Define the confirmation message
      case $(echo "$__verbose_prompt" | cut -f1 -d:) in
        [Ss]* ) local _p1="are you sure?" ; local __p1=s ;;
        [Cc]* ) local _p1="Continue?" ; local __p1=c ;;
            * ) local _p1="Continue?" ; local __p1=C ;;
      esac;

      case $(echo "$__verbose_prompt" | cut -f2 -d:) in
        [Yy]* ) local _p2="\e[93m[Y/\e[2mn\e[22m]\e[39m" ; local __p2=y ;;
        [Nn]* ) local _p2="\e[93m[N/\e[2my\e[22m]\e[39m" ; local __p2=n ;;
            * ) local _p2="\e[93m[N/\e[2my\e[22m]\e[39m" ; local __p2=N ;;
      esac;
      # End confirmation message definition & building

      # if settings still both exist (this should), then I redefine the prompt settings (just in case catchall)
      [[ ! -z "$__p1" ]] && [[ ! -z "$__p2" ]] && local __verbose_prompt="$__p1:$__p2" ;
      # If both pieces of the prompt exist, assign the confirmation message to it's var
      [[ ! -z "$_p1" ]] && [[ ! -z "$_p2" ]] && local __question__="$_p1 $_p2" ;

      # get the user input feedback display setting or use the default (which is to not display input feedback)
      local __verbose_display=$(echo "$__verbose" | cut -f2 -d/) ;
      [[ "${__verbose_display}" == "n" ]] && unset __verbose_display ;  # display is enabled, otherwise unset var
    else  # just clean up
      [[ "$__verbose_prompt" ]] && unset __verbose_prompt ;
      [[ "$__verbose_display" ]] && unset __verbose_display ;
    fi
  else  # more cleaning
    [[ "$__verbose" ]] && unset __verbose ;
  fi  # done with building the confirmation prompt

  [[ "$__return" ]] && unset __return ; # unsetting any potential. this is probably overkill- just making sure
  [[ "$return__" ]] && unset return__ ;

  while [ -z "$return__" ] ;
  do # while no value has been committed

    if [ "$__verbose" == 10 ] || \
       [ "$__verbose" == 11 ] || \
       [ "$__verbose" == 20 ] ;
    then

      #### 10 OR 11 ########################################
      if [ "$__verbose" == 10 ] || \
         [ "$__verbose" == 11 ] ;  # this is a yes / no prompt = true / false output
      then

        # PROMPT THE USER
        ##  -- yes/no question
        color white - bold ;
        printf "$__prompt__: \e[s" && read -n 1 yn ; # Prompt the user

        [[ -n "$yn" ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D" ;
        color - - clearAll ;

        [[ "${yn:=$__q}" ]]  # check user input against default (if blank and has a default)

        case "$yn" in
          [Yy]* ) local __return=true ; echo -e " Yes.\n" ;;
          [Nn]* ) local __return=false ; echo -e " No.\n" ;;
              * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel)\n" ;;
        esac

      #### 20 #############################################
      elif [ "$__verbose" == 20 ] ; # this is a number input
      then

        # PROMPT THE USER
        ## -- number input
        color white - bold ;
        echo -e -n "$__prompt__: " ;
        read -n "$__i3" __return ;
        color - - clearAll ;
      fi

    else

      ####################
      # PROMPT THE USER
      ## -- standard prompt
	  [[ "$__random" == "true" ]] \
	    && printf "   \e[93m\e[1mRandom Password (Leave Blank to Accept):\n\n" \
	    && echo -e -n "\t\e[33m> \e[31m$__default \e[33m<\e[0m\n\n"
      color white - bold ;
      echo -n "$__prompt__: " ; # prompt the user
      color - - clearAll ;

      read __return ; # read in the user's response to the prompt
    fi

    if [[ -n "$__default" ]] ;
    then       # if there is a default value,
      [[ "${__return:=$__default}" ]] ;    # read in input or use default value.
    fi                                    # otherwise, just use the input even if it is blank

    ###############################
    # Input Validation
    ##
    if [ ! -z "$__return" ] && [ "$__return" != "true" ] && [ "$__return" != "false" ] ;
    then  # if there is an input that is not zero length
      [[ "$__invalid" ]] && unset __invalid   # clear whatever setting may be set to __invalid (dusting off the equipment)
      local __valid=1 # pre-validate the users input
      local __length=$(expr length "$__return")  # what is the length

      # NUMBER VALIDATION
      if [ "$__verbose" == 20 ] ; # this is a number input
      then
        if [ "$__return" -eq "$__return" ] 2> /dev/null    # check if user entered a valid integer
        then # This is a number
          [[ "$__return" -le "$__i1" ]] && __invalid="You've entered a number less than $__i1..." && unset __valid ;
          [[ "$__return" -ge "$__i2" ]] && __invalid="You've entered a number greater than $__i2..." && unset __valid ;
        else
          __invalid="This input requires you to enter a number."
          unset __valid ;
        fi
      fi
      [[ "$__verbose" == 20 ]] && unset __verbose_prompt  # if this is verbose 20, then there is no need for verbose_prompt


      # LENGTH VALIDATION
      if [ "$__min_len" ] && [ ! "$__length" -ge "$__min_len" ] && [ ! "$__verbose" == 20 ] ;
      then
        local __invalid="Minimum length required."    # invalidated user input with reason
        unset __valid    # revoke validation
      fi

      if [ "$__max_len" ] && [ ! "$__length" -le "$__max_len" ] && [ ! "$__verbose" == 20 ] ;
      then
        local __invalid="Too many characters entered."    # invalidate user input with reason
        unset __valid    # revoke validation
      fi
      unset __length    # clean up
    elif [ "$__return" == "true" ] || [ "$__return" == "false" ] ;
    then
        # do not validate; set the value and move on.
	__valid="1" ;
        unset __verbose_prompt
    else
      local __invalid="No user input received from the console."  # invalidate user input with reason
      unset __valid   # revoke any potential validation
    fi  # done validating the users input

    # VALIDATION CHECK (DID THE ABOVE FLAG THIS? IF YES, INVALIDATE)
    [[ "$__return" ]] && [[ "$__invalid" ]] && unset __return  # if invalid, unset
    if [ "$__return" ] && [ "$__valid" ] ;  # if there is input that is not zero length
    then # the input was found and validated
      if [ ! "$__verbose_prompt" ] ;  # If there is no confirmation prompt set (or this is true false statement)
      then # then it has been disabled.
        local return__="$__return"  # do not confirm; set the value and move on.

        [[ "$__return" != *$'\r'* ]] && printf "\r"
        [[ "$__verbose" != 2 ]] && [[ "$__return" != "true" ]] \
          && [[ "$__return" != "false" ]] && echo -e "Using \"$return__\"...\n"
        unset __return

        printf -v "${__fig_key}" '%s' "$return__"

      else # otherwise, confirm with console that the value was correctly entered.

        unset __confirm  # unsetting a var before i read in user input
        while true;
        do # loop while

	  # Console display of input (for confirmation)
          if [ -n "$__verbose_display" ] ;
	  then
	    local _qref=$(echo "$__cached_prompt" | cut -f 3- -d" ")
	    echo -e -n "\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[999D"
            echo -e -n "    \e[93m For the $_qref, you've entered:\e[0m\n\n"
	    echo -e -n "\t\e[92m  $__return  \n\n"
	  fi

          # echo the prompt with no newline; read the user input; backup 1 column (before newline)
          color white
          printf "$__question__: \e[s" && read -n 1 yn
          color - - clearAll

          [[ -n "$yn" ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
          [[ "$yn" == "n" ]] && printf "\e[2K\e[1A\r"

          [[ "${yn:=$__p2}" ]]  # check user input against default (if blank and has a default)
          case "$yn" in
          [Yy]* ) local __confirm=y ; echo -e " Yes.\n" ;  break ;;
          [Nn]* ) unset __confirm ; break ;;
              * ) printf "\e[2B\e[999D\e[K\e[91mPlease answer yes or no (or hit control-c to cancel).\e[0m" ;;
          esac
        done
        if [ "$__confirm" ] ; then
          local return__="$__return"
          unset __return
          printf -v "${__fig_key}" '%s' "$return__"
	  printf "\n"
        else
	  [[ -n "$__RESET__" ]] && printf "\e[5A\n\e[KOkay, user input cleared... Let's try that again.\n"
	  [[ -z "$__RESET__" ]] && local __RESET__="1" \
            && printf "\n\e[2K\r\e[1A\e[2K\r\e[1A\e[2K\r\e[1A\e[2K\r\e[1A\e[2K\r" \
            && printf "Okay, user input cleared... Let's try that again.\n"
        fi

      fi
    else

      ########
      # INVALID -- RESPONSE
      ##
      color red - bold
      color - - underline
      echo -e "\n\nERROR!\n"
      color - - noUnderline
      [[ "$__invalid" ]] && echo "$__invalid" && unset __invalid
      echo -e "Input not valid.  Please try again.\n"
      color clear clear clearAll
    fi
  done
  unset __prompt__ ; unset return__ ;  unset __confirm ; unset __question__ ;

}

cook_figs() {
	# GETTING IT ALL HOT AND READY!
        if [ -z "$PRIVATE" ] ;
	then
                echo "Erp. Derp. Problems... I have no private! FAILED @ x0532!"
                exit 1
	elif [ -z "$CONFIG" ] ;
	then
		echo "Config write failed.  No config definition discovered..."
		exit 1
        fi

	local _content=$(cat "$CONFIG" 2>/dev/null)
	##################################################################################
	if [ ! -d "${CONFIG%/*}" ] || [ ! -f "$CONFIG" ] || [ -z "$_content" ] ;
	then
		[[ "$1" == "QUIETLY" ]] && loading 1 CONTINUE || echo "No valid previous configuration was found.  Building base config..."
		[[ ! -d "${CONFIG%/*}" ]] && mkdir "${CONFIG%/*}"
		[[ -f "$CONFIG" ]] && rm "$CONFIG"
		BASE_CONFIG="{}"
	else
		[[ "$1" == "QUIETLY" ]] && loading 1 CONTINUE || echo "Config file identified and is not zero length..."

		BASE_CONFIG="$(cat $CONFIG | jq .)"

		if [ "$_all_new_" ] && [ "${#_all_new_[@]}" -gt 0 ] ;
		then
			[[ "$1" == "QUIETLY" ]] && __LOADING_STOPPED__="1" && loading 1 CONFIG && printf "\n\n"
		else
			color white - bold
			echo "No changes discovered."
			color - - clearAll
			__UNCHANGED__="1"
		fi
	fi

	identify_branches

	for _cfug in "${_all_new_[@]}" ;
	do
		plant_fig "BASE_CONFIG" "$_cfug"
	done

        if [ -d "${CONFIG%/*}" ] && [ -f "$CONFIG" ] && [ -n "$_content" ] ;
        then
		color lightYellow - bold
		echo -e "\nPrevious config found... Rebuilding with new config values...\n"
		echo -e "This will over-write the current config found at:\n"
		echo -e "        $CONFIG\n\n"
		color - - clearAll

		color white - bold
		echo -e "\nLast chance to cancel..."
		color - - clearAll

	        while [ -z "$__confirmed__" ] ;
	        do
			ask_to_review _content - "current"
			ask_to_review BASE_CONFIG red "revised"

			display_array_title "red" "New or altered values:"
			display_array "red" "${_all_new_[@]}"

			color white - bold
		        echo -n -e "Overwrite system config with above values? "
		        color lightYellow - bold
		        echo -n -e "(TYPE 'YES' TO CONTINUE)"
		        color white - bold
			echo -n -e ":"
			color - - clearAll
			unset _confirm ;
			read -n 3 _confirm ;
			case "$_confirm" in
		            Yes | yes | YES ) __confirmed__="1" ; unset _confirm ;;
			                  * ) unset _confirm ;;
			esac ;
			if [ -z "$__confirmed__" ] ;
			then
				echo -e "\n\e[97mYou did not type 'YES' -- if you'd like to cancel, hit control-c\e[0m" ; # Fired!
			fi
		done
		color white - bold
		printf "\nOkay...\n"
		color - - clearAll
	fi
	unset _content

	if [ -n "$BASE_CONFIG" ] ;
	then

		commit "BASE_CONFIG"
	else
		printf "CONFUGGERING FAILED."
		exit 1
	fi

}

ask_to_review() {

	# USAGE:
	# $1 = NAME OF VAR THAT IS HOLDING REVIEW DATA (WITHOUT THE $)
	# $2 = (can be skipped with a - [dash]) COLOR  (eg ask_to_review "data" - )
	# $3 = (can be blank) Type of configuration (eg "new" configuraiton // "existing" configuration

	[[ -z "$1" ]] && echo "Must include data to review" && exit 1 || local _data_holder="$1"
	[[ -n "$3" ]] && local _type_name="$3"

	if [ "$REVIEW_CONFIGS" != "true" ] || [ -z "$REVIEW_CONFIGS" ] ;
	then
		if [ -n "$_type_name" ] ;
		then
			PROMPT="Would you like to review the $_type_name configuration?"
			local _head="${_type_name^^} CONFIGURATION"
		else
			PROMPT="Would you like to review the configuration?"
			local _head="CONFIGURATION"
		fi

		pluck_fig "__REVIEW__" 11 false	
		if [ "$__REVIEW__" == "true" ] ;
		then

			unset __REVIEW__
			unset __READY__
			until [ "$__READY__" == "true" ] ;
			do
				[[ -n "$2" ]] && [[ "$2" != "-" ]] && color "$2" - bold || color gray - bold
				printf "\n---------------[ $_head ]---------------\n"
				color - - clearAll
				echo "${!_data_holder}" | jq .
				printf "\n\n"

				PROMPT="Ready to continue? (Control-C to Cancel)"
				pluck_fig "__READY__" 11 false
			done
			unset __READY__
		else
			unset __REVIEW__
		fi
	fi
}

commit() {
	# USAGE:
	# commit    		::    VALIDATION ONLY - JUST CHECKS FOR CONFIG CONTENT
	# commit  COMMIT_NAME   ::    NEED TO USE THE NAME OF THE VAR, NOT THE ACTUAL VAR
	#			      THIS WILL COMMIT THE CHANGE (FIRST VERIFYING IT IS NOT 0 LENGTH)
	#			      THEN IT WILL VALIDATE THAT THE CHANGE TOOK SUCCESSFULLY.

	[[ -n "$1" ]] && local _commit="$(eval echo \${$1})"
	if [ -n "$1" ] && [ -z "$_commit" ] ;
	then
		printf "\n\e[91m\e[4mNothing to commmit!\e[0m\n\n"

	elif [ -z "$CONFIG" ] ;
	then
		printf "\n\e[91m\e[4mNo config defined!\e[0m\n\n"

	elif [ -z "$1" ] ;
	then
		check_configuration QUIETLY
                if [ -n "$__INVALID_CONFIG__" ] ;
                then
                        color red - bold
                        printf "\nCONFIG CONTENT VALIDATION FAILED!\n"
                        color - - clearAll
                elif [ -n "$__CONFIG__" ] ;
                then
			color green - bold
			printf "\nCONFIG CONTENT VALIDATION SUCCEEDED!\n"
			color - - clearAll
                fi
	elif [ -n "$1" ] && [ -n "$_commit" ] && [ -n "$CONFIG" ] ;
	then
		# OKAY TO ASSUME:
		# 1) A COMMIT ATTEMPT IS BEING MADE
		# 2) THE COMMIT IS NOT ZERO LENGTH
		# 3) THERE IS A CONFIG FILE DEFINED

		check_configuration QUIETLY
                if [ -n "$__INVALID_CONFIG__" ] ;
                then
			# OKAY TO ASSUME:
                        # 4) CONFIG AT DEFINED LOCATION IS CURRENTLY INVALID
                        local __NEW__="1"
			# current config is invalid
			# starting from scratch

                elif [ -n "$__CONFIG__" ] ;
                then
			# OKAY TO ASSUME:
			# 4) CONFIG AT DEFINED LOCATION IS VALID

                        [[ -z "$__QUIET_MODE__" ]] && color red - bold \
                          && echo "$__CONFIG__" && color - - clearAll

			# CACHE THE CURRENT CONFIG
			local _cached_config=$(cat "$CONFIG" 2>/dev/null)

			# IF THE CURRENT CONFIG DIDNT CACHE (IT SHOULD, BUT OKAY) THEN CALL IT OUT
			if [ -z "$_cached_config" ] ;
			then
				echo -e "\nCaching of current config has failed..."
				echo -e "If we continue, there will be no reverting a failed commit.\n"
				unset __CURRENT__
				PROMPT="Are you sure you still want to continue?"
				unset __CONTINUE__
				pluck_fig "__CONTINUE__" 11 false
				if [ -n "$__CONTINUE__" ] ;
				then
					echo -e "\n\t\e[91m\e[4mOkay, you've been warned.\e[0m\n"
					unset __CONTINUE__
				else
					echo -e "\n\e[91mConfiguration cancelled by user... exiting!\e[0m\n"
					exit 1
				fi
			fi
                fi

		while true ;
		do

			color yellow - bold
			printf "\n      Writing config to:\n"
			color yellow - dim
			printf "      $CONFIG\n\n"
			color - - clearAll

			echo "$_commit" > "$CONFIG"   				  # WRITE THE CONFIG

			unset _content					      # CYA-Probably overkill though
			local _content=$(cat "$CONFIG" 2>/dev/null)    # READ IN THE REVISED CONFIG CONTENTS

			if [ -n "$_content" ] ;
			then
				if [ "$_commit" == "$_content" ] ;
				then
					# SUCCESS!
		                        color green - bold
		                        printf "\nCONFIGURATION SAVED SUCCESSFULLY!\n"
		                        color - - clearAll
					ask_to_review "_content" "white" "saved"
		                        unset _content
					break ;

				elif [ "$_cached_config" == "$_content" ] ;
		                then
					# NO CHANGES? WEIRD, BUT OKAY- LET ME KNOW.
					color yellow - bold
					echo "CONFIGURATION APPEARS UNALTERED..."
					color - - clearAll
					ask_to_review "_cached_config" "red" "revised"
					ask_to_review "_commit" "red" "revised"
					ask_to_review "_content" "red" "committed"
				else
					echo "unknown data received during commit verification.  failed!"
					exit 1
				fi
			elif [ -n "$_cached_config" ] ;
			then
				# FAILED, BUT WE CAN GO BACK!
		                color red - bold
	        	        printf "\nFAILED TO SAVE CONFIGURATION!\n"
	                        color - - clearAll

				color white - bold
				echo "reverting..."
				color - - clearAll
				echo "$_cached_config" | jq . > "$CONFIG"
				local _content=$(cat "$CONFIG" 2>/dev/null)
				[[ -z "$_content" ]] \
				  && echo "well, I tried to commit... but I got my privates stuck in a ceiling fan" \
				  && echo "...I've failed.  I'm very sorry!" && exit 1
				[[ -n "$_content" ]] && [[ "$_content" == "$_cached_config" ]] \
				  && echo "Successfully reverted the configuration back to its original state."

			elif [ -z "$_cached_config" ] ;
                        then
				# FAILED, NO RETURN!
				echo "well, I tried to commit... but I got my privates stuck in a ceiling fan"
				echo "If you are seeing this... I'm sorry.  You were warned though!"
				echo -e "\nWe could try again, but I don't have much hope...\n"
			else
				# I HAVE NO IDEA WHY THIS WOULD EVER TRIGGER
				echo "Configuration to commit configuration.  FAILED!"
				exit 1
			fi
			printf "\n\n"
			PROMPT="Try again?" && unset __CONTINUE__
			pluck_fig "__CONTINUE__" 10 false
			[[ -z "$__CONTINUE__" ]] && break || unset __CONTINUE__
		done
		unset _content
	fi
}

plant_fig() {
	local _crop="$1"
	local _fig="$2"
	local _path="$(eval echo \$jq_${_fig})"

	[[ -z "$__RUNTIME__" ]] && identify_branches

	_fruit="${!_fig}"
	_yield=$(eval echo \${$_crop} | jq $_path=\""$_fruit"\")

	[[ -n "$_yield" ]] && printf -v "$_crop" '%s' "$_yield" \
	  || echo "\n\e[97merror planting fig!\e[0m"
}

#-----[ CONFIGURES ]-----######################################################################
###############################################################################################

###############################################################################################
#-----[ RCON TINGS ]-----######################################################################

salt_rcon() {
	if [ "$RCON_ENABLE" == "true" ] ; then
		local _today=$(date +%Y-%m-%d)
		local _content=$(cat "$CONFIG" 2>/dev/null)
		if [ -n "$_content" ] ;
		then
			local _last_set="$(cat $CONFIG | jq -r '.sys.rcon.password.timestamp')"
		fi
		if [ -n "$_last_set" ] && [ "$_last_set" != "null" ] ;
		then
			local _d1=$(date -d "$_today" '+%s')
			local _d2=$(date -d "$_last_set" '+%s')
			local _since_set=$(( ("$_d1" - "$_d2")/(60*60*24) )) # in days
			unset _d1 ; unset _d2 ;
		else
			unset _last_set
		fi

		if [ "$RCON_PASSWORD_GEN" == "true" ] ; then

			local __RANDOM_PASSWORD__="$(add_salt $RCON_PASSWORD_LENGTH 1 date)"

			if "$RCON_ASK_TO_CONFIRM" ; then
				unset RCON_PASSWORD

				while [ -z "$RCON_PASSWORD" ] ;
				do
					color lightYellow - bold
					echo ""
					echo "You may enter a custom RCON password, but we recommend you accept the randomly generated one."
					echo ""
					PROMPT="Enter RCON password"
					pluck_fig "RCON_PASSWORD" "s:n/y" true 25 128
				done
			fi
			# WRITE THE CURRENT PASSWORD TO THE CONFIG
			color white - bold
			echo "Writing new RCON password to config..."
			color - - clearAll
			commit_rcon_password

			[[ -z "$RCON_PASSWORD" ]] && echo "RCON Password Generation Failed..." && exit 1 || echo "RCON Password generated..." && true
		elif [ -z "$RCON_PASSWORD" ] || [ "$RCON_PASSWORD" == "random" ] || [ "$_since_set" -ge 30 ] || [ -z "$_last_set" ] ;
		then

			# YOUR PASSWORD IS MORE THAN 30 DAYS OLD
			[[ -n "$_last_set" ]] && color red - bold
			[[ -n "$_last_set" ]] && [[ "$_since_set" -ge 30 ]] \
			  && echo -e "\nYou last changed your RCON password on: $_last_set" \
			  && echo -e "It has been $_since_set days since you last changed your RCON password.\n"

			echo -e "You should make sure and change this password often\n"
			[[ -n "$_last_set" ]] && color - - clearAll

			_RCON_PASSWORD="$RCON_PASSWORD"
			if [ -n "$_RCON_PASSWORD" ] && [ -n "$_last_set" ] ;
			then
				echo -e "Current password:\n${_RCON_PASSWORD}\n"
				PROMPT="Keep using $_since_set day-old password? (not recommended)"
				pluck_fig "__KEEP__" 11 false
			fi

			if [ -z "$__KEEP__" ] ;
			then
				unset RCON_PASSWORD
				while [ -z "$RCON_PASSWORD" ] ;
				do
					PROMPT="Enter RCON password"
					pluck_fig "RCON_PASSWORD" "s:n/y" true 25 128
				done
				commit_rcon_password
			else
				printf "\n"
				color yellow red bold
				echo -e "This is not smart... but okay.\e[0m\n"

				unset "__KEEP__"
                                PROMPT="Do you want to silence this reminder for another 30 days? (really not recoomented)?"
                                pluck_fig "__KEEP__" 11 false

				if [ "$__KEEP__" == "true" ] ;
				then
					 printf "\n"
					color yellow red bold
					echo -e -n "If you get hacked, don't cry to me. I hope it is a long password!\e[0m\n"
					commit_rcon_password "timestamp"
				fi
			fi
		fi
	fi
}

commit_rcon_password() {
	# IT IS ASSUMED THAT YOU MUST HAVE CONTENT IN THE FILE TO EVEN GET THIS FAR
	# SO IF THIS VALIDATION FAILED, WE JUST SKIP THE ADDITION.  IT SHOULD GET ADDED
	# WHEN THE QUICK CONFIG COMMITS ITS DATA.
	[[ -z "$CONFIG" ]] && echo "No config defined. failed." && exit 1
        local _content=$(cat "$CONFIG" 2>/dev/nul)
	if [ -n "$_content" ] ;
	then  # if there is no content in the file... we probably shouldn't be this far.  My assumption here atleast.
		[[ -z "$1" ]] && local _rev1=$(echo "$_content" | jq ".sys.rcon.password=\"${RCON_PASSWORD}\"")
		if [ -n "$_rev1" ] ;
              	then
			_revision=$(echo "$_rev1" | jq ".sys.rcon.password.timestamp=\"${_today}\"")
                      	unset _rev1
		elif [ -n "$1" ] ;
		then # IF $1 IS PASSED, ASSUME THIS IS ONLY A PASSWORD TIMESTAMP UPDATE
			_revision=$(echo "$_content" | jq ".sys.rcon.password.timestamp=\"${_today}\"")
		else
                      	echo "failed while processing RCON password revision.  exiting."
                	exit 1
                fi
        	[[ -n "$_revision" ]] && commit "_revision" && unset _revision

		commit "_revision"
        fi # OTHERWISE, SKIP THIS.  IT IS NOT NEEDED YET.
	unset _content
}

#-----[ RCON TINGS ]-----######################################################################
###############################################################################################

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#--[ WORKER FUNCTIONS ]--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#> THESE ARE MINE <3 Jay @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#

loading() {
        color yellow - -
	_1="$1"
        [[ -z "$2" ]] && echo -e -n "Loading"
        COUNTER="${_1:=1}"
        until [ "$COUNTER" -lt 0 ] ;
        do
                echo -e -n "."
                ping -c 1 127.0.0.1 > /dev/null || true
                let "COUNTER-=1"

        done
        [[ -n "$2" ]] && [[ "$2" == "END" ]] \
	  && color lightYellow - bold \
	  && echo -e -n " Ready!\n\n" \
	  && color clear - unBold
        [[ -n "$2" ]] && [[ "$2" == "CONFIG" ]] \
	  && color lightYellow - bold \
	  && echo -e -n " More configuration is needed...!\n\n" \
	  && color clear - unBold
	color - - clearAll
}

display_array_title() {
	printf "\e[0m\e[1m"
	[[ -n "$2" ]] && local _color="$1" || local _color="none"
	[[ -n "$2" ]] && local _title="$2" || local _title="$1"
	[[ -z "$_title" ]] && echo "no title definition.  can't be right..." && exit 1

        case "$_color" in
  	      "red" ) printf "\e[31m" ;;
            "green" ) printf "\e[32m" ;;
           "yellow" ) printf "\e[33m" ;;
	    "white" ) printf "\e[97m" ;;
		  * ) printf "\e[37m" ;; # Gray
	esac
	printf "\t\e[4m${_title}\e[24m:\e[0m\n" # Underlined / places colon & clears all format at end
}

display_array() {
	printf "\e[0m\e[37m"
        for _item in "$@" ;
        do
	        case "$_item" in
	  	      "red" ) printf "\e[31m" ;;
	            "green" ) printf "\e[32m" ;;
	           "yellow" ) printf "\e[33m" ;;
		    "white" ) printf "\e[97m" ;;
			  * ) echo -n -e "\t $_item \xe2\x86\x92 ${!_item}\n" ;;
		esac
        done
        printf "\e[0m\n"
}

color(){    # COLOR FOR ALL THE TERMS!
  [[ ! "$2" ]] || [[ "$2" == "0" ]] && __back="clear"
  [[ ! "$1" ]] || [[ "$1" == "0" ]] && __fore="clear"
  local __fore="$1"
  local __back="$2"
  local __dcor="$3"

  if [ "$__fore" != "-" ] ;
  then
    case "$__fore" in
       "clear") printf "\e[39m";;
       "black") printf "\e[30m";;
         "red") printf "\e[31m";;
       "green") printf "\e[32m";;
      "yellow") printf "\e[33m";;
        "blue") printf "\e[34m";;
     "magenta") printf "\e[35m";;
        "cyan") printf "\e[36m";;
   "lightGray") printf "\e[37m";;
    "darkGray") printf "\e[90m";;
    "lightRed") printf "\e[91m";;
  "lightGreen") printf "\e[92m";;
 "lightYellow") printf "\e[93m";;
   "lightBlue") printf "\e[94m";;
"lightMagenta") printf "\e[95m";;
   "lightCyan") printf "\e[96m";;
       "white") printf "\e[97m";;
             *) printf "\e[39m";;
    esac
  fi

  if [ "$__back" != "-" ] ;
  then
    case "$__back" in
       "clear") printf "\e[49m";;
       "black") printf "\e[40m";;
         "red") printf "\e[41m";;
       "green") printf "\e[42m";;
      "yellow") printf "\e[43m";;
        "blue") printf "\e[44m";;
     "magenta") printf "\e[45m";;
        "cyan") printf "\e[46m";;
   "lightGray") printf "\e[47m";;
    "darkGray") printf "\e[100m";;
    "lightRed") printf "\e[101m";;
  "lightGreen") printf "\e[102m";;
 "lightYellow") printf "\e[103m";;
   "lightBlue") printf "\e[104m";;
"lightMagenta") printf "\e[105m";;
   "lightCyan") printf "\e[106m";;
       "white") printf "\e[107m";;
             *) printf "\e[49m";;
    esac
  fi

  if [ "$__dcor" != "-" ] ;
  then
    case "$__dcor" in
        "bold") printf "\e[1m";;
         "dim") printf "\e[2m";;
   "underline") printf "\e[4m";;
       "blink") printf "\e[5m";;
      "invert") printf "\e[7m";;
      "hidden") printf "\e[8m";;
      "noBold") printf "\e[21m";;
       "noDim") printf "\e[22m";;
 "noUnderline") printf "\e[24m";;
     "noBlink") printf "\e[25m";;
    "noInvert") printf "\e[27m";;
    "noHidden") printf "\e[28m";;
    "clearAll") printf "\e[0m";;
    esac
  fi
}

add_salt() {

	# default
	local _default_length_=64

	# some vars
	[[ -n "$1" ]] && __len="$1" || __len="$_default_length_"
	[[ -n "$2" ]] && local __salt="$2" || local __salt="default"
	[[ -n "$3" ]] && local __stamp="$3"

	if ! [ "$1" -eq "$1" ] 2> /dev/null
	then
        	# using default
		local __len="$_default_length_"
	else
		declare -i local __len
		__len="$1"
	fi

	#random delim char
	if [ "$__salt" -eq 1 ] ; then
		_d=$(cat /dev/urandom | tr -dc "!@#" | fold -w 1 | head -n 1)
	else
		_d=$(cat /dev/urandom | tr -dc "!@#$&*_+?" | fold -w 1 | head -n 1)
	fi

	#make stamp
	if [ -n "$__stamp" ] ;
	then
		case "$__stamp" in
		  "date" ) local _shakerStamp="${_d}$(date +%B${_d}%Y)" ;;
		       * ) local _shakerStamp="${_d}$__stamp" ;;
		esac ;
		local __len="$(( $__len - ${#_shakerStamp} ))"
		[ "$__len" -lt 0 ] && __len=3 && _shakerStamp="${_shakerStamp:3}"
	fi

	# make salt
	case "$__salt" in
	  0 ) local _salt="$(date +%s | sha256sum | base64 | head -c ${__len}; echo)" ;;
	  1 ) local _salt=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%&_+?~" | fold -w "$__len" | head -n 1) ;;
	  * ) local _salt="$(date +%s | sha256sum | base64 | head -c ${__len}; echo)" ;;
	esac ;

	# if __stamp is empty, then just add salt / otherwise, add salt and the shaker stamp
	[ ! "$__stamp" ] && local __shaker="${_salt}" || local __shaker="${_salt}${_shakerStamp}"

	# This is needed to return for variable assignment
	echo "$__shaker"

}

stop_screen() {    # THIS STOPS A SCREEN SESSION.

  SCREEN_SESSION_NAME="fivem"
  echo "Quiting screen session '$SCREEN_SESSION_NAME' for FiveM (if applicable)"
  su "$SERVICE_ACCOUNT" -c "screen -XS '$SCREEN_SESSION_NAME' quit"
  
}

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

#--[ WORKER FUNCTIONS ]--######################################################################
###############################################################################################

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#--[ FUNCTIONS I DID NOT WRITE ]--------------------------------------------------------------#
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
