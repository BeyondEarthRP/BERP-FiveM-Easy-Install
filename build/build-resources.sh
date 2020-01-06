#!/bin/bash
if [ -z "$__RUNTIME__" ] ;
then
        if [ ! "$BUILD" ] ;
        then
          THIS_SCRIPT_ROOT="$(dirname $(readlink -f $0))"
          [[ -d "$THIS_SCRIPT_ROOT/build" ]] && _BUILD="$THIS_SCRIPT_ROOT/build"
          [[ "$(echo $THIS_SCRIPT_ROOT | rev | cut -f1 -d/ | rev)" == "build" ]] && _BUILD="$THIS_SCRIPT_ROOT"
          [[ "$(echo $(dirname THIS_SCRIPT_ROOT) | rev | cut -f1 -d/ | rev)" == "build" ]] && _BUILD="$(dirname $THIS_SCRIPT_ROOT)"
          unset THIS_SCRIPT_ROOT

          [[ -z "$BUILD" ]] && echo "Build folder not found.  cache-txadmin.sh has failed you!" && exit 1
          . "$BUILD/build-env.sh" RUNTIME

          [[ -z "$SOURCE" ]] || [[ "$SOURCE" == "null" ]] && echo "Build folder not found. FAILED!" && exit 1
        fi
fi
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then
	echo "Creating base directory structure"
	if [ ! -d "${RESOURCES:?}" ]; then
		mkdir "${RESOURCES:?}"
	fi
	if [ ! -d "${ESX:?}" ]; then
		mkdir "${ESX:?}"
	fi
	if [ ! -d "${ESUI:?}" ]; then
		mkdir "${ESUI:?}"
	fi
	if [ ! -d "${ESSENTIAL:?}" ]; then
		mkdir "${ESSENTIAL:?}"
	fi
    cp -Rf "${SOURCE:?}/__[LOADING-SCREENS]__/cyberload" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[esx]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[essential]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[vehicles-civ]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[plugins]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[vehicles]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/FiveM-RealisticVehicles/[vehicles]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[places]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[billboards]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[posters]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[weapons]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[rendertarget]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/[non-esx]" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/GcPhoneForESX/resources/esx_addons_gcphone" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/GcPhoneForESX/resources/gcphone" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/es_ui" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/essentialmode" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/mysql-async" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/esplugin_mysql" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/async" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/cron" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/es_admin2" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/skinchanger" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/fivem-ipl" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/bob74_ipl" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/Calm-AI" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/Hot-Female-Ped-Pack/ped_pack" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/trew_hud_ui/ESX/trew_hud_ui" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/WeightDisplayForTrew" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/mapaddons" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/Peds" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/LegacyFuel" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/FiveM-DinoWeather" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/societybalance" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/jointransition" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/airports" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/live_map" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/NativeUILua_Reloaded" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/NativeUILua/NativeUI" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/interactSound" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/malteser_cinema" "${GAME:?}/resources/"
    cp -Rf "${SOURCE:?}/pNotify/pNotify" "${GAME:?}/resources/"
else
    echo "This script must be executed by the deployment script"
fi

