#!/bin/bash

test_ret()
{
    if [ $1 -ne 0 ]; then
        echo "###Error: fail, exit"
        exit 1
    else
        echo "###successful"
    fi
}

wait_started()
{
    domain_id=`virsh list | grep $domain_name | cut -d \  -f 2`
    echo domain id is $domain_id 
    echo "waiting domain started"
    last_cpu_time=`virsh dominfo $domain_name | grep "CPU time" | cut -d : -f 2 | sed s/^\ *//`
    sleep 1
    echo -n "cpu time is "
    while true; do
        cpu_time=`virsh dominfo $domain_name | grep "CPU time" | cut -d : -f 2 | sed s/^\ *//`
        echo -n "$cpu_time, "
        if [ "$cpu_time" == "$last_cpu_time" ]; then
            echo cpu time is $cpu_time. $domain_name fully started. 
            break 
        fi
        last_cpu_time=$cpu_time
        sleep 2
    done
}

reboot_or_shutdown()
{
    action=$1

    domain_id=`virsh list | grep $domain_name | cut -d \  -f 2`
    wait_started
    echo "$action $domain_name"
    virsh $action $domain_name
    echo -n "wait for $domain_name $domain_id ${action}ing"
    while true; do 
        virsh list | grep $domain_name | grep $domain_id 2>&1 > /dev/null || break
        echo -n "."
        sleep 2
    done
    ret=$?
    echo 
    echo "$domain_name $domain_id ${action}ed"
    if [ $action == "reboot" ]; then
        virsh list | grep $domain_name 
        test_ret $ret
    elif [ $action == "shutdown" ]; then
        test_ret $ret
    fi
}

managed_save()
{
    echo "managed save..."
    virsh managedsave $domain_name
    test_ret $?
    echo "check managedsave result from libvirt..."
    virsh list --with-managed-save --all | grep sles11_hvm_10_vm5
    test_ret $?
    echo "check managedsave image..."
    ls -lh /var/lib/xen/save/$domain_name.save
    test_ret $?
}

if [ -z $1 ]; then
    echo "Error: demain xml missing, exit". 
    exit 1
fi

domain_xml=$1
domain_name=`cat $domain_xml | grep "<name>" | sed "s/<name>\(.*\)<\/name>/\1/" | sed "s/^\ *//"`
echo "domain_xml is $domain_xml; domain_name is $domain_name"

echo "destroy managedsave domain if exits"
virsh list --with-managed-save --all | grep sles11_hvm_10_vm5 && virsh destroy $domain_name

echo "start testing..."

for i in `seq 100`; do
    echo "test $i times"
    echo "define domain as $domain_name from $domain_xml"
    virsh define $domain_xml
    echo "define result..."
    virsh list --all --state-shutoff | grep $domain_name
    test_ret $?
    echo "start vm..."
    virsh start $domain_name
    wait_started
    echo "check domain status..."
    virsh list | grep sles11_hvm_10_vm5
    test_ret $?
    managed_save
    echo "start vm from managed save image..."
    virsh start $domain_name
    echo "check domain status..."
    virsh list | grep sles11_hvm_10_vm5
    test_ret $?
    managed_save
    echo "remove managed save image..."
    virsh managedsave-remove $domain_name
    test_ret $?
    echo "start vm..."
    virsh start $domain_name
    wait_started
    echo "check domain status..."
    virsh list | grep sles11_hvm_10_vm5
    test_ret $?
    managed_save
    echo "start vm with --force-boot, it will remove managed save image..."
    virsh start --force-boot $domain_name
    echo "check domain status..."
    virsh list | grep sles11_hvm_10_vm5
    test_ret $?
    echo "destroy domain $domain_name"
    virsh destroy $domain_name
    test_ret $?
    echo "start vm with --force-boot, it should be ok even if there is no managed save image..."
    virsh start --force-boot $domain_name
    wait_started
    managed_save
    echo "undefine domain if domain should not be removed if the managedsave image exist without \"--managedsave\""
    virsh undefine sles11_hvm_10_vm5 && exit 1
    virsh undefine --managed-save sles11_hvm_10_vm5
    test_ret $?
done

