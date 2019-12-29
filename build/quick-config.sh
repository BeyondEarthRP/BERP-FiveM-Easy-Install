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
[[ ! "$APPMAIN" ]] && APPMAIN="QUICK_DEPLOY" && . "$BUILD/build-env.sh" "RUNTIME"
####
# If assumptions were correct, we should not fail!
if [ -z "$CONFIG" ] && [ -z "$_CONFIG" ]; then
	echo "No config file has been defined.  I'VE FAILED!"
	exit 1
fi
[[ ! "$CONFIG" ]] && [[ "$_CONFIG" ]] && CONFIG="$_CONFIG"

#################################################################
# DEFAULTS
_SERVICE_ACCOUNT=fivem
_MYSQL_USER=admin

_STEAM_WEBAPIKEY=""
_SV_LICENSEKEY=""

_RCON=true
_RCON_PASSWORD_GEN=true
_RCON_PASSWORD_LENGTH=64
_RCON_ASK_TO_CONFIRM=false

_SERVER_NAME="Beyond Earth Roleplay (BERP)"

# I feel like there is a better way
# Whatever the current figs are, if they are blank... then use the default above....
# Then set the default (over-writing the above) to whatever is read in from the config file.

[[ "${SERVICE_ACCOUNT:=$_SERVICE_ACCOUNT}" ]] ;
[[ ! -z "$SERVICE_ACCOUNT" ]] &&  _SERVICE_ACCOUNT="$SERVICE_ACCOUNT" ;

[[ "${MYSQL_USER:=$_MYSQL_USER}" ]] ;
[[ ! -z "$MYSQL_USER" ]] && _MYSQL_USER="$MYSQL_USER" ;

[[ "${STEAM_WEBAPIKEY:=$_STEAM_WEBAPIKEY}" ]] ;
[[ ! -z "$STEAM_WEBAPIKEY" ]] && _STEAM_WEBAPIKEY="$STEAM_WEBAPIKEY" ;

[[ "${SV_LICENSEKEY:=$_SV_LICENSEKEY}" ]] ;
[[ ! -z "$SV_LICENSEKEY" ]] &&  _SV_LICENSEKEY="$SV_LICENSEKEY" ;

[[ "${RCON:=$_RCON}" ]] ;
[[ ! -z "$RCON" ]] && _RCON="$RCON" ;

[[ "${RCON_PASSWORD_GEN:=$_RCON_PASSWORD_GEN}" ]] ;
[[ ! -z "$RCON_PASSWORD_GEN" ]] && _RCON_PASSWORD_GEN="$RCON_PASSWORD_GEN" ;

[[ "${RCON_PASSWORD_LENGTH:=$_RCON_PASSWORD_LENGTH}" ]] ;
[[ ! -z "$RCON_PASSWORD_LENGTH" ]] && _RCON_PASSWORD_LENGTH="$RCON_PASSWORD_LENGTH" ;

[[ "${RCON_ASK_TO_CONFIRM:=$_RCON_ASK_TO_CONFIRM}" ]] ;
[[ ! -z "$RCON_ASK_TO_CONFIRM" ]] && _RCON_ASK_TO_CONFIRM="$RCON_ASK_TO_CONFIRM"

[[ "${SERVER_NAME:=$_SERVER_NAME}" ]] ;
[[ ! -z "$SERVER_NAME" ]] && _SERVER_NAME="$SERVER_NAME"

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
. "$BUILD/fuct-input.sh"
[[ "$APPMAIN" == "QUICK_DEPLOY" ]] && . "$BUILD/fuct-color.sh"

##################################################################
# AND.... GO!
unset _confirm
while true ;
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

if [ "$_confirm" == n ] ; then
	echo "Okay... leaving quick config. Goodbye!"
	exit 0
else
	# FIG  PROMPT  dialog:default/display  MIN  MAX
	PROMPT="Enter the linux account to be used for FiveM"
	input_fig_entry "SERVICE_ACCOUNT" "$PROMPT" "0"

        PROMPT=$(echo "Enter a password for $SERVICE_ACCOUNT")
	input_fig_entry "SERVICE_PASSWORD" "$PROMPT" "s:n/y" 9

        PROMPT="Password for root account on MySQL"
	input_fig_entry "DB_ROOT_PASSWORD" "$PROMPT" "s:n/y" 16

	PROMPT="Enter MySql username for the essentialmode database"
	input_fig_entry "MYSQL_USER" "$PROMPT" "0"

	PROMPT=$(echo "Enter MySQL password for $MYSQL_USER")
	input_fig_entry "MYSQL_PASSWORD" "$PROMPT" "s:n/y" 16 128

	PROMPT="Enter Blowfish Secret for PHP"
	input_fig_entry "BLOWFISH_SECRET" "$PROMPT" "s:n/y" 16

	PROMPT="Enter your Steam Web API Key"
	input_fig_entry "STEAM_WEBAPIKEY" "$PROMPT" "s:y/y"

	PROMPT="Enter your Cfx FiveM License"
	input_fig_entry "SV_LICENSEKEY" "$PROMPT" "s:y/y"

	##########################################################################################
	# RCON DETAILS
	## THESE ARE NOT SETTINGS TO BE CHANGED- DOING SO WILL VOID THE MANUFACTURERS WARRANTY!

	PROMPT="Enable RCON (probably not needed)?"
        input_fig_entry "RCON" "$PROMPT" 10

	if [ "$RCON" == "true" ] ;
        then
          PROMPT="(recommended) Allow RCON Passwords to be randomly generated?"
          input_fig_entry "RCON_PASSWORD_GEN" "$PROMPT" 10

            if [ "$RCON_PASSWORD_GEN" == "true" ] ;
            then
              PROMPT="Number of characters to generate?"
              input_fig_entry "RCON_PASSWORD_LENGTH" "$PROMPT" 20 20 128

              PROMPT="(not recommended) Require manual approval of each randomly generated password"
              input_fig_entry "RCON_ASK_TO_CONFIRM" "$PROMPT" 11
            fi
	fi

        if [ -z "$SERVER_NAME" ]; then
          PROMPT="What would you like to name the server?"
          input_fig_entry "SERVER_NAME" "$PROMPT" "s:y/y"
          # _all_new_+="SERVER_NAME"
          # let _new_++
        fi


	if [ -f "$CONFIG" ] ; then
          [[ "$__confirmed__" ]] && unset __confirmed__

          color white - bold
          echo "This will over-write the current config found at:"
          echo ""
          echo "        $CONFIG"
          color red - bold
          echo -e -n "\n  "
          color - - underline
          echo -e -n "New values:"
          color - - noUnderline
          echo -e -n " \n"
          echo " .sys.acct.user = \"$SERVICE_ACCOUNT\""
          echo " .sys.acct.password = \"$SERVICE_PASSWORD\""
          echo " .sys.mysql.user = \"$MYSQL_USER\""
          echo " .sys.mysql.passwor = \"$MYSQL_PASSWORD\""
          echo " .sys.mysql.rootPassword = \"$DB_ROOT_PASSWORD\""
          echo " .sys.rcon.password = \"$RCON_PASSWORD\""
          echo " .sys.rcon.pref.enable = \"$RCON\""
          echo " .sys.rcon.pref.randomlyGenerate = \"$RCON_PASSWORD_GEN\""
          echo " .sys.rcon.pref.length = \"$RCON_PASSWORD_LENGTH\""
          echo " .sys.rcon.pref.confirm = \"$RCON_ASK_TO_CONFIRM\""
          echo " .sys.php.blowfishSecret = \"$BLOWFISH_SECRET\""
          echo " .sys.keys.fivemLicenseKey = \"$SV_LICENSEKEY\""
          echo " .sys.keys.steamWebApiKey = \"$STEAM_WEBAPIKEY\""
          echo ""
          color - - clearAll

          color white - bold
          echo -e "Last chance to cancel..."
          color - - clearAll

          while [ -z "$__confirmed__" ] ;
          do
            color white - bold
            echo -n -e "Overwrite system config with above values? "
            color lightYellow - bold
            echo -n -e "(TYPE 'YES' TO CONTINUE)"
            color white - bold
            echo -n -e ":"
            color - - clearAll

            unset _confirm ;
            read -n 3 _confirm ;
            case "$_confirm" in
              Yes | yes | YES ) __confirmed__="1" ; unset _confirm ;;
                            * ) unset _confirm ;;
            esac ;
            if [ -z "$__confirmed__" ] ; then
              color red - bold ;
              echo -e "\nYou did not type 'YES' -- if you'd like to cancel, hit control-c" ; # Fired!
              color - - clearAll ;
            fi
          done
          color white - bold
          echo -e "\nOkay, writing the config...\n"
          color - - clearAll
	fi

	                                                                                     BASE_CONFIG={}
        echo "$BASE_CONFIG"                                                                              | \
        jq ". += {\"sys\":{}}"                                                                           | \
	        jq ".sys += {\"serviceAccount\":{}}"                                                     | \
			jq ".sys.acct += {\"user\":\"${SERVICE_ACCOUNT}\"}"                              | \
			jq ".sys.acct += {\"password\":\"${SERVICE_PASSWORD}\"}"                         | \
		jq ".sys += {\"mysql\":{}}"                                                              | \
			jq ".sys.mysql += {\"user\":\"${MYSQL_USER}\"}"                                  | \
			jq ".sys.mysql += {\"password\":\"${MYSQL_PASSWORD}\"}"                          | \
			jq ".sys.mysql += {\"rootPassword\":\"${DB_ROOT_PASSWORD}\"}"                    | \
		jq ".sys += {\"rcon\":{}}"                                                               | \
			jq ".sys.rcon += {\"password\":\"${RCON_PASSWORD}\"}"                            | \
			jq ".sys.rcon += {\"pref\":{}}"                                                  | \
				jq ".sys.rcon.pref += {\"enable\":\"${RCON}\"}"                          | \
				jq ".sys.rcon.pref += {\"randomlyGenerate\":\"${RCON_PASSWORD_GEN}\"}"   | \
				jq ".sys.rcon.pref += {\"length\":\"${RCON_PASSWORD_LENGTH}\"}"          | \
				jq ".sys.rcon.pref += {\"confirm\":\"${RCON_ASK_TO_CONFIRM}\"}"          | \
		jq ".sys += {\"php\":{}}"                                                              | \
			jq ".sys.php += {\"blowfishSecret\":\"${BLOWFISH_SECRET}\"}"                     | \
		jq ".sys += {\"keys\":{}}"                                                             | \
	                jq ".sys.keys += {\"fivemLicenseKey\":\"${SV_LICENSEKEY}\"}"                     | \
	                jq ".sys.keys += {\"steamWebApiKey\":\"${STEAM_WEBAPIKEY}\"}"                      > "$CONFIG"

fi
