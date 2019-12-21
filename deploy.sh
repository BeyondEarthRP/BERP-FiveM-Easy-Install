#!/bin/bash
##############################################################
#####
#####  Beyond Earth Roleplay Server
#####   FiveM: Grand Theft Auto V
#####         Deploy Script
#####
##############################################################
###############################
# Sudo Check
###############################
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
###############################
###############################

###############################
# CONFIGURATION:
# fill in appropriately
#------------------------------
#- Steam Key Goes Below:
steam_webApiKey="D5E22AE91C9735328F8C397ACAA77389"
export steam_webApiKey

#- FiveM License:
sv_licenseKey="iejska94yn650vfrh7dqy99ruuhxvw5m"
export sv_licenseKey

#- MySql Account Info
mysql_user="esmAdmin" #--> Essential Mode Database Admin
mysql_password="vAELN964FMHvnHkuAJeXtzSZvZCvpD"
export mysql_user
export mysql_password

global_mysql_user="Global_Admin" #--> This is for root login via PHPMYADMIN
global_mysql_password="msspcXhl1iySar7rzRxMewH2iIPUVP23Yo4"
export global_mysql_user
export global_mysql_password

#- PHP Config [config.inc.php]
blowfish_secret="ac5e3348f1df39cff67e6a4a1e76a541"
export blowfish_secret

#- Server Local Account
srvAcct="fivem"
srvPassword="lOI8cDDjwUC9O0VQhiihnudWT1VosP5Y4NvSNN"
export srvAcct
export srvPassword

#- .ssh Bundle
sshKeyBundle=https://www.dropbox.com/s/uwxjyomdhh539zm/sshKey.tar.gz
export sshKeyBundle


########################
# Account Creation
########################
    account=$(id -u ${srvAcct})
    if [ -z $account ]; then
        adduser $srvAcct --gecos "FiveM Server, , , " --disabled-password
        echo "$srvAcct:$srvPassword" | chpasswd
    fi


########################
# Varriables
########################
set -a
SCRIPT=$(echo $0 | rev | cut -f1 -d/ | rev)
SCRIPT_ROOT=`dirname "$(readlink -f "$0")"`
SCRIPT_FULLPATH=$SCRIPT_ROOT/$SCRIPT

cd ~
SOURCE_ROOT=`pwd`
    SOURCE=$SOURCE_ROOT/REPO

SOFTWARE=/var/software
    TFIVEM=$SOFTWARE/fivem
        TCCORE=$TFIVEM/citizenfx.core.server

MAIN=/home/$srvAcct
    GAME=$MAIN/server-data
        RESOURCES=$GAME/resources

            GAMEMODES=$RESOURCES/\[gamemodes\]
                MAPS=$GAMEMODES/\[maps\]

            ESX=$RESOURCES/\[esx\]
                ESEXT=$ESX/es_extended
                ESUI=$ESX/\[ui\]

            ESSENTIAL=$RESOURCES/\[essential\]
                ESMOD=$ESSENTIAL/essentialmode

            MODS=$RESOURCES/\[mods\]
            VEHICLES=$RESOURCES/\[vehicles\]
set +a

#$SCRIPT_ROOT/fetch-source.sh EXECUTE
$SCRIPT_ROOT/build-dependancies.sh EXECUTE
$SCRIPT_ROOT/build-config.sh EXECUTE
$SCRIPT_ROOT/build-resources.sh EXECUTE
$SCRIPT_ROOT/build-vmenu.sh EXECUTE


## ---- sESX ---- ##
#this is working, but I'm writing my own base runtime deployment instead
#TSESX=/var/software/fivem/sesx
#echo "sESX"
#    wget -P "$TSESX" https://cdn.discordapp.com/attachments/529782752812204106/653783126253764649/sesx-current.zip
#    unzip $TSESX/sesx-current.zip -d $TSESX
#    rm $TSESX/sesx-current.zip
#
#    cp -rfup $TSESX/server-data/server.cfg $GAME/server.cfg
#    cp -rfup $TSESX/server-data/sesx.sql $GAME/sesx.sql
#    cp -rfup $TSESX/server-data/resources/\[essentialmode\] $RESOURCES/
#    cp -rfup $TSESX/server-data/resources/\[esx\] $RESOURCES/
#    cp -rfup $TSESX/server-data/resources/\[utility\] $RESOURCES/
#
#    mysql essentialmode -e "SOURCE $GAME/sesx.sql"
#
## ---- sESX ---- ##



####### THIS SHOULD BE AT THE END STAGES ###########
## ---- Personalize the Configuration ---- ##
if [ ! -f $GAME/server.cfg ]; then
    cp $SOURCE/server.cfg.base $GAME/server.cfg
fi
mv $GAME/server.cfg{,.orig} #--> Renaming file to be processed

#-RCON Password Creation
echo "Generating RCON Password."
    Pass=`date +%s | sha256sum | base64 | head -c 64 ; echo`
    DateStamp=`date +"@%B#%Y"`
    rcon_password="$Pass$DateStamp"
    echo "RCON: $rcon_password"
    echo ""
    rcon_placeholder="#rcon_password changeme"
    rcon_actual="rcon_password \"${rcon_password}\""
echo "Accepting original configuration; Injecting RCON configuration..."
    sed "s/${rcon_placeholder}/${rcon_actual}/" $GAME/server.cfg.orig > $GAME/server.cfg.rconCfg
    rm -f $GAME/server.cfg.orig  #--> cleaning up; handing off a .rconCfg

#-mySql Configuration
echo "Accepting RCON config handoff; Injecting MySQL Connection String..."
    db_conn_placeholder="set mysql_connection_string \"server=localhost;database=sesx;userid=username;password=YourPassword\""
    db_conn_actual="set mysql_connection_string \"server=localhost;database=essentialmode;userid=$mysql_user;password=$mysql_password\""
    sed "s/$db_conn_placeholder/$db_conn_actual/" $GAME/server.cfg.rconCfg > $GAME/server.cfg.dbCfg
    rm -f $GAME/server.cfg.rconCfg #--> cleaning up; handing off a .dbCfg

#-Steam Key Injection into Config
echo "Accepted MySql config handoff; Injecting Steam Key into config..."
    steamKey_placeholder="set steam_webApiKey \"SteamKeyGoesHere\""
    steamKey_actual="steam_webApiKey  \"${steam_webApiKey}\""
    sed "s/${steamKey_placeholder}/${steamKey_actual}/" $GAME/server.cfg.dbCfg > $GAME/server.cfg.steamCfg
    rm -f $GAME/server.cfg.dbCfg #--> cleaning up; handing off a .steamCfg

#-FiveM License Key Injection into Config
echo "Accepting Steam config handoff; Injecting FiveM License into config..."
    sv_licenseKey_placeholder="sv_licenseKey LicenseKeyGoesHere"
    sv_licenseKey_actual="sv_licenseKey ${sv_licenseKey}"
    sed "s/${sv_licenseKey_placeholder}/${sv_licenseKey_actual}/" $GAME/server.cfg.steamCfg > $GAME/server.cfg
    rm -f $GAME/server.cfg.steamCfg #--> cleaning up; handing off a server.cfg

if [ -f $GAME/server.cfg ]; then
    echo "Server configuration file found."
else
    echo "ERROR: Something went wrong during the configuration personalization..."
fi

#### THIS NEEDS TO BE LAST
chown -R $srvAcct:$srvAcct $MAIN
