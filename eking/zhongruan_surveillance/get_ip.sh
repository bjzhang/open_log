#!/bin/bash

#Try to get ip through arp with 10 seconds timeout.
#Arguments: $1 name of vm: could be name, uuid, ID any of which could be
#                          supported by virsh
#DEBUG=yes

VIRSH="sudo virsh"
DEBUG() {
    if [ "$DEBUG" = "yes" ]; then
        echo $@
    fi
}

get_ip() {
    NAME=$1
    $VIRSH list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "Error: vm($NAME) inexist. exit"
        return
    fi

    bridges=`$VIRSH dumpxml $NAME | grep source.bridge | cut -d \' -f 2`
    DEBUG $bridges
    for bridge in `echo $bridges`; do
        mac=`$VIRSH dumpxml $NAME | grep source.bridge.*$bridge -B 1 | head -n1 |  grep mac.address | cut -d = -f 2 | sed "s/['/>']//g"`
        DEBUG $mac
        for i in `seq 10`; do
            ip=`arp -a -i $bridge | grep $mac | cut -d \  -f 2 | sed "s/[()]//g"`
            if [ "$ip" != "" ]; then
                echo "Ip address is $ip"
                return
            fi
            sleep 1
            echo -n "."
        done
    done
    echo "wait for ip address timeout"
}

if [ "$1" != "" ]; then
	get_ip $1
fi

