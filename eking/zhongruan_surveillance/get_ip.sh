
#Try to get ip through arp with 10 seconds timeout.
#Arguments: $1 name of vm: could be name, uuid, ID any of which could be
#                          supported by virsh
VIRSH="sudo virsh"
get_ip() {
    NAME=$1
    $VIRSH list --all | grep $NAME -w 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "Error: vm($NAME) inexist. exit"
        return
    fi

    bridge=`$VIRSH dumpxml $NAME | grep source.bridge | cut -d \' -f 2`
    mac=`$VIRSH dumpxml $NAME |grep mac.address | cut -d = -f 2 | sed "s/['/>']//g"`
    for i in `seq 10`; do
        ip=`arp -a -i $bridge | grep $mac | cut -d \  -f 2 | sed "s/[()]//g"`
        if [ "$ip" != "" ]; then
            echo "Ip address is $ip"
            return
        fi
        sleep 1
        echo -n "."
    done
    echo "wait for ip address timeout"
}

if [ "$1" != "" ]; then
	get_ip $1
fi

