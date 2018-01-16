
本文的说明使用kiwi构建并测试镜像的过程
--------------------------------------

1.  构建：在opensuse/suse执行, `git clone --branch 0.1 https://github.com/journeymidnight/kiwi-descriptions`
    ```
    > cd centos/x86_64/ceph-applicance
    > sudo bash ./build.sh c1d302e89018ed05282b08779d2d3cd5d7842fbc
    #构建结果位于/root/works/software/kiwi/Ceph-CentOS-07.0.x86_64-${version}.install.iso 
    > sudo scp -p /root/works/software/kiwi/Ceph-CentOS-07.0.x86_64-0.6.2.install.iso 10.72.84.158:/mnt/images
    Ceph-CentOS-07.0.x86_64-0.6.2.install.iso                                                                                                                                                                   100%  846MB 105.8MB/s   00:08
    ```

2.  安装虚拟机:
    1.  登陆到物理机并设置环境变量：
        ```
        ssh bamvor10.72.84.158
        passwd: suse
        export PATH=$PATH:/home/bamvor/works/open_log/eking/zhongruan_surveillance
        ```

    2.  安装虚拟机(install.sh iso_name vm_name)：
        ```
        install.sh /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.2.install.iso ceph_test_0.6.2_01
        ...
        Domain installation still in progress. You can reconnect to
        the console to complete the installation process.
        Connect to ip:5916 to do the installation:
        ...
        ```
        根据提示使用vncviewer连接虚拟机，连接后在运行install.sh的终端输入回车，在vnc中选择Install：
        ```
        vncview 10.72.84.158:5916
        ```

    3.  安装成功后后，可以用如下命令查看虚拟机ip地址，最后一行地址是配置config.json
        ```
        $ vm.sh ips ceph_test_0.6.0
        ceph_test_0.6.0_01: 192.168.122.98
        ceph_test_0.6.0_02: 192.168.122.38
        ceph_test_0.6.0_04: 192.168.122.16
        ceph_test_0.6.0_03: 192.168.122.207
        ["192.168.122.98", "192.168.122.38", "192.168.122.16", "192.168.122.207"]
        ```
    4.  动态插入硬盘
        ```
        [bamvor@ceph-bj-rabbit-10-72-84-158 zhongruan_surveillance]$ insert_data_disk.sh ceph_test_0.6.0_04 vda
        Target     Source
        ------------------------------------------------
        hda        /mnt/images/ceph_test_0.6.0_04.raw
        hdb        /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.0.install.iso

        Device attached successfully

        Target     Source
        ------------------------------------------------
        hda        /mnt/images/ceph_test_0.6.0_04.raw
        hdb        /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.0.install.iso
        vda        /mnt/images/ceph_data_0.6.0_04_vda.raw
        ```

3.  部署业务
    1.  连接到任意一台虚机：`vm.sh ssh ceph_test_0.6.0_01`，root密码是"Eking1234!"，vip需要时同网段未被使用的ip。例如：
        ```
        {
            "monitors": ["192.168.122.98", "192.168.122.38", "192.168.122.16"],
            "osdnodes": ["192.168.122.98", "192.168.122.38", "192.168.122.16", "192.168.122.207"],
            "user":  "root",
            "password":  "Eking1234!",
            "clusterinfo":  "bj-beishu-cluster",
            "ntpserverip":  "10.70.140.20",
            "vip":  "192.168.122.178",
            "vip_nic":  "lan0",
            "disks": ["/dev/vda"]
        }
        ```
    2.  修改nginx /etc/nginx/nginx.conf，ip修改为上面的vip：
		```
		upstream nier {
				server 192.168.122.179:8080;
		}
		upstream niergui {
				server 192.168.122.179:80;
		}

		upstream prome{
				server 192.168.122.179:9090;
		}
		```

