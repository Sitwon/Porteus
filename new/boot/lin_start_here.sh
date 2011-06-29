#!/bin/bash
# Script to install Porteus to USB device
# Author: Brokenman <brokenman@porteus.org>

# Set Porteus version
ver="Porteus-v1.0"

# Set variables
CWD=`pwd`
bootdir=${CWD}
portdir=../porteus
c='\e[36m'
r='\e[31m'
g='\e[32m'
e=`tput sgr0`

# safety checks

main_menu(){
clear
echo -e "${c}              _.====.._"
echo "            ,:._       ~-_"
echo "                '\        ~-_"
echo "                  \        \\."
echo "                ,/           ~-_"
echo -e "       -..__..-''   PORTEUS   ~~--..__"$e

echo -e "${g}--==--==--==--==--==--==--==--==--==--==--==--=="
echo "            Welcome to $ver      "
echo -e "--==--==--==--==--==--==--==--==--==--==--==--=="$e
echo
echo "[1] Check for Porteus update"
echo "[2] Read Porteus requirements"
echo "[3] Read Porteus installation instructions"
echo "[4] Read Porteus cheatcodes"
echo "[5] Read about bootloaders"
echo "[6] Install Porteus to EXTx partition (extlinux)"
echo "[7] Install Porteus to FATx partition (syslinux)"
echo "[8] Install Porteus to any partition (lilo)"
echo "    no graphical - only text menu available"
echo "[9] Quit this application"
echo
echo "Please choose a menu item ..."
read -n1 option > /dev/null
echo

while [ "$option" != "9" -a "$option" != "q" ]
        do
                case $option in
                        1 )
                        check_net
			check_update
			exit
                        ;;
                        2 )
                        clear
                        cat docs/requirements.txt|less
                        main_menu
                        exit
                        ;;
                        3 )
			clear
			cat docs/install.txt|less
			main_menu
			exit
                        ;;
                        4 )
			clear
                        cat docs/cheatcodes.txt|less
			main_menu
			exit
                        ;;
                        5 )
			clear
			cat docs/bloaders.txt|less
			main_menu
			exit
                        ;;
			6 )
			echo
			./syslinux/bootextlinux.sh
			exit
                        ;;
                        7 )
                        echo
                        ./syslinux/bootsyslinux.sh
                        exit
                        ;;
                        8 )
                        echo
                        ./syslinux/liloinst.sh
                        exit
                        ;;
                esac
done
}

check_net () {
clear
echo
echo "Checking net connectivity ..."

if (wget --spider --force-html --inet4-only http://www.google.com >/dev/null 2>&1); then
echo "Net connection: active"
else
echo "It seems you have no net connection"
echo "We cannot check for an update, exiting."
exit
fi
}

check_update() {
rverfile=http://www.porteus.org/version/version.txt
lver32=`grep 32 docs/version.txt|awk -F: '{print$2}'`
lver64=`grep 64 docs/version.txt|awk -F: '{print$2}'`
wget $rverfile
rver32=`grep 32 version.txt|awk -F: '{print$2}'`
rver64=`grep 64 version.txt|awk -F: '{print$2}'`
if [ $lver32 -lt $rver32 ]; then
   echo "A 32-bit update is available"
   exit
fi

if [ $lver64 -lt $rver64 ]; then
   echo "A 64-bit update is available"
   exit
fi
}

install_porteus() {
echo "Installing Porteus now"
exit
}

main_menu