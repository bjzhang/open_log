
HOST=$1
shift 1
if [ "$HOST" = "" ]; then
	echo "target host is empty. exit"
	exit 1
fi
# User could pass the "--start-at-task=update" outside this script to run ansible kiwi.yml from update task
# ansible-playbook kiwi.yml --start-at-task=update
ansible-playbook -i $HOST, --limit $HOST kiwi.yml $@
