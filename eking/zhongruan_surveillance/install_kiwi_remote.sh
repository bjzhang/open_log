#!/bin/bash

TARGET=$1
shift 1
echo "Copy install_kiwi script to remote and run it with ssh default user with all other parameter given by user"
# DOC: be carefull the \$ and $ in the following command. $@ will replace by the
#      all the parameter at the time of ssh of host system(there is a `shift 1`
#      before the follow command). While the \$HOME will be expanded in the
#      target system. reference <https://unix.stackexchange.com/questions/134114/how-do-i-pass-a-variable-from-my-local-server-to-a-remote-server/134116#134116>
scp -p install_kiwi.sh $TARGET:~/; ssh -t $TARGET "bash -x ./install_kiwi.sh \$HOME $@"
