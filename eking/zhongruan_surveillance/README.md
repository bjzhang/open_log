
本文的说明使用kiwi构建并测试镜像的过程
--------------------------------------

1.  构建：在opensuse/suse执行, `git clone --branch 0.1 https://github.com/journeymidnight/kiwi-descriptions`
    ```
    ssh ct01@10.72.84.147(Suse1234!)
    ssh osh01.local
    cd works/source/kiwi-descriptions/centos/x86_64/ceph-applicance/
    ```
    ```
    > cd centos/x86_64/ceph-applicance
    ```
	强烈建议当镜像有调整时（包括不限于rpm包，二进制，代码等更新，kiwi配置文件修改），修改config.xml中版本号：
	```
    <preferences>
        <version>0.6.2</version>
        <packagemanager>yum</packagemanager>
        <bootsplash-theme>charge</bootsplash-theme>
	```
	构建，your_github_token需要时有权访问所需github repo的权限，例如有权限访问指定private repo：
	```
    > sudo bash ./build.sh ${your_github_token}
    #构建结果位于/root/works/software/kiwi/Ceph-CentOS-07.0.x86_64-${version}.install.iso
    > sudo scp -p /root/works/software/kiwi/Ceph-CentOS-07.0.x86_64-0.6.2.install.iso 10.72.84.158:/mnt/images
    Ceph-CentOS-07.0.x86_64-0.6.2.install.iso                                    100%  846MB 105.8MB/s   00:08
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
        install.sh /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.2.install.iso ceph_test_0.6.2_02
        ...（执行多次，每次安装一个虚拟机）
        ...
        Domain installation still in progress. You can reconnect to
        the console to complete the installation process.
        Connect to ip:5916 to do the installation:
        ...
        ```
        根据提示使用vncviewer连接虚拟机，连接后在运行install.sh的终端输入回车，在vnc中选择"Install xxx"：
        ```
        vncviewer 10.72.84.158:5916
        ```

    3.  安装成功后后，可以用如下命令查看虚拟机ip地址，最后一行地址是配置config.json
        ```
        $ vm.sh ips ceph_test_0.6.2_0
        ceph_test_0.6.0_01: 192.168.122.98
        ceph_test_0.6.0_02: 192.168.122.38
        ceph_test_0.6.0_04: 192.168.122.16
        ceph_test_0.6.0_03: 192.168.122.207
        ["192.168.122.98", "192.168.122.38", "192.168.122.16", "192.168.122.207"]
        ```
    4.  动态插入硬盘。此处的vda是我们希望vm中的硬盘名称，**每个机器必须都插入硬盘**
        ```
        $ insert_data_disk.sh ceph_test_0.6.2_01 vda
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
        **libvirt实际会根据已有硬盘个数，重命名为vdX**，下述脚本操作的硬盘以日志结尾的新增的target硬盘为准，例如上面的"vda        /mnt/images/ceph_data_0.6.0_04_vda.raw"

3.  部署业务
    1.  连接到任意一台虚机(`vm.sh ssh ceph_test_0.6.0_01`，root密码是"Eking1234!")
    2.  解压部署脚本
        ```
        cd /binaries/
        tar zxf storedeployer_v1.1.2.tar.gz
        cd bjzhang-storedeployer-94b5eba9f09c1738c4f0431bd2e43204cc0f6624/
        ```
    3.  根据需要修改参数：
        ```
        {
            #任意三台机器
            "monitors": ["192.168.122.98", "192.168.122.38", "192.168.122.16"],
            #所有机器的IP
            "osdnodes": ["192.168.122.98", "192.168.122.38", "192.168.122.16", "192.168.122.207"],
            "user":  "root",
            "password":  "Eking1234!",
            "clusterinfo":  "bj-beishu-cluster",
            "ntpserverip":  "10.70.140.20",
            #vip需要时同网段未被使用的ip
            "vip":  "192.168.122.178",
            "vip_nic":  "lan0",
            #步骤2.4中插入的硬盘名称
            "disks": ["/dev/vda"]
        }
        ```
    3.  执行脚本`python ./fabfile.py`
    4.  如果测试在虚拟机，需要修改host上的nginx代理文件的物理机158: nginx /etc/nginx/nginx.conf，ip修改为上面的vip：
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
        修改后重启nginx服务：`systemctl restart nginx`

