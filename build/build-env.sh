#!/bin/bash
#-ex

get_me_going () {
	# THIS BIT IS NEEDED TO GET THE JSON CONFIG TO WORK
	##
	apt update && apt -y upgrade && apt -y install jq
}

define_runtime_env () {
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
	SCRIPT=$(echo $0 | rev | cut -f1 -d/ | rev)
	SCRIPT_ROOT=`dirname "$(readlink -f $0)"`
		SCRIPT_FULLPATH="$SCRIPT_ROOT/$SCRIPT"
		BUILD="$SCRIPT_ROOT/build"

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
	if [ -d $DB_BKUP_PATH ]; then
		DB="$(ls -Art $DB_BKUP_PATH/ | tail -n 1)"
		PATH_TO_DB="$DB_BKUP_PATH/$DB"
	else
		DB="null"
		PATH_TO_DB="null"
	fi
	# END DATABASE BACKUP DISCOVERY
}

check_for_config () {
	#####################################################################
	#
	# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
	##
	                                                                        echo "Looking for a BERP ingest config file..."
	while [ -z $CONFIG ];
	do
	        _CONFIG="$PRIVATE/$CONFIG_NAME"
	        if [ -f "$_CONFIG" ]; then
	                                                                        echo "BERP injest config found @ ${_CONFIG}"
										echo "Preparing to deploy BERP..."
	                CONFIG="$_CONFIG"
	        else
        	                                                                echo "No BERP ingest config found..."
	                . $BUILD/quick-config.sh
	        fi
		done
	echo ""
}

quick_config () {
	echo ""
	echo "Welcome to the BERP deployer!"
	echo "Let's create a new BERP injest config..."
	. $BUILD/quick-config.sh
}

import_system_config () {
	#####################################################################
	#
	# IMPORT THE DEPLOYMENT SCRIPT CONFIGURATION
	##
	echo "Reading config..."

	ALLFIGS=( \
	SERVICE_ACCOUNT SERVICE_PASSWORD MYSQL_USER MYSQL_PASSWORD \
	STEAM_WEBAPIKEY SV_LICENSEKEY BLOWFISH_SECRET DB_ROOT_PASSWORD \
	)

	for _fig in "${ALLFIGS[@]}";
	do
	    echo -n "Importing ${_fig} configuration"
	        if [ -z ${!_fig} ];
	        then
	                eval "$_fig"="$(jq .[\"$_fig\"] $CONFIG)"

	                #echo -n " => $_fig = ${!_fig} => "  # DISPLAY ON SCREEN
	                echo -n "... " # DO NOT DISPLAY ON SCREEN

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
	srvAcct=SERVICE_ACCOUNT # TEMPORARY FOR COMPATABIBLITY (CONVERTING THESE TO UPPERS)
	srvPassword=SERVICE_PASSWORD # ditto.
	mysql_user=MYSQL_USER # i'm not going to continue typing ditto.
	mysql_password=MYSQL_PASSWORD
	steam_webApiKey=STEAM_WEBAPIKEY
	sv_licenseKey=SV_LICENSEKEY
	blowfish_secret=BLOWFISH_SECRET
	DBPSWD=DB_ROOT_PASSWORD # this one just needs to be more litteral
}

import_env_config () {
	##############################
	#	"pref": {
	#		"serverName":"${SERVER_NAME}",
	#		"artifactBuild":"${ARTIFACT_BUILD}",
	#		"repoName":"${REPO_NAME}",
	#		"serviceAccount":"${SERVICE_ACCOUNT}"
	#	},
	#	"env": {
	#		"sourceRoot":"${SOURCE_ROOT}",
	#			"source":"${SOURCE}",
	#		"private": {
	#		      "txadminCache":"${TXADMIN_CACHE}",
	#		       "dbBkupPath":"${DB_BKUP_PATH}"
	#		},
	#		"software": {
	#			"softwareRoot":"${SOFTWARE_ROOT}",
	#	                "tfivem":"${TFIVEM}",
	#                       "tccore":"${TCCORE}"
	#		},
	#		"install": {
	#			"main":"${MAIN}",
	#	                "game":"${GAME}",
	#                       "resources":"${RESOURCES}",
	#			"gamemodes":"${GAMEMODES}",
	#			"maps":"${MAPS}",
	#			"esx":"${ESX}",
	#			"esext":"${ESEXT}",
	#			"esui":"${ESUI}",
	#			"essential":"${ESSENTIAL}",
	#			"esmod":"${ESMOD}",
	#			"vehicles":"${VEHICLES}"
	#		}

	#pref
	SERVER_NAME=$( jq '.pref.serverName' $CONFIG )
	ARTIFACT_BUILD=$( jq '.pref.artifactBuild' $CONFIG )
	REPO_NAME=$( jq '.pref.repoName' $CONFIG )
	SERVICE_ACCOUNT=$( jq '.pref.serviceAccount' $CONFIG )

	#env
	SOURCE_ROOT=$( jq '.env.sourceRoot' $CONFIG )
	SOURCE=$( jq '.env.source' $CONFIG )

	#env.private
	TXADMIN_CACHE=$( jq '.env.private.txadminCache' $CONFIG )
	DB_BKUP_PATH=$( jq '.env.private.dbBkupPath' $CONFIG )

	#env.software
	SOFTWARE_ROOT=$( jq '.env.software.softwareRoot' $CONFIG )
	TFIVEM=$( jq '.env.software.tfivem' $CONFIG )
	TCCORE=$( jq '.env.software.tccore' $CONFIG )

	#env.install
	MAIN=$( jq '.env.install.main' $CONFIG )
	GAME=$( jq '.env.install.game' $CONFIG )
	RESOURCES=$( jq '.env.install.resources' $CONFIG )
	GAMEMODES=$( jq '.env.install.gamemodes' $CONFIG )
	MAPS=$( jq '.env.install.maps' $CONFIG )
	ESX=$( jq '.env.install.esx' $CONFIG )
	ESEXT=$( jq '.env.install.esext' $CONFIG )
	ESUI=$( jq '.env.install.esui' $CONFIG )
	ESSENTIAL=$( jq '.env.install.essential' $CONFIG )
	ESMOD=$( jq '.env.install.esmod' $CONFIG )
	VEHICLES=$( jq '.env.install.vehicles' $CONFIG )
}

define_configures () {
	_new_=0
	_all_new_=()
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  SERVER_NAME  ::  TXADMIN_CACHE  ::  DB_BKUP_PATH  ::  ARTIFACT_BUILD  #
	#////////////////////////////////////////////////////////////////////////#
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  SOFTWARE_ROOT  ::  TFIVEM  ::  TCCORE  #
	#/////////////////////////////////////////#
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
	#  MAIN  ::  GAME  ::  RESOURCES  ::  GAMEMODES  ::  MAPS  ::  ESX  #
	#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||#
	#  ESEXT ::  ESUI  ::  ESSENTIAL  ::    ESMOD    ::     VEHICLES    #
	#///////////////////////////////////////////////////////////////////#

	if [ -z "$SERVER_NAME" ]; then
		_SERVER_NAME="Beyond Earth Roleplay (BERP)"
		read -p "What would you like to name the server? [$_SERVER_NAME]" SERVER_NAME
		SERVER_NAME=${SERVER_NAME:-$_SERVER_NAME}
		_all_new_+="SERVER_NAME"
		let _new_++
	fi
	if [ -z "$PRIVATE" ]; then
		echo "Erp. Derp. Problems... I have no private! FAILED @ x0532!"
		exit 1
	fi
	_prompt_=0
	if [ -z "$TXADMIN_CACHE" ]; then
		if [ _prompt_ == 0 ]; then
			echo "You'll probably want to hit enter for these next few that may come up... just accept the defaults."
			let _prompt_++
		fi
		_TXADMIN_CACHE="data-txadmin"
		read -p "txAdmin backup folder name [$_TXADMIN_CACHE]: " TXADMIN_CACHE
		_TXADMIN_CACHE=${TXADMIN_CACHE:-$_TXADMIN_CACHE}
		TXADMIN_CACHE="$PRIVATE/$_TXADMIN_CACHE"
		_all_new_+="TXADMIN_CACHE"
		let _new_++
	fi
	if [ -z "$TXADMIN_CACHE" ]; then
		if [ _prompt_ == 0 ]; then
			echo "You'll probably want to hit enter for these next couple that may come up... just accept the defaults."
			let _prompt_++
		fi
		_DB_BKUP_PATH="data-mysql"
		read -p "MySQL backup folder name [$_DB_BKUP_PATH]: " DB_BKUP_PATH
		_DB_BKUP_PATH=${DB_BKUP_PATH:-$_DB_BKUP_PATH}
		DB_BKUP_PATH="$PRIVATE/$_DB_BKUP_PATH"
		_all_new_+="DB_BKUP_PATH"
		let _new_++
	fi
	if [ -z "$ARTIFACT_BUILD" ]; then
		if [ _prompt_ == 0 ]; then
			echo "You'll probably want to hit enter for this new one... just accept the defaults."
			let _prompt_++
		fi
		_ARTIFACT_BUILD="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"
		echo "What CFX Artifact Build would you like to use?"
		echo "**ONLY DO THIS IF YOU KNOW HOW! OTHERWISE, JUST HIT ENTER**"
		echo ""
		read -p "Enter Build [$_ARTIFACT_BUILD]: " ARTIFACT_BUILD
		ARTIFACT_BUILD=${ARTIFACT_BUILD:-$_ARTIFACT_BUILD}
		_all_new_+="ARTIFACT_BUILD"
		let _new_++

		# CFX_BUILD = FiveM's build number
		CFX_BUILD="$( echo $ARTIFACT_BUILD | cut -f1 -d- )"
	else
		artifact_build="$ARTIFACT_BUILD" # THIS SHOULD BE TEMPORARY / I MOVED THIS TO UPPER LATE
	fi
	_prompt_=0

	##########################################################################
	#THIS CAN BE CACHED. CAN ALSO CHANGE WITHOUT AFFECTING THE INSTALL.
	if [ -z "$SOFTWARE_ROOT" ]; then
		_SOFTWARE_ROOT="/var/software"
		echo "NOTE: This is not the repo.  It is basically a cache of temporary downloads."
		read -p "Where would you like to store the downloaded files? [$_SOFTWARE_ROOT]" SOFTWARE_ROOT
		SERVER_NAME=${SOFTWARE_ROOT:-$_SOFTWARE_ROOT}
		_all_new_+="SOFTWARE_ROOT"
		let _new_++
	fi
	SOFTWARE_ROOT="SOFTWARE_ROOT"  # I just did this to keep my structure below.  Its for me, shut up!
		TFIVEM="$SOFTWARE_ROOT/fivem"
			TCCORE="$TFIVEM/citizenfx.core.server"


	if [ -z "$SERVICE_ACCOUNT" ]; then
		_SERVICE_ACCOUNT="fivem"
		echo ""
		echo "DO NOT USE ROOT HERE! SU OR SUDO LIKE NORMAL!"
		echo ""
		read -p "What linux account would you like to use for fivem? [$_SERVICE_ACCOUNT]" SERVICE_ACCOUNT
		SERVICE_ACCOUNT=${SERVICE_ACCOUNT:-$_SERVICE_ACCOUNT}
		srvAcct=$SERVICE_ACCOUNT
		_all_new_+="SERVICE_ACCOUNT"
		let _new_++
	else
		srvAcct=$SERVICE_ACCOUNT  # THIS SHOULD BE TEMPORARY / WAS THE OLD NAME- USING A MORE LITTERAL UPPER NOW
	fi
	#THIS NEEDS TO BE CACHED.  SHOULDN'T/CAN NOT CHANGE!
	MAIN="/home/$SERVICE_ACCOUNT"
		GAME="$MAIN/server-data"
			RESOURCES="$GAME/resources"
				GAMEMODES="$RESOURCES/[gamemodes]"
					MAPS="$GAMEMODES/[maps]"
				ESX="$RESOURCES/[esx]"
					ESEXT="$ESX/es_extended"
					ESUI="$ESX/[ui]"
				ESSENTIAL="$RESOURCES/[essential]"
					ESMOD="$ESSENTIAL/essentialmode"
				VEHICLES="$RESOURCES/[vehicles]"
}

build_env_config () {
	##################################################################################
	if [ ! -d "${CONFIG%/*}" ];
	then
		echo "No previous configuration found.  Building Privly folder & base config..."
		mkdir "${CONFIG%/*}"
		touch "$CONFIG"
		BASE_CONFIG="{}"
	else
		echo "Previous config found... Rebuilding with new config options..."
		echo ""
		_check=$( read -p 'are you sure you know what you are doing? (y/N)' )
		if [ "$_check"=="y" ];
		then
			_CONFIG="$( cat $CONFIG )"
			_SERVER_NAME="$( echo $_CONFIG | jq -r '.pref.serverName' )"
			_ARTIFACT_BUILD="$( echo $_CONFIG | jq -r '.pref.artifactBuild' )"
			_REPO_NAME="$( echo $_CONFIG | jq -r '.pref.repoName' )"

			if [ -z "$_CONFIG" ];
			then
				echo "The current config is not valid or is empty.  Starting over."
				BASE_CONFIG="{}"
			else
				BASE_CONFIG="$( echo $_CONFIG | jq 'del(.pref)' | jq 'del(.env)' )"

				if [ -z "$_SERVER_NAME" ]; then
					SERVER_NAME="B.E.R.P Clone"
					echo "Server name is empty. Using hard-coded version: $SERVER_NAME"
				else
					SERVER_NAME="$_SERVER_NAME"
				fi
				if [ -z "$_ARTIFACT_BUILD" ]; then
					ARTIFACT_BUILD="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"
					echo "Artifact build is not populated. Using hard-coded version: $ARTIFACT_BUILD"
				else
					ARTIFACT_BUILD="$_ARTIFACT_BUILD"
				fi

				if [ -z "$_REPO_NAME" ]; then
					REPO_NAME="BERP-Source"
					echo "Repository name is not populated. Using hard-coded version: $REPO_NAME"
				else
					REPO_NAME="$_REPO_NAME"
				fi
			fi
		fi
	fi
	echo "$BASE_CONFIG"                                                | \
	jq ". += {\"pref\":{}}"                                            | \
	  jq ".pref += {\"serverName\":\"${SERVER_NAME}\"}"                | \
	  jq ".pref += {\"artifactBuild\":\"${ARTIFACT_BUILD}\"}"          | \
	  jq ".pref += {\"repoName\":\"${REPO_NAME}\"}"                    | \
	jq ". += {\"env\":{}}"                                             | \
	  jq ".env += {\"sourceRoot\":\"${SOURCE_ROOT}\"}"                 | \
	  jq ".env += {\"source\":\"${SOURCE}\"}"                          | \
	  jq ".env += {\"private\":{}}"                                    | \
	    jq ".env.private += {\"txadminCache\":\"$TXADMIN_CACHE\"}"     | \
	    jq ".env.private += {\"dbBkupPath\":\"${DB_BKUP_PATH}\"}"      | \
	  jq ".env += {\"software\":{}}"                                   | \
	    jq ".env.software += {\"softwareRoot\":\"${SOFTWARE_ROOT}\"}"  | \
	    jq ".env.software += {\"tfivem\":\"${TFIVEM}\"}"               | \
	    jq ".env.software += {\"tccore\":\"${TCCORE}\"}"               | \
	  jq ".env += {\"install\":{}}"                                    | \
	    jq ".env.install += {\"main\":\"${MAIN}\"}"                    | \
	    jq ".env.install += {\"game\":\"${GAME}\"}"                    | \
	    jq ".env.install += {\"resources\":\"${RESOURCES}\"}"          | \
	    jq ".env.install += {\"gamemodes\":\"${GAMEMODES}\"}"          | \
	    jq ".env.install += {\"maps\":\"${MAPS}\"}"                    | \
	    jq ".env.install += {\"esx\":\"${ESX}\"}"                      | \
	    jq ".env.install += {\"esext\":\"${ESEXT}\"}"                  | \
	    jq ".env.install += {\"esui\":\"${ESUI}\"}"                    | \
	    jq ".env.install += {\"essential\":\"${ESSENTIAL}\"}"          | \
	    jq ".env.install += {\"esmod\":\"${ESMOD}\"}"                  | \
	    jq ".env.install += {\"vehicles\":\"${VEHICLES}\"}" > $CONFIG
}


if [ ! -z $1 ] && [ $1 == "TEST" ];
then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ];
then

	## ---- BUILD ENVIRONMENT ---- ##

	define_runtime_env;
	check_for_config

	if [ -d "${CONFIG%/*}" ];
	then
		import_env_config
		define_configures
		if [ $_new_ != 0 ]; then
			echo "_new_ :: $_new_"
			# LOOP THROUGH _all_new_ to display changes
			# CONFIRM
			build_env_config
		fi
	else
		define_configures
		build_env_config
	fi

	## ---- BUILD ENVIRONMENT ---- ##

else
    echo "This script must be executed by the deployment script"
fi

