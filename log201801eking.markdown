
11:17 2018-01-02
----------------
eking, GTD
----------
1.  today
	1.	-17:27
    1.  感觉自己有点乱。搞不清该做什么。
    2.  监控
        1.  catkeeper:
            1.  catkeeper设为自动启动。需要用"WorkingDirectory"设置启动目录，否则web找不到public目录中的网页。另外Type需要设为simple表示前台运行的普通应用。其它常见的类型是forking表示会自动变为后台运行的daemon。
                ```
				[root@ceph220 ~]# cat /usr/lib/systemd/system/catkeeper.service
				[Unit]
				Description=Cat keeper

				[Service]
				WorkingDirectory=/mnt/ssd/catkeeper/web/
				ExecStart=/mnt/ssd/catkeeper/web/web
				ExecReload=/bin/kill -HUP $MAINPID
				KillMode=process
				Restart=always
				RestartSec=10
				Type=simple

				[Install]
				WantedBy=multi-user.target
				```
            2.  DONE: ssd分区使用所有剩余nvme区域。
            3.  DONE: 223机器ssd1改为ssd。
			4.  看网桥没有起来的问题。对比ifcfg-br0，发现唯一的区别是ceph223写成了Bridge="br0"，改为BRIDGE="br0"就可以了。
			5.	今天发现我和兴义同时用了nvme的第二个分区。我当时找兴义确认过，当时兴义说没有使用。但是我自己脚本的写法也有问题，因为我只是测试能否mount。兴义当作块设备用，本来也没法mount。
        2.  kiwi:
            1.  使用干净的python3-kiwi，尽量不改代码.
            2.  保证resize正确。
            3.  使用脚本修改grub同时支持serial和console.
        3.  TIDB部署脚本。
            1.  TiDB环境检查部分用kiwi完成。
            2.  脚本仅仅负责启动TiDB。


09:27 2018-01-05
----------------
eking, GTD
----------
1.  today
    1.  每次都觉得时间很少，事情做不完。
    2.  孩子：
        1.  需要一个比较方便的远程协作软件。考虑team viewer。需求：
            1.  直接同步屏幕。
            2.  我可以控制屏幕。
            3.  有声音。
            4.  跨平台：支持windows，os x, ios, Linux, Android
            5.  随系统默认启动，我可以直接连接孩子的设备。
        2.  可控的翻墙方式。

10:04 2018-01-05
----------------
1.  <https://googleprojectzero.blogspot.jp/2018/01/reading-privileged-memory-with-side.html>
2.  Variant 1: Bounds check bypass
    1.  理论上可以利用已有分支做攻击，但是google做PoC时并没有找到这样的可利用的点。google使用了eBPF JIT实现这种攻击。后者据google说，并没有在发行版中默认打开。
    2.  The Linux kernel supports eBPF since version 3.18
    3.  google指出该PoC没有在打开SMAP。我也感觉SMAP不影响这个攻击。
        ```
        Supervisor Mode Access Prevention (SMAP) is a feature of some CPU
        implementations such as the Intel Broadwell microarchitecture that allows
        supervisor mode programs to optionally set user-space memory mappings so
        that access to those mappings from supervisor mode will cause a trap.
        ```
3.  Variant 3: Rogue data cache load
    1.  "This works by using the code pattern that was used for the previous variants, but in userspace."

13:53 2018-01-05
漏洞讨论
--------
1.  升级范围：600-700 node. 5000 vm.
2.  sammy: 私有云风险大不大？
3.  zhenyao: 虚拟机镜像是否和host一起升级？
4.  sammy: 1月底完成评估。2月份升级。
5.  建议用户从vmware迁移到新的私有云。或者用户自行升级。
6.  客户支持？
    1.  云平台接口。
    2.  安全相关的直接去安全平台。

10:55 2018-01-08
----------------
proxy, cow
----------
<https://github.com/cyfdecyf/cow>
遇到这个错误<https://github.com/golang/go/issues/17335>，重新用go构建就好了。
go get github.com/cyfdecyf/cow
go build

11:02 2018-01-08
----------------
1.  "sudo useradd -G docker <builduser>"
    应该是"sudo usermod -a -G docker <builduser>
2.  根据[docker systemd文档](https://docs.docker.com/engine/admin/systemd/#httphttps-proxy)docker需要单独在systemd service里面设置代理：
	不知道为什么docker用[cow](https://github.com/cyfdecyf/cow)做二级代理时会报错："net/http: TLS handshake timeout"。这次还知道[systemd unit](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)可以用servicde.d/xxx.conf在不修改原有service文件情况下，增加功能：
	```
	Along with a unit file foo.service, the directory foo.service.wants/ may exist. All unit files symlinked from such a directory are implicitly added as dependencies of type Wants= to the unit. This is useful to hook units into the start-up of other units, without having to modify their unit files. For details about the semantics of Wants=, see below. The preferred way to create symlinks in the .wants/ directory of a unit file is with the enable command of the systemctl(1) tool which reads information from the [Install] section of unit files (see below). A similar functionality exists for Requires= type dependencies as well, the directory suffix is .requires/ in this case.

	Along with a unit file foo.service, a "drop-in" directory foo.service.d/ may exist. All files with the suffix ".conf" from this directory will be parsed after the file itself is parsed. This is useful to alter or add configuration settings for a unit, without having to modify unit files. Each drop-in file must have appropriate section headers. Note that for instantiated units, this logic will first look for the instance ".d/" subdirectory and read its ".conf" files, followed by the template ".d/" subdirectory and the ".conf" files there.

	In addition to /etc/systemd/system, the drop-in ".d" directories for system services can be placed in /usr/lib/systemd/system or /run/systemd/system directories. Drop-in files in /etc take precedence over those in /run which in turn take precedence over those in /usr/lib. Drop-in files under any of these directories take precedence over unit files wherever located. Multiple drop-in files with different names are applied in lexicographic order, regardless of which of the directories they reside in.
	```
	```
	suse01@osh01:~> sudo cat /etc/systemd/system/docker.service.d/http-proxy.conf
	[Service]
	Environment="HTTP_PROXY=http://127.0.0.1:7228/"
	suse01@osh01:~> sudo systemctl status docker
	● docker.service - Docker Application Container Engine
	   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
	   Active: active (running) since Sun 2018-01-07 22:00:52 EST; 13min ago
		 Docs: http://docs.docker.com
	  Process: 1818 ExecStartPost=/usr/lib/docker/docker_service_helper.sh wait (code=exited, status=0/SUCCESS)
	 Main PID: 1817 (dockerd)
		Tasks: 14
	   Memory: 54.0M
		  CPU: 1.749s
	   CGroup: /system.slice/docker.service
			   └─1817 /usr/bin/dockerd --containerd /run/containerd/containerd.sock --add-runtime oci=/usr/bin/docker-runc

	Jan 07 22:07:56 osh01 dockerd[1817]: time="2018-01-07T22:07:56.039627913-05:00" level=warning msg="failed to retrieve docker-runc version: unknown output format: runc version spec: 1.0.0-rc2-dev\n"
	Jan 07 22:07:56 osh01 dockerd[1817]: time="2018-01-07T22:07:56.039726176-05:00" level=warning msg="failed to retrieve docker-init version"
	Jan 07 22:08:11 osh01 dockerd[1817]: time="2018-01-07T22:08:11.042496163-05:00" level=warning msg="Error getting v2 registry: Get https://registry-1.docker.io/v2/: net/http: request canceled whi...iting headers)"
	Jan 07 22:08:11 osh01 dockerd[1817]: time="2018-01-07T22:08:11.042617745-05:00" level=info msg="Attempting next endpoint for pull after error: Get https://registry-1.docker.io/v2/: net/http: req...iting headers)"
	Jan 07 22:08:11 osh01 dockerd[1817]: time="2018-01-07T22:08:11.042679650-05:00" level=error msg="Handler for POST /v1.28/images/create returned error: Get https://registry-1.docker.io/v2/: net/h...iting headers)"
	Jan 07 22:08:24 osh01 dockerd[1817]: time="2018-01-07T22:08:24.163960278-05:00" level=warning msg="failed to retrieve docker-runc version: unknown output format: runc version spec: 1.0.0-rc2-dev\n"
	Jan 07 22:08:24 osh01 dockerd[1817]: time="2018-01-07T22:08:24.164052192-05:00" level=warning msg="failed to retrieve docker-init version"
	Jan 07 22:08:39 osh01 dockerd[1817]: time="2018-01-07T22:08:39.166635111-05:00" level=warning msg="Error getting v2 registry: Get https://registry-1.docker.io/v2/: net/http: request canceled whi...iting headers)"
	Jan 07 22:08:39 osh01 dockerd[1817]: time="2018-01-07T22:08:39.166726076-05:00" level=info msg="Attempting next endpoint for pull after error: Get https://registry-1.docker.io/v2/: net/http: req...iting headers)"
	Jan 07 22:08:39 osh01 dockerd[1817]: time="2018-01-07T22:08:39.166786788-05:00" level=error msg="Handler for POST /v1.28/images/create returned error: Get https://registry-1.docker.io/v2/: net/h...iting headers)"
	Warning: docker.service changed on disk. Run 'systemctl daemon-reload' to reload units.
	Hint: Some lines were ellipsized, use -l to show in full.
	suse01@osh01:~> sudo systemctl daemon-reload
	suse01@osh01:~> sudo systemctl restart docker
	suse01@osh01:~> docker pull opensuse/dice:latest
	latest: Pulling from opensuse/dice
	caf3d94c0ab8: Pulling fs layer
	error pulling image configuration: Get https://dseasb33srnrn.cloudfront.net/registry-v2/docker/registry/v2/blobs/sha256/a9/a9b445468bcd1417360e988c7f38a89988b5f7e0683f9c6abde7b9071affd1d8/data?Expires=1515424637&Signature=a41X4WJBiHJA3l7RUvmCfVhjjx717lBDURjnl7-gElxFZ2e27K3loPlcy8sdyzjodLke-YUFZ-g6yPY0XqH5kFfGGGOHl9DLinmAdgVKN~vcw3HzA0irZ4UnXsVjILvmnywVS558xhR2TqipxJxvqYb9zAel6TWXKvE5JtLXRrA_&Key-Pair-Id=APKAJECH5M7VWIS5YZ6Q: net/http: TLS handshake timeout
	suse01@osh01:~> sudo cat /etc/systemd/system/docker.service.d/http-proxy.conf
	[Service]
	Environment="HTTP_PROXY=http://127.0.0.1:8228/"
	suse01@osh01:~> sudo systemctl restart docker
	Warning: docker.service changed on disk. Run 'systemctl daemon-reload' to reload units.
	suse01@osh01:~> sudo systemctl daemon-reload
	suse01@osh01:~> sudo systemctl restart docker
	suse01@osh01:~> docker pull opensuse/dice:latest
	```

12:13 2018-01-08
----------------
[ INFO    ]: 23:09:24 | --> Type: rpm-md
[ INFO    ]: 23:09:24 | --> Translated:
/home/suse01/works/source/kiwi-descriptions/centos/x86_64/ceph-applicance/rpms
[ INFO    ]: 23:09:24 | --> Alias: rpms
[ WARNING ]: 23:09:24 | repository
file:///home/suse01/works/source/kiwi-descriptions/centos/x86_64/ceph-applicance/rpms does not exist and will be skipped

14:59 2018-01-08
----------------
中软监控, 需要增加的文件
------------------------
```
https://github.com/journeymidnight/niergui  ALL
https://github.com/journeymidnight/automata ALL
https://github.com/journeymidnight/nier     ALL
https://github.com/journeymidnight/prometheus-rpm/  ceph_exporter, node-exporter, prometheus
https://github.com/journeymidnight/storedeployer
tidb
```

11:45 2018-01-09
----------------
中软
----
1.  昨天不行的原因时private repo必须assert id下载。并且给出Accept application/octet-stream
2.  环境变量:
    1.  有人说jq引用环境变量有时要用单引号，jq自己用双引号。<https://stackoverflow.com/questions/40027395/passing-bash-variable-to-jq-select>。但是我在命令行里面传数字可以，在shell脚本里面传数字不行。
    2.
        ```
        > test=url; count=; cat json | jq '.assets[]' | jq "[.$test, .id][$count]"
        "https://api.github.com/repos/journeymidnight/nier/releases/assets/5808414"
        5808414
        "https://api.github.com/repos/journeymidnight/nier/releases/assets/5808413"
        5808413
        > test=url; count=1; cat json | jq '.assets[]' | jq "[.$test, .id][$count]"
        5808414
        5808413
        > test=url; count=0; cat json | jq '.assets[]' | jq "[.$test, .id][$count]"
        "https://api.github.com/repos/journeymidnight/nier/releases/assets/5808414"
        "https://api.github.com/repos/journeymidnight/nier/releases/assets/5808413"
        ```
3.  上午本来想用go访问GitHub api，尝试了下发现自己对go web差的太远。还是改为bash curl jq了。jq感觉不太方便。

21:20 2018-01-10
----------------
1.  现在兴义有没有配置hostname？
2.  kiwi: 根据bootstrap脚本修改。

09:44 2018-01-11
----------------
software skill, bash, sudo
--------------------------
1.  sudo执行函数: <https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo>
	```
	function hello()
	{
		echo "Hello!"
	}

	# Test that it works.
	hello

	FUNC=$(declare -f hello)
	sudo bash -c "$FUNC; hello"
	Or more simply:

	sudo bash -c "$(declare -f hello); hello"
	```

12:06 2018-01-11
---------------
GTD
---
1.  去兴义的机器看fabric脚本。ssh cloud-user@116.204.24.47 Lalala1200099
2.  打算学学ansible，这两天刚写的shell脚本打算用ansible实现：同时看看有没有其它机器部署安装的工具。
3.  vm创建阶段：需要增加一块硬盘。如果系统有两个硬盘，iso安装有没有问题？
4.  TiDB ip修改, <https://pingcap.com/docs-cn/FAQ/>
    ```
    更改 PD 的启动参数 当想更改 PD 的 --client-url，--advertise-client-url 或 --name 时，只要用更新后的参数重新启动该 PD 就可以了。当更改的参数是 --peer-url 或 --advertise-peer-url 时，有以下几种情况需要区别处理：
    之前的启动参数中有 --advertise-peer-url，但只想更新 --peer-url：用更新后的参数重启即可。 之前的启动参数中没有 --advertise-peer-url：先用 etcdctl 更新该 PD 的信息，之后再用更新后的参数重启即可。
    ```
5.	DML, DDL, DCL。<http://blog.csdn.net/level_level/article/details/4248685>
	```
	DML（data manipulation language）：
		   它们是SELECT、UPDATE、INSERT、DELETE，就象它的名字一样，这4条命令是用来对数据库里的数据进行操作的语言
	DDL（data definition language）：
		   DDL比DML要多，主要的命令有CREATE、ALTER、DROP等，DDL主要是用在定义或改变表（TABLE）的结构，数据类型，表之间的链接和约束等初始化工作上，他们大多在建立表时使用
	DCL（Data Control Language）：
		   是数据库控制功能。是用来设置或更改数据库用户或角色权限的语句，包括（grant,deny,revoke等）语句。在默认状态下，只有sysadmin,dbcreator,db_owner或db_securityadmin等人员才有权力执行DCL
	```

16:19 2018-01-11
----------------
1.  sunxin：之前在联想。
2.  超融合对标:
    1.  http://www.maxta.com/cn/
    2.  https://www.nutanix.com/

10:27 2018-01-12
----------------
(10:46 2018-01-17)
software skills, useful link
1.  SUSE Linux Enterprise Product Sources
    <https://www.suse.com/download-linux/source-code/>
2.  Using Paxos to Build a Scalable, Consistent, and Highly Available Datastore
3.  开源的dropbox: <https://syncthing.net/>
4.  owncloud
5.  kernel
    1.  内核测试可以看看。https://kernelci.org/
    2.  然后用https://github.com/google/syzkaller做fuzz测试。
6.  语言学习
    1.  go <https://github.com/astaxie/go-best-practice/blob/master/ebook/zh/preface.md>

10:50 2018-01-12
----------------
GTD
---
1.  中软:
    1.  直接写ceph安装脚本。
    2.  fabric.
    3.  TiDB暂时不考虑重新起ip。直接重新部署。

18:47 2018-01-14
----------------
<https://doc.opensuse.org/documentation/leap/reference/html/book.opensuse.reference/cha.dns.html>
<http://www.syrlug.org/contrib/ipmasq.html>
<https://doc.opensuse.org/documentation/leap/security/html/book.security/cha.security.firewall.html>
之前转发一直不行。最后发现必须打开防火墙。
```
bamvor@localhost:~> sudo iptables -t nat -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  anywhere             anywhere
```

20:35 2018-01-14
----------------
1.  突然想起原来脚本里面配置TiDB所需的系统参数还没有配置。
    1.  未测试。
    2.  加入到root/etc/sysctl.d/99-tidb.conf
        本地测试可以。
    3.  如果不行加入到fabric.py
2.  三节点TiDB还没有测试。
    1.  初步测试正确。
    2.  找人帮我测试。
3.  TiDB的配置文件需要和TiDB二进制在一起。
    1.  将来在支持更新TiDB二进制。
4.  (12:00 2018-01-15)
    1.  装mysql
5.  curl check http code, <https://gist.github.com/rgl/f90ff293d56dbb0a1e0f7e7e89a81f42>
    ```
    # curl -s -o /dev/null -w ''%{http_code}'' 192.168.122.35:2379/pd/api/v1/members
    200
    ```
6.  感觉今天进展不大，有时候越是着急，越是没有进展。整理一下思路。确认下修改都已经提交。
    1.  今天主要进展是TiDB toml配置文件有问题。目前是fabric里面没法把tidb拉起来。
        1.  systemd拉不起来的原因是tidb deploy目录的log和status使用root建立的，用户tidb没有权限写入。晚上是在没有办法了，切换到用户tidb执行/home/tidb/deploy/scripts/run_pd.sh，才发现目录权限问题。
    2.  ceph: 需要在其中一台目标机器执行fabric脚本。
    3.  包：已加入mysql，未测试。
    4.  自动拿最新的包。还没有做。
7.  (10:15 2018-01-16)昨天ceph和ctdb其实都有问题。问题原因是硬盘不可写，我添加硬盘时加了readonly参数。ref"23:26 2018-01-15"

09:52 2018-01-15
----------------
mysql -u root -h 192.168.122.53 -P 4000
MySQL [test]> CREATE TABLE Persons (     PersonID int,     LastName varchar(255),     FirstName varchar(255),     Address varchar(255), City varchar(255)  );

mysql -u root -h 192.168.122.115 -P 4000
MySQL [test]> insert into Persons (PersonID, LastName, FirstName) values (1, "Bamvor", "Zhang");

mysql -u root -h 192.168.122.232 -P 4000
MySQL [test]> update Persons set LastName="Bamvor Jian" where PersonID=1;

mysql -u root -h 192.168.122.53 -P 4000
MySQL [test]> select * from Persons;

11:13 2018-01-15
----------------
cpu漏洞讨论
1.  有人说如果内存比较大，热迁移比较慢，不如停机。家军说如果是万兆网络还好。

21:57 2018-01-15
----------------
```
[root@ceph-bj-beishu-cluster-node-2 ~]# systemctl status pd
...
Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: pd.service: main process exited, code=exited, status=1/FAILURE
Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: Unit pd.service entered failed state.
Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: pd.service failed.
[root@ceph-bj-beishu-cluster-node-2 ~]# systemctl status pd
● pd.service - pd service
   Loaded: loaded (/etc/systemd/system/pd.service; disabled; vendor preset: disabled)
   Active: activating (auto-restart) (Result: exit-code) since Mon 2018-01-15 13:52:50 UTC; 6s ago
  Process: 28660 ExecStart=/home/tidb/deploy/scripts/run_pd.sh (code=exited, status=1/FAILURE)
 Main PID: 28660 (code=exited, status=1/FAILURE)
   CGroup: /system.slice/pd.service

Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: pd.service: main process exited, code=exited, status=1/FAILURE
Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: Unit pd.service entered failed state.
Jan 15 13:52:50 ceph-bj-beishu-cluster-node-2 systemd[1]: pd.service failed.
[root@ceph-bj-beishu-cluster-node-2 ~]# tail -f /home/tidb/deploy/log/pd.log
2018/01/15 13:53:05.473 log.go:85: [info] rafthttp: [started streaming with peer 70adc409ea993288 (stream MsgApp v2 reader)]
2018/01/15 13:53:05.473 log.go:85: [info] rafthttp: [started streaming with peer 70adc409ea993288 (stream Message reader)]
2018/01/15 13:53:05.474 log.go:85: [info] rafthttp: [started streaming with peer 3311b709387977fb (writer)]
2018/01/15 13:53:05.474 log.go:85: [info] rafthttp: [started streaming with peer 3311b709387977fb (writer)]
2018/01/15 13:53:05.474 log.go:85: [info] rafthttp: [started streaming with peer 3311b709387977fb (stream MsgApp v2 reader)]
2018/01/15 13:53:05.474 log.go:85: [info] rafthttp: [started streaming with peer 3311b709387977fb (stream Message reader)]
2018/01/15 13:53:05.475 log.go:85: [info] rafthttp: [started streaming with peer 70adc409ea993288 (writer)]
2018/01/15 13:53:05.476 log.go:79: [error] rafthttp: [request sent was ignored (cluster ID mismatch: peer[3311b709387977fb]=b91f7b0260e4b739, local=f66c304993c262f9)]
2018/01/15 13:53:05.477 log.go:79: [error] rafthttp: [request sent was ignored (cluster ID mismatch: peer[3311b709387977fb]=b91f7b0260e4b739, local=f66c304993c262f9)]
2018/01/15 13:53:05.559 main.go:86: [fatal] run server failed: Etcd cluster ID mismatch, expect 17756620523384759033, got 13339515871440451385
^C
[root@ceph-bj-beishu-cluster-node-2 ~]# sudo rm /home/tidb/deploy/data.pd/ -rf
```

23:26 2018-01-15
----------------
```
[192.168.122.202] sudo: sudo rm  /etc/ctdb/public_addresses /etc/ctdb/nodes -f
[192.168.122.31] sudo: sudo rm  /etc/ctdb/public_addresses /etc/ctdb/nodes -f
[192.168.122.206] sudo: sudo rm  /etc/ctdb/public_addresses /etc/ctdb/nodes -f
[192.168.122.202] sudo: echo 192.168.122.176 ctdb  >> /etc/hosts
[192.168.122.31] sudo: echo 192.168.122.176 ctdb  >> /etc/hosts
[192.168.122.206] sudo: echo 192.168.122.176 ctdb  >> /etc/hosts
[192.168.122.202] sudo: echo 192.168.122.176/24  lan0 > /etc/ctdb/public_addresses
[192.168.122.31] sudo: echo 192.168.122.176/24  lan0 > /etc/ctdb/public_addresses
[192.168.122.206] sudo: echo 192.168.122.176/24  lan0 > /etc/ctdb/public_addresses
[192.168.122.202] sudo: echo '192.168.122.202' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.31] sudo: echo '192.168.122.202' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.206] sudo: echo '192.168.122.202' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.202] sudo: echo '192.168.122.31' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.206] sudo: echo '192.168.122.31' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.31] sudo: echo '192.168.122.31' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.202] sudo: echo '192.168.122.206' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.206] sudo: echo '192.168.122.206' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.31] sudo: echo '192.168.122.206' >> "$(echo /etc/ctdb/nodes)"
[192.168.122.202] Executing task 'all_startctdb'
[192.168.122.31] Executing task 'all_startctdb'
[192.168.122.206] Executing task 'all_startctdb'
[192.168.122.206] sudo: systemctl enable ctdb
[192.168.122.31] sudo: systemctl enable ctdb
[192.168.122.202] sudo: systemctl enable ctdb
[192.168.122.206] out: Created symlink from /etc/systemd/system/multi-user.target.wants/ctdb.service to /usr/lib/systemd/system/ctdb.service.
[192.168.122.31] out: Created symlink from /etc/systemd/system/multi-user.target.wants/ctdb.service to /usr/lib/systemd/system/ctdb.service.
[192.168.122.202] out: Created symlink from /etc/systemd/system/multi-user.target.wants/ctdb.service to /usr/lib/systemd/system/ctdb.service.
[192.168.122.206] out:
[192.168.122.31] out:

[192.168.122.206] sudo: systemctl restart ctdb

[192.168.122.31] sudo: systemctl restart ctdb
[192.168.122.202] out:

[192.168.122.202] sudo: systemctl restart ctdb
[192.168.122.206] out: Job for ctdb.service failed because a timeout was exceeded. See "systemctl status ctdb.service" and "journalctl -xe" for details.
[192.168.122.206] out:


Fatal error: sudo() received nonzero return code 1 while executing!

Requested: systemctl restart ctdb
Executed: sudo -S -p 'sudo password:'  /bin/bash -l -c "systemctl restart ctdb"

Aborting.
[192.168.122.202] out: Job for ctdb.service failed because a timeout was exceeded. See "systemctl status ctdb.service" and "journalctl -xe" for details.
[192.168.122.202] out:


Fatal error: sudo() received nonzero return code 1 while executing!

Requested: systemctl restart ctdb
Executed: sudo -S -p 'sudo password:'  /bin/bash -l -c "systemctl restart ctdb"

Aborting.
[192.168.122.31] out: Job for ctdb.service failed because a timeout was exceeded. See "systemctl status ctdb.service" and "journalctl -xe" for details.
[192.168.122.31] out:


Fatal error: sudo() received nonzero return code 1 while executing!

Requested: systemctl restart ctdb
Executed: sudo -S -p 'sudo password:'  /bin/bash -l -c "systemctl restart ctdb"

Aborting.

Fatal error: One or more hosts failed while executing task 'all_startctdb'

Aborting.
```
```
[192.168.122.185] out: [192.168.122.185][WARNIN] IOError: [Errno 1] Operation not permitted
[192.168.122.169] out: [192.168.122.169][ERROR ] RuntimeError: command returned non-zero exit status: 1
[192.168.122.169] out: [ceph_deploy.osd][ERROR ] Failed to execute command: /usr/sbin/ceph-disk -v prepare --zap-disk --cluster ceph --fs-type xfs -- /dev/vda
[192.168.122.169] out: [ceph_deploy][ERROR ] GenericError: Failed to create 1 OSDs
[192.168.122.169] out:
[192.168.122.185] out: [192.168.122.185][ERROR ] RuntimeError: command returned non-zero exit status: 1
[192.168.122.185] out: [ceph_deploy.osd][ERROR ] Failed to execute command: /usr/sbin/ceph-disk -v prepare --zap-disk --cluster ceph --fs-type xfs -- /dev/vda
[192.168.122.185] out: [ceph_deploy][ERROR ] GenericError: Failed to create 1 OSDs
```

09:28 2018-01-16
----------------
```
   <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/mnt/ssd/catkeeper/images/opensuse42.3_01.qcow2'/>
      <backingStore type='file' index='1'>
        <format type='raw'/>
        <source file='/mnt/ssd/catkeeper/images/opensuse42.3_base_20171215.qcow2'/>
        <backingStore/>
      </backingStore>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
```
```
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/mnt/ssd/catkeeper/images/kiwi/ceph_data_02.raw'/>
      <backingStore/>
      <target dev='vdb' bus='virtio'/>
      <alias name='virtio-disk1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x0a' function='0x0'/>
    </disk>
```
```
<disk type='file' device='disk'>
        <driver name='qemu' type='raw'/>
        <source file='/mnt/images/disk_name.raw'/>
        <target dev='vdb' bus='virtio'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x0e' function='0x0'/>
</disk>
```
```
[root@ceph-bj-beishu-cluster-node-0 storedeployer]# ceph -s
  cluster:
    id:     e81275ae-4452-4a0d-80ba-11c2e7723474
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-bj-beishu-cluster-node-0,ceph-bj-beishu-cluster-node-2,ceph-bj-beishu-cluster-node-1
    mgr: ceph-bj-beishu-cluster-node-0(active), standbys: ceph-bj-beishu-cluster-node-1, ceph-bj-beishu-cluster-node-2
    mds: newfs-1/1/1 up  {0=ceph-bj-beishu-cluster-node-2=up:active}, 2 up:standby
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   2 pools, 256 pgs
    objects: 21 objects, 22277 bytes
    usage:   3168 MB used, 296 GB / 299 GB avail
    pgs:     256 active+clean

  io:
    client:   255 B/s wr, 0 op/s rd, 0 op/s wr

[root@ceph-bj-beishu-cluster-node-0 storedeployer]# ctdb status
Number of nodes:3
pnn:0 192.168.122.74   OK (THIS NODE)
pnn:1 192.168.122.185  OK
pnn:2 192.168.122.169  OK
Generation:420110881
Size:3
hash:0 lmaster:0
hash:1 lmaster:1
hash:2 lmaster:2
Recovery mode:NORMAL (0)
Recovery master:1
```

10:04 2018-01-16
----------------
1.  promesus 153.
2.  测试:
    1.  测试多个硬盘和网卡。
    2.  测试合法的不同配置文件。


16:51 2018-01-16
----------------
1.  dialog包缺失造成在多块硬盘时无法选择。
    ```
    BAMVOR: Echo to ttyS0: Searching harddrive for CD installation
    BAMVOR: Echo to ttyS0: Disk 0 -> /dev/sda [ 102400 MB ]
    BAMVOR: Echo to ttyS0: Disk 1 -> /dev/sdb [ 102400 MB ]
    BAMVOR: Echo to ttyS0: Entering installation mode for disk:
    BAMVOR: Echo to ttyS0: Have size:  -> 0 MB
    BAMVOR: Echo to ttyS0: Need size: /squashed/Ceph-CentOS-07.0.raw -> 3500 MB
    BAMVOR: Echo to ttyS0: Not enough space available for this image
    BAMVOR: Echo to ttyS0: rebootException: reboot in 120 sec...
    ```
    ```
    dialog --yesno "Continue?" 5 80
    ```
    如果选择yes会$?=0，选择no是1。我觉得这里需要有个判断。如果dialog不存在改为命令行方式？
2.  性能
    1.  8vcpu, 2G memory，机械硬盘，大约构建26分钟。
    2.  mksquashfs会把cpu跑满，大约持续3分钟。感觉增加vcpu，提升也不会很大。

18:40 2018-01-16
----------------
```
BAMVOR: Echo to ttyS0: Searching for boot device in Application ID...
BAMVOR: Echo to ttyS0: Found Install CD/DVD: /dev/cdrom
BAMVOR: Echo to ttyS0: Searching harddrive for CD installation
BAMVOR: Echo to ttyS0: Disk 0 -> /dev/sda [ 102400 MB ]
BAMVOR: Echo to ttyS0: Entering installation mode for disk:
/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001
BAMVOR: Echo to ttyS0: System installation canceled
BAMVOR: Echo to ttyS0: reboot triggered by user
BAMVOR: Echo to ttyS0: reboot in 30 sec...
```

21:06 2018-01-16
----------------
<https://git-lfs.github.com/>

```
$ git init
Initialized empty Git repository in /Users/Shared/iso/.git/
$ git lfs track "*.iso"
Tracking "*.iso"
```
添加.gitattributes
$ git add .gitattributes
```
$ cat .gitattributes
*.iso filter=lfs diff=lfs merge=lfs -text
```
$ git remote add origin https://github.com/bjzhang/iso.git
支持的最大文件是2G：
```
bogon:iso bamvor$ git push --set-upstream origin master
Git LFS: (0 of 0 files, 1 skipped) 0 B / 0 B, 4.32 GB skipped
[195baca6c5f3b7f3ad4d7984a7f7bd5c4a37be2eb67e58b65d07ac3a2b599e83] Size must be
less than 2147483648: [422] Size must be less than 2147483648
error: failed to push some refs to 'https://github.com/bjzhang/iso.git'
```
换了小一些文件。不过eof了（走的新加坡代理）。
```
bogon:iso bamvor$ git push --set-upstream origin master
Git LFS: (0 of 1 files) 253.66 MB / 846.00 MB
LFS: Put
https://github-cloud.s3.amazonaws.com/alambic/media/166029199/59/f9/59f9d53ba2d11aa8d6d5f10c92e822ecd9eb4c06c6ff9c1fa3ae4e8d55b36c52?actor_id=2332740:
EOF
error: failed to push some refs to 'https://github.com/bjzhang/iso.git'
```

10:20 2018-01-17
----------------
software skills, virtualization, spice, os x上安装spice client
--------------------------------------------------------------
<https://wiki.gnome.org/Projects/GTK+/OSX/Building>
```
$ ./gtk-osx-build-setup.sh
$ jhbuild bootstrap
I: Moving temporary DESTDIR u'/Users/bamvor/gtk/inst/_jhbuild/root-intltool'
into build prefix
I: Install complete: 12 files copied
*** success *** [24/24]
```

11:53 2018-01-17
----------------
中软
----
1.  测试3-5台物理机。
2.  测试小硬盘(容量大于)情况。
    1.  修改kiwi-description: 不做var分区。
    2.  修改install脚本。
3.  测试机器硬盘1-x块硬盘数量。
    1.  不同的硬盘名称。
    2.  安装到不同的硬盘。
4.  录屏。
	1.	已完成装机。
	2.	TODO：fabric.
5.	网卡默认配置脚本。
6.	159物理机装机测试

14:10 2018-01-17
----------------
1.  安装vagrant
    ```
    [bamvor@ceph-bj-rabbit-10-72-84-158 ~]$ sudo yum install https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.rpm
    已加载插件：fastestmirror
    Repository extras is listed more than once in the configuration
    Repository updates is listed more than once in the configuration
    无法打开 https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.rpm ，跳过。
    错误：无须任何处理
    wget  https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.rpm
    echo y | sudo yum install vagrant_2.0.1_x86_64.rpm
    ```

2.  安装vagrant provider
    1.  参考<https://github.com/vagrant-libvirt/vagrant-libvirt>。保证libvirt已经正常安装。并安装如下包： `sudo dnf install libxslt-devel libxml3-devel libvirt-devel libguestfs-tools-c ruby-devel gcc`

3.  varant启动vm失败
    ```
    $ vagrant up
    Bringing machine 'default' up with 'libvirt' provider...
    Error while connecting to libvirt: Error making a connection to libvirt URI qemu:///system?no_verify=1&keyfile=/home/bamvor/.ssh/id_rsa:
    Call to virConnectOpen failed: authentication unavailable: no polkit agent available to authenticate action 'org.libvirt.unix.manage'
    ```

4.  突然发现libvvirtd启动不了了；
```
1月 17 16:01:01 ceph-bj-rabbit-10-72-84-158 systemd[1]: Started Session 32 of user root.
-- Subject: Unit session-32.scope has finished start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit session-32.scope has finished starting up.
--
-- The start-up result is done.
1月 17 16:01:01 ceph-bj-rabbit-10-72-84-158 systemd[1]: Starting Session 32 of user root.
-- Subject: Unit session-32.scope has begun start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit session-32.scope has begun starting up.
1月 17 16:01:01 ceph-bj-rabbit-10-72-84-158 CROND[21282]: (root) CMD (run-parts /etc/cron.hourly)
1月 17 16:01:01 ceph-bj-rabbit-10-72-84-158 run-parts(/etc/cron.hourly)[21285]: starting 0anacron
1月 17 16:01:01 ceph-bj-rabbit-10-72-84-158 run-parts(/etc/cron.hourly)[21291]: finished 0anacron
1月 17 16:01:39 ceph-bj-rabbit-10-72-84-158 sudo[21384]:   bamvor : TTY=pts/18 ; PWD=/home/bamvor/works/vagrant ; USER=root ; COMMAND=/bin/vim /etc/polkit-1/rules.d/50-default.rules
1月 17 16:02:34 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPREQUEST(virbr0) 192.168.122.76 52:54:00:09:31:b7
1月 17 16:02:34 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPACK(virbr0) 192.168.122.76 52:54:00:09:31:b7
1月 17 16:02:34 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: not giving name ceph-bj-beishu-cluster-node-0 to the DHCP lease of 192.168.122.35 because the name exists in /etc/hosts with address 192.168.122.74
1月 17 16:03:53 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPREQUEST(virbr0) 192.168.122.72 52:54:00:28:13:f7
1月 17 16:03:53 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPACK(virbr0) 192.168.122.72 52:54:00:28:13:f7
1月 17 16:03:53 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: not giving name ceph-bj-beishu-cluster-node-0 to the DHCP lease of 192.168.122.35 because the name exists in /etc/hosts with address 192.168.122.74
1月 17 16:04:22 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPREQUEST(virbr0) 192.168.122.84 52:54:00:9b:7f:bc
1月 17 16:04:22 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: DHCPACK(virbr0) 192.168.122.84 52:54:00:9b:7f:bc
1月 17 16:04:22 ceph-bj-rabbit-10-72-84-158 dnsmasq-dhcp[2774]: not giving name ceph-bj-beishu-cluster-node-0 to the DHCP lease of 192.168.122.35 because the name exists in /etc/hosts with address 192.168.122.74
```
删除了"/etc/hosts"中192.168.122的地址都不行。前者是fabric脚本加入的。根据`systemctl status livirtd`的提示，看看"/var/lib/libvirt/dnsmasq"。
```
 Main PID: 22859 (libvirtd)
   CGroup: /system.slice/libvirtd.service
           ├─ 2735 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/virbr1.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
           ├─ 2736 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/virbr1.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
           ├─ 2774 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
           ├─ 2775 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
           └─22859 /usr/sbin/libvirtd
```
在/var/lib/libvirt/dnsmasq/virbr0.status，看到
```

  {
    "ip-address": "192.168.122.35",
    "mac-address": "52:54:00:84:60:47",
    "hostname": "ceph-bj-beishu-cluster-node-0",
    "expiry-time": 1516180037
  }
```
和上面信息能对上。删除这个文件后。libvirtd可以正常启动。

sudo usermod -a -G wheel bamvor
修改"/etc/libvirt/libvirtd.conf"，加入：
auth_unix_rw = "none"
上面两个修改后可以，不确定是否都有。

5.  vagrant卡在了nfs。两次Ctrl+C后可以使用虚机。

6.  改进设置
    1.  使用已有的网卡：
        <https://github.com/vagrant-libvirt/vagrant-libvirt/issues/380>
        machine.vm.network :public_network, :dev => 'virbr0', :type => 'bridge'
    2.  hostname:
        config.vm.hostname = "os01"
    3.  disable nfs
        <https://stackoverflow.com/questions/36727053/disable-nfs-pruning-in-vagrant>
        config.nfs.functional = false


16:57 2018-01-17
----------------
调用kpartx -dv xxx.raw时有个分区没有umount，造成kpartx失败。再执行kpartx也没有用。参考下文手工解决。
<https://davidjb.com/blog/2009/05/unix-removing-open-logical-volumes-in-centosrhl/>
<https://gist.github.com/waja/c780d4217fd695e4f55f>
```
osh01:~/works/software/temp # dmsetup status
loop0p4: 0 5971935 linear
loop0p3: 0 614400 linear
systemVG-LVRoot: 0 5742592 linear
loop0p2: 0 40960 linear
loop0p1: 0 4096 linear
systemVG-var: 0 221184 linear
osh01:~/works/software/temp # lvs
  LV     VG       Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LVRoot systemVG -wi-a-----   2.74g
  var    systemVG -wi-a----- 108.00m
osh01:~/works/software/temp # vgs
  VG       #PV #LV #SN Attr   VSize VFree
  systemVG   1   2   0 wz--n- 2.84g    0
osh01:~/works/software/temp # lvchange -an /dev/systemVG/LVRoot
osh01:~/works/software/temp # lvchange -an /dev/systemVG/var
osh01:~/works/software/temp # vgs
  VG       #PV #LV #SN Attr   VSize VFree
  systemVG   1   2   0 wz--n- 2.84g    0
osh01:~/works/software/temp # lvs
  LV     VG       Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LVRoot systemVG -wi-------   2.74g
  var    systemVG -wi------- 108.00m
osh01:~/works/software/temp # dmsetup status
loop0p4: 0 5971935 linear
loop0p3: 0 614400 linear
loop0p2: 0 40960 linear
loop0p1: 0 4096 linear
osh01:~/works/software/temp # dmsetup statusf^C
osh01:~/works/software/temp # fuser -c /dev/mapper/loop0p1
/dev/dm-0:               1rce     2rc     3rc     5rc     7rc     8rc     9rc    10rc    11rc    12rc    13rc    15rc    16rc    17rc    18rc    20rc    21rc    22rc    23rc    25rc    26rc    27rc    28rc    30rc    31rc    32rc    33rc    35rc    36rc    37rc    38rc    40rc    41rc    42rc    43rc    45rc    47rc    48rc    49rc    50rc    51rc    52rc    53rc    55rc    56rc    57rc    58rc    59rc    60rc    62rc    63rc    64rc    65rc    78rc    80rc    82rc    83rc    93rc   139rc   141rc   144rc   149rc   150rc   247rc   248rc   249rc   250rc   251rc   252rc   253rc   254rc   263rc   283rc   287rc   288rc   289rc   290rc   295rc   557rc   558rc   560rc   561rc   568rc   586rc   588rc   589rc   590rc   591rc   592rc   593rc   594rc   595rc   596rc   597rc   598rc   599rc   600rc   601rc   602rc   603rc   604rc   605rc   606rc   607rc   658rc   660rc   663rc   665rc   678rc   680rce   690rc   739rc   747rce   794rc   863rc  1015rce  1019rc  1032rce  1036rce  1040rce  1043rce  1054rce  1056rce  1058rce  1060rce  1064rce  1067rce  1072rce  1531rce  1533rce  1536rce  1577rce  1578rce  1581rce  1785re  1788re  1809rce  2990rce  2994rce  3037rce  3041rce  3042re  3309re 17582rc 18057rc 18061rc 18065rc 18066rc 18074rc 18079rc 18086rc 18247re 18248rce 18249rce 18319rc 18320rc 18401rc 18404rc 18405rc 18406rc 18443rc 18446rc 18448rc 18452rc 18454rc 18458rc 18459rc 18464rc 18465rc 18497rc 18552rc 18675re 18676re 18677re 18683rce 22737rc 22739rc 22741rc 22742rc 22744rc 22746rc 22747rc 22749rc 22871rc 22872rc 26666rc 28196rce 28199rce 28200re 29183rc 29405rc 29409rc 29417re 29644rc 29698rc 29703rc 30023rce 30026rce 30027re 30178rc 30547rce 30550rc 30730rc
osh01:~/works/software/temp # ll /dev/mapper/loop0p
loop0p1  loop0p2  loop0p3  loop0p4
osh01:~/works/software/temp # ll /dev/mapper/loop0p1
lrwxrwxrwx 1 root root 7 Jan 17 03:46 /dev/mapper/loop0p1 -> ../dm-0
osh01:~/works/software/temp # dmsetup remove /dev/mapper/loop0p1
osh01:~/works/software/temp # dmsetup remove /dev/mapper/loop0p2
osh01:~/works/software/temp # dmsetup remove /dev/mapper/loop0p3
osh01:~/works/software/temp # dmsetup remove /dev/mapper/loop0p4
osh01:~/works/software/temp # dmsetup status
No devices found
```

18:14 2018-01-17
----------------
1.  ceph:
    1.  检查硬盘在不在。
        DONE
    2.  完善文档，说明每个虚机都要加硬盘。
        DONE
    3.  20180117 18:14
        1.  node0 tidb启动失败。systemctl重启tidb后正常。
            1.  TODO: 检查tidb是否启动成功。
                1.  参考"https://github.com/pingcap/tidb-ansible.git"的start.yml各组件的name: wait up
                2.  例如pd: curl -s -o /dev/null -w ''%{http_code}'' 192.168.122.35:2379/pd/api/v1/members
        2.  node0的osd没有启动成功。重跑一遍脚本后可以。
        3.  ceph exporter没有启动起来。
            1.  TODO:
                1.  restart ceph_exporter, add dependency in systemd
                2.  restart nier, add dependency in systemd
        4.  xingyi: 改minsize. DONE.
        5.  脚本默认重定向，保存日志。
        6.  0118冬卯帮忙做优盘。
        7.  kiwi
            1.  spare_part有什么用，可以作为可选的扩展区域么？
            2.  installstick用于优盘？
            3.  构建的镜像如何做成优盘。 <https://suse.github.io/kiwi/building/working_with_images/iso_to_usb_stick_deployment.html>
    4.  (10:05 2018-01-18)
        1.  tidb三个组建用wants。
        2.  加tidb组件的monitor，后面的服务以来monitor service。
        3.  加入wget, curl包。
    5.  启动时kernel cmdline改为kiwidebug=1，如果安装失败会进入shell。

3.  usermod，polkit。
4.  Linux音频剪辑软件。Audacity

10:40 2018-01-18
----------------
资源：
10.72.22.49 10.72.84.158 E15-27U-28U Printfzj*158
10.72.22.58 10.72.84.159 E16-27U-28U

12:46 2018-01-18
----------------
<https://stackoverflow.com/questions/27243891/run-a-python-script-from-within-python-and-also-catch-the-exception>
1.  
```
vagrant@os01:~/works/source/kiwi-descriptions/centos/x86_64/centos-07.0-JeOS>
python build.py
Traceback (most recent call last):
      File "build.py", line 3, in <module>
          from pkg_resources import load_entry_point
      ImportError: No module named pkg_resources
```
1.  无效
pip install --upgrade distribute
1.  python3 build.py works/

22:12 2018-01-18
----------------
```
[ INFO    ]: Processing: [########################################] 100%
[ ERROR   ]: 08:55:32 | KiwiInstallPhaseFailed: System package installation
failed: Main config did not have a requires_policy attr. before setopt
Error unpacking rpm package nier-1.2-46.fea4e11git.el7.centos.x86_64
```

08:49 2018-01-19
----------------
```
[   10.579371] fbcon: cirrusdrmfb (fb0) is primary device
[   10.643902] Console: switching to colour frame buffer device 128x48
[   10.676698] ata1.00: ATA-7: QEMU HARDDISK, 1.5.3, max UDMA/100
[   10.676702] ata1.00: 209715200 sectors, multi 16: LBA48
[   10.676725] ata1.01: ATAPI: QEMU DVD-ROM, 1.5.3, max UDMA/100
[   10.677518] ata1.00: configured for MWDMA2
[   10.678187] ata1.01: configured for MWDMA2
[   10.678710] scsi 0:0:0:0: Direct-Access     ATA      QEMU HARDDISK    3    PQ: 0 ANSI: 5
[   10.699254] cirrus 0000:00:02.0: fb0: cirrusdrmfb frame buffer device
[   10.710033] [drm] Initialized cirrus 1.0.0 20110418 for 0000:00:02.0 on minor 0
[   10.720925] scsi 0:0:1:0: CD-ROM            QEMU     QEMU DVD-ROM     1.5. PQ: 0 ANSI: 5
[   10.738566] scsi 0:0:0:0: Attached scsi generic sg0 type 0
[   10.740716] scsi 0:0:1:0: Attached scsi generic sg1 type 5
[   10.752124] sr 0:0:1:0: [sr0] scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[   10.752378] sd 0:0:0:0: [sda] 209715200 512-byte logical blocks: (107 GB/100 GiB)
[   10.752464] sd 0:0:0:0: [sda] Write Protect is off
[   10.752511] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   10.758617] sd 0:0:0:0: [sda] Attached SCSI disk
[   10.765176] cdrom: Uniform CD-ROM driver Revision: 3.20
[    0.992489] Starting boot shell on /dev/tty2
[   13.179533] brd: module loaded
[   13.193583] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
[   13.216430] device-mapper: uevent: version 1.0.3
[   13.218824] device-mapper: ioctl: 4.35.0-ioctl (2016-06-23) initialised: dm-devel@redhat.com
[   13.260149] loop: module loaded
[   13.270698] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   13.287158] fuse init (API version 7.22)
[    0.992489] Starting boot shell on /dev/tty2
[    3.500040] Couldn't find any boot device... abort
Give root password for maintenance
(or type Control-D to continue):
sulogin: crypt failed: Invalid argument
Login incorrect
```
11:16 2018-01-19
----------------
1.	"multiple devices matches same MBR ID: $mbrI", kiwi/boot/functions:
```
        #======================================
        # Multiple matches are bad
        #--------------------------------------
        if [ $match_count -gt 1 ];then
            export biosBootDevice="multiple devices matches same MBR ID: $mbrI"
            return 2
        fi
```

```
        i*386|x86_64)
            masterBootID=$(printf 0x%04x%04x $RANDOM $RANDOM)
            Echo "writing new MBR ID to master boot record: $masterBootID"
            echo $masterBootID > /boot/mbrid
            masterBootIDHex=$(echo $masterBootID |\
                sed 's/^0x\(..\)\(..\)\(..\)\(..\)$/\\x\4\\x\3\\x\2\\x\1/')
            echo -e -n $masterBootIDHex | dd of=$imageDiskDevice \
                bs=1 count=4 seek=$((0x1b8))
            ;;
```

16:21 2018-01-19
----------------
01: 
02: 10.16.1.27 -> 10.16.0.221
03: 10.16.1.94 -> 10.16.0.222
04: 10.16.1.43 -> 10.16.0.223

<http://kernelpanik.net/rename-a-linux-network-interface-without-udev/>
ip link set peth0 name eth0 

16:53 2018-01-22
----------------
software skills, virtualizaiton, machine management, vagrant
------------------------------------------------------------
1.  provider: libvirt, virtualbox等虚拟化管理工具。
2.  `vagrant up`: start vm.
    vagrant默认会使用目录名名+config.vm.define作为libvirt管理机器名称。我一般会建立一个数字目录，然后用符号连接或复制vagrant配置文件。
3.  `vagrant global-status --prune`: display all vagrant managed vm.
    1.  可以用里面的id操作具体vm。例如`vagrant ssh $id`
3.  `vagrant destroy`: 彻底删除虚拟机。这个和libvirt，virsh
destroy行为有差异。后者只是不由libvirt管理，不会实际删除硬盘。

17:53 2018-01-22
----------------
1.  看了看pulp部署有点复杂，稍后在用。

