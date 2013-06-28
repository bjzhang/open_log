#!/bin/bash

domain_name=$1

for i in `seq 100`; do
    date
    echo "test $i times"
    virsh list
    virsh save $domain_name $domain_name.save
    echo "save successful"
    virsh list
    virsh restore $domain_name.save
    echo "restore successful"
    virsh list
    ls -lh $domain_name.save
    rm $domain_name.save
    echo "sleep 10 seconds"
    sleep 10
done
