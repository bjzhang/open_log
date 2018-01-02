
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


