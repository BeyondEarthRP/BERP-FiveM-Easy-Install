#!/bin/bash
_YAPP="DEPLOY_CONTAINERS" # SHORT NAME FOR YOUR APP... JUST DON'T USE MAIN OR APPMAIN (OR ANY THAT I AM USING HAHAHA)
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

    ## ---- All code goes below ---- ##

	[[ -z "${TXADMIN_BACKUP}" ]] && echo "txAdmin data is not defined" &&  exit 1

	##### DEFINE SOME TINGS #################################################
	NETWORK_NAME="berp-fivem-tier"
	PRIVATE_FIVEM_DATA="${PRIVATE:?}/fivem-data/"

	# MARIADB
	MARIADB_NAME="mariadb"
	#MARIADB_VERSION="10.4"
	MARIADB_VERSION="latest"
	PRIVATE_FIVEM_MYSQL="${PRIVATE_FIVEM_DATA:?}/mysql"
	DATABASE_NAME="essentialmode"

	# PHPMYADMIN
	PHPMYADMIN_NAME="phpmyadmin"
	PHPMYADMIN_80="8880"		# PUBLISHED PORT / PUBLIC
	PHPMYADMIN_443="8443"		# PUB
	#PHPMYADMIN_VERSION="4.9.3"
	PHPMYADMIN_VERSION="latest"
	PRIVATE_FIVEM_PHPMYADMIN="${PRIVATE_FIVEM_DATA:?}/phpmyadmin"

	# FIVEM
	BERP_FIVEM_NAME="berp-fivem"
	BERP_FIVEM_30110="30110"		# PUB
	BERP_FIVEM_30120="30120"		# PUB
	BERP_TXADMIN_40120="40120"		# PUB
	BERP_FIVEM_VERSION="1868"

	# berp fivem docker image
        tfmdock="${TFIVEM:?}/berp-fivem_${BERP_FIVEM_VERSION:?}.tar"

	mariadb_docker=mariadb:"${MARIADB_VERSION:?}"
	phpmyadmin_docker=phpmyadmin/phpmyadmin:"${PHPMYADMIN_VERSION:?}"
	berp_fivem_docker=berp-fivem:"${BERP_FIVEM_VERSION:?}"

	##### PREPARING #########################################################
	#------------------------------------------------------------------------
	# PULLING IMAGES
	docker pull "${mariadb_docker:?}"
	docker pull "${phpmyadmin_docker:?}"
	#-------------------------------------------------------------------------
	# docker pull "${berp_fivem_docker:?}" <-- DOESN'T EXIST.  DOING THAT HERE
	#-Get the docker image for berp-fivem from me
	tfmdock="${TFIVEM:?}/berp-fivem_${BERP_FIVEM_VERSION:?}.tar"
	berp_fivem_docker_image=$(docker images -q "berp-fivem:${BERP_FIVEM_VERSION:?}" 2>/dev/null)
	if [ -z "$berp_fivem_docker_image" ] ;
	then
		# GET THE DOCKER IMAGE
		[[ ! -f "${tfmdock:?}" ]] && wget -O "${tfmdock:?}" https://bit.ly/2Fl2vbr

		# LOAD THE DOCKER IMAGE
		_status=$(docker load --input "${tfmdock:?}")
		[[ -n "$_status" ]] \
		  && echo "\\e[92m\\e[1mBERP FiveM Docker image loaded successfully.\\e[0m" \
		  ||  echo "\\e[91m\\e[1mBERP FiveM Docker image load failed. exiting.\\e[0m"
		[[ -z "$_status" ]] && exit 1 || unset _status
	fi
skip() {
	#------------------------------------------------------------------------
	# CHECK FOR & (IF NEEDED) CREATE THE NETWORK
	network_exists=$(docker network inspect "${NETWORK_NAME:?}" 2>/dev/null)
	[[ "${network_exists:?}" == "[]" ]] 	\
	  || [[ -z "${network_exists:?}" ]] 	\
	  && docker network create 		\
               --subnet="172.42.42.0/24" 	\
	       --gateway="172.42.42.254" 	\
	       "${NETWORK_NAME:?}"

	#------------------------------------------------------------------------
	# DOCKER PRECIOUS DATASTORES
	if [ ! -d "${PRIVATE_FIVEM_DATA:?}" ] ;
	then
		mkdir -p "${PRIVATE_FIVEM_DATA:?}"
	fi
	if [ ! -d "${PRIVATE_FIVEM_MYSQL:?}" ] ;
	then
		mkdir -p "${PRIVATE_FIVEM_MYSQL:?}"
	fi
	if [ ! -d "${PRIVATE_FIVEM_PHPMYADMIN:?}" ] ;
	then
		mkdir -p "${PRIVATE_FIVEM_PHPMYADMIN:?}"
	fi

	##### DEPLOYING CONTAINERS ##############################################
	# CREATE A MARIADB INSTANCE:
	docker run --name="${MARIADB_NAME:?}" 					\
	  --network="${NETWORK_NAME:?}"						\
	  --ip="172.42.42.10"							\
	  --network-alias=db --network-alias=mysql				\
	  --volume="${PRIVATE_FIVEM_MYSQL:?}":/var/lib/mysql		 	\
	  -e MYSQL_ROOT_PASSWORD="${DB_ROOT_PASSWORD:?}"			\
	  -e MYSQL_ROOT_HOST=%							\
	  -e MYSQL_USER="${MYSQL_USER:?}"					\
	  -e MYSQL_PASSWORD="${MYSQL_PASSWORD:?}"				\
	  -e MYSQL_DATABASE="${DATABASE_NAME:?}"				\
	  -d "${mariadb_docker:?}"

	# CREATE A PHPMYADMIN INSTANCE
	docker run --name="${PHPMYADMIN_NAME:?}"				\
	  --network="${NETWORK_NAME:?}"						\
	  --ip="172.42.42.5"							\
	  --volume="${PRIVATE_FIVEM_PHPMYADMIN:?}":/etc/phpmyadmin		\
	  -p "${PHPMYADMIN_80:?}":80						\
	  -p "${PHPMYADMIN_443:?}":443 						\
	  -e PMA_PASSWORD="${DB_ROOT_PASSWORD:?}"				\
	  -d "${phpmyadmin_docker:?}"

	# FIVEM CFX SERVER INSTANCE
	docker run --name="${BERP_FIVEM_NAME}"					\
	  --network="${NETWORK_NAME:?}"						\
	  --ip="172.42.42.100"							\
	  --volume="${TXADMIN_BACKUP:?}":/home/fivem/txAdmin/data		\
	  --volume="${GAME:?}":/home/fivem/server-data				\
	  -p "${BERP_TXADMIN_40120:?}":40120					\
	  -p "${BERP_FIVEM_30110:?}":30110					\
	  -p "${BERP_FIVEM_30110:?}":30110/udp					\
	  -p "${BERP_FIVEM_30120:?}":30120					\
	  -p "${BERP_FIVEM_30120:?}":30120/udp					\
	  -d "${berp_fivem_docker:?}"						\
	  /bin/bash -c "trap 'echo gotsigint' INT; cd /home/fivem/txAdmin; /usr/bin/node /home/fivem/txAdmin/src/index.js default;  bash"
}
	####
        # CHECK FOR MYSQL
        check_for_mysql

	# CONFIGURE THE TINGS!
	_check_MYSQL_SERVER="172.42.42.10"
        mysql -h "${_check_MYSQL_SERVER:?}" --user=root --password="${DB_ROOT_PASSWORD:?}" <<_EOF_
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
#NOT NEEDED UNLESS WE USE BLANK PASSWORDS INITIALLY.  NOT DOING THAT THOUGH, BECAUSE OTHER WAY WORKS FINE.
#UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PASSWORD}') WHERE User='root';

	if [ "$?" -eq 0 ] ;
	then
		echo -e "\\e[92mDatabase connection made successly and secure configuration added. (This will not execute a second time)\\e[0m"
	else
		mysql -h "${_check_MYSQL_SERVER:?}" --user="${MYSQL_USER:?}" --password="${MYSQL_PASSWORD:?}" -e 'USE `essentialmode`'
		if [ "$?" -eq 0 ] ;
		then
			echo -e "\\e[93mDatabase connection made successly, but from the ${MYSQL_USER}, not root.\\e[0m"
			echo -e "\\e[93mThis should only happen if you've tried to run this configuration twice.\\e[0m"
			echo -e "\\e[93mYou'll need to redeploy the container, if something is not correct. Otherwise, moving on....\\e[0m"
		else
		  	echo -e "\\e[91mDatabase connection failed.  The server is likely non-operational.  exiting.\\e[0m"
			exit 1
		fi
	fi

	MYSQL_SERVER="${_check_MYSQL_SERVER:?}"

	echo -e "Writing database server IP '${MYSQL_SERVER:?}' to configuration..."
        unset _contents ; unset _revision
        can_config "_contents" ;
        if [ -n "$_contents" ] ;
        then  # if there is no content in the file... we probably shouldn't be this far.  My assumption here atleast.
		_revision=$(echo "${_contents:?}" | eval jq -r \'"${jq_MYSQL_SERVER:?}"=\""${MYSQL_SERVER:?}"\"\')
		if [ "$?" -ne 0 ] ;
		then
			echo -e "\\e[91mConfiguration commit failed. exiting\\e[0m"
			exit 1
		fi
		[[ -n "$_revision" ]] && commit "_revision" "SILENT" || echo -e "\\e[91mConfiguration commit failed. exiting\\e[0m"
		unset _revision ;
        fi # OTHERWISE, SKIP THIS.  IT IS NOT NEEDED YET.
        unset _contents




    ## ---- Done with the code? ---- ##

else
    echo "This script must be executed by the deployment script"
fi
