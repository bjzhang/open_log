#!/bin/bash

usage(){
	echo "Usage: $0 hostname_or_ip arguments_to_install_kiwi"
	echo "Example: "
	echo "1.  setup environment, update the kiwi-description and build kiwi image"
	echo "    $0 os03 proxy_user@proxy_host_name"
	echo "Example: "
	echo "2.  build kiwi image"
	echo "    $0 os03 proxy_user@proxy_host_name -m build"
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
echo "Copy install_kiwi script to remote and run it with ssh default user with all other parameter given by user"

# DOC: be carefull the \$ and $ in the following command. $@ will replace by the
#      all the parameter at the time of ssh of host system(there is a `shift 1`
#      before the follow command). While the \$HOME will be expanded in the
#      target system. reference <https://unix.stackexchange.com/questions/134114/how-do-i-pass-a-variable-from-my-local-server-to-a-remote-server/134116#134116>
echo "arguments: $@"
scp -p ${WORK_DIR}/install_kiwi.sh $TARGET:~/; ssh -t $TARGET "./install_kiwi.sh \$HOME $@"
