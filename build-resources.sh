#!/bin/bash
if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then
    ##########--LOADING SCREEN--#############################
    #cp -rfup $SOURCE/__\[LOADING-SCREENS\]__/loqscript-material_load-loadingscreen $GAME/resources/
    #cp -rfup $SOURCE/__\[LOADING-SCREENS\]__/fivem-gta-loading $GAME/resources/
    cp -rfup $SOURCE/__\[LOADING-SCREENS\]__/cyberload $GAME/resources/
    #########################################################
	#    cp -rfup $SOURCE/cfx-server-data/* $GAME/  #--> already doing this in the deploy script
    cp -rfup $SOURCE/GcphoneForESX/resources $GAME/
    cp -rfup $SOURCE/[esx] $GAME/resources/
    cp -rfup $SOURCE/[essential] $GAME/resources/
    cp -rfup $SOURCE/[vehicles-civ] $GAME/resources/
    cp -rfup $SOURCE/[plugins] $GAME/resources/
    cp -rfup $SOURCE/[vehicles] $GAME/resources/
    cp -rfup $SOURCE/FiveM-RealisticVehicles/[vehicles] $GAME/resources/
    cp -rfup $SOURCE/[places] $GAME/resources/
    cp -rfup $SOURCE/[billboards] $GAME/resources/
    cp -rfup $SOURCE/[posters] $GAME/resources/
    cp -rfup $SOURCE/[weapons] $GAME/resources/
    cp -rfup $SOURCE/[rendertarget] $GAME/resources/
    cp -rfup $SOURCE/es_ui $GAME/resources/
    cp -rfup $SOURCE/essentialmode $GAME/resources/
    cp -rfup $SOURCE/mysql-async $GAME/resources/
    cp -rfup $SOURCE/esplugin_mysql $GAME/resources/
    cp -rfup $SOURCE/async $GAME/resources/
    cp -rfup $SOURCE/cron $GAME/resources/
    cp -rfup $SOURCE/es_admin2 $GAME/resources/
    cp -rfup $SOURCE/skinchanger $GAME/resources/
    cp -rfup $SOURCE/fivem-ipl $GAME/resources/
    cp -rfup $SOURCE/Calm-AI $GAME/resources/
    cp -rfup $SOURCE/Hot-Female-Ped-Pack/ped_pack $GAME/resources/
    cp -rfup $SOURCE/trew_hud_ui/ESX/trew_hud_ui $GAME/resources/
    cp -rfup $SOURCE/WeightDisplayForTrew $GAME/resources/
    cp -rfup $SOURCE/mapaddons $GAME/resources/
    cp -rfup $SOURCE/Peds $GAME/resources/
    cp -rfup $SOURCE/LegacyFuel $GAME/resources/
    cp -rfup $SOURCE/FiveM-DinoWeather $GAME/resources/
    cp -rfup $SOURCE/societybalance $GAME/resources/
    cp -rfup $SOURCE/jointransition $GAME/resources/
    cp -rfup $SOURCE/airports $GAME/resources/
    cp -rfup $SOURCE/live_map $GAME/resources/
    cp -rfup $SOURCE/NativeUILua_Reloaded $GAME/resources/
    cp -rfup $SOURCE/NativeUILua/NativeUI $GAME/resources/
    cp -rfup $SOURCE/interactSound $GAME/resources/
    cp -rfup $SOURCE/malteser_cinema $GAME/resources/
    cp -rfup $SOURCE/pNotify/pNotify $GAME/resources/
else
    echo "This script must be executed by the deployment script"
fi

