#!/bin/bash
#####################################################################
#
# JUST A BANNER
##

if [ -z "$__RUNTIME__" ] ;
then # GO LOOK FOR IT
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
        #-----------------------------------------------------------------
	. "$_BUILD/includes.sh"
fi

if [ "$1" == WELCOME ] ;
then
	color lightYellow - bold
	cat <<EOF
                                                                  
                                                                  
   8 888888888o   8 88888888888  8 888888888o.   8 888888888o     
   8 8888    \`88. 8 8888         8 8888    \`88.  8 8888    \`88.   
   8 8888     \`88 8 8888         8 8888     \`88  8 8888     \`88   
   8 8888     ,88 8 8888         8 8888     ,88  8 8888     ,88   
   8 8888.   ,88' 8 888888888888 8 8888.   ,88'  8 8888.   ,88'   
   8 8888888888   8 8888         8 888888888P'   8 888888888P'    
EOF
	color yellow - bold
	cat <<EOF
   8 8888    \`88. 8 8888         8 8888\`8b       8 8888           
   8 8888      88 8 8888         8 8888 \`8b.     8 8888           
   8 8888    ,88' 8 8888         8 8888   \`8b.   8 8888           
   8 888888888P   8 888888888888 8 8888     \`88. 8 8888           
   8 Beyond       8 Earth        8 Role          8 Play           
EOF
	color white - -
	cat <<EOF
      __                 __             __                        
     |__) _   _  _  _|  |_  _  _|_|_   |__)_ | _ _ | _            
     |__)(-\\/(_)| )(_|  |__(_|| |_| )  | \\(_)|(-|_)|(_|\\/       
           /                                    |      /          
                                                                  
EOF
	color red - bold
	cat <<EOF
           EASY (FOR YOU!) FIVEM DEPLOYMENT SCRIPT               
                                                                  
                                                                  
EOF
	color - - clearAll
fi

if [ "$1" == "BELCHER" ] ; 
then
	color cyan - bold
	echo "______  _____ ______  ______                 ";
	echo "| ___ \\|  ___|| ___ \\ | ___ \\                ";
	echo "| |_/ /| |__  | |_/ / | |_/ /                ";
	echo "| ___ \\|  __| |    /  |  __/                 ";
	echo "| |_/ /| |____| |\\ \\ _| |_                   ";
	echo "\\____(_)____(_)_| \\_(_)_(_)                  ";
	echo "                                             ";
	echo "                                             ";
	echo "______ _____ _     _____  _   _  ___________ ";
	echo "| ___ \\  ___| |   /  __ \\| | | ||  ___| ___ \\";
	echo "| |_/ / |__ | |   | /  \\/| |_| || |__ | |_/ /";
	echo "| ___ \\  __|| |   | |    |  _  ||  __||    / ";
	echo "| |_/ / |___| |___| \\__/\\| | | || |___| |\\ \\ ";
	echo "\\____/\\____/\\_____/\\____/\\_| |_/\\____/\\_| \\_|";
	echo "                                             ";
	color white - bold
	echo " BY: Beyond Earth (Made for Beyond Earth Roleplay)";
	echo " " ;
	color - - clearAll
fi

if [ "$1" == NEW_INSTALL ] ; 
then
	echo "                                                                                      ";
	echo "                                                                                      ";
	echo "███╗   ██╗███████╗██╗    ██╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ";
	echo "████╗  ██║██╔════╝██║    ██║    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ";
	echo "██╔██╗ ██║█████╗  ██║ █╗ ██║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ";
	echo "██║╚██╗██║██╔══╝  ██║███╗██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ";
	echo "██║ ╚████║███████╗╚███╔███╔╝    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗";
	echo "╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝";
	echo "                                                                                      ";
	echo "    you've got about 10 seconds to cancel this script (hit control-c two times!)      ";
	echo "                                                                                      ";
	echo "                                                                                      ";
fi

if [ "$1" == REDEPLOY ] ; 
then
	echo "                                                                  ";
	echo "██████╗ ███████╗██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗";
	echo "██╔══██╗██╔════╝██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝";
	echo "██████╔╝█████╗  ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ ";
	echo "██╔══██╗██╔══╝  ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ";
	echo "██║  ██║███████╗██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ";
	echo "╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ";
	echo "                                                                  ";
	echo "        you've got about 10 seconds to cancel this script         ";
	echo "                  (hit control-c two times!)                      ";
	echo "                                                                  ";
	echo "                                                                  ";
fi

if [ "$1" == REBUILD ] ; 
then
	echo "                                                    ";
	echo "██████╗ ███████╗██████╗ ██╗   ██╗██╗██╗     ██████╗ ";
	echo "██╔══██╗██╔════╝██╔══██╗██║   ██║██║██║     ██╔══██╗";
	echo "██████╔╝█████╗  ██████╔╝██║   ██║██║██║     ██║  ██║";
	echo "██╔══██╗██╔══╝  ██╔══██╗██║   ██║██║██║     ██║  ██║";
	echo "██║  ██║███████╗██████╔╝╚██████╔╝██║███████╗██████╔╝";
	echo "╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ";
	echo "                                                    ";
	echo " you've got about 10 seconds to cancel this script  ";
	echo "           (hit control-c two times!)               ";
	echo "                                                    ";
	echo "                                                    ";
fi

if [ "$1" == RESTORE ] ; 
then
	echo "                                                          ";
	echo "██████╗ ███████╗███████╗████████╗ ██████╗ ██████╗ ███████╗";
	echo "██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝";
	echo "██████╔╝█████╗  ███████╗   ██║   ██║   ██║██████╔╝█████╗  ";
	echo "██╔══██╗██╔══╝  ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  ";
	echo "██║  ██║███████╗███████║   ██║   ╚██████╔╝██║  ██║███████╗";
	echo "╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝";
	echo "                                                          ";
	echo "    you've got about 10 seconds to cancel this script     ";
	echo "              (hit control-c two times!)                  ";
	echo "                                                          ";
	echo "                                                          ";
fi
