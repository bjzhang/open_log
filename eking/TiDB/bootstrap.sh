#!/bin/bash

die()
{
	echo $1
}

deploy_user=$1
dryrun="true"
if [ "$deploy_user" = "" ]; then
    deploy_user=etidb
fi
if [ "$dryrun" = "true" ]; then
        LIMITS_CONF="etc_security_limits.conf"
else
        LIMITS_CONF="/etc/security/limits.conf"
fi

echo "Checking whether disk is full or not"
#disk is not 100%:  `df -h . |tail -n1`

echo "Checking date(ntp)"
#check ntp

echo "Configuration system and user limitation"
sysctl -w net.core.somaxconn=32768
sysctl -w vm.swappiness=0
sysctl -w net.ipv4.tcp_syncookies=0
sysctl -w fs.file-max=1000000
echo "$deploy_user        soft        nofile        1000000" >> $LIMITS_CONF
echo "$deploy_user        hard        nofile        1000000" >> $LIMITS_CONF
echo "$deploy_user        soft        core          unlimited" >> $LIMITS_CONF
echo "$deploy_user        soft        stack         10240" >> $LIMITS_CONF

echo "Disalbe swap"
([ $(swapon -s | wc -l) -ge 1 ] && (swapoff -a && echo disable)) || echo already

echo "Add user and group"
groupadd -f $deploy_user
if [ "$?" != 0 ]; then
	die "ERROR: group add fail, exit"
fi
useradd -m $deploy_user -g $deploy_user
if [ "$?" != 0 ]; then
	die "ERROR: user add fail, exit"
	groupdel $deploy_user 
fi

echo "Disable Firewall"
#Centos
#Opensuse
SuSEfirewall2 off

#echo "Enable Firewall"
##Centos
##Opensuse
#SuSEfirewall2 on

