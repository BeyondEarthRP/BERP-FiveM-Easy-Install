#!/bin/bash
# -exabT
#\
#>\___________________
#>> THESE ARE MINE <3
#>>>>>>>>>>>>>>>>>>>>>
# INPUT A CONFIG ENTRY

pluck_fig() { # fig // prompt // confirm => 0/1

  [[ "$return__" ]] && unset return__ ; [[ "$__default" ]] && unset __default ;
  [[ "$__prompt__" ]] && unset __prompt___ ; [[ "$__prompt" ]] && unset __prompt ;
  [[ "$__verbose" ]] && unset __verbose ; [[ "$__min_len" ]] && unset __min_len ;
  [[ "$__max_len" ]] && unset __max_len ; [[ "$__return" ]] && unset __return ;
  [[ "$__confirm" ]] && unset __confirm ; [[ "$__def_applied" ]] && unset __def_applied ;
  [[ "$__p1" ]] && unset __p1 ; [[ "$__p1" ]] && unset __p1 ;
  [[ "$_p1" ]] && unset _p1 ; [[ "$_p2" ]] && unset _p2 ;

  #local __prompt="$2" ;
  local __prompt="$PROMPT" ; unset "$PROMPT"
  
  local __fig_key="$1" ; 
  local __verbose="$2" ;
  local __random="$3" ;
  local __min_len="$4" ;
  local __max_len="$5" ;
  
  if [ "$__random" == "true" ] ; 
  then
	local _pass="$(add_salt 64 1 date)"
	printf -v "_${__fig_key}" '%s' "$_pass"
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

		[[ "$__default" == "true" ]] || [[ "$__default" == "1" ]] && __verbose=10
		[[ "$__default" == "false" ]] || [[ "$__default" == "0" ]] && __verbose=11

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
        echo -e -n "$__prompt__: " && printf "\e[s" && read -n 1 yn ; # Prompt the user
        [[ ! -z "$yn" ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D" ;
        color - - clearAll ;

        [[ "${yn:=$__q}" ]]  # check user input against default (if blank and has a default)
        case "$yn" in
        [Yy]* ) local __return=true ; echo -e " Yes.\n" ; break ;;
        [Nn]* ) local __return=false ; echo -e " No.\n"  ; break ;;
            * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n" ;;
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
	    && echo -e -n "\n   \e[93m\e[1mRandom Password (Leave Blank to Accept):\n\n" \
	    && echo -e -n "        \e[33m> \e[31m$__default \e[33m<\e[0\n\n"
      color white - bold ;
      echo -n "$__prompt__: " ; # prompt the user
      color - - clearAll ;

      read __return ; # read in the user's response to the prompt
    fi

    if [[ ! -z "$__default" ]] ;
    then       # if there is a default value,
      [[ "${__return:=$__default}" ]] ;    # read in input or use default value.
    fi                                    # otherwise, just use the input even if it is blank


    ###############################
    # Input Validation
    ##
    if [ ! -z "$__return" ] ;
    then  # if there is an input that is not zero length
      [[ "$__invalid" ]] && unset __invalid   # clear whatever setting may be set to __invalid (dusting off the equipment)
      local __valid=1 # pre-validate the users input
      local __length="$(expr length $__return)"  # what is the length

      # CHECK IF IT IS CLEAN
      #local __CLEAN="${__return//[^a-zA-Z0-9]/}"
      local __CLEAN="$__return"

      if [ ! "$__CLEAN" == "$__return" ] ;
      then
        __invalid="Input must only include: a-z A-Z 0-9 spaces" ; unset __valid
      fi
      unset __CLEAN  # clean up

      # NUMBER VALIDATION
      if [ "$__verbose" == 20 ] ; # this is a number input
      then
        if [ "$__return" -eq "$__return" ] 2> /dev/null    # check if user entered a valid integer
        then # This is a number
          [[ ! "$__return" -ge "$__i1" ]] && __invalid="You've entered a number less than $__i1..." && unset __valid ;
          [[ ! "$__return" -le "$__i2" ]] && __invalid="You've entered a number greater than $__i2..." && unset __valid ;
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
    else
      local __invalid="No user input received from the console."  # invalidate user input with reason
      unset __valid   # revoke any potential validation
    fi  # done validating the users input

    # VALIDATION CHECK (DID THE ABOVE FLAG THIS? IF YES, INVALIDATE)
    [[ "$__return" ]] && [[ "$__invalid" ]] && unset __return  # if invalid, unset
    if [ "$__return" ] && [ "$__valid" ] ;  # if there is an input that is not zero length
    then # the input was found and validated
      if [ ! "$__verbose_prompt" ] ;  # If there is no confirmation prompt set
      then # then it has been disabled.
        local return__="$__return"  # do not confirm; set the value and move on.
        [[ "$__return" == *$'\r'* ]] || printf "\r"
        [[ "$__verbose" != 2 ]] && echo -e "Using \"$return__\"...\n"

        unset __return
        printf -v "${__fig_key}" '%s' "${return__}"

      else # otherwise, confirm with console that the value was correctly entered.
        unset __confirm  # unsetting a var before i read in user input
        while true;
        do # loop while
          [ ! -z "$__verbose_display" ] && echo -e "\n> $__return <\n"  # Console display of input (for confirmation)

          # echo the prompt with no newline; read the user input; backup 1 column (before newline)
          color white
          echo -e -n "$__question__: " && printf "\e[s" && read -n 1 yn
          [[ ! -z "$yn" ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
          color - - clearAll

          [[ "${yn:=$__p2}" ]]  # check user input against default (if blank and has a default)
          case "$yn" in
          [Yy]* ) local __confirm=y ; echo -e " Yes.\n" ;  break ;;
          [Nn]* ) echo -e " No.\n" ; break ;;
              * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n" ;;
          esac
        done

        if [ "$__confirm" ] ; then
          local return__="$__return"

          unset __return
          printf -v "${__fig_key}" '%s' "${return__}"

        else
          echo -e "\nOkay, user input cleared... Let's try that again.\n"
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

	_all_new_=()	
	
	# SERVER_NAME
	if [ "$__CONFIGURE__" ] || [ -z "$SERVER_NAME" ] ;
	then
		PROMPT="Enter the linux account to be used for FiveM"
		pluck_fig "SERVICE_ACCOUNT" "0" -
		_all_new_+="SERVER_NAME"
	fi

	# SERVICE_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$SERVICE_PASSWORD" ] ;
	then
		PROMPT=$(echo "Enter a password for $SERVICE_ACCOUNT")
		pluck_fig "SERVICE_PASSWORD" "s:n/y" true 9
		_all_new_+="SERVICE_PASSWORD"
	fi

	# DB_ROOT_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$DB_ROOT_PASSWORD" ] ;
	then
		PROMPT="Password for root account on MySQL"
		pluck_fig "DB_ROOT_PASSWORD" "s:n/y" true 16
		_all_new_+="DB_ROOT_PASSWORD"
	fi

	# MYSQL_USER
	if [ "$__CONFIGURE__" ] || [ -z "$MYSQL_USER" ] ;
	then
		PROMPT="Enter MySql username for the essentialmode database"
		pluck_fig "MYSQL_USER" "0" -
		_all_new_+="MYSQL_USER"
	fi

	# MYSQL_PASSWORD
	if [ "$__CONFIGURE__" ] || [ -z "$MYSQL_PASSWORD" ] ;
	then
		PROMPT=$(echo "Enter MySQL password for $MYSQL_USER")
		pluck_fig "MYSQL_PASSWORD" "s:n/y" true 16 128
		_all_new_+="MYSQL_PASSWORD"
	fi
	
	# BLOWFISH_SECRET
	if [ "$__CONFIGURE__" ] || [ -z "$BLOWFISH_SECRET" ] ;
	then
		PROMPT="Enter Blowfish Secret for PHP"
		pluck_fig "BLOWFISH_SECRET" "s:n/y" true 16
		_all_new_+="BLOWFISH_SECRET"
	fi

	# STEAM_WEBAPIKEY
	if [ "$__CONFIGURE__" ] || [ -z "$STEAM_WEBAPIKEY" ] ;
	then
		PROMPT="Enter your Steam Web API Key"
		pluck_fig "STEAM_WEBAPIKEY" "s:y/y" false
		_all_new_+="STEAM_WEBAPIKEY"
	fi

	# SV_LICENSEKEY
	if [ "$__CONFIGURE__" ] || [ -z "$SV_LICENSEKEY" ] ;
	then
		PROMPT="Enter your Cfx FiveM License"
		pluck_fig "SV_LICENSEKEY" "s:y/y" false
		_all_new_+="SV_LICENSEKEY"
	fi

	##########################################################################################
	# RCON DETAILS
	## THESE ARE NOT SETTINGS TO BE CHANGED- DOING SO WILL VOID THE MANUFACTURERS WARRANTY!

	# RCON
	if [ "$__CONFIGURE__" ] || [ -z "$RCON" ] ;
		PROMPT="Enable RCON (probably not needed)?"
		pluck_fig "RCON" 10 -
		_all_new_+="RCON"
	fi
	if [ "$RCON" == "true" ] ;
        then
		
		# RCON_PASSWORD_GEN
		if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD_GEN" ] ;
			PROMPT="(recommended) Allow RCON Passwords to be randomly generated?"
			pluck_fig "RCON_PASSWORD_GEN" 10 -
			_all_new_+="RCON_PASSWORD_GEN"
		fi
		if [ "$RCON_PASSWORD_GEN" == "true" ] ;
		then
		
			# RCON_PASSWORD_LENGTH
			if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD_LENGTH" ] ;
				PROMPT="Number of characters to generate?"
				pluck_fig "RCON_PASSWORD_LENGTH" 20 - 20 128
				_all_new_+="RCON_PASSWORD_LENGTH"
				
			fi

			# RCON_ASK_TO_CONFIRM
			if [ "$__CONFIGURE__" ] || [ -z "$RCON_ASK_TO_CONFIRM" ] ;
				PROMPT="(not recommended) Require manual approval of each randomly generated password"
				pluck_fig "RCON_ASK_TO_CONFIRM" 11 -
				_all_new_+="RCON_ASK_TO_CONFIRM"
								
			fi
		else
			# RCON_PASSWORD
			if [ "$__CONFIGURE__" ] || [ -z "$RCON_PASSWORD" ] ;
			then
				PROMPT="Enter RCON password:")
				pluck_fig "RCON_PASSWORD" "s:n/y" true 30 128
				_all_new_+="RCON_PASSWORD"
			fi			
        fi
	fi

	# TXADMIN_BACKUP_FOLDER
	if [ "$__CONFIGURE__" ] || [ -z "$TXADMIN_BACKUP_FOLDER" ] ;
		PROMPT="What name would you like for the txAdmin backup folder?"
		pluck_fig "TXADMIN_BACKUP_FOLDER" "s:y/y"
		_all_new_+="TXADMIN_BACKUP_FOLDER"
				
	fi

	# DB_BACKUP_FOLDER
	if [ "$__CONFIGURE__" ] || [ -z "$DB_BACKUP_FOLDER" ] ;	
		PROMPT="What name would you like for the MySQL backup folder?"
		pluck_fig "DB_BACKUP_FOLDER" "s:y/y"
		_all_new_+="DB_BACKUP_FOLDER"

	fi
	
	# ARTIFACT_BUILD
	if [ "$__CONFIGURE__" ] || [ -z "$ARTIFACT_BUILD" ] ;
		printf "\n" ; color red - bold ; color - - underline
		echo -e -n "**ONLY DO THIS IF YOU KNOW HOW! OTHERWISE, JUST HIT ENTER**" ; printf "\e\[0\n\n"
		color white - bold ; echo -e "What CFX Artifact Build would you like to use?" ; color - - clearAll

		PROMPT="Enter CFX Build Artifact"
		pluck_fig "ARTIFACT_BUILD" "s:y/y"
		_all_new_+="ARTIFACT_BUILD"
	fi
	
	# SOFTWARE_ROOT
	if [ "$__CONFIGURE__" ] || [ -z "$SOFTWARE_ROOT" ] ;	
	printf "\n" ; color yellow - bold ; color - - underline
		echo -e -n "NOTE: This is not the repo.  It is basically a cache of temporary downloads."
		printf "\e\[0\n"
	
		PROMPT="Where would you like to store the downloaded files?"
		pluck_fig "SOFTWARE_ROOT" "s:y/y"
		_all_new_+="SOFTWARE_ROOT"
	fi
		
	# REPO_NAME
	if [ "$__CONFIGURE__" ] || [ -z "$REPO_NAME" ] ;	
		PROMPT="What would you like to name the B.E.R.P. Source Repository?"
		pluck_fig "REPO_NAME" "s:y/y"
		_all_new_+="REPO_NAME"
	fi
	
	# SERVER_NAME
	if [ "$__CONFIGURE__" ] || [ -z "$SERVER_NAME" ] ;
		PROMPT="What would you like to name the server?"
		pluck_fig "SERVER_NAME" "s:y/y" -
		_all_new_+="SERVER_NAME"
	fi
	
	# _all_new_+="TXADMIN_CACHE"
	# let _new_++
	
	# if [ -z "$DB_BKUP_PATH" ]; then
	# fi	
	####
	TXADMIN_BACKUP="$PRIVATE/$TXADMIN_BACKUP_FOLDER"
	DB_BACKUPS="$PRIVATE/$DB_BACKUP_FOLDER"
	CFX_BUILD="$(echo $ARTIFACT_BUILD | cut -f1 -d-)"
	
}

cook_figs() {

	# WRITE THE FIGS TO THE JSON FILE
	
	[[ ! "$CONFIG" ]] && echo "Config write failed.  No config definition discovered..." && exit 1
	
	##################################################################################
	BASE_CONFIG="{}"
	if [ ! -d "${CONFIG%/*}" ];
	then
		echo "No previous configuration found.  Building Privly folder & base config..."
		mkdir "${CONFIG%/*}"
		touch "$CONFIG"
	else
		if [ "$_all_new_" ] && [ "${#_all_new_[@]}" -ne 0 ] ; then
			color lightYello - bold
			echo -e "\nPrevious config found... Rebuilding with new config options...\n"			
			echo "This will over-write the current config found at:"
			echo ""
			echo "        $CONFIG"
			color red - bold
			echo -e -n "\n  "
			color - - underline
			echo -e -n "Config items being added:"
			color - - noUnderline
			echo -e -n " \n"			
			color lightRed - bold
			for _cfug in "${_all_new_[@]}" ;
			do
				echo -e -n "$_cfug"
				color gray - bold
				echo -e -n " => "
				color red -
				echo -e -n "${!_cfug}"
			done
			
			         color - - clearAll

          color white - bold
          echo -e "Last chance to cancel..."
          color - - clearAll

          while [ -z "$__confirmed__" ] ;
          do
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
            if [ -z "$__confirmed__" ] ; then
              color red - bold ;
              echo -e "\nYou did not type 'YES' -- if you'd like to cancel, hit control-c" ; # Fired!
              color - - clearAll ;
            fi
          done
          color white - bold
          echo -e "\nOkay, writing the config...\n"
          color - - clearAll
		fi
	fi

	echo "$BASE_CONFIG"																	| \
	jq ". += {\"sys\":{}}"     	                                          	            | \
	jq ".sys += {\"acct\":{}}"                                                     		| \
		jq ".sys.acct += {\"user\":\"${SERVICE_ACCOUNT}\"}"                         	| \
		jq ".sys.acct += {\"password\":\"${SERVICE_PASSWORD}\"}"                        | \
	jq ".sys += {\"mysql\":{}}"                                                         | \
		jq ".sys.mysql += {\"user\":\"${MYSQL_USER}\"}"                                 | \
		jq ".sys.mysql += {\"password\":\"${MYSQL_PASSWORD}\"}"                         | \
		jq ".sys.mysql += {\"rootPassword\":\"${DB_ROOT_PASSWORD}\"}"                   | \
	jq ".sys += {\"rcon\":{}}"                                                          | \
		jq ".sys.rcon += {\"password\":\"${RCON_PASSWORD}\"}"                           | \
		jq ".sys.rcon += {\"pref\":{}}"                                                 | \
			jq ".sys.rcon.pref += {\"enable\":\"${RCON}\"}"                             | \
			jq ".sys.rcon.pref += {\"randomlyGenerate\":\"${RCON_PASSWORD_GEN}\"}"      | \
			jq ".sys.rcon.pref += {\"length\":\"${RCON_PASSWORD_LENGTH}\"}"          	| \
			jq ".sys.rcon.pref += {\"confirm\":\"${RCON_ASK_TO_CONFIRM}\"}"         	| \
	jq ".sys += {\"php\":{}}"                                                           | \
		jq ".sys.php += {\"blowfishSecret\":\"${BLOWFISH_SECRET}\"}"                    | \
		jq ".sys += {\"keys\":{}}"                                                      | \
			jq ".sys.keys += {\"fivemLicenseKey\":\"${SV_LICENSEKEY}\"}"                | \
	        jq ".sys.keys += {\"steamWebApiKey\":\"${STEAM_WEBAPIKEY}\"}"               | \
	jq ". += {\"pref\":{}}"                                            					| \
	  jq ".pref += {\"serverName\":\"${SERVER_NAME}\"}"									| \
	  jq ".pref += {\"artifactBuild\":\"${ARTIFACT_BUILD}\"}"							| \
	  jq ".pref += {\"repoName\":\"${REPO_NAME}\"}"										| \
	jq ". += {\"env\":{}}"																| \
	  jq ".env += {\"sourceRoot\":\"${SOURCE_ROOT}\"}"									| \
	  jq ".env += {\"source\":\"${SOURCE}\"}"											| \
	  jq ".env += {\"private\":{}}"														| \
	    jq ".env.private += {\"txadminCache\":\"$TXADMIN_CACHE\"}"						| \
	    jq ".env.private += {\"dbBkupPath\":\"${DB_BKUP_PATH}\"}"						| \
	  jq ".env += {\"software\":{}}"													| \
	    jq ".env.software += {\"softwareRoot\":\"${SOFTWARE_ROOT}\"}"					| \
	    jq ".env.software += {\"tfivem\":\"${TFIVEM}\"}"								| \
	    jq ".env.software += {\"tccore\":\"${TCCORE}\"}"								| \
	  jq ".env += {\"install\":{}}"														| \
	    jq ".env.install += {\"main\":\"${MAIN}\"}"										| \
	    jq ".env.install += {\"game\":\"${GAME}\"}"										| \
	    jq ".env.install += {\"resources\":\"${RESOURCES}\"}"							| \
	    jq ".env.install += {\"gamemodes\":\"${GAMEMODES}\"}"							| \
	    jq ".env.install += {\"maps\":\"${MAPS}\"}"										| \
	    jq ".env.install += {\"esx\":\"${ESX}\"}"										| \
	    jq ".env.install += {\"esext\":\"${ESEXT}\"}"									| \
	    jq ".env.install += {\"esui\":\"${ESUI}\"}"										| \
	    jq ".env.install += {\"essential\":\"${ESSENTIAL}\"}"							| \
	    jq ".env.install += {\"esmod\":\"${ESMOD}\"}"									| \
	    jq ".env.install += {\"vehicles\":\"${VEHICLES}\"}"								   > "$CONFIG"

}

