#!/bin/bash

TARGET=$1
scp -p install_kiwi.sh $TARGET:~/; ssh -t $TARGET 'screen bash -x ./install_kiwi.sh `whoami`'
