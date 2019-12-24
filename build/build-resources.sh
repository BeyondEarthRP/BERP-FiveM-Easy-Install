#!/bin/bash
if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then
	echo "Creating base directory structure"
	if [ ! -d $RESOURCES ]; then
		mkdir $RESOURCES
	fi
	if [ ! -d $ESX ]; then
		mkdir $ESX
	fi
	if [ ! -d $ESUI ]; then
		mkdir $ESUI
	fi
	if [ ! -d $ESSENTIAL ]; then
		mkdir $ESSENTIAL
	fi
    cp -RfT "$SOURCE/__[LOADING-SCREENS]__/cyberload" "$GAME/resources/"
    cp -RfT "$SOURCE/[esx]" "$GAME/resources/"
    cp -RfT "$SOURCE/[essential]" "$GAME/resources/"
    cp -RfT "$SOURCE/[vehicles-civ]" "$GAME/resources/"
    cp -RfT "$SOURCE/[plugins]" "$GAME/resources/"
    cp -RfT "$SOURCE/[vehicles]" "$GAME/resources/"
    cp -RfT "$SOURCE/FiveM-RealisticVehicles/[vehicles]" "$GAME/resources/"
    cp -RfT "$SOURCE/[places]" "$GAME/resources/"
    cp -RfT "$SOURCE/[billboards]" "$GAME/resources/"
    cp -RfT "$SOURCE/[posters]" "$GAME/resources/"
    cp -RfT "$SOURCE/[weapons]" "$GAME/resources/"
    cp -RfT "$SOURCE/[rendertarget]" "$GAME/resources/"
	cp -RfT "$SOURCE/[non-esx]" "$GAME/resources/"
    cp -RfT "$SOURCE/GcPhoneForESX/resources/esx_addons_gcphone" "$GAME/resources/"
    cp -RfT "$SOURCE/GcPhoneForESX/resources/gcphone" "$GAME/resources/"
    cp -RfT "$SOURCE/es_ui" "$GAME/resources/"
    cp -RfT "$SOURCE/essentialmode" "$GAME/resources/"
    cp -RfT "$SOURCE/mysql-async" "$GAME/resources/"
    cp -RfT "$SOURCE/esplugin_mysql" "$GAME/resources/"
    cp -RfT "$SOURCE/async" "$GAME/resources/"
    cp -RfT "$SOURCE/cron" "$GAME/resources/"
    cp -RfT "$SOURCE/es_admin2" "$GAME/resources/"
    cp -RfT "$SOURCE/skinchanger" "$GAME/resources/"
    cp -RfT "$SOURCE/fivem-ipl" "$GAME/resources/"
	cp -RfT "$SOURCE/bob74_ipl" "$GAME/resources/"
    cp -RfT "$SOURCE/Calm-AI" "$GAME/resources/"
    cp -RfT "$SOURCE/Hot-Female-Ped-Pack/ped_pack" "$GAME/resources/"
    cp -RfT "$SOURCE/trew_hud_ui/ESX/trew_hud_ui" "$GAME/resources/"
    cp -RfT "$SOURCE/WeightDisplayForTrew" "$GAME/resources/"
    cp -RfT "$SOURCE/mapaddons" "$GAME/resources/"
    cp -RfT "$SOURCE/Peds" "$GAME/resources/"
    cp -RfT "$SOURCE/LegacyFuel" "$GAME/resources/"
    cp -RfT "$SOURCE/FiveM-DinoWeather" "$GAME/resources/"
    cp -RfT "$SOURCE/societybalance" "$GAME/resources/"
    cp -RfT "$SOURCE/jointransition" "$GAME/resources/"
    cp -RfT "$SOURCE/airports" "$GAME/resources/"
    cp -RfT "$SOURCE/live_map" "$GAME/resources/"
    cp -RfT "$SOURCE/NativeUILua_Reloaded" "$GAME/resources/"
    cp -RfT "$SOURCE/NativeUILua/NativeUI" "$GAME/resources/"
    cp -RfT "$SOURCE/interactSound" "$GAME/resources/"
    cp -RfT "$SOURCE/malteser_cinema" "$GAME/resources/"
    cp -RfT "$SOURCE/pNotify/pNotify" "$GAME/resources/"
else
    echo "This script must be executed by the deployment script"
fi

