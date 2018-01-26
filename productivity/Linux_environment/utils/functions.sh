
ENABLE_DEBUG=true

DEBUG(){
    if [ "${ENABLE_DEBUG}" = "true" ]; then
        echo $@
    fi
}

sshretry () {
    ping -c 4 $1
    if [ "$?" != "0" ]; then
        echo "Destination($1) is not reachable, exit"
        exit
    fi
    while true; do
        ssh $1 || sleep 1
        break
    done
}

test_script(){
    if [ "$0" = "bash" ] || [ "$0" = "-bash" ]; then
        DEBUG "It is in the main shell, not in a shell script."
        echo false
    else
        DEBUG "It is in a shell script."
        echo true
    fi
}

# smart means exit function in shell script but return from function call in
# main shell. ONLY support bash at the monment.
# Parameter:
# $1: exit code. exit with 1 if missing.
smart_exit(){
    OLD_ENABLE_DEBUG=$ENABLE_DEBUG
    ENABLE_DEBUG=false
    ret=`test_script`
    ENABLE_DEBUG=$OLD_ENABLE_DEBUG
    exit_ret=$1
    if [ "${exit_ret}" = "" ]; then
        exit_ret=1
    fi
    if [ "$ret" = "true" ]; then
        DEBUG "exit from script shell"
        exit ${exit_ret}
    else
        DEBUG "return from function"
        echo ${exit_ret}
        return
    fi
}

realpath_safe() {
    path=`realpath --canonicalize-existing --quiet $1`
    ret=$?
    if [ "$ret" != "0" ]; then
        echo "ERROR: invalid path $1. exit with $ret"
        ENABLE_DEBUG=false
        ret=`smart_exit $ret`
        $?=$ret
        return
    fi
    echo $path
}

