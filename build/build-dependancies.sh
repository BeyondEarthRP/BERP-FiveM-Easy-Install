#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	while [ -z "$DB_ROOT_PASSWORD" ];
	do
		_return="";read -p "Enter root account password for MySQL: " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			DB_ROOT_PASSWORD="$_return"
		fi
	done

    # TEMP DIRECTORIES
    mkdir "$SOFTWARE"
    mkdir "$TFIVEM"
    mkdir "$TSESX"
    mkdir "$TCCORE"
    mkdir "$TESMOD"

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

	blowfish_secret_placeholder="\\\$cfg\['blowfish_secret'\] = ''; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
	blowfish_secret_actual="\\\$cfg\['blowfish_secret'\] = '${blowfish_secret}'; \/\* YOU MUST FILL IN THIS FOR COOKIE AUTH! \*\/"
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


	echo "--> Installing: NodeJS"
	sudo apt update
	sudo apt -y install nodejs npm -y
	sudo apt -y install build-essential -y

	nodejs --version
	npm --version

else
    echo "This script must be executed by the deployment script"
fi

