
name=`grep "^NAME" /etc/os-release | cut -d "=" -f 2  | sed "s/\"//g"`
#bamvor@linux-qfgj:/etc> cat os-release
#NAME="openSUSE Leap"
#VERSION="42.2"
#ID=opensuse
#ID_LIKE="suse"
#VERSION_ID="42.2"
#PRETTY_NAME="openSUSE Leap 42.2"
#ANSI_COLOR="0;32"
#CPE_NAME="cpe:/o:opensuse:leap:42.2"
#BUG_REPORT_URL="https://bugs.opensuse.org"
#HOME_URL="https://www.opensuse.org/"

#[bamvor@VM_137_212_redhat ~]$ cat /etc/os-release
#NAME="CentOS Linux"
#VERSION="7 (Core)"
#ID="centos"
#ID_LIKE="rhel fedora"
#VERSION_ID="7"
#PRETTY_NAME="CentOS Linux 8 (Core)"
#ANSI_COLOR="0;31"
#CPE_NAME="cpe:/o:centos:centos:7"
#HOME_URL="https://www.centos.org/"
#BUG_REPORT_URL="https://bugs.centos.org/"
#
#CENTOS_MANTISBT_PROJECT="CentOS-7"
#CENTOS_MANTISBT_PROJECT_VERSION="7"
#REDHAT_SUPPORT_PRODUCT="centos"
#REDHAT_SUPPORT_PRODUCT_VERSION="7"

if [ "$n" = "openSUSE Leap" ]; then
	echo opensuse
	echo "TODO"
elif [ "$n" = "CentOS Linux" ]; then
	echo y | sudo yum install mosh
	echo y | sudo yum install tmux
else
	echo "Error, exit"
	exit
fi

