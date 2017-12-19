
echo y | screen
echo y | yum install lvm2
echo y | yum install go
echo y | yum install git
echo y | yum install libvirt-devel
echo y | yum install libvirt
echo y | yum install qemu-kvm

#Copying file from aliyun to internal network. Only need to run on one server
#mkdir -p /mnt/ssd/catkeeper/images
#cd /mnt/ssd/catkeeper/images
#wget -c http://los-cn-north-1.lecloudapis.com/document/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw
#scp -p bamvor@119.23.217.97:/var/local/catkeeper/libvirt/centos7.0_01.xml /mnt/ssd/catkeeper/libvirt
#scp -p bamvor@119.23.217.97:/var/local/catkeeper/libvirt/centos7.0_02.xml /mnt/ssd/catkeeper/libvirt
#scp -p bamvor@119.23.217.97:/var/local/catkeeper/libvirt/centos7.0_03.xml /mnt/ssd/catkeeper/libvirt
#scp -p bamvor@119.23.217.97:/var/local/catkeeper/libvirt/centos7.0_04.xml /mnt/ssd/catkeeper/libvirt
#scp -p bamvor@119.23.217.97:/home/bamvor/works/publish/schema.sql /mnt/ssd/catkeeper #scp -p bamvor@119.23.217.97:/home/bamvor/works/publish/web /mnt/ssd/catkeeper

#Prepare disk. It may format the user data, run it seperately!
#mkdir -p /mnt/ssd
#mount /dev/nvme0n1p2 /mnt/ssd
#if [ $? = 0 ]; then
#   echo "nvme0n1p2 aleady formatted. exit"
#   exit
#fi
#vgcreate nvme_vg0 /dev/nvme0n1p2
#lvcreate -L 120g -n images nvme_vg0
#mkfs.ext4 /dev/mapper/nvme_vg0-images
#mount /dev/mapper/nvme_vg0-images /mnt/ssd
#setup go env
#build code on target due to differnce libvirt version
#go get github.com/bjzhang/catkeeper
#go get ./...
#cd /root/go/src
#wget http://los-cn-north-1.lecloudapis.com/document/golang.org.tar.gz
#tar zxf golang.org.tar.gz
#rm golang.org.tar.gz
#cd /root/go/src/github.com/bjzhang/catkeeper
#make -f makefile -C web
#cd /root/go/src/github.com/bjzhang/catkeeper/web
#sqlite3 /tmp/post_db.bin < /root/go/src/github.com/bjzhang/catkeeper/web/schema.sql

#Prepare ssh key login
#ssh-keygen
#ssh-copy-id ceph220

echo "make sure there is enough space in /mnt/ssd and ssh to ceph220 with sshkey. Press enter to continue"$
#[root@ct147 libvirt]# /usr/libexec/qemu-kvm  -machine help |grep i440fx
#pc                   RHEL 7.0.0 PC (i440FX + PIIX, 1996) (alias of pc-i440fx-rhel7.0.0)
#pc-i440fx-rhel7.0.0  RHEL 7.0.0 PC (i440FX + PIIX, 1996) (default)

echo "Mount /mnt/ssd and create directory"
mount /mnt/ssd
df -h
mkdir -p  /mnt/ssd/catkeeper/images
mkdir -p  /mnt/ssd/catkeeper/libvirt

echo "Copy and create images"
scp -p ceph220:/mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw /mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw
qemu-img create -f qcow2 -b /mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw /mnt/ssd/catkeeper/images/centos7.0_01.qcow2 20g
qemu-img create -f qcow2 -b /mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw /mnt/ssd/catkeeper/images/centos7.0_02.qcow2 20g
qemu-img create -f qcow2 -b /mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw /mnt/ssd/catkeeper/images/centos7.0_03.qcow2 20g
qemu-img create -f qcow2 -b /mnt/ssd/catkeeper/images/LimeJeOS-CentOS-07.0.x86_64-1.2.0.raw /mnt/ssd/catkeeper/images/centos7.0_04.qcow2 20g

echo "Configure libvirt"
systemctl restart libvirtd
systemctl status -l libvirtd
#● libvirtd.service - Virtualization daemon
#   Loaded: loaded (/usr/lib/systemd/system/libvirtd.service; enabled; vendor preset: enabled)
#   Active: active (running) since Fri 2017-12-15 11:17:52 CST; 8ms ago
#     Docs: man:libvirtd(8)
#           http://libvirt.org
# Main PID: 119233 (libvirtd)
#   CGroup: /system.slice/libvirtd.service
#           ├─119233 /usr/sbin/libvirtd
#           └─119252 /usr/sbin/libvirtd
#
#Dec 15 11:17:52 ceph220 systemd[1]: Starting Virtualization daemon...
#Dec 15 11:17:52 ceph220 systemd[1]: Started Virtualization daemon.

cat > bridge0.xml << EOF
<network>
  <name>bridge0</name>
  <uuid>8e1199bf-458f-4575-8baf-4c08a9e70220</uuid>
  <forward mode='route'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:67:94:20'/>
  <domain name='bridge0'/>
  <ip address='192.168.101.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.101.100' end='192.168.101.254'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define bridge0.xml
virsh net-autostart bridge0
virsh net-start bridge0
virsh net-list --all |grep bridge0

#[root@ceph220 ~]# virsh net-define bridge0.xml
#Network bridge0 defined from bridge0.xml
#
#[root@ceph220 ~]# virsh net-autostart bridge0
#Network bridge0 marked as autostarted
#
#[root@ceph220 ~]# virsh net-start bridge0
#Network bridge0 started
#
#[root@ceph220 ~]# virsh net-list --all
# Name                 State      Autostart     Persistent
#----------------------------------------------------------
# bridge0              active     yes           yes
# default              active     yes           yes

scp -p ceph220:/mnt/ssd/catkeeper/libvirt/centos7.0_01.xml /mnt/ssd/catkeeper/libvirt
scp -p ceph220:/mnt/ssd/catkeeper/libvirt/centos7.0_02.xml /mnt/ssd/catkeeper/libvirt
scp -p ceph220:/mnt/ssd/catkeeper/libvirt/centos7.0_03.xml /mnt/ssd/catkeeper/libvirt
scp -p ceph220:/mnt/ssd/catkeeper/libvirt/centos7.0_04.xml /mnt/ssd/catkeeper/libvirt

virsh define /mnt/ssd/catkeeper/libvirt/centos7.0_01.xml
virsh define /mnt/ssd/catkeeper/libvirt/centos7.0_02.xml
virsh define /mnt/ssd/catkeeper/libvirt/centos7.0_03.xml
virsh define /mnt/ssd/catkeeper/libvirt/centos7.0_04.xml

virsh list --all
# Id    Name                           State
#----------------------------------------------------
# -     centos7.0_01                   shut off
# -     centos7.0_02                   shut off
# -     centos7.0_03                   shut off
# -     centos7.0_04                   shut off

