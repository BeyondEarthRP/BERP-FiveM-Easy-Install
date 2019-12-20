#!/bin/bash
##############################################################
#####
#####   FiveM Roleplay Server
#####     Grand Theft Auto
#####      Deploy Script
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
steamKey="D5E22AE91C9735328F8C397ACAA77389"

#- FiveM License:
cfx_license="iejska94yn650vfrh7dqy99ruuhxvw5m"

#- MySql Account Info
mysql_user="esmAdmin" #--> Essential Mode Database Admin
mysql_password="vAELN964FMHvnHkuAJeXtzSZvZCvpD"
global_mysql_user="Global_Admin" #--> This is for root login via PHPMYADMIN
global_mysql_password="msspcXhl1iySar7rzRxMewH2iIPUVP23Yo4"

#- Server Local Account
srvAcct="fivem"
srvPassword="lOI8cDDjwUC9O0VQhiihnudWT1VosP5Y4NvSNN"

# Account Creation
########################
    adduser $srvAcct --gecos "FiveM Server, , , " --disabled-password
    echo "$srvAcct:$srvPassword" | chpasswd

########################



# Varriables
########################

SOFTWARE=/var/software
    TFIVEM=$SOFTWARE/fivem
        TSESX=$TFIVEM/sesx
        TCCORE=$TFIVEM/citizenfx.core.server
        TESMOD=$TFIVEM/essentialmode

MAIN=/home/$srvAcct
    GAME=$MAIN/server-data
        RESOURCES=$GAME/resources
            ESMOD=$RESOURCES/essentialmode
            ESEXT=$RESOURCES/\[essential\]
            MODS=$RESOURCES/\[mods\]
            VEHICLES=$RESOURCES/\[vehicles\]
            MAPS=$RESOURCES/\[maps\]
            ESX=$RESOURCES/\[esx\]

            SESX=$RESOURCES/\[sesx\]

# TEMP DIRECTORIES
mkdir $SOFTWARE
mkdir $TFIVEM
mkdir $TSESX
mkdir $TCCORE
mkdir $TESMOD

# Dependancies
########################
echo "Linux Software"
 apt-get update
 apt-get upgrade
 sudo apt-get -y install unzip unrar-free mariadb-server apache2 phpmyadmin

echo "mySQL"
 mysql_secure_installation


## ---- mySQL Database ---- ##
    mysql -e "CREATE DATABASE essentialmode;"
    mysql -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';"
    mysql -e "GRANT ALL PRIVILEGES ON essentialmode.* TO '${mysql_user}'@'localhost';"

    mysql -e "CREATE USER '${global_mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';"
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${global_mysql_user}'@'localhost';"
## ---- mySQL Database ---- ##


## ---- FiveM ---- ##
echo "FiveM - Base"
    echo "Get Packages"
	artifact=https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/1868-9bc0c7e48f915c48c6d07eaa499e31a1195b8aec/fx.tar.xz

        wget -P $TFIVEM $artifact

    echo "Extract Package"
        tar -xf $TFIVEM/fx.tar.xz --directory $MAIN/


echo "FiveM - CitizenFX"
    git clone https://github.com/citizenfx/cfx-server-data.git $GAME

echo "CitizenFX Module Update"
    wget -P $TCCORE https://d.fivem.dev/CitizenFX.Core.Server.zip
    unzip $TCCORE/CitizenFX.Core.Server.zip -d $TCCORE/CCORE

    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.sym $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.sym
    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.Server.dll $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.dll
    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.Server.sym $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.sym
## ---- FiveM ---- ##



## ---- sESX ---- ##

echo "sESX"
    wget -P "$TSESX" https://cdn.discordapp.com/attachments/529782752812204106/653783126253764649/sesx-current.zip
    $TSESX/sesx-current.zip -d $TSESX/source

    cp -Rfup $TSESX/source/server-data $MAIN

    mysql essentialmode -e "SOURCE $GAME/sesx.sql"

## ---- sESX ---- ##





####### THIS SHOULD BE AT THE END STAGES ###########
## ---- Personalize the Configuration ---- ##
mv /home/fivem/server-data/server.cfg{,.orig} #--> Renaming file to be processed

#-RCON Password Creation
echo "Generating RCON Password."
    Pass=`date +%s | sha256sum | base64 | head -c 64 ; echo`
    DateStamp=`date +"@%B#%Y"`
    rcon_password="$Pass$DateStamp"
    echo "RCON: $rcon_password"
    echo ""
    rcon_placeholder="#rcon_password changeme"
    rcon_actual="rcon_password \"$rcon_password\""
echo "Accepting original configuration; Injecting RCON configuration..."
    sed "s/$rcon_placeholder/$rcon_actual/" $GAME/server.cfg.orig > $GAME/server.cfg.rconCfg
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
    steamKey_actual="steam_webApiKey  \"$steamKey\""
    sed "s/$steamKey_placeholder/$steamKey_actual/" $GAME/server.cfg.dbCfg > $GAME/server.cfg.steamCfg
    rm -f $GAME/server.cfg.dbCfg #--> cleaning up; handing off a .steamCfg

#-FiveM License Key Injection into Config
echo "Accepting Steam config handoff; Injecting FiveM License into config..."
    sv_licenseKey_placeholder="sv_licenseKey LicenseKeyGoesHere"
    sv_licenseKey_actual="sv_licenseKey $sv_licenseKey"
    sed "s/$sv_license_placeholder/$sv_license_actual/" $GAME/server.cfg.steamCfg > $GAME/server.cfg
    rm -f $GAME/server.cfg.steamCfg #--> cleaning up; handing off a server.cfg

if [ -f $GAME/server.cfg ]; then
    echo "Server configuration file found."
else
    echo "ERROR: Something went wrong during the configuration personalization..."
fi

#### THIS NEEDS TO BE LAST
chown -R $srvAcct:$srvAcct $MAIN
