#!/bin/bash

set -e

usage(){
    echo "Usage: ./run_ansible.sh git.yml dm58"
}

YML=$1
if [ "$YML" = "" ]; then
    echo "Error: yml fail mising"
    exit
fi
YML=`realpath --canonicalize-existing --quiet $YML`
dir=`dirname $YML`
HOST=$2
if [ "$HOST" = "" ]; then
    echo "Error: target host(hostname of ip listed in $dir) fail mising"
    exit
fi

cd $dir
ansible-playbook --limit $HOST $YML
