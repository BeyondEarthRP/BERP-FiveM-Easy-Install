#!/bin/bash
_YAPP="DEPLOY_LOCAL_SERVER"
if [ -z "$__RUNTIME__" ] ;
then
        if [ -z "$_BUILD" ] ;
        then
          THIS_SCRIPT_ROOT=$(dirname $(readlink -f "$0")) ;
          BUILDCHECK=()
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../../build") ) || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/../build") )    || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}/build") )       || true
          BUILDCHECK+=( $(readlink -f "${THIS_SCRIPT_ROOT:?}") )             || true
          unset THIS_SCRIPT_ROOT ;
          for cf in "${BUILDCHECK[@]}" ;
          do
            if [ -d "$cf" ] && [ -f "${cf:?}/build-env.sh" ] ;
            then
                _BUILD="$cf"
            fi
          done
        fi
        [[ -z "$_BUILD" ]] && echo "Build folder undefined. Failed." && exit 1
        #-----------------------------------------------------------------------------------------------------------------------------------
        if [ -z "$APPMAIN" ] ;
        then
          APPMAIN="${_YAPP:?}"
          . "$_BUILD/build-env.sh" EXECUTE
        elif [ -z "$__RUNTIME__" ] ;
        then
                echo "Runtime not loaded... I'VE FAILED!"
                exit 1
        fi
        [[ -z "${SOURCE:?}" ]] &&  echo "Source undefined... " && exit 1

        [[ -n "$__INVALID_CONFIG__" ]] && echo "You'll need to run the quick configure before this will work..." && exit 1
fi
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then
    [[ -z "$DB_ROOT_PASSWORD" ]] \
        && echo "Root password not yet entered.  This should have already been done. Failed!" \
        && exit 1

    [[ -z "$SOFTWARE_ROOT" ]] && echo "software folder location not defined." && exit 1
    [[ -z "$TFIVEM" ]] && echo "tfivem folder location not defined." && exit 1
    [[ -z "$TCCORE" ]] && echo "tccore folder location not defined." && exit 1

    # TEMP DIRECTORIES
    [[ ! -d "$SOFTWARE_ROOT" ]] && mkdir "$SOFTWARE_ROOT"
    [[ ! -d "$TFIVEM" ]] && mkdir "$TFIVEM"
    [[ ! -d "$TCCORE" ]] && mkdir "$TCCORE"

    # Dependancies
    ########################
    echo "Linux Software & Configuration"
	echo "--> Fetch Updates"
	sudo apt update && sudo apt -y upgrade
	echo ""

	echo "--> INSTALLING: PHP"
	sudo apt-get install -y php
	sudo apt-get install -y php-cgi
	sudo apt-get install -y php-mysqli
	sudo apt-get install -y php-pear
	sudo apt-get install -y php-mbstring
	sudo apt-get install -y php-gettext
	sudo apt-get install -y libapache2-mod-php
	sudo apt-get install -y php-common
	sudo apt-get install -y php-phpseclib
	echo ""

	echo "--[ Fetch Updates ]--"
	sudo apt update && sudo apt -y upgrade
	echo ""

	echo "--> INSTALLING: MariaDB"
	sudo apt -y install mariadb-server mariadb-client
	# When prompted to set the root password, provide the password and confirm.
	# sudo mysql_secure_installation  ## <-- USE THIS IF YOU LIKE SUPER INTERACTIVE EDITION.  HANDS!
	##
	#### the amazingness below is by this guy: Bert Van Vreckem <bert.vanvreckem@gmail.com>
	#### you should use that instead.  Way less struggle.  I got this from his script at:
	#### https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
	##
	mysql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
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
	wget "https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-english.tar.gz"
	tar xvf "phpMyAdmin-${VER}-english.tar.gz"

	#- working
	rm phpMyAdmin*.gz
	sudo mv phpMyAdmin-* /usr/share/phpmyadmin
	phpmyadmin_tmp=/var/lib/phpmyadmin/tmp
	sudo mkdir -p "$phpmyadmin_tmp"
	sudo chown -R www-data:www-data /var/lib/phpmyadmin
	sudo mkdir /etc/phpmyadmin/

	echo ":: phpMyAdmin PHP Configuration"
	phpConfigSource=/usr/share/phpmyadmin/config.sample.inc.php
	phpConfig=/usr/share/phpmyadmin/config.inc.php

	blowfish_secret_placeholder="\\\$cfg\['BLOWFISH_SECRET'\] = ''; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
	blowfish_secret_actual="\\\$cfg\['BLOWFISH_SECRET'\] = '${BLOWFISH_SECRET}'; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
	sed "s/${blowfish_secret_placeholder}/${blowfish_secret_actual}/" "$phpConfigSource" > "$phpConfig"

	echo "" >> "$phpConfig"
	echo "\$cfg['TempDir'] = '$phpmyadmin_tmp';" >> "$phpConfig"

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

    ## ---- FiveM ---- ##

        printf "\\e[91m\\e[1m"
    [[ -z "$TFIVEM" ]] && echo -e "tfivem folder location not defined.\\e[0m" && exit 1
    [[ -z "$TCCORE" ]] && echo -e "tccore folder location not defined.\\e[0m" && exit 1
    [[ -z "$MAIN" ]] && echo -e "main folder location not defined.\\e[0m" && exit 1
    [[ -z "$GAME" ]] && echo -e "game folder location not defined.\\e[0m" && exit 1
        printf "\\e[0m"

    echo "FiveM - Base"
        echo "Get Packages"
            artifact="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${ARTIFACT_BUILD:?}/fx.tar.xz"

            wget -P "${TFIVEM:?}" "$artifact"

        echo "Extract Package"
            tar -xf "$TFIVEM/fx.tar.xz" --directory "${MAIN:?}/"

    echo "CitizenFX Module Update"
        wget -P "${TCCORE:?}" https://d.fivem.dev/CitizenFX.Core.Server.zip
        unzip "${TCCORE:?}/CitizenFX.Core.Server.zip" -d "${TCCORE:?}/CCORE"

        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.sym" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.sym"
        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.Server.dll" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.dll"
        cp -RfT "${TCCORE:?}/CCORE/CitizenFX.Core.Server.sym" "${MAIN:?}/alpine/opt/cfx-server/citizen/clr2/lib/mono/4.5/CitizenFX.Core.Server.sym"

    ## ---- FiveM ---- ##



else
    echo "This script must be executed by the deployment script"
fi

