#!/bin/bash
# -exabT
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
