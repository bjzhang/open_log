#!/bin/bash

LANG=en_US.UTF-8
MOUNT_POINT=/mnt/images
BRIDGE=virbr0

install_from_iso() {
    MOUNT_POINT=$1
    ISO=$2
    BRIDGE=$3
    NAME=$4
    MEMORY=2048
    VCPUS=2
    HYPERVISOR=kvm
    DISK=$MOUNT_POINT/$NAME.raw
    SIZE=100g
    GRAPHICS=vnc,listen=0.0.0.0
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
    sudo virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR --disk $DISK --cdrom $ISO \
            --graphics $GRAPHICS --network bridge=$BRIDGE --noreboot \
            --noautoconsole
    if [ "$?" != "0" ]; then
        echo "virt-install failed. exit"
        exit
    fi
    sleep 1
    while true; do
            sudo virsh vncdisplay $NAME 2>&1 > /dev/null
            if [ "$?" = "0" ]; then
                break
            fi
    done
    PORT=`sudo virsh vncdisplay $NAME | cut -d : -f 2`
    echo "Connect to through vncview ip:$((PORT + 5900)) to do the installation:"
    while true; do
        echo "debug: pause domain"
        sudo virsh suspend $NAME
        state=`sudo virsh domstate $NAME | head -n1`
        sleep 1
        if [ "$state" = "paused" ]; then
            break
        fi
    done
    echo "press enter to continue installation. Then select Install"
    read
    sudo virsh resume $NAME
}

usage() {
    echo "$0 cdrom vm_name"
    exit
}

ISO=$1
NAME=$2
if ! [ -f "$ISO" ]; then
	echo image $ISO does not exist. exit
        usage
	exit
fi
if [ "$NAME" = "" ]; then
	echo vm $NAME empty. exit
	exit
fi
echo "Install vm from iso"
install_from_iso $MOUNT_POINT $ISO $BRIDGE $NAME
