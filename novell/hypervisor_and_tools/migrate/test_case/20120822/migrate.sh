#!/bin/bash

for i in `seq 20`; do 
    date
    echo "$i: vm5->vm8"
    virsh -c xen:// migrate sles11_hvm_10_2 xen+ssh://linux-vm8
    echo "$i: vm8->vm5"
    virsh -c xen+ssh://linux-vm8 migrate sles11_hvm_10_2 xen+ssh://linux-vm5
    echo "sleep 2"
    sleep 2
    echo "sleep 2 end"
done

