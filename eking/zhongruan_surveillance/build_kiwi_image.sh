#!/bin/bash

ZYPPER="sudo zypper -v --non-interactive --gpg-auto-import-keys"

function abort {
        echo "Abort from $0."
}

set -e
trap abort ERR

# Variable: proxy: user@host(could provide 7228 and 8228 proxy)
create_proxy_tunnel() {
	PROXY=$1
	echo "Create proxy tunnel(input password when necessary):"
	if [ "`sudo netstat -anltp |grep 7228.*LISTEN`" = "" ]; then
		ssh -fNL 7228:localhost:7228 $PROXY
	fi
	if [ "`sudo netstat -anltp |grep 8228.*LISTEN`" = "" ]; then
		ssh -fNL 8228:localhost:8228 $PROXY
	fi
}

# Global variable: ZYPPER
init() {
	home=$1
	SOURCE=$2
	PROXY=$3

	echo "INFO: environment setup"

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
		
		if [ "`cat $MY_ENV | grep http_proxy > /dev/null; echo $?`" != "0" ]; then
			echo "#export http_proxy=localhost:8228" >> $MY_ENV
			echo "export http_proxy=localhost:7228" >> $MY_ENV
		fi
		if [ "`cat $MY_ENV | grep https_proxy > /dev/null; echo $?`" != "0" ]; then
			echo "#export https_proxy=localhost:8228" >> $MY_ENV
			echo "export https_proxy=localhost:7228" >> $MY_ENV
		fi
		source $MY_ENV
		
		create_proxy_tunnel $PROXY
		sudo bash -c "echo 'Defaults env_keep += \"http_proxy https_proxy\"' > /etc/sudoers.d/proxy"
	fi

	OPEN_LOG_PATH="$home/works/open_log"
	if [ -d $OPEN_LOG_PATH/.git ]; then
		echo "open log already exist skip"
	else
		git clone https://github.com/bjzhang/open_log.git $OPEN_LOG_PATH
	fi

	KIWI_REPO="http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_42.3/Virtualization:Appliances:Builder.repo"
	PACKAGES="python3-kiwi>=9.11 man jq yum git command-not-found syslinux jing createrepo lsof xfsprogs"

	if [ "`$ZYPPER lr | grep Appliance.Builder > /dev/null; echo $?`" != "0" ]; then
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
	KIWI_DESCRIPTIONS="https://github.com/SUSE/kiwi-descriptions.git"
	KIWI_DESCRIPTIONS_PATH=$SOURCE/${KIWI_DESCRIPTIONS##*/}
	#echo $KIWI_DESCRIPTIONS_PATH
	KIWI_DESCRIPTIONS_PATH=${KIWI_DESCRIPTIONS_PATH%.git}
	#echo $KIWI_DESCRIPTIONS_PATH
	cd $KIWI_DESCRIPTIONS_PATH
	if [ -d "$KIWI_DESCRIPTIONS_PATH/.git" ]; then
		echo "kiwi descriptions exist. skip"
	else
		git clone $KIWI_DESCRIPTIONS $KIWI_DESCRIPTIONS_PATH
	fi
	KIWI_DESCRIPTIONS="https://github.com/journeymidnight/kiwi-descriptions.git"
	GIT_URL_BASE=${KIWI_DESCRIPTIONS%\/*.git}
	ACCOUNT=${GIT_URL_BASE##*\/}
	#FIXME: I do not checkout the actually git remote url.
	remote=`git remote | grep $ACCOUNT || true`
	echo "remote is $remote"
	if [ "$remote" = "" ]; then
		git remote add $ACCOUNT $KIWI_DESCRIPTIONS
	fi
	git fetch $ACCOUNT
	#echo cd $KIWI_DESCRIPTIONS_PATH; git checkout -f -b ceph_deploy journeymidnight/ceph_deploy
	# DOC: set -e will not catch the error in some like test state, e.g. if statement, && and so on.
	if [ "`git branch | grep ceph_deploy`" = "" ]; then
		git checkout -f -b ceph_deploy $ACCOUNT/ceph_deploy
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

	echo "INFO: update kiwi-descriptions"
	if ! [ -d $APPLIANCE ]; then
		echo "ERROR: appliance($APPLIANCE) is inexist. exit"
		exit 128
	fi
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

	echo "INFO: checkout to specific commit of kiwi-description"
	if ! [ -d $APPLIANCE ]; then
		echo "ERROR: appliance($APPLIANCE) is inexist. exit"
		exit 128
	fi
	cd $APPLIANCE
	git fetch journeymidnight
	if [ "$COMMIT" != "" ]; then
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
	echo "INFO: update system installed packages"
	$ZYPPER update
}

precheck(){
	echo "INFO: precheck build environment"
	echo "Check if the version of kernel and modules is consistent"
	# To avoid the "losetup: cannot find an unused loop device"
	MODULES=`ls /lib/modules/* -d`
	if ! [ -d /lib/modules/"$(uname -r)" ]; then
		echo "INFO: current kernel version is `uname -r` while modules verion(s) are $MODULES, check bootloader(grub2) config"
		for version in `echo $MODULES`; do
			echo "DEBUG: looking for `basename ${version}`"
			if ! [ -z "$(sudo grep `basename ${version}` /boot/grub2/grub.cfg 2>/dev/null)" ]; then
				echo "DEBUG: found corresponding kernel in grub.cfg"
				KERNEL_VER=`basename ${version}`
				found=true
			fi
		done
		if [ "$found" = "true" ]; then
			ENTRIES=$(sudo grep "\(\<menuentry\>.*{\)\|\(linux.*vmlinu.*${KERNEL_VER}\)" /boot/grub2/grub.cfg | grep "linux.*\/vmlinu.*${KERNEL_VER}" -B 1 | grep -v "linux.*vmlinu.*${KERNEL_VER}" | sed "s/[\ \t][\ \t]*/ /g" | cut -d \' -f 2)
			echo "INFO: possible entry(s) you could use:"
			echo "$ENTRIES"
		else
			echo "ERROR: not found the kernel in current grub2 config. exit"
			exit 3
		fi
	else
		echo "DEBUG: kernel and modules are consistent: `uname -r`"
	fi

	echo "INFO: check if need to reboot or restart services after installation"
	SERVICES=$(sudo zypper ps --print "systemctl status %s")
	if ! [ -z $SERVICES ]; then
		echo "INFO: some process use deleted files: run 'zypper ps -s' to show the relatives process"
		echo "INFO: you could reboot or restart the following services at least"
		echo "$SERVICES"
		exit 4
	fi
}

build(){
	APPLIANCE=$1
	TARGET=$2
	KIWI_TYPE=$3
	PROXY=$4
	# Makefile shift the number of above arguments!
	shift 4

	echo "INFO: build kiwi image"
	create_proxy_tunnel $PROXY

	if ! [ -d $APPLIANCE ]; then
		echo "ERROR: appliance($APPLIANCE) is inexist. exit"
		exit 128
	fi
	if [ -f $APPLIANCE/prepare.sh ]; then
		echo "run extra prepare script <$APPLIANCE/prepare.sh> with arguments $@"
		cd $APPLIANCE
		sudo ./prepare.sh $@
	else
		echo "INFO: there is no extra prepare script. run build immediately"
		exit
	fi

	echo "Cleaning up the previous build"
	if [ -d ${TARGET}/build/image-root/var/lib/machines/ ]; then
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

echo "mode: $mode"
echo "appliance: $APPLIANCE"
echo "proxy: $PROXY"
echo "kiwi description commit: $COMMIT"
echo "remains arguments(will be used if extra prepare exist): $@"

if [ "$mode" = "" ]; then
	mode=all
fi
if [ "$mode" = "all" ] || [ "$mode" = "init" ]; then
       init $home $SOURCE $PROXY
fi
if [ "$mode" = "rebase" ]; then
	rebase $APPLIANCE $TARGET $KIWI_TYPE
fi
if [ "$mode" = "all" ] || [ "$mode" = "update_and_build" ] || [ "$mode" = "checkout" ]; then
	checkout $APPLIANCE $COMMIT
fi
if [ "$mode" = "all" ] || [ "$mode" = "update_and_build" ] || [ "$mode" = "update" ]; then
	update
fi
if [ "$mode" = "all" ] || [ "$mode" = "update_and_build" ] || [ "$mode" = "precheck" ]; then
	precheck
fi
if [ "$mode" = "all" ] || [ "$mode" = "update_and_build" ] || [ "$mode" = "build" ]; then
	build $APPLIANCE $TARGET $KIWI_TYPE $PROXY $@
fi

