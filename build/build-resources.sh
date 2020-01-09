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

          [[ -z "$_BUILD" ]] && echo "Build folder not found!" && exit 1
          . "$_BUILD/build-env.sh" RUNTIME

          [[ -z "$SOURCE" ]] || [[ "$SOURCE" == "null" ]] && echo "\\e[91m\\e[1mBuild folder not found. FAILED!\\e[0m" && exit 1
        fi
fi
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then
	. "${BUILD:?}/fetch-fivemresources.sh" EXECUTE

	echo "Creating base directory structure"
        if [ ! -d "${GAME:?}/resources" ]; then
                mkdir -p "${GAME:?}/resources"
        fi
	if [ ! -d "${RESOURCES:?}" ]; then
		mkdir -p "${RESOURCES:?}"
	fi
	if [ ! -d "${ESX:?}" ]; then
		mkdir -p "${ESX:?}"
	fi
	if [ ! -d "${ESUI:?}" ]; then
		mkdir -p "${ESUI:?}"
	fi
	if [ ! -d "${ESSENTIAL:?}" ]; then
		mkdir -p "${ESSENTIAL:?}"
	fi
    cp -rf "${SOURCE:?}/__[LOADING-SCREENS]__/cyberload" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[esx]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[essential]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[vehicles-civ]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[plugins]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[vehicles]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/FiveM-RealisticVehicles/[vehicles]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[places]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[billboards]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[posters]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[weapons]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[rendertarget]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/[non-esx]" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/GcPhoneForESX/resources/esx_addons_gcphone" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/GcPhoneForESX/resources/gcphone" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/es_ui" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/essentialmode" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/mysql-async" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/esplugin_mysql" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/async" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/cron" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/es_admin2" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/skinchanger" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/fivem-ipl" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/bob74_ipl" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/Calm-AI" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/Hot-Female-Ped-Pack/ped_pack" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/trew_hud_ui/ESX/trew_hud_ui" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/WeightDisplayForTrew" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/mapaddons" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/Peds" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/LegacyFuel" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/FiveM-DinoWeather" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/societybalance" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/jointransition" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/airports" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/live_map" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/NativeUILua_Reloaded" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/NativeUILua/NativeUI" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/interactSound" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/malteser_cinema" "${GAME:?}/resources/"
    cp -rf "${SOURCE:?}/pNotify/pNotify" "${GAME:?}/resources/"
else
    echo "This script must be executed by the deployment script"
fi

