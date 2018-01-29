#!/bin/bash

LANG=en_US.UTF-8
MOUNT_POINT=/mnt/images
BRIDGE=virbr0

install_from_iso() {
    MOUNT_POINT=$1
    ISO=$2
    BRIDGE=$3
    NAME=$4
    NUM_OF_DISK=$5
    MEMORY=4096
    VCPUS=4
    HYPERVISOR=kvm
    DISK=$MOUNT_POINT/$NAME.raw
    SIZE=100g
    GRAPHICS=vnc,listen=0.0.0.0
    for num in `seq $NUM_OF_DISK`; do
        DISK=$MOUNT_POINT/${NAME}_${num}.raw
        if [ -f $DISK ]; then
            echo "ERROR: disk($DISK) exist. exit"
            exit
        fi
    done
    for num in `seq $NUM_OF_DISK`; do
        DISK=$MOUNT_POINT/${NAME}_${num}.raw
        sudo truncate -s $SIZE $DISK
        DISK_CMDLINE="$DISK_CMDLINE --disk $DISK"
    done
    echo $DISK_CMDLINE
    sudo virsh list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" = "0" ]; then
        echo "Error: vm($NAME) exist. exit"
        echo "Run \"sudo bash -c 'virsh destroy $NAME; virsh undefine $NAME'\" if you want to delete it"
        return
    fi
    sudo virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR $DISK_CMDLINE --cdrom $ISO \
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

install_from_disk() {
    MOUNT_POINT=$1
    BASE_DISK=$2
    BRIDGE=$3
    NAME=$4
    MEMORY=4096
    VCPUS=16
    HYPERVISOR=kvm
    GRAPHICS=vnc,listen=0.0.0.0
    DISK=$MOUNT_POINT/${NAME}.qcow2
    if [ -f $DISK ]; then
        echo "ERROR: disk($DISK) exist. exit"
        exit
    fi
    capacity=`sudo virsh vol-info --bytes ${BASE_DISK} | grep Capacity | sed "s/\ \ */ /g" | cut -d \  -f 2`
    actual_size=`python -c "print $capacity/1024.0/1024/1024"`
    echo "use the same size of backing vol(${BASE_DISK}) $capacity($actual_size GB)"
    sudo virsh vol-create-as images `basename $DISK` --capacity $capacity --format qcow2 --backing-vol ${BASE_DISK} --backing-vol-format qcow2
    DISK_CMDLINE="--import --disk $DISK,bus=virtio"
    echo $DISK_CMDLINE
    sudo virsh list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" = "0" ]; then
        echo "Error: vm($NAME) exist. exit"
        echo "Run \"sudo bash -c 'virsh destroy $NAME; virsh undefine $NAME'\" if you want to delete it"
        return
    fi
    sudo virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR $DISK_CMDLINE --boot hd\
            --graphics $GRAPHICS --network bridge=$BRIDGE --noreboot \
            --noautoconsole
    if [ "$?" != "0" ]; then
        echo "virt-install failed. exit"
        exit
    fi
    sleep 1
    sudo virsh start $NAME
    sleep 1
    while true; do
            sudo virsh vncdisplay $NAME 2>&1 > /dev/null
            if [ "$?" = "0" ]; then
                break
            fi
    done
    PORT=`sudo virsh vncdisplay $NAME | cut -d : -f 2`
    echo "Connect to through vncview ip:$((PORT + 5900)):"
}

usage() {
    echo "Install from cdrom:"
    echo "    $0 cdrom vm_name"
    echo "Install from base disk which will be used as base disk:"
    echo "    $0 /mnt/images/zhangjian/opensuse42.3_kiwi.qcow2 opensuse_42.3_kiwi_03"
    echo "    watch installation through vnc port display by this script. And"
    echo "    get ip/ssh in to it through vm.sh ssh/ip opensuse_42.3_kiwi_03"
    exit
}

FILE=$1
NAME=$2
if ! [ -f "$FILE" ]; then
	echo image $FILE does not exist. exit
        usage
	exit
fi
if [ "$NAME" = "" ]; then
	echo vm $NAME empty. exit
	exit
fi
echo $FILE | grep "iso$"
if [ "$?" = "0" ]; then
	echo "Install vm from iso"
	NUM_OF_DISK=$3
	if [ "$NUM_OF_DISK" = "" ]; then
		echo "Set number of DISK as default while arguments missing"
		NUM_OF_DISK="1"
	fi
	install_from_iso $MOUNT_POINT $FILE $BRIDGE $NAME $NUM_OF_DISK
else
	echo "Install vm from disk"
	install_from_disk $MOUNT_POINT $FILE $BRIDGE $NAME
fi
