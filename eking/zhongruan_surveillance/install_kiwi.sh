#!/bin/bash

ZYPPER="sudo zypper -v --non-interactive --gpg-auto-import-keys"

function abort {
        echo "Abort."
}

set -e
trap abort ERR

# Global variable: ZYPPER
init() {
	home=$1
	SOURCE=$2
	PROXY=$3
	echo "environment setup"
	if [ -f "$home/.ssh/id_rsa.pub" ]; then
		echo "ssh public key exist. skip"
	else
		echo "generate ssh key, press anykey to continue"
		ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	fi

	mkdir -p $SOURCE

	echo "ssh setup"
	if [ "$PROXY" != "" ]; then
		ssh-copy-id $PROXY
		MY_ENV=~/.bash_profile
		if ! [ -f "$MY_ENV" ]; then
			touch $MY_ENV
		fi
		cat $MY_ENV | grep http_proxy > /dev/null
		if [ "$?" != "0" ]; then
			echo "#export http_proxy=localhost:8228" >> $MY_ENV
			echo "export http_proxy=localhost:7228" >> $MY_ENV
		fi
		cat $MY_ENV | grep https_proxy > /dev/null
		if [ "$?" != "0" ]; then
			echo "#export https_proxy=localhost:8228" >> $MY_ENV
			echo "export https_proxy=localhost:7228" >> $MY_ENV
		fi
		source $MY_ENV
		
		if [ "`sudo netstat -anltp |grep 7228.*LISTEN`" = "" ]; then
			ssh -fNL 7228:localhost:7228 $PROXY
		fi
		if [ "`sudo netstat -anltp |grep 8228.*LISTEN`" = "" ]; then
			ssh -fNL 8228:localhost:8228 $PROXY
		fi
		sudo bash -c "echo 'Defaults env_keep += \"http_proxy https_proxy\"' > /etc/sudoers.d/proxy"
	fi

	OPEN_LOG_PATH="$home/works/open_log"
	if [ -d $OPEN_LOG_PATH/.git ]; then
		echo "open log already exist skip"
	else
		git clone https://github.com/bjzhang/open_log.git $OPEN_LOG_PATH
	fi

	KIWI_REPO="http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_42.3/Virtualization:Appliances:Builder.repo"
	PACKAGES="python3-kiwi>=9.11 man jq yum git command-not-found syslinux jing"

	$ZYPPER lr | grep Appliance.Builder > /dev/null
	if [ "$?" = "" ]; then
		$ZYPPER addrepo -c -f -r $KIWI_REPO
	fi
	$ZYPPER install $PACKAGES
	ret=$?
	if [ "$ret" != "0" ]; then
		echo "ERROR: zypper installation fail. exit"
		if [ "$ret" = "104" ]; then
			echo "ERROR: one of packages($PACKAGES) is not found"
		fi
		exit
	fi
	echo "clone kiwi-descriptions"
	KIWI_DESCRIPTIONS="https://github.com/journeymidnight/kiwi-descriptions.git"
	KIWI_DESCRIPTIONS_PATH=$SOURCE/${KIWI_DESCRIPTIONS##*/}
	echo $KIWI_DESCRIPTIONS_PATH
	KIWI_DESCRIPTIONS_PATH=${KIWI_DESCRIPTIONS_PATH%.git}
	echo $KIWI_DESCRIPTIONS_PATH
	if [ -d "$KIWI_DESCRIPTIONS_PATH/.git" ]; then
		echo "kiwi descriptions exist. skip"
	else
		git clone $KIWI_DESCRIPTIONS $KIWI_DESCRIPTIONS_PATH
	fi
	#echo cd $KIWI_DESCRIPTIONS_PATH; git checkout -f -b ceph_deploy journalmidnight/ceph_deploy
	cd $KIWI_DESCRIPTIONS_PATH
	
	# DOC: set -e will not catch the error in some like test state, e.g. if statement, && and so on.
	if [ "`git branch | grep ceph_deploy`" = "" ]; then
		git checkout -f -b ceph_deploy journalmidnight/ceph_deploy
	else
		echo "ceph_deploy branch exits. checkout without create it"
		git checkout -f ceph_deploy
	fi

	echo "initial finish. re-login or soruce $MY_ENV to valid the environment!"
}

rebase(){
	APPLIANCE=$1
	TARGET=$2
	KIWI_TYPE=$3

	echo "update kiwi-descriptions"
	cd $APPLIANCE
	git fetch
	git rebase
	ret=$?
	if [ "$ret" != "0" ]; then
		echo "ERROR: git rebase fail. exit with $ret"
		exit $ret
	fi
}

rebase(){
	APPLIANCE=$1
	TARGET=$2
	KIWI_TYPE=$3

	echo "update kiwi-descriptions"
	cd $APPLIANCE
	git fetch
	git rebase
	ret=$?
	if [ "$ret" != "0" ]; then
		echo "ERROR: git rebase fail. exit with $ret"
		exit $ret
	fi
}

checkout(){
	APPLIANCE=$1
	COMMIT=$2

	git fetch journalmidnight
	if [ "$COMMIT" != "" ]; then
		cd $APPLIANCE
		if [ -z "$(git status --untracked-files=no --porcelain)" ]; then 
			echo "Working directory clean excluding untracked files"
			git checkout -f $COMMIT
		else 
			echo "Uncommitted changes in tracked files, exit"
			exit 128
		fi
	fi
}

# Global variable: ZYPPER
update() {
	$ZYPPER update
}

build(){
	APPLIANCE=$1
	TARGET=$2
	KIWI_TYPE=$3

	echo "Cleaning up the previous build"
	if [ -d ${TARGET}/build/image-root/var/lib/machines/ ]; then
		echo mv
		sudo mv -f ${TARGET}/build/image-root/var/lib/machines/ ${TARGET}/kiwi.machines.old-`date "+%d%m%S"`
	fi
	if [ -d ${TARGET} ]; then
		# Force rm successful. It is known bug when build centos 7 in opensuse host.
		# Some directory(e.g. /lib/machiens) could be not deleted.
		sudo rm -rf ${TARGET} 2&>/dev/null | true
	fi
	sudo systemctl restart lvm2-lvmetad.service

	echo "Building(comment --debug if you want to a clean output)"
	sudo kiwi-ng --debug --color-output --type $KIWI_TYPE system build --description $APPLIANCE --target-dir $TARGET
	ret=$?
	if [ "$ret" = "0" ]; then
		echo "Building Successful"
	else
		echo "Building fail with $ret"
		exit $ret
	fi
}

# ref: <https://gist.github.com/cosimo/3760587#file-parse-options-sh-L8>
OPTS=`getopt -o c:m: --long appliance:,commit:,help,mode:,proxy: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#DEBUG "$OPTS"
eval set -- "$OPTS"

APPLIANCE=""
COMMIT=""
DISK=""
HELP=false
while true; do
	case "$1" in
		--appliance )
			APPLIANCE=$2
			shift 2
			;;
		-c | --commit )
			COMMIT=$2
			shift 2
			;;
		-h | --help )
			HELP=true
			shift
			;;
		-m | --mode )
			mode=$2
			shift 2
			;;
		--proxy )
			PROXY=$2
			shift 2
			;;
		-- )
			shift
			break
			;;
		* )
			break
			;;
	esac
done

if [ "$APPLIANCE" = "" ]; then
	echo "ERROR: applicance($APPLIANCE) is empty. exit"
	exit 128
fi

home=$1
shift 1
if [ "$home" = "" ]; then
	echo "ERROR: home empty .exit"
	# DOC: Return 128 means invalid arguments.
	#      Reference: <http://tldp.org/LDP/abs/html/exitcodes.html#EXITCODESREF>
	exit 128
fi
if ! [ -d "$home" ]; then
	echo "ERROR: home directroy $home does not exist. exit"
	exit 128
fi
if [ "$PROXY" = "" ]; then
	echo "WARNING: PROXY empty. press anykey to continue."
	read
fi
SOURCE=${home}/works/source
TARGET=${home}/works/software/kiwi
KIWI_TYPE="oem"

APPLIANCE_ROOT=${home}/works/source/kiwi-descriptions
APPLIANCE=${APPLIANCE_ROOT}/${APPLIANCE}
if ! [ -d $APPLIANCE ]; then
	echo "ERROR: appliance($APPLIANCE) is inexist. exit"
	exit 128
fi

echo "mode: $mode"
echo "appliance: $APPLIANCE"
echo "proxy: $PROXY"
echo "kiwi description commit: $COMMIT"
echo "remains arguments(will be used if extra prepare exist): $@"

if [ "$mode" = "all" ] || [ "$mode" = "" ]; then
	echo all
	init $home $SOURCE $PROXY
	checkout $APPLIANCE $COMMIT
	update
	build $APPLIANCE $TARGET $KIWI_TYPE
fi

if [ "$mode" = "init" ]; then
	echo $mode
	init $home $SOURCE $PROXY
	exit
fi
if [ "$mode" = "rebase" ]; then
	echo $mode
	rebase $APPLIANCE $TARGET $KIWI_TYPE
	exit
fi
if [ "$mode" = "checkout" ]; then
	echo $mode
	checkout $APPLIANCE $TARGET $KIWI_TYPE
	exit
fi
if [ "$mode" = "update" ]; then
	echo $mode
	update
	exit
fi
if [ "$mode" = "build" ]; then
	echo $mode
	if [ -f $APPLIANCE/prepare.sh ]; then
		echo "run extra prepare script <$APPLIANCE/prepare.sh> with arguments $@"
		cd $APPLIANCE
		sudo bash ./prepare.sh $@
	else
		echo "INFO: there is no extra prepare script. run build immediately"
	fi
	build $APPLIANCE $TARGET $KIWI_TYPE
	exit
fi

