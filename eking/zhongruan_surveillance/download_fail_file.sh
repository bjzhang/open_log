
WGET="sudo wget"

download_url()
{
	url=$1
	#echo url is $url
	repo=${url%/*}
	repo=`echo $repo | sed "s/repodata//g" | sed "s/%3A/:/g"`
	repo=${repo##*//}
	repo=${repo#*/}
	echo $repo | grep opensuse -i
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
		echo "ERROR: alias is empty. exit"
		echo "Current repo is $repo"
		exit 1
	fi
	REPO_PATH=/var/cache/kiwi/yum/cache/$alias
	name=${url##*//}
	name=${name##*/}
	#echo package name is $name
	echo $name | grep "\.rpm$"
	if [ "$?" = "0" ]; then
		echo "rpm package. download to $REPO_PATH/packages"
		PACKAGE_FULL_NAME=$REPO_PATH/packages/$name
		sudo rm $PACKAGE_FULL_NAME
		$WGET --directory-prefix `dirname $PACKAGE_FULL_NAME` $url
	else
		sudo rm /var/cache/kiwi/yum/cache/$alias/$name
		$WGET --directory-prefix $REPO_PATH $url
	fi
}

for url in `grep HTTP.Error.502 /home/vagrant/works/software/kiwi/build/image-root.log  | sed "s/^.*HTTP.Error.502\ :\ \(.*\)$/\1/g" | sort | uniq`; do
	download_url $url
done
for url in `grep Timeout /home/vagrant/works/software/kiwi/build/image-root.log  | sed "s/^.*Timeout.on \(.*.\): (.*$/\1/g" | sort | uniq`; do
	download_url $url
done
