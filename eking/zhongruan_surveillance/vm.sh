#!/bin/bash

op=$1
name=$2
dir=`dirname $0`

echo "PLEASE migrate to vagrant. those scripts will not add new features"

if [ "$op" = "" ]; then exit; fi

if [ "$op" = "ssh" ]; then
	if [ "$name" = "" ]; then exit; fi
	USER=$3
	if [ "$USER" = "" ]; then
		USER=root
	fi
	IP=`sudo $dir/get_ip.sh $name | cut -d \  -f 4`
	echo "ssh to $USER@$IP"
	for i in `seq 10`; do
		http_proxy= https_proxy= curl -s $IP:22 | grep SSH > /dev/null
		if [ "$?" = "0" ]; then
			break
		else
			sleep 1
		fi
	done
	ssh-copy-id $USER@$IP
	ssh $USER@$IP
elif [ "$op" = "ip" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
elif [ "$op" = "ips" ]; then
        pattern=$name
	if [ "$pattern" = "" ]; then exit; fi
        vms=`sudo virsh list --name | grep $pattern`
	if [ "$vms" = "" ]; then exit; fi
        for vm in `echo $vms`; do
                IP=`sudo $dir/get_ip.sh $vm | cut -d \  -f 4`; echo $vm: $IP
                IPS+="\"$IP\", "
        done
        echo [${IPS%??}]
elif [ "$op" = "list" ]; then
	sudo virsh list --all
elif [ "$op" = "tidb_mysql" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	mysql -u root -h $IP -P 4000
elif [ "$op" = "pd" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "systemctl restart pd"
	ssh root@$IP "tail -f /home/tidb/deploy/log/pd.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/pd_stderr.log"
elif [ "$op" = "tikv" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "systemctl restart tikv-20160"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tikv.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tikv_stderr.log"
elif [ "$op" = "tidb" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "systemctl restart tidb-4000"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tidb.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tidb_stderr.log"
fi
