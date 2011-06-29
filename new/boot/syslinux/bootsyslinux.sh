#!/bin/bash

# Safer boot installer for porteus
# Modified by Brokenman for use without safety equipment

set -e
TARGET=""
MBR=""
c='\e[36m'
r='\e[31m'
e=`tput sgr0`
bootdir=`pwd`
portdir=../porteus


# Check md5sums before we start
if [ ! -d ../porteus ]; then
   echo "Please enter the path to your porteus directory:"
   echo "For example: /mnt/sda5/porteus"
   read portdir
fi
pushd $portdir
sh chkbase.sh
popd

# Find out which partition or disk are we using
MYMNT=$(cd -P $(dirname $0) ; pwd)
while [ "$MYMNT" != "" -a "$MYMNT" != "." -a "$MYMNT" != "/" ]; do
   TARGET=$(egrep "[^[:space:]]+[[:space:]]+$MYMNT[[:space:]]+" /proc/mounts | cut -d " " -f 1)
   if [ "$TARGET" != "" ]; then break; fi
   MYMNT=$(dirname "$MYMNT")
done

if [ "$TARGET" = "" ]; then
   echo "Can't find device to install to."
   echo "Make sure you run this script from a mounted device."
   exit 1
fi

if [ "$(cat /proc/mounts | grep "^$TARGET" | grep noexec)" ]; then
   echo "The disk $TARGET is mounted with noexec parameter, trying to remount..."
   mount -o remount,exec "$TARGET"
fi

clear
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo "              Backup Mother Boot Record                      "
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo
echo "Would you like to backup the MBR of $TARGET now?"
echo -e "${c}(backing up is recommended)"$e
echo "Press  [y/n]"
read -n1 bup

if [ "$bup" == "y" ]; then
	dd if=$TARGET of=$MYMNT/mbr.bak bs=512 count=1
	echo
	echo "Backup of mbr is now at $MYMNT/mbr.bak"
	echo "Instructions to restore an MBR in the case of overwriting"
	echo "can be found in boot/docs/restore-mbr.txt"
	echo
	echo "Press enter to continue"
	read abook
fi



MBR=$(echo "$TARGET" | sed -r "s/[0-9]+\$//g")
NUM=${TARGET:${#MBR}}
cd "$MYMNT"

clear
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "             Welcome to Porteus boot installer              "
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo
echo "This installer will setup disk $TARGET to boot only Porteus."
if [ "$MBR" != "$TARGET" ]; then
   echo
   echo -e "${r}Warning!"$e
   echo "Master boot record (MBR) of $MBR will be overwritten."
   echo
   echo -e "${c}If you use $MBR to boot any existing operating system, it will not"
   echo "anymore.$e Only Porteus will boot from this device. Be careful!"
   echo "If you made a backup of your MBR it is at $MYMNT/mbr.bak"
   echo "Read the file boot/docs/restore-mbr.txt"
   echo
   echo -e "${r}Warning!"$e
   echo "When you are installing Porteus on writable media (usb stick/hard drive)"
   echo "with FAT or NTFS filesystem, you need to use a save.dat container"
   echo "to save persistent changes. You will be prompted for creating save.dat"
   echo "during boot time. If you refuse to do it, booting will continue in"
   echo "Always Fresh mode."
   echo -e "${c}You have been warned!"$e
fi
echo
echo "Press any key to continue, or Ctrl+C to abort..."
read junk
clear

echo "Flushing filesystem buffers, this may take a while..."
sync

# setup MBR if the device is not in superfloppy format
if [ "$MBR" != "$TARGET" ]; then
   echo "Setting up MBR on $MBR..."
   ./boot/syslinux/lilo -S /dev/null -M $MBR ext # this must be here to support -A for extended partitions
   echo "Activating partition $TARGET..."
   ./boot/syslinux/lilo -S /dev/null -A $MBR $NUM
   echo "Updating MBR on $MBR..." # this must be here because LILO mbr is bad. mbr.bin is from syslinux
   cat ./boot/syslinux/mbr.bin > $MBR
fi

echo "Setting up boot record for $TARGET..."
./boot/syslinux/syslinux -d boot/syslinux $TARGET

echo "Disk $TARGET should be bootable now. Installation finished."

echo
echo "Read the information above and then press any key to exit..."
read junk
