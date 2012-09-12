#!/bin/bash

virsh -c qemu:///system  migrate sles11_qemu_12 qemu+ssh://linux-vm4/system &
while true; do
    echo linux-vm4; virsh -c qemu:///system list &
    echo linux-vm5; virsh -c qemu+ssh://linux-vm4/system list &
    alive=`virsh -c qemu:///system list --name | grep sles11_qemu_12`
    if [ "$alive" = "" ]; then
        break
    fi
    sleep 1
done

echo migration finished, migration back. 
ssh linux-vm4 'virsh -c qemu:///system  migrate sles11_qemu_12 qemu+ssh://linux-vm5/system'
echo migration finished

