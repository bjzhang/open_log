
init() {
    home=$1
    SOURCE=$2
    proxy=$3
	echo "environment setup"
	if [ -f "$home/.ssh/id_rsa.pub" ]; then
		echo "ssh public key exist. skip"
	else
		echo "generate ssh key, press anykey to continue"
		ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	fi

	mkdir -p $SOURCE

	echo "ssh setup"
    if [ "$proxy" = "true" ]; then
        ssh-copy-id smb_rd@10.71.84.51

        MY_ENV="$home/.bash_profile"
        echo "export http_proxy=localhost:8228" > $MY_ENV
        echo "export https_proxy=localhost:8228" >> $MY_ENV
        echo "#export http_proxy=localhost:7228" >> $MY_ENV
        echo "#export https_proxy=localhost:7228" >> $MY_ENV
        source $MY_ENV
		ssh -fNL 8228:localhost:8228 smb_rd@10.71.84.51
		ssh -fNL 7228:localhost:7228 smb_rd@10.71.84.51
        sudo bash -c "echo 'Defaults env_keep += \"http_proxy https_proxy\"' > /etc/sudoers.d/proxy"
	fi

	OPEN_LOG_PATH="$home/works/open_log"
	if [ -d $OPEN_LOG_PATH/.git ]; then
		echo "open log already exist skip"
	else
		git clone https://github.com/bjzhang/open_log.git $OPEN_LOG_PATH
	fi

	KIWI_REPO="http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_42.3/Virtualization:Appliances:Builder.repo"
	PACKAGES="python3-kiwi>=9.11 man jq yum git command-not-found syslinux"

	ZYPPER="sudo zypper -v --non-interactive --gpg-auto-import-keys"

	$ZYPPER ar -c -f -r $KIWI_REPO
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
	echo cd $KIWI_DESCRIPTIONS_PATH; git checkout -f -b ceph_deploy origin/ceph_deploy
	cd $KIWI_DESCRIPTIONS_PATH; git checkout -f -b ceph_deploy origin/ceph_deploy

	echo "initial finish. re-login or soruce $MY_ENV to valid the environment!"
}

build(){
	APPLICANCE=$1
	TARGET=$2
	KIWI_TYPE=$3

	echo "update kiwi-descriptions"
	cd $APPLICANCE
	git fetch
	git rebase
	ret=$?
	if [ "$ret" != "0" ]; then
		echo "ERROR: git rebase fail. exit with $ret"
		exit $ret
	fi
	echo "Cleaning up the previous build"
	sudo mv ${TARGET}/build/image-root/var/lib/machines/ ${TARGET}/kiwi.machines.old-`date "+%d%m%S"`
	sudo rm -rf ${TARGET}/build/image-root/
	sudo systemctl restart lvm2-lvmetad.service

	echo "Building(comment --debug if you want to a clean output)"
	sudo kiwi-ng --debug --color-output --type $KIWI_TYPE system build --description $APPLICANCE --target-dir $TARGET
	ret=$?
	if [ "$ret" = "0" ]; then
		echo "Building Successful"
	else
		echo "Building fail with $ret"
		exit $ret
	fi
}


user=$1
if [ "$user" = "" ]; then
    echo "user empty .exit"
    exit 1
fi
home=/home/$user
SOURCE=${home}/works/source
TARGET=${home}/works/software/kiwi
APPLICANCE=${home}/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS
KIWI_TYPE="oem"

init $home $SOURCE "true"
build $APPLICANCE $TARGET $KIWI_TYPE
