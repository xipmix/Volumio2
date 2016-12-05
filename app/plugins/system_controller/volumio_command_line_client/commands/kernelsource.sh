#!/bin/bash

if [ "0" != "`id -u`" ]; then
 echo "You must be root to run $0" 1>&2
 exit 1
fi

HARDWARE_REV=`cat /proc/cpuinfo | grep "Hardware" | awk -F: '{print $NF}'`

function kernelinstall {

echo " ---- VOLUMIO RASPBERRY PI KERNEL SOURCE DOWNLOADER ----"
echo " "
echo "This process might take a long time"
echo " "

ARCH=`/usr/bin/arch`

echo "Checking if build essential is installed"
if [ $(dpkg-query -W -f='${Status}' make 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing build essential"
  apt-get update && apt-get install -y build-essential bc;
fi

cd /home/volumio
FIRMWARE_REV=`cat /boot/.firmware_revision`
echo "Firmware revision is"  $FIRMWARE_REV 

KERNEL_REV=`curl -L https://github.com/Hexxeh/rpi-firmware/raw/${FIRMWARE_REV}/git_hash`
echo "Kernel revision is "$KERNEL_REV

if [ "$ARCH" = armv7l ]; then
 echo "Getting modules symvers for V7 kernel"
 curl -L https://github.com/Hexxeh/rpi-firmware/raw/${FIRMWARE_REV}/Module7.symvers >Module7.symvers
 else
 echo "Getting modules symvers for V6 kernel"
 curl -L https://github.com/Hexxeh/rpi-firmware/raw/${FIRMWARE_REV}/Module.symvers >Module.symvers
fi

echo "Donwloading Kernel source tarball from " https://github.com/raspberrypi/linux/archive/${KERNEL_REV}.tar.gz
curl -L https://github.com/raspberrypi/linux/archive/${KERNEL_REV}.tar.gz >rpi-linux.tar.gz

echo "creating /usr/src/rpi-linux folder"
mkdir /usr/src/rpi-linux

echo "Extracting Kernel"
tar --strip-components 1 -xf rpi-linux.tar.gz -C /usr/src/rpi-linux
cd /usr/src/rpi-linux

echo "Cloning current config"
/sbin/modprobe configs
gunzip -c /proc/config.gz >.config

echo "Copying modules symverse"
if [ "$ARCH" = armv7l ]; then
 cp /home/volumio/Module7.symvers Module.symvers
else
 cp /home/volumio/Module.symvers Module.symvers
fi
make modules_prepare
echo "Linking Modules"
ln -sv /usr/src/rpi-linux /lib/modules/$(uname -r)/build
echo " "
echo "Done, you can now build and install out of kernel modules"
}


if [ "$HARDWARE_REV" = " BCM2709" ] || [ "$HARDWARE_REV" = " BCM2708" ]; then
 kernelinstall
else
 echo "This tool is available only for Raspberry PI, exiting"
fi

