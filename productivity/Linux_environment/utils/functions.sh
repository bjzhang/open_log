
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

