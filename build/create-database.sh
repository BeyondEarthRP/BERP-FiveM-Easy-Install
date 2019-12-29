#!/bin/bash
if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "EXECUTE" ]; then

	if [ ! -z "${MYSQL_USER}" ] && [ ! -z "${MYSQL_PASSWORD}" ];
	then
		## ---- mySQL Database ---- ##

			mysql -e "CREATE DATABASE essentialmode;"
			mysql -e "CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
			mysql -e "GRANT ALL PRIVILEGES ON essentialmode.* TO '${MYSQL_USER}'@'localhost';"

		## ---- mySQL Database ---- ##
	else
		echo "Error: no exports found.  I'VE FAILED!"
	fi
else
    echo "This script must be executed by the deployment script"
fi
