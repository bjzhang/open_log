
WGET="sudo wget"

download_url()
{
	url=$1
	#echo url is $url
	echo $url | grep opensuse -i
	if [ "$?" = "0" ]; then
		repo_type=opensuse
	else
		# <source path="http://mirrors.aliyun.com/centos/7/os/x86_64/"/>
		echo $repo | grep centos -i
		if [ "$?" = "0" ]; then
			repo_type=centos
		else
			echo "unknow repo type: $repo. exit"
			exit
		fi
	fi
	repo=${url%/*}
	repo=`echo $repo | sed "s/repodata//g" | sed "s/%3A/:/g"`
	repo=${repo##*//}
	repo=${repo#*/}
	if [ "${repo_type}" = "opensuse" ]; then
		repo=`echo $repo | sed "s/repositories\///g"`
		repo=`echo $repo | sed "s/\/x86_64//g"`
	elif [ "${repo_type}" = "centos" ]; then
		repo=`echo $repo | sed "s/Packages//g"`
		repo=${repo%/*}
	fi
	#    <repository type="rpm-md" alias="KIWI-NG_Appliance">
	alias=`grep $repo /home/vagrant/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS/config.xml -B 1 | head -n1`
	alias=`echo $alias | cut -d = -f 3 | sed "s/[\">]//g"`
	#echo "repo alias is $alias"
	if [ "$alias" = "" ]; then
		echo "ERROR: alias is empty. try suse open build service style link."
		repo=`echo $repo | sed "s/:\//:/g"`
		#<repository type="rpm-md" alias="KIWI-NG_Appliance">
		#<repository type="rpm-md" priority="1" alias="kiwi-common-boot">
		alias=`grep $repo /home/vagrant/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS/config.xml -B 1 | head -n1`
		alias=`echo $alias | sed "s/^.*alias=\"\(.*\)\">[\ \t]*$/\1/g"`
		if [ "$alias" = "" ]; then
			echo "ERROR: alias is empty. exit"
			echo "Current repo is $repo"
			exit 1
		fi
	fi
	REPO_PATH=/var/cache/kiwi/yum/cache/$alias
	name=${url##*//}
	name=${name##*/}
	#echo package name is $name
	echo $name | grep "\.rpm$"
	if [ "$?" = "0" ]; then
		echo -n "rpm package: "
		PACKAGE_DIR_NAME=$REPO_PATH/packages
	else
		echo -n "package metadata"
		PACKAGE_DIR_NAME=/var/cache/kiwi/yum/cache/$alias/
	fi
	if ! [ -d "$PACKAGE_DIR_NAME" ]; then
		echo "ERROR: package directory $PACKAGE_DIR_NAME does not exist. exit"
		exit 1
	fi
	echo "download to $PACKAGE_DIR_NAME/$name"
	sudo rm $PACKAGE_DIR_NAME/$name
	$WGET --directory-prefix $PACKAGE_DIR_NAME $url
}

for url in `grep HTTP.Error.502 /home/vagrant/works/software/kiwi/build/image-root.log  | sed "s/^.*HTTP.Error.502\ :\ \(.*\)$/\1/g" | sort | uniq`; do
	download_url $url
done
for url in `grep Timeout /home/vagrant/works/software/kiwi/build/image-root.log  | sed "s/^.*Timeout.on \(.*.\): (.*$/\1/g" | sort | uniq`; do
	download_url $url
done
