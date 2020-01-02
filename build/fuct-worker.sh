#!/bin/bash
# -exabT
#####################################################################
#
# A BIT OF FUNCTION
##
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
		if [ -n "$_rev1"] ;
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
	[[ -z "$_title" ]] && echo "no title definition.  can't be right..." && break

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
			  * ) echo -n -e "\t \xe2\x86\x92 $_item => ${!_item}\n" ;;
		esac
        done
        printf "\e[0m\n"
}

