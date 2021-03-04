
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

USER=bamvor
# call select-editor to select the vim
# Add user and create home directory automatically.
useradd -m $USER
# call vipw to change shell to bash in /etc/passwd.
# source: https://ostechnix.com/the-right-way-to-edit-etc-passwd-and-etc-group-files-in-linux/
# examples:
# bamvor:x:1000:1000::/home/bamvor:/bin/bash
# set password
passwd $USER
# Add $USER with sudo
usermod -G sudo bamvor
# Check with groups, example:
# #groups bamvor
# bamvor : bamvor sudo
# re-login as $USER
# Install go
# Ubuntu
# sudo snap install --classic go
# OpenSUSE
sudo zypper install go
# Install go-shadowsocks
go get github.com/shadowsocks/go-shadowsocks2
# If fail similar with followings, update the proxy
# go get github.com/shadowsocks/go-shadowsocks2
# package golang.org/x/crypto/chacha20poly1305: unrecognized import path "golang.org/x/crypto/chacha20poly1305": https fetch: Get "https://golang.org/x/crypto/chacha20poly1305?go-get=1": dial tcp 216.239.37.1:443: i/o timeout
# package golang.org/x/crypto/hkdf: unrecognized import path "golang.org/x/crypto/hkdf": https fetch: Get "https://golang.org/x/crypto/hkdf?go-get=1": dial tcp 216.239.37.1:443: i/o timeout
# reference: https://learnku.com/go/wikis/38122
# go env -w GO111MODULE=on
# go env -w  GOPROXY=https://goproxy.io,direct
# Start shadowsocks, replace password and port
~/go/bin/go-shadowsocks2  -s 'ss://AEAD_CHACHA20_POLY1305:your-password@:8488' -verbose
echo "Install cow"
go get github.com/cyfdecyf/cow
echo "Configuration cow"
echo "listen = http://127.0.0.1:7228
> proxy = socks5://127.0.0.1:1080" > ~/.cow/rc

# Enable firewall
# OpenSUSE
# Reference: https://firewalld.org/documentation/zone/default-zone.html
# Add the following port to default zone(Mark as X in yast), it is public zone by default
# 7228, 8228, 1080

# Configure tmux
echo "set-window-option -g mode-keys vi" >> ~/.tmux.conf
# Start tmux
tmux
echo "Start shadowsocks"
~/go/bin/go-shadowsocks2 -c 'ss://AEAD_CHACHA20_POLY1305:StartFrom2021_@$SERVERIP:SERVERPORT' -verbose -socks :1080 -u -udptun :8053=8.8.8.8:53,:8054=8.8.4.4:53 -tcptun :8053=8.8.8.8:53,:8054=8.8.4.4:53 echo "Start cow for convert http to socks
~/go/bin/cow -reply -request -color
