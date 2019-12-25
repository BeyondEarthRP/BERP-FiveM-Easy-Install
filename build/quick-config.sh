#!/bin/bash

if [ -z $_outconfig ]; then
	_outconfig="config.json"
fi

echo "We are about to create a configuration file to be used at deployment."
echo ""
_confirm="";read -p "Continue? (N/y)" _confirm
if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
then
	while [ -z $srvAcct ];
	do
		_prompt="";_prompt="Enter the linux account to be used for FiveM (fivem):"

		_return="";read -p "$_prompt " _return
		if [ -z $_return ]; then _return="admin"; fi
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			srvAcct=$_return
		fi
	done
	while [ -z $srvPassword ];
	do
		_prompt="";_prompt="Enter a password for ${srvAcct}:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			srvPassword=$_return
		fi
	done
	while [ -z $mysql_user ];
	do
		_prompt="";_prompt="Enter MySql username for the essentialmode database (admin):"

		_return="";read -p "$_prompt " _return
		if [ -z $_return ]; then _return="admin"; fi
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			mysql_user=$_return
		fi
	done
	while [ -z $mysql_password ];
	do
		_prompt="";_prompt="Enter MySQL password for ${mysql_user}:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			mysql_password=$_return
		fi
	done
	while [ -z $steam_webApiKey ];
	do
		_prompt="";_prompt="Enter your Steam Web API Key:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			steam_webApiKey=$_return
		fi
	done
	while [ -z $sv_licenseKey ];
	do
		_prompt="";_prompt="Enter your Cfx FiveM License:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			sv_licenseKey=$_return
		fi
	done
	while [ -z $blowfish_secret ];
	do
		_prompt="";_prompt="Enter Blowfish Secret for PHP:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			blowfish_secret=$_return
		fi
	done
	while [ -z $DBPSWD ];
	do
		_prompt="";_prompt="Enter root account password for MySQL:"

		_return="";read -p "$_prompt " _return
		echo ""
		_confirm="";read -p "are you sure? " _confirm
		if [ "$_confirm"=="y" ] || [ "$_confirm"=="yes" ];
		then
			DBPSWD=$_return
		fi
	done

	cat << EOF > $_outconfig
{
	"srvAcct"="${srvAcct}",
	"srvPassword"="${srvPassword}",
	"mysql_user"="${mysql_user}",
	"mysql_password"="${mysql_password}",
	"steam_webApiKey"="${steam_webApiKey}",
	"sv_licenseKey"="${sv_licenseKey}",
	"blowfish_secret"="${blowfish_secret}"
	"DBPSWD":"${DBPSWD}"
}
EOF
fi
