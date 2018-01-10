
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

