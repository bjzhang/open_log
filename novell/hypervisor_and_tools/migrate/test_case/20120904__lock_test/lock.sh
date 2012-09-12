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

reboot_or_shutdown()
{
    action=$1

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

if [ -z $1 ]; then
    echo "Error: demain xml missing, exit". 
    exit 1
fi

domain_xml=$1
domain_name=`cat $domain_xml | grep "<name>" | sed "s/<name>\(.*\)<\/name>/\1/" | sed "s/^\ *//"`
echo "domain_xml is $domain_xml; domain_name is $domain_name"

echo "test libxlDomainCreateWithFlags: start"
virsh define $domain_xml
virsh start $domain_name
virsh list | grep $domain_name -w 
test_ret $1

virsh destroy $domain_name
sleep 1

echo "test libxlDomainCreateXML: create"
virsh create /etc/xen/vm/sles11_hvm_10.xml
virsh list | grep $domain_name -w
test_ret $1
sleep 1

echo "test libxlDomainSuspend: suspend"
virsh suspend $domain_name
virsh list | grep $domain_name -w | grep paused -w
test_ret $1
sleep 1

echo "test libxlDomainResume: resume"
virsh resume $domain_name
virsh list | grep $domain_name -w | grep running -w
test_ret $1
sleep 1

echo "test libxlDomainReboot: reboot"
reboot_or_shutdown reboot

echo "test libxlShutdownFlags: shutdown"
reboot_or_shutdown shutdown
irsh create $domain_xml
leep 1

echo "test libxlDoDomainSave: save"
virsh save $domain_name ${domain_name}.save
test_ret $?

echo "test libxlDomainRestoreFlags: restore"
virsh restore ${domain_name}.save 
test_ret $?

echo "test libxlDomainCoreDump: dump"
virsh dump $domain_name ${domain_name}.dump
test_ret $?

echo "test libxlDomainDestroyFlags: destroy"
virsh destroy $domain_name
test_ret $?
virsh create $domain_xml
sleep 1

echo "test libxlDomainSetMemoryFlags: setmem"
echo "set memory to 256M"
virsh setmem $domain_name 262144 --live
test_ret $?
virsh dominfo $domain_name | grep memory
echo "set memory to 512M"
virsh setmem $domain_name 524288 --live
test_ret $?
virsh dominfo $domain_name | grep memory 

echo "test libxlDomainSetVcpusFlags: setvpus"
echo "set virtual cpu to 2"
virsh setvcpus $domain_name 2 --live
test_ret $?
virsh vcpucount $domain_name
echo "set virtual cpu to 4"
virsh setvcpus $domain_name 4 --live
test_ret $?
virsh vcpucount $domain_name

echo "test libxlDomainModifyDeviceFlags: detach-device, detach-disk, detach-interface, detach-device, detach-disk, detach-interface, update-device, domif-setlink, change-media"

