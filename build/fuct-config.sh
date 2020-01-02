#!/bin/bash
# -exabT
#\
#>\___________________
#>> THESE ARE MINE <3
#>>>>>>>>>>>>>>>>>>>>>
# INPUT A CONFIG ENTRY

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
}

load_user_defaults() {

        local DEFFIGS=(                                                               \
                SERVICE_ACCOUNT         MYSQL_USER		RCON_ENABLE           \
                STEAM_WEBAPIKEY         SV_LICENSEKEY                                 \
                RCON_PASSWORD_GEN       RCON_PASSWORD_LENGTH                          \
                RCON_ASK_TO_CONFIRM     SERVER_NAME             ARTIFACT_BUILD        \
                REPO_NAME		SOURCE_ROOT		SOURCE	              \
		TXADMIN_BACKUP		DB_BACKUPS                                    \
                SOFTWARE_ROOT           TFIVEM                  TCCORE                \
                MAIN                    GAME                    RESOURCES             \
                GAMEMODES               MAPS                    ESX                   \
                ESEXT                   ESUI                    ESSENTIAL             \
                ESMOD                   VEHICLES                TXADMIN_BACKUP_FOLDER \
                DB_BACKUP_FOLDER        		                              \
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
  then                                                                                          # otherwise, do nothing but clean up
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
  if [ ! -z "$__verbose" ] ;                                                                     # If the confirmation is enabled
  then                                                                        # check if the setting is a valid int (1 = on / 2 = off)
    if [[ "$__verbose" =~ '^[0-9]+$' ]] ;                                                     # If this validation checks out okay
    then                                                      # this is a number, not a defininition string; Using the on/off assignment
      if [ "$__verbose" -eq 1 ] ;
      then                                                        # if it is set to 1, use quick settings- C:N
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
    else       																										 # because this is not a valid int, this prompt has param settings
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


harvest() {
	# COLLECT ALL FIGS FROM USER AND PREPARE TO WRITE

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
	# FIG  dialog:default/display random MIN  MAX #
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

	load_static_defaults
	load_user_defaults

	[[ "$_all_new_" ]] && unset _all_new_ ; _all_new_=()

	PROMPT="Would you like to see advanced configuration options? (probably not)"
	pluck_fig "__ADVANCED__" 11 false

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

			if [ "$__ADVANCED__" == "true" ] ;
			then
				# RCON_PASSWORD_LENGTH
				if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD_LENGTH" ] ;
				then
					PROMPT="Number of characters to generate?"
					pluck_fig "RCON_PASSWORD_LENGTH" 20 false 20 128
					_all_new_+=("RCON_PASSWORD_LENGTH")
				fi
			else
				RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH"
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
		RCON_PASSWORD_GEN="$_RCON_PASSWORD_GEN"
		RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH"
		RCON_ASK_TO_CONFIRM="$_RCON_ASK_TO_CONFIRM"
	fi

	if [ "$__ADVANCED__" == "true" ] ;
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
		TXADMIN_BACKUP_FOLDER="$_TXADMIN_BACKUP_FOLDER" && _all_new_+=("TXADMIN_BACKUP_FOLDER")
		DB_BACKUP_FOLDER="$_DB_BACKUP_FOLDER" &&  _all_new_+=("DB_BACKUP_FOLDER")
		ARTIFACT_BUILD="$_ARTIFACT_BUILD" &&  _all_new_+=("ARTIFACT_BUILD")
		SOFTWARE_ROOT="$_SOFTWARE_ROOT" &&  _all_new_+=("SOFTWARE_ROOT")
		REPO_NAME="$_REPO_NAME" &&  _all_new_+=("REPO_NAME")
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

cook_figs() {

	# WRITE THE FIGS TO THE JSON FILE
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

	pluck_fig "__REVIEW__" 11 false
	if [ "$__REVIEW__" == "true" ] ;
	then
		if [ -n "$_type_name" ] ;
		then
			PROMPT="Would you like to review the $_type_name configuration?"
			local _head="${_type_name^^} CONFIGURATION"
		else
			PROMPT="Would you like to review the configuration?"
			local _head="CONFIGURATION"
		fi

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

	[[ -z "$__RUNTIME__" ]] && get_env_config_paths
	[[ -z "$__RUNTIME__" ]] && get_system_config_paths

	_fruit="${!_fig}"
	_yield=$(eval echo \${$_crop} | jq $_path=\""$_fruit"\")

	[[ -n "$_yield" ]] && printf -v "$_crop" '%s' "$_yield" \
	  || echo "\n\e[97merror planting fig!\e[0m"
}








########################################################################
# SOME STUFF I AM TESTING -- NOT CURRENTLY IN USE OR PART OF ANY ACTION
########################################################################

harvester(){
        [[ ! "$FIGTREE" ]] && echo "I need a fig tree to harvest..." && exit 1

        local _figs=$(<"$FIGTREE" jq '. | keys[]')
        _figs=($(echo "${_figs//\"/}" | tr '\n' ' '))

        for fig in "${_figs[@]}"
        do
                echo -e "\n$fig"
                local _seedpods=$(<"$FIGTREE" jq --arg fig "$fig" '.[$fig] | keys[]')
                _seedpods=($(echo "${_seedpods//\"/}" | tr '\n' ' '))
                for seedpod in "${_seedpods[@]}"
                do
                        _seed=$(<"$FIGTREE" jq --arg fig "$fig" --arg seedpod "$seedpod" '.[$fig][$seedpod]')
                        seed="${_seed//\"/}"

                        [[ ! -z "$seed" ]] && [[ "$seed" != "null" ]] && printf -v "__$seedpod" '%s' "$seed"

                        echo "__$seedpod: $(eval echo \${__$seedpod})"
                done

                printf -v "PROMPT" '%s' "$__prompt"
                pluck_fig "$fig" "${__verbose:=0}" "${__random:=false}" "${__min:=''}" "${__max:=''}"
        done

}

figsower() {

	[[ ! "$FIGTREE" ]] && echo "I need a fig tree to sow..." && exit 1

	local _cfug="$1"

	[[ ! -z "$2" ]] && local _vbose="$2" || local _vbose="null"
	[[ ! -z "$3" ]] && local _rdom="$3"  || local _rdome="null"
	[[ ! -z "$4" ]] && local _min="$4"   || local _min="null"
	[[ ! -z "$5" ]] && local _max="$5"   || local _max="null"

	local _figtree="$(cat ${FIGTREE})"
	[[ -z "$_figtree" ]] && local _figroot="{}" \
			     || local _figroot="$_figtree"

	unset _figtree
	_figtree="$( echo ${_figroot} | jq . )"
	_figtree=$( echo ${_figtree} | jq --arg prompt "$PROMPT" --arg FIG "$_cfug" '.[$FIG].prompt=$prompt' )
	_figtree=$( echo ${_figtree} | jq --arg verbose "$_vbose" --arg FIG "$_cfug" '.[$FIG].verbose=$verbose' )
	_figtree=$( echo ${_figtree} | jq --arg random "$_rdom" --arg FIG "$_cfug" '.[$FIG].random=$random' )
	_figtree=$( echo ${_figtree} | jq --arg min "$_min" --arg FIG "$_cfug" '.[$FIG].min=$min' )
	_figtree=$( echo ${_figtree} | jq --arg max "$_max" --arg FIG "$_cfug" '.[$FIG].max=$max' )
	[[ ! -z "$_figtree" ]] && ( echo "$_figtree" | jq . > "$FIGTREE" )

	unset _figtree ; unset _cfug ; unset _prompt ;
	unset _vbose ; unset _rdom ; unset _min ; unset _max ;
}

