#!/bin/bash

while true; do
    echo "vm5->vm8"
    virsh migrate  sles11_hvm_10_2 xen+ssh://linux-vm8
    echo "vm8->vm5"
    ssh linux-vm8 'virsh migrate sles11_hvm_10_2 xen+ssh://linux-vm5'
    echo "sleep 2"
    sleep 2
    echo "sleep 2 end"
done

