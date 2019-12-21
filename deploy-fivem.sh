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
steam_webApiKey="D5E22AE91C9735328F8C397ACAA77389"

#- FiveM License:
sv_licenseKey="iejska94yn650vfrh7dqy99ruuhxvw5m"

#- MySql Account Info
mysql_user="esmAdmin" #--> Essential Mode Database Admin
mysql_password="vAELN964FMHvnHkuAJeXtzSZvZCvpD"
global_mysql_user="Global_Admin" #--> This is for root login via PHPMYADMIN
global_mysql_password="msspcXhl1iySar7rzRxMewH2iIPUVP23Yo4"

#- PHP Config [config.inc.php]
blowfish_secret="ac5e3348f1df39cff67e6a4a1e76a541"

#- Server Local Account
srvAcct="fivem"
srvPassword="lOI8cDDjwUC9O0VQhiihnudWT1VosP5Y4NvSNN"

#- .ssh Bundle
sshKeyBundle=https://www.dropbox.com/s/uwxjyomdhh539zm/sshKey.tar.gz

########################
# Account Creation
########################
    adduser $srvAcct --gecos "FiveM Server, , , " --disabled-password
    echo "$srvAcct:$srvPassword" | chpasswd

########################
# Varriables
########################

SOURCE=`pwd`

SOFTWARE=/var/software
    TFIVEM=$SOFTWARE/fivem
        TSESX=$TFIVEM/sesx
        TCCORE=$TFIVEM/citizenfx.core.server
        TESMOD=$TFIVEM/essentialmode

MAIN=/home/$srvAcct
    GAME=$MAIN/server-data
        RESOURCES=$GAME/resources
            GAMEMODES=$RESOURCES/\[gamemodes\]
                MAPS=$GAMEMODES/\[maps\]
            ESX=$RESOURCES/\[esx\]
                ESEXT=$ESX/es_extended

            ESSENTIALMODE=$RESOURCES/\[essentialmode\]
	        ESMOD=$ESSENTIALMODE/essentialmode

            MODS=$RESOURCES/\[mods\]
            VEHICLES=$RESOURCES/\[vehicles\]

# TEMP DIRECTORIES
mkdir $SOFTWARE
mkdir $TFIVEM
mkdir $TSESX
mkdir $TCCORE
mkdir $TESMOD

# Dependancies
########################
echo "Linux Software & Configuration"
    echo "--> Fetch Updates"
        sudo apt update && sudo apt -y upgrade
        echo ""

    echo "--> INSTALLING: unzip, unrar, wget, git, screen"
        sudo apt-get -y install unzip
        sudo apt-get -y install unrar-free
        sudo apt-get -y install wget
        sudo apt-get -y install git
        sudo apt-get -y install screen
        echo ""

    echo "--( Configuring .SSH for root )--"
        cd ~
        wget $sshKeyBundle
        bundle=$(echo $sshKeyBundle | rev | cut -f1 -d/ | rev)
        tar xvzf $bundle
        rm $bundle
        echo ""

    echo "--( Configuring git )--"
        git config --global --edit
#        ssh git@github.com

    echo "--> INSTALLING: PHP"
        sudo apt-get install -y php php-cgi php-mysqli php-pear php-mbstring php-gettext libapache2-mod-php php-common php-phpseclib php-mysql
        echo ""

    echo "--[ Fetch Updates ]--"
        sudo apt update && sudo apt -y upgrade
        echo ""

    echo "--> INSTALLING: MariaDB"
        sudo apt -y install mariadb-server mariadb-client
        # When prompted to set the root password, provide the password and confirm.
        sudo mysql_secure_installation
        echo ""

    echo "--> INSTALLING: Apache"
        sudo apt-get -y install apache2

    echo "--> INSTALLING: phpMyAdmin"
        VER="4.9.2"
	cd /tmp
        ### phpMyAdmin Version Selection #############################################################
        #' -> ONLY UNCOMMENT ONE (2 lines; wget & tar) BELOW: INTERNATIONAL vs ENGLISH-ONLY'
        #
	# All Languages Version:
	# wget https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-all-languages.tar.gz
	# tar xvf phpMyAdmin-${VER}-all-languages.tar.gz
        #
        #' English Only Version:'
        wget https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-english.tar.gz
	tar xvf phpMyAdmin-${VER}-english.tar.gz

        #- working
        rm phpMyAdmin*.gz
        sudo mv phpMyAdmin-* /usr/share/phpmyadmin
        phpmyadmin_tmp=/var/lib/phpmyadmin/tmp
        sudo mkdir -p $phpmyadmin_tmp
        sudo chown -R www-data:www-data /var/lib/phpmyadmin
        sudo mkdir /etc/phpmyadmin/

        echo ":: phpMyAdmin PHP Configuration"
        phpConfigSource=/usr/share/phpmyadmin/config.sample.inc.php
        phpConfig=/usr/share/phpmyadmin/config.inc.php

        blowfish_secret_placeholder="\\\$cfg\['blowfish_secret'\] = ''; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
        blowfish_secret_actual="\\\$cfg\['blowfish_secret'\] = '${blowfish_secret}'; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
        sed "s/${blowfish_secret_placeholder}/${blowfish_secret_actual}/" $phpConfigSource > $phpConfig

        echo "" >> $phpConfig
        echo "\$cfg['TempDir'] = '$phpmyadmin_tmp';" >> $phpConfig

        echo ":: phpMyAdmin Apache Configuration"
        apacheConfig=/etc/apache2/conf-enabled/phpmyadmin.conf
        cat <<EOF > /etc/apache2/conf-enabled/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF

        echo "Restarting apache."
            sudo systemctl restart apache2



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
    git clone https://github.com/BeyondEarthRP/cfx-server-data.git $GAME

echo "CitizenFX Module Update"
    wget -P $TCCORE https://d.fivem.dev/CitizenFX.Core.Server.zip
    unzip $TCCORE/CitizenFX.Core.Server.zip -d $TCCORE/CCORE

    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.sym $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.sym
    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.Server.dll $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.dll
    cp -Rfup $TCCORE/CCORE/CitizenFX.Core.Server.sym $MAIN/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.sym

## ---- FiveM ---- ##



## ---- sESX ---- ##
#this is currently breaking shit
#TSESX=/var/software/fivem/sesx
echo "sESX"
    wget -P "$TSESX" https://cdn.discordapp.com/attachments/529782752812204106/653783126253764649/sesx-current.zip
    unzip $TSESX/sesx-current.zip -d $TSESX
    rm $TSESX/sesx-current.zip

    cp -rfup $TSESX/server-data/server.cfg $GAME/server.cfg
    cp -rfup $TSESX/server-data/sesx.sql $GAME/sesx.sql
    cp -rfup $TSESX/server-data/resources/\[essentialmode\] $RESOURCES/
    cp -rfup $TSESX/server-data/resources/\[esx\] $RESOURCES/
    cp -rfup $TSESX/server-data/resources/\[utility\] $RESOURCES/

    mysql essentialmode -e "SOURCE $GAME/sesx.sql"
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
