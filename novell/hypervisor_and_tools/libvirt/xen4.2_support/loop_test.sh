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

rclibvirtd restart
for i in `seq 10000`; do
    echo "test $i times"
    echo "test libxlDomainCreateXML: create"
    virsh create $domain_xml
    virsh list | grep $domain_name -w
    test_ret $?
    sleep 1

    echo "sleep 20 second"
    for t in `seq 20`; do date; virsh list; sleep 1;done
    virsh destroy $domain_name
    sleep 1

    echo "reboot libvirtd"
    rclibvirtd restart
    sleep 1
done

