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

teardown_network() {
	local _network ; local _network_exists
	_network="$1"
	_network_exists=$(docker network inspect "${_network:?}" 2>/dev/null)
        if [ "${_network_exists:?}" != "[]" ] ;
        then
                local _status
		_status=$(docker network rm "${_network:?}")
                if [ "${_status}" == "${_network:?}" ] ;
                then
                        echo -e "\\n\\e[92m\\e[1mNetwork '${_network:?}' removed successfully.\\e[0m"
		else
                        echo -e "\\n\\e[91m\\e[1mNetwork '${_network:?}' removal failed.\\e[0m"
                fi
        else
                echo -e "\\n\\e[93m\\e[1mNetwork '${_network:?}' does not exist.\\e[0m"
        fi
}

teardown_container() {
	local _container ; local _container_exists
	_container="$1"
        _container_exists=$(docker container inspect "${_container:?}" 2>/dev/null)
        if [ "${_container_exists:?}" != "[]" ] ;
	then
		if [ $(docker container inspect "${_container:?}" | jq -r '.[].State.Running') == "true" ] ;
		then
			local _status
			_status=$(docker stop "${_container:?}")
			[[ "${_status}" == "${_container:?}" ]] \
			  && echo -e "\\n\\e[92m\\e[1mContainer '${_container:?}' successfully powered down.\\e[0m" \
			  || echo -e "\\n\\e[91m\\e[1mContainer '${_container:?}' failed to powered down.\\e[0m"
			[[ "${_status}" == "${_container:?}" ]] && unset _status
		fi
		if [ -z "${_status}" ] ;
		then
			local _status
			_status=$(docker container rm "${_container:?}")
			if [ "${_status}" == "${_container:?}" ] ;
		        then
				echo -e "\\n\\e[92m\\e[1mContainer '${_container:?}' removed successfully.\\e[0m"
			else
				echo -e "\\n\\e[91m\\e[1mContainer '${_container:?}' removal failed.\\e[0m"
			fi
			unset _status
		fi
	else
		echo -e "\\n\\e[93m\\e[1mContainer '${_container:?}' does not exist.\\e[0m"
	fi
}

if [ ! -z "$1" ] && [ "$1" == "TEST" ]; then
    echo "TEST WAS A SUCCESS!"
elif [ ! -z "$1" ] && [ "$1" == "CONFIRM-DELETE" ]; then

    ## ---- All code goes below ---- ##

	teardown_container berp-fivem
	teardown_container mariadb
	teardown_container phpmyadmin
	teardown_network berp-fivem-tier

    ## ---- Done with the code? ---- ##

else
    echo -e "\\e[91mTo execute this script, you must use it like: \\e[37mteardown-containers.sh \\e[4mCONFIRM-DELETE\\e[0m\\n"
fi
