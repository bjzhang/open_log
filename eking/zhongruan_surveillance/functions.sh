
#Try to get ip through arp with 10 seconds timeout.
#Arguments: $1 name of vm: could be name, uuid, ID any of which could be
#                          supported by virsh
get_ip() {
    NAME=$1
    virsh list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "Error: vm($NAME) inexist. exit"
        return
    fi

    bridge=`virsh dumpxml $NAME | grep source.bridge | cut -d \' -f 2`
    mac=`virsh dumpxml $NAME |grep mac.address | cut -d = -f 2 | sed "s/['/>']//g"`
    for i in `seq 10`; do
        ip=`arp -a -i $bridge | grep $mac | cut -d \  -f 2 | sed "s/[()]//g"`
        if [ "$ip" != "" ]; then
            echo "Ip address is $ip"
            return
        fi
        sleep 1
        echo -n "."
    done
    echo "wait for ip address timeout"
}

#Install vm
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
        truncate -s $SIZE $DISK
    fi
    virsh list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" = "0" ]; then
        echo "Error: vm($NAME) exist. exit"
        echo "Run \"virsh destroy $NAME\" and \"virsh undefine $NAME\" if you want to delete it"
        return
    fi
    echo "start virt-install"
    screen -d -m virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR --disk $DISK --cdrom $CDROM \
            --graphics $GRAPHICS --network bridge=$BRIDGE --noreboot \
            --noautoconsole
    sleep 1
    echo "wait for vnc setup"
    while true; do
            virsh vncdisplay $NAME 2&> /dev/null
            if [ "$?" = "0" ]; then
                break
            fi
    done
    PORT=`virsh vncdisplay $NAME | cut -d : -f 2`
    echo "Connect to ip:$((PORT + 5900)) to do the installation"
    virsh suspend $NAME
    echo "press enter to continue installation"
    read
    virsh resume $NAME
    screen -d -r
    echo "wait for ip address"
    get_ip $NAME
}
