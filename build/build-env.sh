#!/bin/bash
# -ex
#\
#>\___________________
#>> THESE ARE MINE
#>>>>>>>>>>>>>>>>>>>>>
# BUILD OUT THE RUN TIME DETIALS
### check if I'm starting from the build directory...
### I assume this is correct.  It should be, let us see!
if [ ! "$BUILD" ] ;
then
  THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
  [[ -d "$THIS_SCRIPT_ROOT/build" ]] && BUILD="$THIS_SCRIPT_ROOT/build"
  [[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$THIS_SCRIPT_ROOT"
  [[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && BUILD="$(dirname $THIS_SCRIPT_ROOT)"
  unset THIS_SCRIPT_ROOT
fi

#####################################################################
# IMPORT FUNCTIONS
. "$BUILD/fuct-env.sh"
. "$BUILD/fuct-config.sh"
. "$BUILD/fuct-worker.sh"

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- BUILD ENVIRONMENT ---- ##

	[[ "$APPMAIN" != "CONFIG" ]] && initialize QUIETLY || initialize
	[[ "$APPMAIN" != "CONFIG" ]] && define_runtime_env QUIETLY || define_runtime_env

	unset __INVALID_CONFIG__
	check_for_config QUIETLY
	[[ "$APPMAIN" != "CONFIG" ]] && [[ -n "$__INVALID_CONFIG__" ]] && __LOADING_STOPPED__="1" && loading 1 CONFIG
	while [ -n "$__INVALID_CONFIG__" ] ;
	do
		case "$APPMAIN" in
			"MAIN" ) . "$BUILD/quick-config.sh" "CONFIGURE" ;;
		      "CONFIG" ) printf "Preparing configuration wizard..." ;;
		esac
		unset __INVALID_CONFIG__
		check_for_config
	done
	[[ "$APPMAIN" != "CONFIG" ]] && [[ -n "$__LOADING_STOPPED__" ]] \
	  && printf "\n\n" && loading && unset __LOADING_STOPPED__

	while [ -z "$__READY__" ] ;
	do
		unset __CONFIG_UNFINISHED__

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

		if [ "$__CONFIG_UNFINISHED__" ] && [ "${#__CONFIG_UNFINISHED__[@]}" -gt 0 ] ;
		then
			[[ "$APPMAIN" != "CONFIG" ]] && __LOADING_STOPPED__="1" && loading 1 CONFIG

			color lightYellow - bold
			echo -e "\n\nConfiguration is incomplete. We should finish it before we deploy!\n"
			color red - underline
			display_array_title "Missing figlets"
			display_array "${__CONFIG_UNFINISHED__[@]}"
			echo -e -n ""
			. "$BUILD/quick-config.sh"
			color - - clearAll
		fi
		[[ -z "$__CONFIG_UNFINISHED__" ]] && __READY__="1"
	done

	[[ -n "$__LOADING_STOPPED__" ]] && printf "\n\n" && loading 1 && unset __LOADING_STOPPED__

	if [ -n "$CONFIG" ] ;
	then
		loading 1 END
		echo -e -n "\n\n\e[97m${__CONFIG__}\e[0m\n\n"
	else
		echo "something went unusually wrong here... I'VE FAILED!"
		exit 1
	fi

	## ---- BUILD ENVIRONMENT ---- ##

elif [ ! -z "$1" ] && [ "$1" == "RUNTIME" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	initialize
	define_runtime_env
	check_for_config RUNTIME
	[[ -z "$__INVALID_CONFIG__" ]] && collect_figs

	## ---- BUILD RUNTIME ONLY ---- ##

else
    echo "This script must be executed by the deployment script"
fi
