#!/bin/bash

usage()
{
	echo "insert_data_disk.sh ceph_test_0.6.9_02 vdb"
}

#NAME=ceph_test_0.5.4_02
DIR=`which $0`
DIR=`dirname $DIR`
NAME=$1
if [ "$1" = "" ]; then
	exit
fi
VDISK=$2
#VDISK is used for host. we could not determine the device name in target(AKA: guest)
if [ "$VDISK" = "" ]; then
	exit
fi
DISK=`echo ${NAME} | sed 's/test/data/g'`_${VDISK}.raw
XML=${DIR}/ceph-data.xml

if [ -f "/mnt/images/$DISK" ]; then
	echo "$DISK exist. exit"
	exit
fi
sudo truncate -s 100g /mnt/images/$DISK
sed "s/^\([\ \t]*<source file='\/mnt\/images\/\).*'\/>$/\1$DISK'\/>/g" -ibak $XML
sed "s/^\([\ \t]*<target dev='\).*\(' bus='.*'\/>\)$/\1$VDISK\2/g" -ibak $XML
sudo virsh domblklist $NAME
sudo virsh attach-device $NAME $XML --persistent --live
sudo virsh domblklist $NAME
