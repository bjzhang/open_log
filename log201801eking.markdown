
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
software skills, useful link
1.  SUSE Linux Enterprise Product Sources
    <https://www.suse.com/download-linux/source-code/>
2.  Using Paxos to Build a Scalable, Consistent, and Highly Available Datastore

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
    3.  包：已加入mysql，为测试。
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

