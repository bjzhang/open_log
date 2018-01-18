
for url in `grep Timeout /home/vagrant/works/software/kiwi/build/image-root.log  | sed "s/^.*Timeout.on \(.*.\): (.*$/\1/g" | sort | uniq`; do
	echo url is $url
	repo=${url%/*}
	repo=`echo $repo | sed "s/repodata//g" | sed "s/%3A/:/g"`
	repo=${repo##*//}
	repo=${repo#*/}
	repo=`echo $repo | sed "s/repositories\///g"`
	repo=`echo $repo | sed "s/\/x86_64//g"`
	#    <repository type="rpm-md" alias="KIWI-NG_Appliance">
        grep mirrors.aliyun.com /home/vagrant/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS/config.xml
        is_source_aliyun=$?
        if [[ $is_source_aliyun ]] ; then
		alias='centos'
        else
		alias=`grep $repo /home/vagrant/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS/config.xml -B 1 | head -n1`
		alias=`echo $alias | cut -d = -f 3 | sed "s/[\">]//g"`
		echo "repo alias is $alias"
		if [ "$alias" = "" ]; then
			echo "ERROR: alias is empty. exit"
			exit 1
		fi
	fi
	REPO_PATH=/var/cache/kiwi/yum/cache/$alias
	name=${url##*//}
	name=${name##*/}
	echo package name is $name
	echo $name | grep "\.rpm$"
	if [ "$?" = "0" ]; then
		echo "rpm package. download to $REPO_PATH/packages"
		PACKAGE_FULL_NAME=$REPO_PATH/packages/$name
		sudo rm $PACKAGE_FULL_NAME
		sudo wget --directory-prefix `dirname $PACKAGE_FULL_NAME` $url
	else
		sudo rm /var/cache/kiwi/yum/cache/$alias/$name
		sudo wget --directory-prefix $REPO_PATH $url
	fi
done
