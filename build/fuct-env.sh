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

quick_config() {
	echo ""
	echo "Welcome to the BERP deployer!"
	echo "Let's create a new BERP injest config..."
	. "$BUILD/quick-config.sh"
}

check_for_config() {
	#####################################################################
	#
	# CHECK FOR A CONFIGURAITON FILE, IF NOT FOUND THEN CREATE IT.
	##
	                                                                        echo "Looking for a BERP ingest config file..."
	_CONFIG="$CONFIG" ; unset CONFIG
	while [ -z "$CONFIG" ]; do
	        if [ -f "$_CONFIG" ]; then
	                                                                        echo "BERP injest config found @ ${_CONFIG}"
										echo "Preparing BERP to be deployed..."
	                CONFIG="$_CONFIG"
	        else
	       	                                                                echo "No BERP ingest config found..."
			if [ -z $1 ] ;
                        then
				# EXECUTION LIKELY CAME FROM DEPLOY
				echo "Entering quick configuration tool..."
                        	quick_config
                        else
                        	# OTHERWISE, WE PASSED IT RUNTIME ONLY
                        	__INVALID_CONFIG__="1"
                        	CONFIG="$_CONFIG"
			fi
	        fi
	done
}


# READS IN MY ENV VARIABLES
read_figs() {
        for _fig in "$@";
#	for _fig in "${ALLFIGS[@]}";

        do
            echo -n "Importing ${_fig} configuration"
                if [ -z "${!_fig}" ];
                then

                        local _jq="$(eval echo \$jq_${_fig})"
                        local _jsData="$(jq -r $_jq $CONFIG)"

			[[ "$_jsData" != "null" ]] && [[ ! -z "$_jsData" ]] && printf -v "$_fig" '%s' "${_jsData}"
                        unset _jsData ; unset _jq

			color yellow - bold
                        [[ $__TEST__ ]] && [[ ${!_fig} ]] && local __val="${!_fig}" || local __val="\"\""
			[[ $__TEST__ ]] &&  echo -e -n " => $_fig == $__val => "  || echo -e -n "... " # DO OR DO NOT DISPLAY ON SCREEN
			color - - clearAll

                fi

		[[ "$_err_" ]] && unset "${!_fig}"

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
	SERVER_NAME ARTIFACT_BUILD REPO_NAME SOURCE_ROOT SOURCE TXADMIN_CACHE \
        DB_BKUP_PATH SOFTWARE_ROOT TFIVEM TCCORE MAIN GAME RESOURCES GAMEMODES \
        MAPS ESX ESEX ESUI ESSENTIAL ESMOD VEHICLES \
        ) ;

	# .pref
	jq_SERVER_NAME=".pref.serverName"
	jq_ARTIFACT_BUILD=".pref.artifactBuild"
	jq_REPO_NAME=".pref.repoName"

	# .env
	jq_SOURCE_ROOT=".env.sourceRoot"
	jq_SOURCE=".env.source"

       	# .env.private
	jq_TXADMIN_CACHE=".env.private.txadminCache"
	jq_DB_BKUP_PATH=".env.private.dbBkupPath"

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

}

define_configures() {
	_new_=0
	_all_new_=()
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	#  SERVER_NAME  ::  TXADMIN_CACHE  ::  DB_BKUP_PATH  ::  ARTIFACT_BUILD  ##
	#//////////////////////////////////////////////////////////////////////////
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	#  SOFTWARE_ROOT  ::  TFIVEM  ::  TCCORE  ##
	#///////////////////////////////////////////
	#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	#  MAIN  ::  GAME  ::  RESOURCES  ::  GAMEMODES  ::  MAPS  ::  ESX  #
	#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||#
	#  ESEXT ::  ESUI  ::  ESSENTIAL  ::    ESMOD    ::     VEHICLES    #
	#////////////////////////////////////////////////////////////////////

	color red - bold
	echo -e "\nI'm all up in the design, doin the configures!\n"
	color - - clearAll

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
		_TXADMIN_CACHE="${TXADMIN_CACHE:-$_TXADMIN_CACHE}"
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
		_DB_BKUP_PATH="${DB_BKUP_PATH:-$_DB_BKUP_PATH}"
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
		ARTIFACT_BUILD="${ARTIFACT_BUILD:-$_ARTIFACT_BUILD}"
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
		SERVER_NAME="${SOFTWARE_ROOT:-$_SOFTWARE_ROOT}"
		_all_new_+="SOFTWARE_ROOT"
		let _new_++
	fi
	SOFTWARE_ROOT="SOFTWARE_ROOT"  # I just did this to keep my structure below.  Its for me, shut up!
		TFIVEM="$SOFTWARE_ROOT/fivem"
			TCCORE="$TFIVEM/citizenfx.core.server"

	if [ "$RCON_PASSWORD" == "random" ]; then
            if [ ! "$DISABLE_RCON" ] ; then

		dateStamp="$(date +%B#%Y)"
		let "RCON_PASSWORD_LENGTH-=$(expr length $dateStamp)"
		salt="$( date +%s | sha256sum | base64 | head -c $RCON_PASSWORD_LENGTH; echo )"
		_RCON_PASSWORD="$salt$dateStamp"

		if "$RCON_ASK_TO_CONFIRM" ; then
		    echo ""
		    echo "You may enter a custom rcon password, or just accept the randomly generated one."
		    echo ""
		    echo "Leave blank and hit enter to use this (Recommended):"
		    echo "      $_RCON_PASSWORD"
		    echo ""
		    read -p "Enter an RCON password [leave blank to accept random]" RCON_PASSWORD
		    RCON_PASSWORD="${RCON_PASSWORD:-$_RCON_PASSWORD}"
		    _all_new_+="RCON_PASSWORD"
		    let _new_++
		else
		    RCON_PASSWORD="$_RCON_PASSWORD"
		    _all_new_+="RCON_PASSWORD"
		    let _new_++
		fi
	        rcon_password=RCON_PASSWORD # THIS SHOULD BE TEMPORARY / WAS THE OLD NAME- USING AN UPPER NOW
	    fi
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

build_env_config() {
	##################################################################################
	if [ ! -d "${CONFIG%/*}" ];
	then
		echo "No previous configuration found.  Building Privly folder & base config..."
		mkdir "${CONFIG%/*}"
		touch "$CONFIG"
		BASE_CONFIG="{}"
		# $BUILD/quick-config.sh
	else
		echo "Previous config found... Rebuilding with new config options..."
		echo ""
		_check=$( read -p 'are you sure you know what you are doing? (y/N)' )
		if [ "$_check"=="y" ];
		then
			if [ -z "$_CONFIG" ];
			then
				echo "The current config is not valid or is empty.  Starting over."
				BASE_CONFIG="{}"
			else
				BASE_CONFIG="$( echo $_CONFIG | jq 'del(.pref)' | jq 'del(.env)' )"

				if [ -z "$_ARTIFACT_BUILD" ]; then
					ARTIFACT_BUILD="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"
					color red - bold
					echo -e "Artifact build is not populated. Using hard-coded version: $ARTIFACT_BUILD"
					color - - clearAll
				else
					ARTIFACT_BUILD="$_ARTIFACT_BUILD"
				fi

				if [ -z "$_REPO_NAME" ]; then
					REPO_NAME="BERP-Source"
					color red - bold
					echo "Repository name is not populated. Using hard-coded version: $REPO_NAME"
					color - - clearAll
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
	    jq ".env.install += {\"vehicles\":\"${VEHICLES}\"}"		      > "$CONFIG"
}
