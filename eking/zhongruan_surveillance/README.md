
本文的说明使用kiwi构建并测试镜像的过程
--------------------------------------

已配置好的机器ip：10.72.84.158，passwd: suse
本文及未特殊说明的脚本地址：<https://github.com/bjzhang/open_log/tree/master/eking/zhongruan_surveillance>

1.  环境准备：
    1.  环境准备参考脚本：fresh_install.sh（只经过分段测试，不要直接执行）。
    2.  准备物理机环境，至少需要安装libvirtd等必要的包，建立虚拟机所需的网桥。为了管理方便158机器上使用了nat网桥（libvirtd安装后会自动建立这个网桥）。
    3.  准备用于build kiwi镜像的vm。kiwi是opensuse提供的构建镜像服务，推荐在opensuse上使用。两种方法
        1.  推荐使用vagrant建立系统的第一个虚拟机镜像。可以用vagrant up下载并启动opensuse镜像。vagrant配置文件参考（Vagrant）。由于vagrant会使用目录名作为vm名称的一部分。可以新建目录并建立符号连接。
            ``` 
            cd ~/works/open_log/eking/zhongruan_surveillance/
            mkdir  kiwi_vagrant_01/
            cd kiwi_vagrant_01/
            ln -sf ../Vagrantfile
            vagrant up
            vm.sh ip kiwi_vagrant_01_opensuse42.3
            ssh vagrant@192.168.122.204
            ``` 
            在vm中修改hostname。
            ``` 
            sudo hostnamectl set-hostname os04
            ``` 
        2.  可以用已有的机器作为base image，节省后续的准备的时间。
            1.  `sudo virsh domblklist vm_name`看到硬盘名称。`sudo virsh destroy vm_name; sudo virsh undefine vm_name`删除系统（libvird）中注册的虚拟机信息（并不会删除虚拟机硬盘）。
            2.  例如用已经配置kiwi基本环境的硬盘(/mnt/images/zhangjian/opensuse42.3_kiwi.qcow2)，建立新的vm：
                1.  保证该硬盘无vm使用，并改为只读保证不会被改写。base image变化会导致依赖镜像出问题。
                2.  `install.sh /mnt/images/zhangjian/opensuse42.3_kiwi.qcow2 ${vm_name}`
                3.  安装后可以用`vm.sh`命令查看ip地址并ssh连接。用户名密码是vagrant(有sudo权限)。具体参考[README_tools](https://github.com/bjzhang/open_log/blob/master/eking/zhongruan_surveillance/README_tools.md) TODO
        3.  安装后，设置在host该机器的hostname和username。
        4.  use internal repo: `sudo sed "s/download.opensuse.org/mirrors.haihangyun.com\/opensuse/g" -ibak /etc/zypp/repos.d/*`
        5.  enable auto refresh
            ```
            sudo zypper modifyrepo --refresh distro-non-oss
            sudo zypper modifyrepo --refresh distro-oss
            sudo zypper modifyrepo --refresh distro-update-oss
            sudo zypper modifyrepo --refresh distro-update-non-oss
            ```
2.  build image(同时适用于x86_64的虚拟机和物理机)
    1.  install_kiwi_remote.sh把同目录的install_kiwi.sh复制到目标机器，并执行，install_kiwi.sh的流程包括（每个步骤都可以用"-m xxx"单独执行）：
        1.  init: 初始化。安装kiwi build环境所需的rpm包，git clone kiwi的配置文件(kiwi-descriptions)。
        2.  rebase: rebase kiwi-descriptions本地commit。为了保证不同节点构建一致性，不建议使用。
        3.  checkout: git checkout $commitid。
        4.  update installed rpm packages.
        5.  precheck: 检查kiwi build环境
        6.  build：首先检查$APPLIANCE下有无prepare.sh，如果有传递剩余参数给它，并执行之。用于定制kiwi当前config.xml无法满足的需求。

    2.  第一次build image 命令：`install_kiwi_remote.sh ${kiwi_vm_name} --appliance ${appliance_name} --proxy user@1.2.3.4 --commit f267a610 ${github_token}`
        1. kiwi_vm_name: 要求openSUSE Leap 42.3（道理上suse系列比较新的版本不管是enterprise linux，opensuse leap还是opensuse tumbleweed都可以，但是脚本是写死了opensuse kiwi相关工具的所需的repo地址），打开ssh端口。
        2.  appliance_name: 待build image的配置文件目录。完整目录是：
            ```
            APPLIANCE_ROOT=${home}/works/source/kiwi-descriptions
            APPLIANCE=${APPLIANCE_ROOT}/${APPLIANCE}
            ```
            install_kiwi_remote.sh会把配置文件git clone到${APPLIANCE_ROOT}目录。如果需要本地修改配置文件，见下面的说明。
        3.  proxy用于临时访问外网。可选参数。
        4.  commitid: kiwi-description的commitid或tag等可以被git checkout的名称。
        5.  github_token: 对于中软的项目，需要去github private项目下载rpm，必须有token。

    3.  根据需要调整xml。可以用"-m build"重新build。如果不加"-m"或"-m all"，会force checkout。强烈建议当镜像有调整时（包括不限于rpm包，二进制，代码等更新，kiwi配置文件修改），修改config.xml中版本号：
    	```
        <preferences>
            <version>0.6.2</version>
            <packagemanager>yum</packagemanager>
            <bootsplash-theme>charge</bootsplash-theme>
	    ```

    4.  build结果位于$home/works/software/kiwi/Ceph-CentOS-07.0.x86_64-${version}.install.iso
        ```
        > sudo scp -p $home/works/software/kiwi/Ceph-CentOS-07.0.x86_64-0.6.2.install.iso 10.72.84.158:/mnt/images
        Ceph-CentOS-07.0.x86_64-0.6.2.install.iso                                    100%  846MB 105.8MB/s   00:08
        ```

3.  安装虚拟机:
    1.  登陆到物理机并设置环境变量：
        ```
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

    3.  安装成功后后，可以用如下命令查看虚拟机ip地址，最后一行地址是配置config.json 文件要用到的
        ```
        $ vm.sh ips ceph_test_0.6.2_0
        ceph_test_0.6.0_01: 192.168.122.98
        ceph_test_0.6.0_02: 192.168.122.38
        ceph_test_0.6.0_04: 192.168.122.16
        ceph_test_0.6.0_03: 192.168.122.207
        ["192.168.122.98", "192.168.122.38", "192.168.122.16", "192.168.122.207"]
        ```
    4.  动态插入硬盘(可选)。此处的vda是我们希望vm中的硬盘名称，**每个机器必须都插入硬盘**
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

4.  部署业务
    1.  连接到任意一台虚机(`vm.sh ssh ceph_test_0.6.0_01`，root密码是"Eking1234!")
    2.  解压部署脚本
        ```
        cd /binaries/
        tar zxf storedeployer_v1.1.2.tar.gz
        cd bjzhang-storedeployer-94b5eba9f09c1738c4f0431bd2e43204cc0f6624/
        ```
    3.  根据需要修改参数config.json：
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
            #配置了上述ip地址的网卡。
            "vip_nic":  "lan0",
            #步骤2.4中插入的硬盘名称，可以是一块或多块。
            "disks": ["/dev/vda"],
            #定制需求：当root硬盘小，不够业务使用时，可以在部署业务前把root和var分区扩容，二者各占50%的容量
            "extendfs": "YOURDISK"
        }
        ```
    3.  执行脚本`python ./fabfile.py`
    4.  如果测试在虚拟机，需要修改host上的nginx代理文件。本文是物理机158: nginx /etc/nginx/nginx.conf，ip修改为上面的vip：
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

5. 测试
    1.  在浏览器中访问10.72.84.158就可以看到登录界面了, admin/admin.
    2.  测试项。
        1.  基本功能
            1.  安装部署四台机器：UI正常。
            2.  物理机可以安装。
            3.  优盘可以安装。
        2.  定制要求
            1.  最小的硬盘（3900m）。
    
