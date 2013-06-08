#!/bin/bash

usage()
{
    echo "$0 -t timeout_second domain_xml"
}

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
    timeout_sec=$1

    domain_id=`virsh list | grep $domain_name | cut -d \  -f 2`
    echo domain id is $domain_id 
    echo "waiting domain started"
    last_cpu_time=`virsh dominfo $domain_name | grep "CPU time" | cut -d : -f 2 | sed s/^\ *//`
    sleep 2
    echo -n "cpu time is "
    while true; do
        cpu_time=`virsh dominfo $domain_name | grep "CPU time" | cut -d : -f 2 | sed s/^\ *//`
        echo -n "$cpu_time, "
        if [ "$cpu_time" == "$last_cpu_time" ]; then
            echo cpu time is $cpu_time. $domain_name fully started. 
            break 
        fi
        if [ `echo $cpu_time | sed "s/\.[0-9]*s//"` -gt $timeout_sec ]; then
            echo "wait started timeout: $timeout_sec".
            break
        fi
        last_cpu_time=$cpu_time
        sleep 3
    done
}

reboot_or_shutdown()
{
    action=$1

    domain_id=`virsh list | grep $domain_name | cut -d \  -f 2`
    wait_started $timeout
    echo "$action $domain_name"
    virsh $action $domain_name
    echo -n "wait for $domain_name $domain_id ${action}ing"
    while true; do 
        virsh list | grep $domain_name | grep "^\ *$domain_id" 2>&1 > /dev/null || break
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

while getopts 'ht:' opt; do
    case $opt in
        t)
            timeout=$OPTARG
            ;;
        h)
            usage
            exit 1
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

if [ -z $1 ]; then
    echo "Error: demain xml missing, exit". 
    exit 1
fi

if [ -z $timeout ]; then
    timeout=20
    echo "timeout is empty, using $timeout as default"
fi

domain_xml=$1
domain_name=`cat $domain_xml | grep "<name>" | sed "s/<name>\(.*\)<\/name>/\1/" | sed "s/^\ *//"`
echo "domain_xml is $domain_xml; domain_name is $domain_name"

for i in `seq 100`; do
    date
    echo "test $i times"
    echo "test libxlDomainCreateXML: create"
    virsh create $domain_xml
    virsh list | grep $domain_name -w
    test_ret $?
    wait_started $timeout
    sleep 5

    echo "test libxlDoDomainSave: save"
    virsh save $domain_name ${domain_name}.save
    test_ret $?
    sleep 5

    echo "test libxlDomainRestoreFlags: restore"
    virsh restore ${domain_name}.save 
    test_ret $?
    sleep 5

    echo "test libxlDomainSuspend: suspend"
    virsh suspend $domain_name
    virsh list | grep $domain_name -w | grep paused -w
    test_ret $?
    sleep 5

    echo "test libxlDomainResume: resume"
    virsh resume $domain_name
    virsh list | grep $domain_name -w | grep running -w
    test_ret $?
    sleep 5

    echo "test libxlShutdownFlags: shutdown"
    reboot_or_shutdown shutdown
    sleep 5
    virsh create $domain_xml
    sleep 5
    wait_started $timeout

    echo "test libxlDoDomainSave: save"
    virsh save $domain_name ${domain_name}.save
    test_ret $?
    sleep 5

    echo "test libxlDomainRestoreFlags: restore"
    virsh restore ${domain_name}.save 
    test_ret $?
    sleep 5

    echo "test libxlShutdownFlags: shutdown"
    reboot_or_shutdown shutdown
    sleep 5
    virsh create $domain_xml
    sleep 5
    wait_started $timeout

    echo "test libxlDoDomainSave: save"
    virsh save $domain_name ${domain_name}.save
    test_ret $?
    sleep 5

    echo "test libxlDomainRestoreFlags: restore"
    virsh restore ${domain_name}.save 
    test_ret $?
    sleep 5

    echo "test libxlDomainCoreDump: dump"
    virsh dump $domain_name ${domain_name}.dump
    test_ret $?
    sleep 5

    echo "end test"
    echo "test libxlShutdownFlags: shutdown"
    reboot_or_shutdown shutdown
    sleep 5
done

