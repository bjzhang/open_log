#!/bin/bash

LANG=en_US.UTF-8
DISK=/dev/sdb
VG=virt
LV=images
MOUNT_POINT=/mnt/images
IMG_IP=10.72.84.147
IMG_NAME=/mnt/ssd/catkeeper/images/kiwi/Ceph-CentOS-07.0.x86_64-0.4.1.install.iso
BRIDGE=virbr1

#Try to get ip through arp with 10 seconds timeout.
#Arguments: $1 name of vm: could be name, uuid, ID any of which could be
#                          supported by virsh
get_ip() {
    NAME=$1
    echo "wait for ip is not tested yet"
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
    screen -d -m virt-install --name $NAME --memory $MEMORY --vcpus $VCPUS \
            --virt-type $HYPERVISOR --disk $DISK --cdrom $CDROM \
            --graphics $GRAPHICS --network bridge=$BRIDGE --noreboot \
            --noautoconsole
    sleep 1
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
    get_ip $NAME
}

echo "WARNING: it is only the collection of my command. NOT FULLY test yet, press enter to continue"
read

echo "Updating all the package before install"
yum update

echo "Installing libvirt, qemu and utils"
yum install libvirt qemu-kvm virt-install screen
systemctl start libvirtd

echo "Make partition. It WILL ERASE ALL the data on $DISK. press enter to continue!"
read
ret=`partprobe -s $DISK`
if [ "$ret" != "" ]; then
    echo "partition table exist, exit"
    exit
fi

parted $DISK -s mklabel gpt
#using 0% to get the auto alignment
parted $DISK -s mkpart primary 0% 100%
vgcreate $VG ${DISK}1
lvcreate -l 100%FREE -n $LV $VG
mkfs.xfs /dev/mapper/$VG-$LV
#meta-data=/dev/mapper/virt-images isize=512    agcount=4, agsize=29293568 blks
#         =                       sectsz=512   attr=2, projid32bit=1
#         =                       crc=1        finobt=0, sparse=0
#data     =                       bsize=4096   blocks=117174272, imaxpct=25
#         =                       sunit=0      swidth=0 blks
#naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
#log      =internal log           bsize=4096   blocks=57214, version=2
#         =                       sectsz=512   sunit=0 blks, lazy-count=1
#realtime =none                   extsz=4096   blocks=0, rtextents=0
mkdir -p $MOUNT_POINT
mount /dev/mapper/$VG-$LV $MOUNT_POINT
DM=`ls -l /dev/mapper/virt-images | cut -d \  -f 11 | xargs basename`
PART_UUID=`ls -l /dev/disk/by-uuid/ | grep $DM | cut -d \  -f 9`
echo "UUID=$PART_UUID $MOUNT_POINT             xfs     defaults        0 0" >> /etc/fstab
mount $MOUNT_POINT
scp -p $IMG_IP:$IMG_NAME $MOUNT_POINT

echo "Install ceph vm"
echo "    Creating virtual network bridge 0"
cat > $BRIDGE.xml << EOF
<network>
  <name>virbr1</name>
  <uuid>8e1199bf-458f-4575-8baf-4c08a9e70220</uuid>
  <forward mode='route'/>
  <bridge name='$BRIDGE' stp='on' delay='0'/>
  <mac address='52:54:00:67:94:20'/>
  <domain name='$BRIDGE'/>
  <ip address='192.168.101.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.101.100' end='192.168.101.254'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define $BRIDGE.xml
virsh net-autostart $BRIDGE
virsh net-start $BRIDGE
virsh net-list --all |grep $BRIDGE
Network virbr1 defined from virbr1.xml
#+ virsh net-autostart virbr1
#Network virbr1 marked as autostarted
#
#+ virsh net-start virbr1
#Network virbr1 started
#
#+ virsh net-list --all
#+ grep virbr1
# virbr1               active     yes           yes

echo "    Install ceph vm from iso"
for i in `seq -f "%02.g" 0 3`; do
    NAME=ceph_test_$i
    install_ceph $MOUNT_POINT $IMG_NAME $BRIDGE $NAME
done

#echo "Boot the managerment vm"

