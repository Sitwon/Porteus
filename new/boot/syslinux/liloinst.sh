#!/bin/bash
# This script will make almost ANY partition bootable, regardless the filesystem
# used on it. bootinst.sh/.bat is only for FAT filesystems, while this one should
# work everywhere. Moreover it setups a 'changes' directory to be used for
# persistent changes.

set -e
TARGET=""
MBR=""
c='\e[36m'
r='\e[31m'
e=`tput sgr0`

# Check md5sums before we start
cd ../porteus
sh chkbase.sh
cd ../boot

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

MBR=$(echo "$TARGET" | sed -r "s/[0-9]+\$//g")
NUM=${TARGET:${#MBR}}
cd "$MYMNT"

# only partition is allowed, not the whole disk
if [ "$MBR" = "$TARGET" ]; then
   echo Error: You must install your system to a partition, not the whole disk
   exit 1
fi

clear
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo "                        Welcome to Porteus boot installer                         "
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo
echo "This installer will setup disk $MBR to boot only Porteus from $TARGET."
echo "Warning! Master boot record (MBR) of $MBR will be overwritten."
echo "If you use $MBR to boot any existing operating system, it will not work"
echo "anymore. Only Porteus will boot from this device. Be careful!"
echo
echo -e "${r}Warning!"$e
echo "When you are installing Porteus on writable media (usb stick/hard drive)"
echo "with FAT or NTFS filesystem, you need to use a save.dat container"
echo "to save persistent changes. You will be prompted for creating save.dat"
echo "during boot time. If you refuse to do it, booting will continue in"
echo "Always Fresh mode."
echo -e "${c}You have been warned!"$e
echo
echo "Press any key to continue, or Ctrl+C to abort..."
read junk
clear

echo "Flushing filesystem buffers, this may take a while..."
sync

cat << ENDOFTEXT >$MYMNT/boot/lilo.conf
boot=$MBR
prompt
#timeout=100
large-memory
lba32
compact
change-rules
reset
install=menu
menu-scheme = Wb:Yr:Wb:Wb
menu-title = "Porteus Boot-Manager"
default = "KDE"

# kde
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "KDE"
vga=791
append = "autoexec=xconf;telinit~4 changes=/porteus"

# lxde
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "LXDE"
vga=791
append = "lxde autoexec=xconf;telinit~4 changes=/porteus"

# fresh
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "Always_Fresh"
append = "nomagic autoexec=xconf;telinit~4"

# cp2ram
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "Copy_To_RAM"
vga=791
append = "copy2ram autoexec=xconf;telinit~4"

# startx
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "VESA_mode"
append = "autoexec=telinit~4 changes=/porteus"

# text
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label="Text_mode"
append = ""

# pxe
image=$MYMNT/boot/vmlinuz
initrd=$MYMNT/boot/initrd.xz
label= "PXE_server"
append = "autoexec=pxe-boot;xconf;telinit~4"

# plop
image=$MYMNT/boot/syslinux/plpbt
label= "PLoP"

# memtest
image=$MYMNT/boot/tools/mt86p
label = "Memtest"

# Windows?
#other = /dev/sda1
#label = "First_partition"
ENDOFTEXT

echo Updating MBR to setup boot record...
boot/syslinux/lilo -C $MYMNT/boot/lilo.conf -S $MYMNT/boot/ -m $MYMNT/boot/lilo.map
echo "Disk $MBR should be bootable now. Installation finished."

echo
echo "Read the information above and then press any key to exit..."
read junk
