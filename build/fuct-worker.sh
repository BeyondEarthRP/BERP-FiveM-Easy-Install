#!/bin/bash
# -exabT
#\
#>\___________________
#>> THESE ARE MINE <3 Jay
#>>>>>>>>>>>>>>>>>>>>>
# COLOR FOR ALL THE TERMS!
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
		_d=$(cat /dev/urandom | tr -dc "!@#%" | fold -w 1 | head -n 1)
	else
		_d=$(cat /dev/urandom | tr -dc "!@#$%&*_+?" | fold -w 1 | head -n 1)
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

salt_rcon() {
	if [ "$RCON" == "true" ] ; then
		if [ "$RCON_PASSWORD_GEN" == "true" ] ; then
			_RCON_PASSWORD="$( add_salt $RCON_PASSWORD_LENGTH 1 date )"
			local __RCON_PASSWORD="$RCON_PASSWORD"
			unset RCON_PASSWORD
			
			if "$RCON_ASK_TO_CONFIRM" ; then
				color lightYellow - bold
				echo ""
				echo "You may enter a custom rcon password, or just accept the randomly generated one."
				echo ""
				echo -e -n "Leave blank and hit enter to use this ("
				color - - underline
				echo -e -n "Recommended"
				color - - noUnderline
				echo -e "):"
				color green - bold
				echo "      $_RCON_PASSWORD"
				color lightYellow - bold
				echo ""
				echo -e -n "Enter an RCON password ["
				color red - underline
				echo -e -n "leave blank to accept random"
				color lightYellow - noUnderline
				color - - bold
				echo -e -n "]: " 
				color - - clearAll
				read RCON_PASSWORD
			fi
				
			RCON_PASSWORD="${__RCON_PASSWORD:=$_RCON_PASSWORD}"
			
			if [[ "$_RCON_PASSWORD" ]] && [[ "$RCON_PASSWORD" == "$_RCON_PASSWORD" ]] ;
			then
				jq ".sys.rcon.password=\"${RCON_PASSWORD}\"" $CONFIG > $CONFIG
			fi
			
			if [[ "$__RCON_PASSWORD" ]] && [[ "$RCON_PASSWORD" == "$__RCON_PASSWORD" ]] ;
			then
				color red - bold
				echo "Previously cached RCON password was used.  Auto-generated password didn't take for some reason."
				color - - clearAll
			fi
			
			[[ ! "$RCON_PASSWORD" ]] && echo "RCON Password Generation Failed..." && exit 1
			
		else
			color red - bold
			echo "You should make sure and change this password often!"
			color - - clearAll			
			RCON_PASSWORD="${RCON_PASSWORD:=$_RCON_PASSWORD}"
		fi
	fi	
	
}

define_configures() {
	#color red - bold
	#echo -e "\nI'm all up in the defines, doin the configures!\n"
	#color - - clearAll

	if [ -z "$PRIVATE" ]; then
		echo "Erp. Derp. Problems... I have no private! FAILED @ x0532!"
		exit 1
	fi

	[[ $SOFTWARE_ROOT ]] \
	  && TFIVEM="${TFIVEM:=$SOFTWARE_ROOT/fivem}" \
	  || echo "Configures error @ SOFTWARE_ROOT" && exit 1
	TFIVEM="${TCCORE:=$TFIVEM/citizenfx.core.server}"
	
	[[ $SERVICE_ACCOUNT ]] \
	  && MAIN="${MAIN:=/home/$SERVICE_ACCOUNT}" \
	  || echo "Configures error @ SERVICE_ACCOUNT" && exit 1
		GAME="${GAME:=$MAIN/server-data}"
			RESOURCES="${RESOURCES:=$GAME/resources}"
				GAMEMODES="${GAMEMODES:=$RESOURCES/[gamemodes]}"
					MAPS="${MAPS:=$GAMEMODES/[maps]}"
				ESX="${ESX:=$RESOURCES/[esx]}"
					ESEXT="${ESEXT:=$ESX/es_extended}"
					ESUI="${ESUI:=$ESX/[ui]}"
				ESSENTIAL="${ESSENTIAL:=$RESOURCES/[essential]}"
					ESMOD="${ESMOD:=$ESSENTIAL/essentialmode}"
				VEHICLES="${VEHICLES:=$RESOURCES/[vehicles]}"
}

# THIS STOPS A SCREEN SESSION.
stop_screen() {
  SCREEN_SESSION_NAME="fivem"
  echo "Quiting screen session '$SCREEN_SESSION_NAME' for FiveM (if applicable)"
  su "$SERVICE_ACCOUNT" -c "screen -XS '$SCREEN_SESSION_NAME' quit"
}
###
# SLEEP ... nuf'said
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
#
###
# invert (if set, unset // if unset, set to 1)
#   BASH BOOLEAN
invert() {
  local __result="$1"
  if [ "${!__result}" ]; then
    eval unset "$__result"
    #FALSE
  else
    eval "$__result"=1
    #TRUE
  fi
}
