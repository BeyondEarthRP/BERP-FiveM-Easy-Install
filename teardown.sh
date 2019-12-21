#!/bin/bash
rm -rf /home/fivem
rm -rf /var/software
deluser fivem
mysql -e "DROP DATABASE essentialmode;"
