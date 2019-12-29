#!/bin/bash
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
	_d1=$(cat /dev/urandom | tr -dc "!@#$%&*_+?" | fold -w 1 | head -n 1)
	_d2=$(cat /dev/urandom | tr -dc "!@#$%&*_+?" | fold -w 1 | head -n 1)

	#make stamp
	if [ -n "$__stamp" ] ;
	then
		case "$__stamp" in
		  "date" ) local _shakerStamp="${_d1}$(date +%B${_d2}%Y)" ;;
		       * ) local _shakerStamp="${_d1}$__stamp" ;;
		esac ;
		local __len="$(( $__len - ${#_shakerStamp} ))"
		[ "$__len" -lt 0 ] && __len=3 && _shakerStamp="${_shakerStamp:3}"
	fi

	# make salt
	case "$__salt" in
	  0 ) local _salt="$(date +%s | sha256sum | base64 | head -c ${__len}; echo)" ;;
	  1 ) local _salt=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%^&*()_+?><~" | fold -w "$__len" | head -n 1) ;;
	  * ) local _salt="$(date +%s | sha256sum | base64 | head -c ${__len}; echo)" ;;
	esac ;

	# if __stamp is empty, then just add salt / otherwise, add salt and the shaker stamp
	[ ! "$__stamp" ] && local __shaker="${_salt}" || local __shaker="${_salt}${_shakerStamp}"

	# This is needed to return for variable assignment
	echo "$__shaker"
}
