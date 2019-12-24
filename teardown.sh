#!/bin/bash
if [ -z $srvAcct ]; then
	srvAcct="fivem"
fi

su $srvAcct -c "screen -XS 'fivem' quit"
rm -rf /home/$srvAcct
rm -rf /var/software
deluser $srvAcct
mysql -e "DROP DATABASE essentialmode;"
