#!/bin/bash

SNAPSHOT_PATH=/var/lib/xen/snapshots/

test_ret()
{
    if [ $1 -ne 0 ]; then
        echo "###Error: fail, exit"
        exit 1
    else
        echo "###successful"
    fi
}

test_ret_noexit()
{
    if [ $1 -ne 0 ]; then
        echo "###Error: fail"
    else
        echo "###successful"
    fi
}


domain_name=$1

#echo "should not include disk snapshot for such domain disk(qemu-img snapshot -l is empty)"
#echo delete all the file in $SNAPSHOT_PATH
#rm $SNAPSHOT_PATH* -rf

echo continue only if domain $domain_name exists
xl list | grep $domain_name
test_ret $?

#get basic domain parameters
uuid=`xl list -v $domain_name | grep $domain_name | awk '{print $7}'`

echo ###snapshot create test###1###parameter input test
echo wrong paramenter test. it should be fail
xl snapshot-create
test_ret_noexit $?

echo ###snapshot create test###2###
echo "create snapshot with default name(epoch second)"
possible_name=`date "+%s"`
xl snapshot-create $domain_name
ls $SNAPSHOT_PATH/$uuid | grep $possible_name
snapshot_name=$possible_name
if [ $? != "0" ]; then
    possible_name=`grep echo $(($possible_name + 1))`
    ls $SNAPSHOT_PATH/$uuid | grep $possible_name
    test_ret $?
fi
#TODO qemu-img command
echo successful

testname="testname`date "+%S"`"
xl snapshot-create -n $testname $domain_name
ls $SNAPSHOT_PATH/$uuid | grep $testname
test_ret $?
#TODO qemu-img command
echo successful

