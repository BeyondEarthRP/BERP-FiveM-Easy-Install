#!/bin/bash
# -ex
#\
#>\___________________
#>> THESE ARE MINE
#>>>>>>>>>>>>>>>>>>>>>
# BUILD OUT THE RUN TIME DETIALS
### check if I'm starting from the build directory...
### I assume this is correct.  It should be, let us see!
if [ -z "$BUILD" ] ;
then
  THIS_SCRIPT_ROOT=$(dirname $(readlink -f "$0")) ;
  BUILDCHECK=()
  BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../../build") ) || true
  BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../build") )    || true
  BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/build") )       || true
  BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}") )             || true
  unset THIS_SCRIPT_ROOT ;
  for cf in "${BUILDCHECK[@]}" ;
  do
    if [ -d "$cf" ] && [ -f "${cf:?}/build-env.sh" ] ;
    then
        BUILD="$cf"
    fi
  done
fi
[[ -z "$BUILD" ]] && echo "Build folder undefined. Failed." && exit 1
#-----------------------------------------------------------------------------------------------------------------------------------

#####################################################################
# IMPORT FUNCTIONS
. "$BUILD/includes.sh"

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- BUILD ENVIRONMENT ---- ##

	if [ "$APPMAIN" != "CONFIG" ] ;
	then
		initialize QUIETLY
		define_runtime_env QUIETLY
	else
		initialize
		define_runtime_env
	fi
	unset __INVALID_CONFIG__
	check_configuration QUIETLY
	if [ "$APPMAIN" != "CONFIG" ] && [ -n "$__INVALID_CONFIG__" ] ;
	then
		__LOADING_STOPPED__="1" && loading 1 CONFIG
	fi

	while [ -n "$__INVALID_CONFIG__" ] ;
	do
		case "$APPMAIN" in
		      "CONFIG" ) printf "Preparing configuration wizard..." ;;
			     * ) . "$BUILD/quick-config.sh" CONFIGURE ; break ;;

		esac
		unset __INVALID_CONFIG__
		check_configuration
	done
	unset __INVALID_CONFIG__

	[[ "$APPMAIN" != "CONFIG" ]] && [[ -n "$__LOADING_STOPPED__" ]] \
	  && printf "\\n\\n" && loading && unset __LOADING_STOPPED__

	while [ -z "$__READY__" ] ;
	do
		unset __CONFIG_UNFINISHED__
		unset __SILENTLY_ACCEPT_DEFAULTS__
		if [ "$APPMAIN" != "CONFIG" ] && [ -n "$__LOADING_STOPPED__" ] ;
		then
			unset __LOADING_STOPPED__ && loading
		elif [ "$APPMAIN" != "CONFIG" ] ;
		then
			loading 1 CONTINUE
			collect_figs QUIETLY

		else
			collect_figs
		fi

		if [ -n "$__CONFIG_UNFINISHED__" ] && [ "${#__CONFIG_UNFINISHED__[@]}" -gt 0 ] ;
		then
			[[ "$APPMAIN" != "CONFIG" ]] && __LOADING_STOPPED__="1" && loading 1 CONFIG

			color lightYellow - bold
			echo -e "\\n\\nConfiguration is incomplete. We should finish it before we deploy!\\n"
			color red - underline

			display_array_title "Missing figlets"
			__X__="1"  #  Sets the bullets to X for display_array
			display_array "${__CONFIG_UNFINISHED__[@]}"
			echo -e -n ""

			. "$BUILD/quick-config.sh" UNFINISHED
			color - - clearAll

		fi
		[[ -z "$__CONFIG_UNFINISHED__" ]] && __READY__="1"
	done

	[[ -n "$__LOADING_STOPPED__" ]] && printf "\\n\\n" && loading 1 && unset __LOADING_STOPPED__

	if [ -n "$CONFIG" ] ;
	then
		loading 1 END
		echo -e -n "\\n\\n\\e[97m${__CONFIG__}\\e[0m\\n\\n"
	else
		echo "something went unusually wrong here... I'VE FAILED!"
		exit 1
	fi

	## ---- BUILD ENVIRONMENT ---- ##

elif [ ! -z "$1" ] && [ "$1" == "RUNTIME" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	if [ -z "$2" ] ;
	then
		initialize
		define_runtime_env
		check_configuration RUNTIME
		[[ -z "$__INVALID_CONFIG__" ]] && collect_figs
	else
		initialize QUIETLY
		define_runtime_env QUIETLY
		check_configuration QUIETLY
		[[ -z "$__INVALID_CONFIG__" ]] && collect_figs QUIETLY || loading 1 CONFIG
		[[ -z "$__INVALID_CONFIG__" ]] && loading 1 END
	fi

	## ---- BUILD RUNTIME ONLY ---- ##

else
    echo "This script must be executed by the deployment script"
fi
