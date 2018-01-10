#!/bin/bash

die()
{
	echo $1
	exit
}

deploy_user=$1
deploy_dir=$2
#dryrun="true"

if [ "$deploy_user" = "" ]; then
    deploy_user=tidb
fi

if [ "$deploy_dir" = "" ]; then
    deploy_dir=/home/$deploy_user/deploy
fi

if [ "$dryrun" = "true" ]; then
        LIMITS_CONF="etc_security_limits.conf"
else
        LIMITS_CONF="/etc/security/limits.conf"
fi

echo "Set language to English UTF8"
LANG = en_US.UTF8

echo "Checking whether disk is full or not"
cd `dirname $deploy_dir`; df -h . |tail -n1 | grep 100%
if [ "$?" = "0" ]; then
        die "Disk is full in $deploy_dir. Exit"
fi

#echo "Installing python"
##centos
#yum install python
##suse
##zypper install python

echo "Install ntp"
#centos
echo y | yum install ntp
#euse
#zypper --non-interactive install ntp

echo "Checking date(ntp)"
systemctl enable ntpd
systemctl start  ntpd
ntpstat | grep -w synchronised | wc -l
#HT=`date "+%s"`
#TARGET=root@10.1.1.100; TT=`ssh $TARGET "date '+%s'"`
#echo $((HT - TT))

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

echo "Create deploy dir"
mkdir -p $deploy_dir
chown -R $deploy_user:$deploy_user $deploy_dir
chmod 755 $deploy_dir

echo "Disable Firewall"
#Centos
systemctl disable firewalld
systemctl stop firewalld
#Opensuse
#SuSEfirewall2 off

#echo "Enable Firewall"
##Centos
#systemctl enable firewalld
#systemctl start firewalld
##Opensuse
#SuSEfirewall2 on

#echo "Configuration irqbalance"
#enable IRQBALANCE_ONESHOT to run irqbalance only once.

