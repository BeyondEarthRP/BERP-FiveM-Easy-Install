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

check_configuration
if [ -n "$__INVALID_CONFIG__" ] ;
then
	__CONFIGURE__="1" ;
	unset __INVALID_CONFIG__
	load_static_defaults
fi ;

color white - bold
echo -e "\n\nWe are about to create a new configuration file."
color - - clearAll

while [ -n "$__CONFIGURE__" ] ;
do
  # read it; check for user input or use default value; ignore the new line (back up!)
  color white - bold
  echo -e -n "Continue? \e[93m[Y/n]\e[39m: \e[s"
  read -n 1 yn
  color - - clearAll

  [[ -z "$yn" ]] && printf "\e[u\e[1A\e[1D\e[s"

  [[ ! -z "${yn:=y}" ]]
  case "$yn" in
    [Yy]* ) _confirm=y && printf "\e[u Yes, continue.\n\e[K\n\e[K" && break ;;
    [Nn]* ) _confirm=n && printf "\e[u No, exit.\n\e[K\n\e[K" && break ;;
        * ) printf "\e[1A\e[999D\e[K\e[97mWe are about to create a new configuration file. \e[91m(Answer with 'Yes' or 'No')\n\e[0m" ;;
  esac
  printf "\e[s\e[1B\e[999D\e[K\e[u"
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
