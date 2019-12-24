#!/bin/bash
if [ -z $srvAcct ]; then
	srvAcct="fivem"
fi
su $srvAcct -c "screen -XS 'fivem' quit"
deluser $srvAcct
if [ -d "/home/$srvAcct" ]; then
	rm -rf /home/$srvAcct
fi
rm -rf /var/software
mysql -e "DROP DATABASE essentialmode;"
