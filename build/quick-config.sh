#!/bin/bash -exabT
###################################################################
# BEGIN BUILDING A NEW BERP BUILDER CONFIG INGEST FILE
###################################################################
### check if I'm starting from the build directory...
### I assume this is correct.  It should be, let us see!
THIS_SCRIPT_ROOT=`dirname "$(readlink -f $0)"`
[[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] \
&& BUILD="$THIS_SCRIPT_ROOT"
###################################################################

[[ -z $CONFIG ]] && . $BUILD/build-env.sh RUNTIME
####
# If assumptions were correct, we should not fail!
if [ -z $CONFIG ] ; then
	echo "No config file has been defined.  I'VE FAILED!"
	exit 1
fi
#################################################################
# DEFAULTS
[[ ${_SERVICE_ACCOUNT:="fivem"} ]]
[[ ${_MYSQL_USER:="admin"} ]]

[[ ${RCON:=true} ]]
[[ ${RCON_PASSWORD_GEN:=true} ]]
[[ ${RCON_PASSWORD_LENGTH:=64} ]]
[[ ${ASK_TO_ACCEPT:=false} ]]
##################################################################
#
#\    DEFINE A BIT OF FUNCTION
#>\____________________
#>> OBTAINED ELSEWHERE
#>>>>>>>>>>>>>>>>>>>>>>

#\
#>\___________________
#>> THESE ARE MINE
#>>>>>>>>>>>>>>>>>>>>>
# INPUT A CONFIG ENTRY
arg_constructor() {
  local _1="$1"
  local _2="$2"
  if [ -n "$(eval echo \${$_1[1]})" ] ;
  then
    echo "array"
    local _v1="$(eval echo \${$_1[0]})" && printf -v "${_1}" '%s' "${_v1}"
    local _v2="$(eval echo \${$_1[1]})" && printf -v "${_2}" '%s' "${_v2}"
  else
    echo "string / not array"
    printf -v "${_1}" '%s' "${!_1}" && printf -v "${_2}" '%s' "n"
  fi
}

color(){
  [[ ! $2 ]] || [[ "$2" == "0" ]] && __back="clear"
  [[ ! $1 ]] || [[ "$1" == "0" ]] && __fore="clear"
  local __fore=$1
  local __back=$2
  local __dcor=$3

  if [ "$__fore" != "-" ] ;
  then
    case $__fore in
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
    case $__back in
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
    case $__dcor in
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

input_fig_entry() { # fig // prompt // confirm => 0/1

  [[ "$return__" ]] && unset return__ ; [[ "$__default" ]] && unset __default ;
  [[ "$__prompt__" ]] && unset __prompt___ ; [[ "$__prompt" ]] && unset __prompt ;
  [[ "$__verbose" ]] && unset __verbose ; [[ "$__min_len" ]] && unset __min_len ;
  [[ "$__max_len" ]] && unset __max_len ; [[ "$__return" ]] && unset __return ;
  [[ "$__confirm" ]] && unset __confirm ; [[ "$__def_applied" ]] && unset __def_applied ;
  [[ "$__p1" ]] && unset __p1 ; [[ "$__p1" ]] && unset __p1 ;
  [[ "$_p1" ]] && unset _p1 ; [[ "$_p2" ]] && unset _p2 ;

  local __fig_key=$1 ; local __prompt=$2 ;
  local __verbose=$3 ; local __min_len=$4 ;
  local __max_len=$5 ;

                                                   # I got this working then realized i didn't need it/ or the above function. derp.
                                                 # declare -a local __prompt=("${!2}")  ## Just saving it here for future reference.
                                                                                         # arg_constructor __prompt  __default_input

  if [ ! -z $__min_len ] && [ ! -z $__max_len ] ;                                               # if there both a min and max length
  then                                        # it has a minimum & maximum length required- update the prompt to reflect requirement
    __prompt=$(echo -n "$__prompt (length: $__min_len to $__max_len )")
  elif [ ! -z $__min_len ] && [ -z $__max_len ] ;                                                    # if there is only a min length
  then                                                 # it has a minimum length required- update the prompt to reflrect requirement
    __prompt=$(echo "$__prompt (min length: $__min_len)")
    unset __max_len
  else                                                                                          # otherwise, do nothing but clean up
    [[ $__min_len ]] && unset __min_len ; [[ $__max_len ]] && unset __max_len
  fi

                                                     # Pull the default and update the prompt (if applicable)- otherwise, do nothing
  local __default="$(eval echo \$_${__fig_key})"                                                         # Pick up the default value
                                                                   # if it is blank, unset the var ; otherwise, add it to the prompt
  [[ -z $__default ]] && unset __default || local __prompt__="$(echo $__prompt [$__default])"

                                                                  # Assign the prompt (with or without default value)- then clean up
  [[ ${__prompt__:=$__prompt}  ]] && unset __prompt
  if [ ! -z $__verbose ] ;                                                                          # If the confirmation is enabled
  then                                                                      # check if the setting is a valid int (1 = on / 2 = off)
    if [[ $__verbose =~ '^[0-9]+$' ]] ;                                                         # If this validation checks out okay
    then                                                  # this is a number, not a defininition string; Using the on/off assignment
      if [ $__verbose -eq 1 ] ;                                                         # if it is set to 1, use quick settings- C:N
      then
        local __verbose_prompt="C:N"
      elif [ $__verbose -eq 10 ] || [ $__verbose -eq 11 ] ;
      then
        unset __verbose_prompt
        unset __verbose_display
      else
        unset __verbose_prompt
        unset __verbose_display
        unset __verbose
      fi
    else # because this is not a valid int, this prompt has param settings
      local __verbose_prompt=$(echo $__verbose | cut -f1 -d/) # collect the prompt params
    fi

    if [ $__verbose == 10 ] || [ $__verbose == 11 ] || [ $__verbose == 20 ] ;
    then
      local __prompt=$__prompt__   # temporarily reassign the current ongoing prompt building
      unset __prompt__    # unset for reassignment

      if [ $__verbose == 20 ] ;
      then
        if [ ! -z $__min_len ] && [ ! -z $__max_len ] ; then
          local _i="($__min_len to $__max_len)"  # build the prompt addition
          local __i1=$__min_len  # build a default value (using the min val)
          local __i2=$__max_len  # I guess this is redundant... oh well.
          local __i3=$(expr length $__max_len)
        fi
        local __prompt__="$__prompt $_i"  # build the new prompt and assign to prompt
      fi

      if [ $__verbose == 10 ] || [ $__verbose == 11 ] ;
      then
        local __prompt=$__prompt__   # temporarily reassign the current ongoing prompt building
        unset __prompt__    # unset for reassignment
        case $__verbose in   # if verbose
          10 ) local _q="[Y/n]" ; local __q=y ;;  # is 10, make Yes the default
          11 ) local _q="[N/y]" ; local __q=n ;;  # is 11, make No the default
        esac;
        local __prompt__="$__prompt $_q"  # build the new prompt and assign to prompt
      fi
      [[ ${__prompt__:=$__prompt} ]]   # if for some reason, this didn't work... take the previous prompt back
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
        [Yy]* ) local _p2="[Y/n]" ; local __p2=y ;;
        [Nn]* ) local _p2="[N/y]" ; local __p2=n ;;
            * ) local _p2="[N/y]" ; local __p2=N ;;
      esac;
      # End confirmation message definition & building

      # if settings still both exist (this should), then I redefine the prompt settings (just in case catchall)
      [[ ! -z "$__p1" ]] && [[ ! -z "$__p2" ]] && local __verbose_prompt="$__p1:$__p2"
      # If both pieces of the prompt exist, assign the confirmation message to it's var
      [[ ! -z "$_p1" ]] && [[ ! -z "$_p2" ]] && local __question__="$_p1 $_p2"

      # get the user input feedback display setting or use the default (which is to not display input feedback)
      local __verbose_display=$(echo $__verbose | cut -f2 -d/)
      [[ ${__verbose_display} == "n" ]] && unset __verbose_display  # display is enabled, otherwise unset var
    else  # just clean up
      [[ $__verbose_prompt ]] && unset __verbose_prompt
      [[ $__verbose_display ]] && unset __verbose_display
    fi
  else  # more cleaning
    [[ $__verbose ]] && unset __verbose
  fi  # done with building the confirmation prompt

  [[ $__return ]] && unset __return  # unsetting any potential. this is probably overkill- just making sure
  [[ $return__ ]] && unset return__

  while [ -z $return__ ] ;
  do # while no value has been committed
    if [ $__verbose == 10 ] || [ $__verbose == 11 ] || [ $__verbose == 20 ] ;
    then
      color white - bold
      if [ $__verbose == 10 ] || [ $__verbose == 11 ] ;
      then
        echo -e -n "$__prompt__: " && printf "\e[s" && read -n 1 yn
        [[ ! -z $yn ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
        color - - clearAll

        [[ ${yn:=$__q} ]]  # check user input against default (if blank and has a default)
        case $yn in
        [Yy]* ) local __return=true ; echo -e " wYes.\n" ; break ;;
        [Nn]* ) local __return=false ; echo -e " No.\n"  ; break ;;
            * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n" ;;
        esac
      elif [ $__verbose == 20 ] ;
      then
        echo -e -n "$__prompt__: " && printf "\e[s" && read -n $__i3 int

        local __valid=1
        if [[ $int =~ '^[0-9]+$' ]] ; # check if user entered a valid int
        then # This is a number
          [[ ! $int -ge $__i1 ]] && __invalid="You've entered a number less than $__i1..." && unset __valid
          [[ ! $int -le $__i2 ]] && __invalid="You've entered a number greater than $__i2..." && unset __valid
        else
          __invalid="You must use only numbers here." && unset __valid
        fi
        [[ $__valid ]] && local __return=$int
        unset __valid
      fi
    else
      color white - bold
      echo -n "$__prompt__: "  # prompt the user
      color - - clearAll
      read __return  # read in the user's response to the prompt
    fi

    if [[ ! -z $__default ]] ;
    then       # if there is a default value,
      [[ ${__return:="$__default"} ]]     # read in input or use default value.
    fi                                    # otherwise, just use the input even if it is blank

    if [ ! -z $__return ] ;
    then  # if there is an input that is not zero length
      [[ $__invalid ]] && unset __invalid   # clear whatever setting may be set to __invalid (dusting off the equipment)
      local __valid=1  # pre-validate the users input
      local __length=$(expr length $__return)  # what is the length
      if [ $__min_len ] && [ ! "$__length" -ge "$__min_len" ] ;
      then
        local __invalid="Minimum length required."    # invalidated user input with reason
        unset __valid    # revoke validation
      fi

      if [ $__max_len ] && [ ! "$__length" -le "$__max_len" ] ;
      then
        local __invalid="Too many characters entered."    # invalidate user input with reason
        unset __valid    # revoke validation
      fi
      unset __length    # clean up
    else
      local __invalid="No user input received from the console."  # invalidate user input with reason
      unset __valid   # revoke any potential validation
    fi  # done validating the users input

    [[ $__return ]] && [[ $__invalid ]] && unset __return  # if invalid, unset
    if [ $__return ] && [ $__valid ] ;  # if there is an input that is not zero length
    then # the input was found and validated
      if [ ! $__verbose_prompt ] ;  # If there is no confirmation prompt set
      then # then it has been disabled.
        local return__="$__return"  # do not confirm; set the value and move on.
        [[ $__verbose != 2 ]] && echo -e "Using \"$return__\"...\n"
        unset __return
      else # otherwise, confirm with console that the value was correctly entered.
        unset __confirm  # unsetting a var before i read in user input
        while true;
        do # loop while
          [ ! -z $__verbose_display ] && echo -e "\n> $__return <\n"  # Console display of input (for confirmation)

          # echo the prompt with no newline; read the user input; backup 1 column (before newline)
          color white
          echo -e -n "$__question__: " && printf "\e[s" && read -n 1 yn
          [[ ! -z $yn ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
          color - - clearAll

          [[ ${yn:=$__p2} ]]  # check user input against default (if blank and has a default)
          case $yn in
          [Yy]* ) local __confirm=y ; echo -e " Yes.\n" ;  break ;;
          [Nn]* ) echo -e " No.\n" ; break ;;
              * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n" ;;
          esac
        done
        if [ $__confirm ] ; then
          local return__="$__return"

          unset __return
          printf -v "${__fig_key}" '%s' "${return__}"
        else
          echo -e "\nOkay, user input cleared... Let's try that again.\n"
        fi
      fi
    else
      echo ""
      [[ $__invalid ]] && echo $__invalid && unset __invalid
      echo -e "Input not valid.  Please try again.\n"
    fi
  done
  unset __prompt__ ; unset return__ ;  unset __confirm ; unset __question__ ;
}

##################################################################
# AND.... GO!
unset _confirm
while true ;
do
  color red - bold
  echo -e "We are about to create a configuration file to be used for deployment(s)."
  # read it; check for user input or use default value; ignore the new line (back up!)
  color white - bold
  echo -e -n "Continue? [Y/n]: \e[s"
  read -n 1 yn
  [[ ! -z $yn ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
  color - - clearAll

  [[ ! -z ${yn:=y} ]]
  case $yn in
    [Yy]* ) _confirm=y && echo -e " Yes, continue.\n" && break;;
    [Nn]* ) _confirm=n && echo -e " No, exit.\n" && break;;
    * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n";;
  esac
done

if [ $_confirm == n ] ; then
	echo "Okay... leaving quick config. Goodbye!"
	exit 0
else
	# FIG  PROMPT  dialog:default/display  MIN  MAX
	PROMPT="Enter the linux account to be used for FiveM"
#	input_fig_entry "SERVICE_ACCOUNT" "$PROMPT" "0"

        PROMPT=$(echo "Enter a password for $SERVICE_ACCOUNT")
#	input_fig_entry "SERVICE_PASSWORD" "$PROMPT" "s:n/y" 9

        PROMPT="Password for root account on MySQL"
#	input_fig_entry "DB_ROOT_PASSWORD" "$PROMPT" "s:n/y" 16

	PROMPT="Enter MySql username for the essentialmode database"
#	input_fig_entry "MYSQL_USER" "$PROMPT" "0"

	PROMPT=$(echo "Enter MySQL password for $MYSQL_USER")
#	input_fig_entry "MYSQL_PASSWORD" "$PROMPT" "s:n/y" 16 128

	PROMPT="Enter Blowfish Secret for PHP"
#	input_fig_entry "BLOWFISH_SECRET" "$PROMPT" "s:y/y" 16

	PROMPT="Enter your Steam Web API Key"
#	input_fig_entry "STEAM_WEBAPIKEY" "$PROMPT" "s:y/y"

	PROMPT="Enter your Cfx FiveM License"
#	input_fig_entry "SV_LICENSEKEY" "$PROMPT" "s:y/y"

	##########################################################################################
	# RCON DETAILS
	## THESE ARE NOT SETTINGS TO BE CHANGED- DOING SO WILL VOID THE MANUFACTURERS WARRANTY!

	# ENABLE?
	PROMPT="Enable RCON (probably not needed)?"
        input_fig_entry "RCON" "$PROMPT" 10

	if [ $RCON == "true" ] ; then
          PROMPT="(recommended) Allow RCON Passwords to be randomly generated?"
          input_fig_entry "RCON_PASSWORD_GEN" "$PROMPT" 10

          if [ $RCON_PASSWORD_GEN == "true" ] ; then
            PROMPT="Number of characters to generate?"
            input_fig_entry "RCON_PASSWORD_LENGTH" "$PROMPT" 20 20 128

		##
		# RANDOM GENERATION OF PASSWORDS
		_prompt="";_prompt="(recommended) Allow RCON Passwords to be randomly generated? [Y/n]:"

		echo ""
		_confirm="";read -p "$_prompt " _confirm
		if [ "$_confirm"=="n" ] || [ "$_confirm"=="no" ] ; then
			RCON_PASSWORD_GEN=false
		fi
		if $RCON_PASSWORD_GEN ; then
			##
			# HOW LONG SHOULD THE PASSWORDS BE?
			_prompt="";_prompt="Number of characters to generate (20-128)? [$RCON_PASSWORD_LENGTH]:"
			_RCON_PASSWORD_LENGTH=RECON_PASSWORD_LENGTH # i feel like there is a better way... haha oh well.  open to assistance.
			RCON_PASSWORD_LENGTH=""
			while [ -z RCON_PASSWORD_LENGTH ] ; do
				echo ""
				_confirm="";read -p "$_prompt" _rclen
				if [ -z $_rclen ] ; then
					RCON_PASSWORD_LENGTH="$_RCON_PASSWORD_LENGTH"
				elif [ "$_rclen" -ge "20" ] && [ "$_rclen" <= "128" ] ; then
					RCON_PASSWORD_LENGTH="$_rclen"
				else
					echo ""
					echo "Something is not right.  Please enter a number between 20 and 128... or just leave blank and hit enter to accept the default."
				fi
			done
			##
			# ASK TO ACCEPT (EACH TIME)
			_prompt="";_prompt="(not recommended) Require manual approval of each randomly generated password [y/N]:"

			echo ""
			_confirm="";read -p "$_prompt " _confirm
			if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ] ; then
				ASK_TO_ACCEPT=true
			fi
		fi
	else
		RCON=false
	fi
	if [ -f $CONFIG ] ; then
		echo "This will over-write the current config found at:"
		echo ""
		echo "        $CONFIG"
		echo ""
		read -p "Last chance to cancel... continue? [N/y]"
		if [ ! "$_confirm"=="y" ] || [ ! "$_confirm"=="yes" ] ; then
			echo "installation canceled by user.  exiting."
			exit 1
		fi
	fi

	# .sys.acct.user = SERVICE_ACCOUNT
	# .sys.acct.password = SERVICE_PASSWORD
	# .sys.mysql.user = MYSQL_USER
	# .sys.mysql.passwor = MYSQL_PASSWORD
	# .sys.mysql.rootPassword = DB_ROOT_PASSWORD
	# .sys.php.blowfishSecret = BLOWFISH_SECRET
	# .sys.keys.fivemLicenseKey = SV_LICENSEKEY
	# .sys.keys.steamWebApiKey = STEAM_WEBAPIKEY

													BASE_CONFIG={}
        echo "$BASE_CONFIG"                                                                              | \
        jq ". += {\"sys\":{}}"                                                                           | \
	        jq ".sys += {\"serviceAccount\":{}}"                                                     | \
			jq ".sys.acct += {\"user\":\"${SERVICE_ACCOUNT}\"}"                              | \
			jq ".sys.acct += {\"password\":\"${SERVICE_PASSWORD}\"}"                         | \
		jq ".sys += {\"mysql\":{}}"                                                              | \
			jq ".sys.mysql += {\"user\":\"${MYSQL_USER}\"}"                                  | \
			jq ".sys.mysql += {\"password\":\"${MYSQL_PASSWORD}\"}"                          | \
			jq ".sys.mysql += {\"rootPassword\":\"${DB_ROOT_PASSWORD}\"}"                    | \
		jq ".sys += {\"rcon\":{}}"                                                               | \
			jq ".sys.rcon += {\"password\":\"${RCON_PASSWORD}\"}"                            | \
			jq ".sys.rcon += {\"pref\":{}}"                                                  | \
				jq ".sys.rcon.pref += {\"enable\":\"${RCON}\"}"                          | \
				jq ".sys.rcon.pref += {\"randomlyGenerate\":\"${RCON_PASSWORD_GEN}\"}"   | \
				jq ".sys.rcon.pref += {\"length\":\"${RCON_PASSWORD_LENGTH}\"}"          | \
				jq ".sys.rcon.pref += {\"confirm\":\"${ASK_TO_CONFRM}\"}"                | \
		jq ".sys += {\"php\":{}}"                                                                | \
			jq ".sys.php += {\"blowfishSecret\":\"${BLOWFISH_SECRET}\"}"                     | \
		jq ".sys += {\"keys\":{}}"                                                               | \
	                jq ".sys.keys += {\"fivemLicenseKey\":\"${SV_LICENSEKEY}\"}"                     | \
	                jq ".sys.keys += {\"steamWebApiKey\":\"${STEAM_WEBAPIKEY}\"}"			> $CONFIG

fi
