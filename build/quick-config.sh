#!/bin/bash
# -exabT

###################################################################
# BEGIN BUILDING A NEW BERP BUILDER CONFIG INGEST FILE
###################################################################
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
###################################################################
[[ "$1" == "CONFIGURE" ]] && __CONFIGURE__="1" || unset __CONFIGURE__
if [ -z "$APPMAIN" ] ;
then
  APPMAIN="CONFIG" && __CONFIGURE__="1"
  . "$BUILD/build-env.sh" "RUNTIME"
elif [ -z "$__RUNTIME__" ] ;
then
	echo "Runtime not loaded... I'VE FAILED!"
	exit 1
fi
[[ "$APPMAIN" == "CONFIG" ]] && . "$BUILD/just-a-banner.sh" WELCOME
##################################################################
# If assumptions were correct, we should not fail!
if [ -z "$CONFIG" ] && [ -z "$_CONFIG" ]; then
  echo "No config file has been defined.  I'VE FAILED!"
  exit 1
fi
[[ -z "$CONFIG" ]] && [[ "$_CONFIG" ]] && CONFIG="$_CONFIG"

##################################################################
# AND.... GO!
unset _confirm

check_for_config
if [ -n "$__INVALID_CONFIG__" ] ;
then
	__CONFIGURE__="1" ;
	unset __INVALID_CONFIG__
	load_static_defaults
fi ;

while [ -n "$__CONFIGURE__" ] ;
do
  color red - bold
  echo -e "\nWe are about to create a new configuration."

  # read it; check for user input or use default value; ignore the new line (back up!)
  color white - bold
  echo -e -n "Continue? \e[93m[Y/n]\e[39m: \e[0m"
  read -n 1 yn
  [[ ! -z "$yn" ]] && printf "\e[2D" || printf "\e[u\e[1A\e[1D"
  color - - clearAll

  [[ ! -z "${yn:=y}" ]]
  case "$yn" in
    [Yy]* ) _confirm=y && echo -e " Yes, continue.\n" && break ;;
    [Nn]* ) _confirm=n && echo -e " No, exit.\n" && break ;;
    * ) echo -e "\nPlease answer yes or no (or hit control-c to cancel).\n" ;;
  esac
done

if [ "$__CONFIGURE__" ] && [ "$_confirm" == n ] ; then
	echo "Okay... leaving quick config. Goodbye!"
	exit 0
else
	harvest
	salt_rcon
	cook_figs
	[[ "$__CONFIGURE__" ]] && unset __CONFIGURE__
fi
