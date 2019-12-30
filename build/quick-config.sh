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
if [ ! "$APPMAIN" ] ; then
  APPMAIN="QUICK_CONFIG"
  . "$BUILD/build-env.sh" "RUNTIME"
  __CONFIGURE__="1"
fi
####
# If assumptions were correct, we should not fail!
if [ -z "$CONFIG" ] && [ -z "$_CONFIG" ]; then
  echo "No config file has been defined.  I'VE FAILED!"
  exit 1
fi
[[ ! "$CONFIG" ]] && [[ "$_CONFIG" ]] && CONFIG="$_CONFIG"
#################################################################
# DEFAULTS
_SERVICE_ACCOUNT="fivem"
_MYSQL_USER="admin"

_STEAM_WEBAPIKEY=""
_SV_LICENSEKEY=""

_RCON=true
_RCON_PASSWORD_GEN=true
_RCON_PASSWORD_LENGTH=64
_RCON_ASK_TO_CONFIRM=false

_TXADMIN_BACKUP_FOLDER="data-txadmin"
_DB_BACKUP_FOLDER="data-mysql"
_ARTIFACT_BUILD="1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec"
_SOFTWARE_ROOT="/var/software"
_REPO_NAME="BERP-Source"

_SERVER_NAME="Beyond Earth Roleplay (BERP)"

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
. "$BUILD/fuct-config.sh"
. "$BUILD/fuct-worker.sh"

##################################################################
# AND.... GO!
unset _confirm

while [[ "$__CONFIGURE__" ]] ;
do
  color red - bold
  echo -e "We are about to create a configuration file to be used for deployment(s)."

  # read it; check for user input or use default value; ignore the new line (back up!)
  color white - bold
  echo -e -n "Continue? \e[93m[Y/n]\e[39m: \e[s"
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
	define_configures
	salt_rcon
	cook_figs
	[[ "$__CONFIGURE__" ]] && unset __CONFIGURE__
fi
