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
. "$BUILD/fuct-color.sh"

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	## ---- BUILD ENVIRONMENT ---- ##

	initialize
	define_runtime_env
	check_for_config
        import_system_config

	if [ -d "${CONFIG%/*}" ]; then
		import_env_config
		define_configures
		if [ "$_new_" != 0 ]; then
			echo "_new_ :: $_new_"

			### TO - DO ############
			# LOOP THROUGH _all_new_ to display changes
			# CONFIRM
			build_env_config
		fi
	else
		define_configures
		build_env_config
	fi

	## ---- BUILD ENVIRONMENT ---- ##

elif [ ! -z "$1" ] && [ "$1" == "RUNTIME" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	initialize
	define_runtime_env
	check_for_config RUNTIME
	[[ ! "$__INVALID_CONFIG__" ]] && import_system_config
	[[ ! "$__INVALID_CONFIG__" ]] && import_env_config


	## ---- BUILD RUNTIME ONLY ---- ##

elif [ ! -z "$1" ] && [ "$1" == "TEST-RUNTIME" ]; then

	## ---- BUILD RUNTIME ONLY ---- ##

	initialize
        __TEST__="1"
	define_runtime_env
	check_for_config RUNTIME
        [[ ! "$__INVALID_CONFIG__" ]] && import_system_config
	[[ ! "$__INVALID_CONFIG__" ]] && import_env_config
        [[ ! "$__INVALID_CONFIG__" ]] && define_configures


	## ---- BUILD RUNTIME ONLY ---- ##
else
    echo "This script must be executed by the deployment script"
fi
