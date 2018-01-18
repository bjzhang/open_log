#!/bin/bash

TARGET=$1
scp -p install_kiwi.sh $TARGET:~/; ssh -t $TARGET 'bash -x ./install_kiwi.sh'
