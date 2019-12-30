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

# LOADING FUNCTIONS
. "$BUILD/fuct-env.sh"
. "$BUILD/fuct-worker.sh"

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- BUILD ENVIRONMENT ---- ##

	initialize
	define_runtime_env
	check_for_config
	#while [ ! "$__ready__" ] ;
#	do
	        import_system_config
		import_env_config
		if [ "$__INCOMPLETE_CONFIG__" ] && [ "${#__INCOMPLETE_CONFIG__[@]}" -gt 0 ] ;
		then
			color lightYellow - bold
			echo -e "\n\nConfiguration is incomplete.  We should finish it before we deploy!\n"
			. "$BUILD/quick-config.sh"
			color - - clearAll
		fi
#	done

	## ---- BUILD ENVIRONMENT ---- ##

elif [ ! -z "$1" ] && [ "$1" == "RUNTIME" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	initialize
	define_runtime_env
	check_for_config RUNTIME
	[[ ! "$__INVALID_CONFIG__" ]] && import_system_config
	[[ ! "$__INVALID_CONFIG__" ]] && import_env_config


	## ---- BUILD RUNTIME ONLY ---- ##

elif [ ! -z "$1" ] && [ "$1" == "TEST-RUNTIME" ] || [ "$1" == "TEST-CONFIGURES" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	[[ "$1" == "TEST-RUNTIME" ]] && APPMAIN="TEST-RUNTIME"
	[[ "$1" == "TEST-CONFIGURES" ]] & APPMAIN="TEST-CONFIGURES"

        __TEST__="1"

	initialize
	define_runtime_env
	[[ "$APPMAIN" == "TEST-RUNTIME" ]] && check_for_config RUNTIME

	[[ "$APPMAIN" == "TEST-CONFIGURES" ]] && check_for_config
        [[ ! "$__INVALID_CONFIG__" ]] && import_system_config

	#[[ ! "$__INVALID_CONFIG__" ]] && import_env_config
        #[[ ! "$__INVALID_CONFIG__" ]] && define_configures


	## ---- BUILD RUNTIME ONLY ---- ##
else
    echo "This script must be executed by the deployment script"
fi
