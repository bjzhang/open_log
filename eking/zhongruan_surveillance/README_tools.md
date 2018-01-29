
1.   install from disk
```
[bamvor@ceph-bj-rabbit-10-72-84-158 zhongruan_surveillance]$ vm.sh ssh opensuse_42.3_kiwi_03
PLEASE migrate to vagrant. those scripts will not add new features
ssh to root@192.168.122.225
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/bamvor/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed

/usr/bin/ssh-copy-id: WARNING: All keys were skipped because they already exist on the remote system.
                (if you think this is a mistake, you may want to use -f option)

Last login: Mon Jan 29 13:45:16 2018 from 192.168.122.1
Have a lot of fun...
os42:~ # logout
Connection to 192.168.122.225 closed.
[bamvor@ceph-bj-rabbit-10-72-84-158 zhongruan_surveillance]$ vim ~/.ssh/config
[bamvor@ceph-bj-rabbit-10-72-84-158 zhongruan_surveillance]$ ssh os03
Last login: Tue Jan 23 09:23:44 2018
Have a lot of fun...
vagrant@os42:~> ls
bin  install_kiwi.sh  works
vagrant@os42:~> sudo hostnamectl set-hostname os03
vagrant@os42:~>
```

2.  Prepare and build kiwi appliance
```
install_kiwi_remote.sh os03 --appliance centos/x86_64/ceph-applicance --proxy smb_rd@10.71.84.48 --commit c6d5ed01 your_git_hub_token
```
