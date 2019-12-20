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
##############################
###############################


# Account Creation
########################

 adduser fivem

########################



# Varriables
########################

SOFTWARE=/var/software
    TFIVEM=$SOFTWARE/fivem
        TSESX=$TFIVEM/sesx
        TCCORE=$TFIVEM/citizenfx.core.server
        TESMOD=$TFIVEM/essentialmode

MAIN=/home/fivem
    GAME=$MAIN/server-data
        RESOURCES=$GAME/resources
            ESMOD=$RESOURCES/essentialmode
            ESEXT=$RESOURCES/\[essential\]
            MODS=$RESOURCES/\[mods\]
            VEHICLES=$RESOURCES/\[vehicles\]
            MAPS=$RESOURCES/\[maps\]
            ESX=$RESOURCES/\[esx\]

            SESX=$RESOURCES/\[sesx\]

mysql_user="custodian"
mysql_password="vAELN964FMHvnHkuAJeXtzSZvZCvpD"

global_mysql_user="JayAdmin"
global_mysql_password="msspcXhl1iySar7rzRxMewH2iIPUVP23Yo4"

# TEMP DIRECTORIES
mkdir $SOFTWARE
mkdir $TFIVEM
mkdir $TSESX
mkdir $TCCORE
mkdir $TESMOD

# Dependancies
########################
echo "Linux Software"
# apt-get update
# apt-get upgrade
# apt-get -y install sudo
# sudo apt-get -y install screen git
# sudo apt-get -y install unzip unrar mariadb-server apache2 phpmyadmin

echo "mySQL"
# mysql_secure_installation


## ---- mySQL Database ---- ##
    mysql -e "CREATE DATABASE essentialmode;"
    mysql -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';"
    mysql -e "GRANT ALL PRIVILEGES ON essentialmode.* TO '${mysql_user}'@'localhost';"

    mysql -e "CREATE USER '${global_mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';"
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${global_mysql_user}'@'localhost';"


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
    unzip $TSESX/sesx-current.zip -d $TSESX/source
    mv -f "$TSESX/source/server-data/resources/'[essentialmode]'" "$TSESX/source/server-data/resources/[essentialmode]"
    mv -f "$TSESX/source/server-data/resources/'[gamemodes]'" "$TSESX/source/server-data/resources/[gamemodes]"
    mv -f "$TSESX/source/server-data/resources/[gamemodes]/'[maps]'" "$TSESX/source/server-data/resources/[gamemodes]/[maps]"
    mv -f "$TSESX/source/server-data/resources/'[managers]'" "$TSESX/source/server-data/resources/[managers]"
    mv -f "$TSESX/source/server-data/resources/'[test]'" "$TSESX/source/server-data/resources/[test]"
    mv -f "$TSESX/source/server-data/resources/'[esx]'" "$TSESX/source/server-data/resources/[esx]"
    mv -f "$TSESX/source/server-data/resources/'[gameplay]'" "$TSESX/source/server-data/resources/[gameplay]"
    mv -f "$TSESX/source/server-data/resources/'[system]'" "$TSESX/source/server-data/resources/[system]"
    mv -f "$TSESX/source/server-data/resources/[system]/'[builders]'" "$TSESX/source/server-data/resources/[system]/[builders]"
    mv -f "$TSESX/source/server-data/resources/'[utility]'" "$TSESX/source/server-data/resources/[utility]"


    cp -Rfup $TSESX/source/server-data $MAIN

    mysql essentialmode -e "SOURCE $GAME/sesx.sql"

## ---- sESX ---- ##





####### THIS SHOULD BE AT THE END STAGES ###########
## ---- Personalize the Configuration ---- ##
mv /home/fivem/server-data/server.cfg{,.orig}

Pass=`date +%s | sha256sum | base64 | head -c 64 ; echo`
DateStamp=`date +"@%B#%Y"`

db_conn="set mysql_connection_string \"server=localhost;database=essentialmode;userid=$mysql_user;password=$mysql_password\""
steamKey="D5E22AE91C9735328F8C397ACAA77389"
license="iejska94yn650vfrh7dqy99ruuhxvw5m"

sed "s/#rcon_password changeme/rcon_password \"${Pass}${DateStamp}\"/" $GAME/server.cfg.orig > $GAME/server.cfg.rcon
rm -f $GAME/server.cfg.orig
sed "s/set mysql_connection_string \"server=localhost;database=sesx;userid=username;password=YourPassword\"/${db_conn}/" $GAME/server.cfg.rcon > $GAME/server.cfg.db
rm -f $GAME/server.cfg.rcon
sed "s/set steam_webApiKey \"SteamKeyGoesHere\"/steam_webApiKey  \"$steamKey\"/" $GAME/server.cfg.db > $GAME/server.cfg.steam
rm -f $GAME/server.cfg.db
sed "s/sv_licenseKey LicenseKeyGoesHere/sv_licenseKey $license/" $GAME/server.cfg.steam > $GAME/server.cfg
rm -f $GAME/server.cfg.steam



#### THIS NEEDS TO BE LAST
chown -R fivem:fivem $MAIN
