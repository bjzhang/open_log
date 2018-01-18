home=/home/vagrant

if [ -f "$home/.ssh/id_rsa.pub" ]; then
	echo "ssh public key exist. skip"
else
	echo "generate ssh key, press anykey to continue"
	ssh-keygen
fi

ssh-copy-id smb_rd@10.71.84.50
export http_proxy=localhost:8228
export https_proxy=localhost:8228
wget google.com
if [ "$?" != "0" ]; then
	ssh -fNL 8228:localhost:8228 smb_rd@10.71.84.50
	ssh -fNL 8228:localhost:8228 smb_rd@10.71.84.50
fi

sudo bash -c "echo 'Defaults env_keep += \"http_proxy https_prox\"' > /etc/sudoers.d/proxy"
OPEN_LOG_PATH="$home/works/open_log"
if [ -d $OPEN_LOG_PATH/.git ]; then
	echo "open log already exist skip"
else
	git clone https://github.com/bjzhang/open_log.git ~/works/open_log
fi

KIWI_REPO="http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_42.3/Virtualization:Appliances:Builder.repo"
PACKAGES="python3-kiwi>=9.11 man jq yum command-not-found"

ZYPPER="sudo zypper -v --non-interactive --gpg-auto-import-keys"

$ZYPPER ar -c -f -r $KIWI_REPO
$ZYPPER install $PACKAGES

echo export http_proxy=localhost:8228
echo export https_proxy=localhost:8228
