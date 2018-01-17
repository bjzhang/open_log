
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
