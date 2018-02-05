#!/bin/bash

usage(){
	echo "Usage: $0 hostname_or_ip arguments_to_build_kiwi_image"
	echo "Example: "
	echo "1.  setup environment, update the kiwi-description and build kiwi image"
	echo "    $0 os01 --appliance centos/x86_64/ceph-applicance --proxy smb_rd@10.71.84.48"
	echo "2.  udpate installed rpm packages"
	echo "    $0 os01 --appliance centos/x86_64/ceph-applicance --proxy smb_rd@10.71.84.48 -m update"
	echo "3.  build kiwi image"
	echo "    $0 os01 --appliance centos/x86_64/ceph-applicance -m build"
	echo "4.  build kiwi image with extra token for extra prepare"
	echo "    $0 os01 --appliance centos/x86_64/ceph-applicance -m build ${your_github_token}"
	echo "5.  build kiwi image checkout to specific commits of kiwi_description, with extra token for extra prepare"
	echo "    $0 os01 --appliance centos/x86_64/ceph-applicance --proxy smb_rd@10.71.84.48 -m build -c f267a610 ${your_github_token}"
}

WORK_DIR=`realpath $0`
WORK_DIR=`dirname ${WORK_DIR}`
echo $WORK_DIR
TARGET=$1
shift 1

if [ "$TARGET" = "" ]; then
	echo "Target host is empty. exit"
	usage
	exit 128
fi

ping -c 2 $TARGET
if [ "$?" != "0" ]; then
	echo "ERROR: invalid $TARGET. exit"
	exit 1
fi
echo "Copy build_kiwi_image script to remote and run it with ssh default user with all other parameter given by user"

# DOC: be carefull the \$ and $ in the following command. $@ will replace by the
#      all the parameter at the time of ssh of host system(there is a `shift 1`
#      before the follow command). While the \$HOME will be expanded in the
#      target system. reference <https://unix.stackexchange.com/questions/134114/how-do-i-pass-a-variable-from-my-local-server-to-a-remote-server/134116#134116>
echo "arguments: $@"
scp -p ${WORK_DIR}/build_kiwi_image.sh $TARGET:~/; ssh -t $TARGET "./build_kiwi_image.sh \$HOME $@"
