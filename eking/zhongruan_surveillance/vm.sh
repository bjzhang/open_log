#!/bin/bash

op=$1
name=$2
dir=`dirname $0`

if [ "$op" = "" ]; then exit; fi

if [ "$op" = "ssh" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP; ssh-copy-id root@$IP
	ssh root@$IP
elif [ "$op" = "ip" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
elif [ "$op" = "list" ]; then
	sudo virsh list --all
elif [ "$op" = "tidb_mysql" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	mysql -u root -h $IP -P 4000
elif [ "$op" = "pd" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "bash -x /home/tidb/deploy/scripts/run_pd.sh"
	ssh root@$IP "tail -f /home/tidb/deploy/log/pd.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/pd_stderr.log"
elif [ "$op" = "tikv" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "bash -x /home/tidb/deploy/scripts/run_tikv.sh"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tikv.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tikv_stderr.log"
elif [ "$op" = "tidb" ]; then
	if [ "$name" = "" ]; then exit; fi
	IP=`sudo bash $dir/get_ip.sh $name | cut -d \  -f 4`; echo $IP
	ssh -f root@$IP "bash -x /home/tidb/deploy/scripts/run_tidb.sh"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tidb.log"
	ssh root@$IP "tail -f /home/tidb/deploy/log/tidb_stderr.log"
fi
