#!/bin/bash
if [ ! -z $1 ] && [ $1 == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z $1 ] && [ $1 == "EXECUTE" ]; then

	if [ ! -z ${mysql_user} ] && [ ! -z ${mysql_password} ];
	then
		## ---- mySQL Database ---- ##

			mysql -e "CREATE DATABASE essentialmode;"
			mysql -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';"
			mysql -e "GRANT ALL PRIVILEGES ON essentialmode.* TO '${mysql_user}'@'localhost';"

		## ---- mySQL Database ---- ##
	else
		echo "Error: no exports found.  I'VE FAILED!"
	fi
else
    echo "This script must be executed by the deployment script"
fi
