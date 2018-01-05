
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
1.  升级范围：600-700 node. 5000 vm.
2.  sammy: 私有云风险大不大？
3.  zhenyao: 虚拟机镜像是否和host一起升级？
4.  sammy: 1月底完成评估。2月份升级。
5.  建议用户从vmware迁移到新的私有云。或者用户自行升级。
6.  客户支持？
    1.  云平台接口。
    2.  安全相关的直接去安全平台。
