#vm=ceph_test_0.7.02_os01_scsi_01
vm=$1
disks=`sudo virsh domblklist $vm | grep "^[svxh]d[a-z].*\(\(raw\)\|\(qcow2\)\)" | sed "s/\ \ */ /g" | cut -d \  -f 2`
for disk in `echo $disks`; do echo "going to delete $disk, press enter to continue"; read; sudo virsh vol-delete $disk; done 
#sudo rm /mnt/images/ceph_test_0.7.02_os01_scsi_01_5.raw
sudo virsh destroy $vm
sudo virsh undefine  $vm
