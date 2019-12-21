#!/bin/bash
if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then

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
            sudo apt-get -y install screen
            echo ""

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
#Alias /phpmyadmin /usr/share/phpmyadmin

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


            echo "--> Installing: NodeJS"
                sudo apt update
                sudo apt -y install nodejs npm -y
                sudo apt -y install build-essential -y

                nodejs --version
                npm --version


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

    ## ---- txAdmin ---- ##

    echo "--> Installing: txAdmin"
        # Download txAdmin, Enter folder and Install dependencies
        git clone https://github.com/tabarra/txAdmin $MAIN/txAdmin
        cd $MAIN/txAdmin
        npm i

        # Add admin
        node src/scripts/admin-add.js

        # Setup default server profile
        node src/scripts/setup.js default

    ## ---- txAdmin ---- ##



else
    echo "This script must be executed by the deployment script"
fi

