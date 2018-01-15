#!/bin/bash

#NAME=ceph_test_0.5.4_02
NAME=$1
if [ "$1" = "" ]; then
	exit
fi
DISK=`echo ${NAME} | sed 's/test/data/g'`.raw
XML=ceph-data.xml

if [ -f "/mnt/images/$DISK" ]; then
	echo "$DISK exist. exit"
	exit
fi
sudo truncate -s 100g /mnt/images/$DISK
ESCAPE_DISK="/mnt/images/`echo ${NAME} | sed 's/test/data/g'`.raw"
sed "s/^\([\ \t]*<source file='\/mnt\/images\/\).*'\/>$/\1$DISK'\/>/g" -ibak $XML
sudo virsh domblklist $NAME
sudo virsh attach-device $NAME $XML --persistent --live
sudo virsh domblklist $NAME
