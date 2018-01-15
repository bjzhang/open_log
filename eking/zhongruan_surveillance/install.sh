#!/bin/bash

LANG=en_US.UTF-8
MOUNT_POINT=/mnt/images
BRIDGE=virbr0

install_ceph() {
    MOUNT_POINT=$1
    IMG_NAME=$2
    BRIDGE=$3
    NAME=$4
    MEMORY=2048
    VCPUS=2
    HYPERVISOR=kvm
    DISK=$MOUNT_POINT/$NAME.raw
    SIZE=100g
    GRAPHICS=vnc,listen=0.0.0.0
    CDROM=$MOUNT_POINT/`basename $IMG_NAME`
    if [ -f $DISK ]; then
        echo "ERROR: disk($DISK) exist. exit"
        return
    else
        sudo truncate -s $SIZE $DISK
    fi
    sudo virsh list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" = "0" ]; then
        echo "Error: vm($NAME) exist. exit"
        echo "Run \"sudo bash -c 'virsh destroy $NAME; virsh undefine $NAME'\" if you want to delete it"
        return
    fi
    sudo screen -d -m virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR --disk $DISK --cdrom $CDROM \
            --graphics $GRAPHICS --network bridge=$BRIDGE --noreboot \
            --noautoconsole
    sleep 1
    while true; do
            sudo virsh vncdisplay $NAME 2>&1 > /dev/null
            if [ "$?" = "0" ]; then
                break
            fi
    done
    PORT=`sudo virsh vncdisplay $NAME | cut -d : -f 2`
    echo "Connect to ip:$((PORT + 5900)) to do the installation"
    sudo virsh suspend $NAME
    echo "press enter to continue installation"
    read
    sudo virsh resume $NAME
    screen -d -r
}

IMG_NAME=$1
NAME=$2
if [ -f "$IMG_NAME" ]; then
	echo $IMG_NAME
else
	exit
fi
if [ "$NAME" = "" ]; then
	exit
fi
echo "    Install ceph vm from iso"
install_ceph $MOUNT_POINT $IMG_NAME $BRIDGE $NAME
