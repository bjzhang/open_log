
14:49 2018-02-02
----------------
GTD
---
1.	中软项目
	1.	完成文档。
	2.	测试问题求助社区。
2.	hikey960 m.2
	1.	uefi要支持pcie
		1.	看启动日志。15:01-16:09
	2.	内核对m.2是怎么支持的？
3.	写一个通用的git clone脚本(ansible?，只写了开头): 
	1.	software skills, SCM, git, <productivity/ansible/git_common.yml>

09:46 2018-02-05
----------------
GTD
---
1.	看bager IO工作。
	1.	读google bigtable论文。09:49-10:28
2.	刻录光盘。10:49-
3.	远程安装。
	1.	在客户的超威机器实验，问题是lvm分区没被挂载。可能是lvm工具问题。
		1.	但是虚拟机里面scsi设备lvm挂载没有问题。看起来是lvm的分区没有active失败。
		2.	0.7.05里面打印参数，看看能不能得到所需的lvm所属的盘。
	2.	0.7.04去掉lvm，看看有没有问题。
		1.	3200m, 4000m都有问题。直接实验100G硬盘。也有问题。错误一样，都是xfs第一次mount失败。
	3.	和冬卯一起看，他怀疑是kiwi resize和dracut有竞争导致后者拿lvm lock失败，造成lv没有被激活。
		1.	后来的解决方案是安装之后手动执行`dracut -f`，系统就可以正常启动了。
2.	更新kiwi，重新测试。
	1.	os01暂时不要更新了。
	2.	kiwi问题反馈到社区。
3.	thedictionary感觉不全。找找新的字典。

09:55 2018-02-05
----------------
bigtable
--------
1.	2006的OSDI。是不是我每年该看下OSDI的论文。
2.	mapreduce的输入输出使用bigtable。bigtable基于gfs。
3.	Chubby(使用Paxos协议)是啥？
    1.  后文多次提到，需要看看。
4.	Each row range is called a tablet, which is the unit of distribution and load balancing. 

09:34 2018-02-06
----------------
GTD
---
1.  bager IO:
    1.  读完bigtable论文。
    2.  写checklist评估进度。
2.  中软监控
    1.  测试昨天镜像。
		1.  配置服务器代理（通过非自己笔记本的路由器出去，这样笔记本拿走了，也不影响）直接上传到外网s3，节省时间。09:36-10:15
		2.	在中软下载镜像，并在超威服务器测试。10:15-11:44
            1.  安装正确
            2.  测试重启。20-kiwi-repart-disk.sh这个脚本还是在。
            3.  再自己看看kiwi调用dracut的过程。
    2.  2U4节点
        1.  确认镜像部署后可以重启。14:00-14:15(临时网络调整，断网了)
            1.  extendfs后`dracut -f`可以使用。
        2.  TiDB可以重新配置IP。14:19-
            1.  机器没发ssh了。稍后测试。
        3.  配置文件修改：
            1.  DONE: 镜像改名。
            2.  DONE: fabric脚本写好硬盘名称。
            3.  DONE 网卡默认脚本改为客户实际的网卡名字.
            4.  DONE 网卡配置脚本 set_ip.sh
                1.  DONE: appliance加入augtool.
                2.  测试通过。
            5.  extendfs需要多次y的问题是否修改？
            6.  等tidb换ip测试后一起打tag。
        5.  测试合入社区补丁98systemd/dracut-pre-mount.service 16:38-17:12
            0.  补丁利用了kiwi的生产文件系统的方式，kiwi-description目录下的root会覆盖系统的根目录（但是kiwi description里面的文件，由于其它原因可能也会被覆盖，比如我之前加入suders.d/xxx，就被删除了）:
				```
				vagrant@os04:~/works/source/kiwi-descriptions/centos/x86_64/ceph-applicance/root/usr/lib/dracut/modules.d> diff -urN ~/works/software/kiwi/build/image-root/usr/lib/dracut/modules.d/98systemd/dracut-pre-mount.service 98systemd/dracut-pre-mount.service
				--- /home/vagrant/works/software/kiwi/build/image-root/usr/lib/dracut/modules.d/98systemd/dracut-pre-mount.service      2018-01-05 13:47:31.000000000 +0100
				+++ 98systemd/dracut-pre-mount.service  2018-02-06 08:03:34.856000000 +0100
				@@ -11,13 +11,12 @@
				 Description=dracut pre-mount hook
				 Documentation=man:dracut-pre-mount.service(8)
				 DefaultDependencies=no
				-Before=initrd-root-fs.target sysroot.mount
				+Before=initrd-root-fs.target sysroot.mount systemd-fsck-root.service
				 After=dracut-initqueue.service
				 After=cryptsetup.target
				 ConditionPathExists=/etc/initrd-release
				 ConditionDirectoryNotEmpty=|/lib/dracut/hooks/pre-mount
				 ConditionKernelCommandLine=|rd.break=pre-mount
				-Conflicts=shutdown.target emergency.target

				 [Service]
				 Environment=DRACUT_SYSTEMD=1
				```
            1.  看起来只解决了一般fsck的问题。没有解决lvm的问题。
            2.  后来发现目录写错了，修改目录重新测试。
            3.  昨天社区有个修复：<https://github.com/SUSE/kiwi/commit/f44ce191c2bc429f14dc21ac0e842a427cf3cde9>，可能可以解决lvm没有ready的问题。
                ```
                Fixed kiwi-dump timing issue

                The install code needs to wait in the pre-udev phase for
                the device containing the installation data to become ready
                before proceeding with the actual installation code.
                ```
		6.	今日计划
            1.  DONE: 确认如何擦除nvme lvm分区。
                `parted -s /dev/nvme0n1 mklabel gpt`
            2.  DONE: 修改kiwi脚本。
            3.  取消：在最新镜像上测试tidb变更ip。
        7.  明天直接用最新镜像给冬卯测试。
    2.  TODO:
        1.  向kiwi社区反馈问题。
            1.  问问题：dracut pre-mount是如何保证只执行一次的。
        2.  能不能用kiwi hook解决？
            1.  editbootscript
            2.  config.sh
            3.  image.sh
        3.  如果找到方案考虑怎么给kiwi社区发补丁。
        4.  var要改成足够的大小。50G。并记录到文档中。
3.  吃饭，午睡，刷牙 11:44-13:50
4.  16:12-16:27 audit
    1.  如果"auditctl -l"显示no rules。可以用auditctl -e 0或内核命令后audit=0关闭audit.

10:02 2018-02-06
----------------
software skills, cloud, s3, s3cmd, proxy
----------------------------------------
1.	ref<http://www.techanswerguy.com/2011/04/s3cmd-through-proxy.html>
2.	s3配置(ak, sk, proxy等)。aws s3cmd有"--configure"参数可以配置所有参数（可以看看都可以配置什么参数）。配置时会自动检测系统proxy。于是得到"proxy_host", "proxy_port"。然后再修改为自己的s3配置即可。
    ```
    [default]
    access_key = xxx
    secret_key = xxxxxxxx
    default_mime_type = binary/octet-stream
    encoding = UTF-8
    host_base = los-cn-north-1.lecloudapis.com
#host_bucket = los-cn-north-2.lecloudapis.com/%(bucket)
    host_bucket = %(bucket).los-cn-north-1.lecloudapis.com
    multipart_chunk_size_mb = 15
    multipart_max_chunks = 10000
    recursive = False
    signature_v2 = True
#use_https = False
    use_mime_magic = True
    proxy_host = 127.0.0.1
    proxy_port = 7228
    use_https = True
    ```
    加入proxy后完整的s3cmd命令debug信息。搜索"prox"查看相关信息。如果没有配置proxy，会打印"non-proxied..."。
    ```
    [bamvor@ceph-bj-rabbit-10-72-84-158 zhongruan_surveillance]$ s3cmd -d ls
    DEBUG: s3cmd version 1.6.1
    DEBUG: ConfigParser: Reading file '/home/bamvor/.s3cfg'
    DEBUG: ConfigParser: access_key->hu...17_chars...S
    DEBUG: ConfigParser: secret_key->ca...37_chars...D
    DEBUG: ConfigParser: default_mime_type->binary/octet-stream
    DEBUG: ConfigParser: encoding->UTF-8
    DEBUG: ConfigParser: host_base->los-cn-north-1.lecloudapis.com
    DEBUG: ConfigParser: host_bucket->%(bucket).los-cn-north-1.lecloudapis.com
    DEBUG: ConfigParser: multipart_chunk_size_mb->15
    DEBUG: ConfigParser: multipart_max_chunks->10000
    DEBUG: ConfigParser: recursive->False
    DEBUG: ConfigParser: signature_v2->True
    DEBUG: ConfigParser: use_mime_magic->True
    DEBUG: ConfigParser: proxy_host->127.0.0.1
    DEBUG: ConfigParser: proxy_port->7228
    DEBUG: ConfigParser: use_https->True
    DEBUG: Updating Config.Config cache_file ->
    DEBUG: Updating Config.Config follow_symlinks -> False
    DEBUG: Updating Config.Config verbosity -> 10
    DEBUG: Unicodising 'ls' using UTF-8
    DEBUG: Command: ls
    DEBUG: CreateRequest: resource[uri]=/
    DEBUG: Using signature v2
    DEBUG: SignHeaders: 'GET\n\n\n\nx-amz-date:Tue, 06 Feb 2018 01:57:15 +0000\n/'
    DEBUG: Processing request, please wait...
    DEBUG: get_hostname(None): los-cn-north-1.lecloudapis.com
    DEBUG: ConnMan.get(): creating new connection: proxy://127.0.0.1:7228
    DEBUG: Using ca_certs_file None
    DEBUG: httplib.HTTPSConnection() has both context and check_hostname
    DEBUG: proxied HTTPSConnection(127.0.0.1, 7228)
    DEBUG: tunnel to los-cn-north-1.lecloudapis.com
    DEBUG: get_hostname(None): los-cn-north-1.lecloudapis.com
    DEBUG: format_uri(): http://los-cn-north-1.lecloudapis.com/
    DEBUG: Sending request method_string='GET', uri='http://los-cn-north-1.lecloudapis.com/', headers={'Authorization': 'AWS huimUJR9v25KSg76ZsES:OHLjP/BBVVBmrxDEv9R5csNPyrg=', 'x-amz-date': 'Tue, 06 Feb 2018 01:57:15 +0000'}, body=(0 bytes)
    DEBUG: Response: {'status': 200, 'headers': {'content-length': '588', 'server': 'openresty/1.9.7.4', 'connection': 'keep-alive', 'x-amz-request-id': 'tx000000000000023d6cbdf-005a790c46-1073188-default', 'date': 'Tue, 06 Feb 2018 02:00:38 GMT', 'content-type': 'application/xml'}, 'reason': 'OK', 'data': '<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>p-2HrgCmEBaL</ID><DisplayName>p-2HrgCmEBaL</DisplayName></Owner><Buckets><Bucket><Name>document</Name><CreationDate>2016-12-01T04:33:28.336Z</CreationDate></Bucket><Bucket><Name>jmd</Name><CreationDate>2018-01-23T08:14:29.607Z</CreationDate></Bucket><Bucket><Name>owncloud</Name><CreationDate>2018-01-23T06:57:10.570Z</CreationDate></Bucket><Bucket><Name>test1111</Name><CreationDate>2017-02-22T02:40:05.811Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>'}
    DEBUG: ConnMan.put(): closing proxy connection (keep-alive not yet supported)
    2016-12-01 04:33  s3://document
    ```
3.  "s3cmd ls s3://document"

10:35 2018-02-06
----------------
distribution, kiwi, dracut, debug
---------------------------------
1.  现象oem install iso安装后系统可以正常登录，但是重启后进入emergency shell（后来知道这就是dracut rd.shell）。
    1.  日志提示有个disk（uuid）找不到。对比成功安装的系统。发现这个uuid对应系统的"systemVG/LVRoot"，也就是系统的根文件系统。
    2.  在emergency shell里面lsblk看到硬盘/dev/sdd的分区是对的。vgs, lvs看到lvm login volume没有被激活。此时手工执行"lvchange -a y"可以激活。
    3.  后来查了dracut的资料，才知道此时输入exit退出emergency shell，系统会继续执行，并且此时系统可以正常启动。
2.  参考链接<https://sites.google.com/site/syscookbook/rhel/rhel-kernel-rebuild>, <https://wiki.centos.org/TipsAndTricks/CreateNewInitrd>知道可以用"dracut -f"重新制作initrd。
3.  TODO
    1.  怎么解开initrd?  因为initrd和kernel做到了一起。而initramfs里面只有intel的microcode?
    ./kernel/x86/microcode:
    AuthenticAMD.bin  GenuineIntel.bin

15:15 2018-02-07
----------------
GTD
---
1.  sudo:
    1.  今天手动改sudo的配置文件（/etc/sudoers.d/xxx），造成sudo无法使用。幸亏另一个机器上有ssh到这个机器root的免密码。
    2.  编辑sudoer文件一定要用："sudo visudo", "sudo visudo -f /etc/sudoers.d/sudo"方式！！！
2.  今天要看论文，不想花更多时间在做镜像上。

11:23 2018-02-08
----------------
GTD
---
1.  10:00-10:52 转正考试。
2.  macbook 10:52-11:24
    1.  macbook重启，网线未插入导致usb网卡inactive。
3.  cow os x plist not work 11:24-11:55
    1.  launchctl list看到exit status是512，开始觉得是没有daemon化，加了"&"，后来发现是arguments string不能有空格。
    2.  更新plist:
        ```
        launchctl unload Library/LaunchAgents/info.chenyufei.cow.plist
        launchctl load Library/LaunchAgents/info.chenyufei.cow.plist
        launchctl list info.chenyufei.cow
        ```
    3.  文档：
        1.  [Creating Launch Daemons and Agents](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html#//apple_ref/doc/uid/10000172i-SW7-BCIEDDBJ)
        2.  [About Daemons and Services](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Introduction.html)
4.  bager io计划。
    1.  今天最好把bigtable论文读一遍。
        1.  13:00-13:08 15:02-15:46 该读Refinement了
    2.  列出下周的checklist。
5.  中软
    1.  帮冬卯看yum无法使用的问题。13:08-13:27
        1.  网络要通。
        2.  如果直接使用baseurl要注释mirrorlist。
        3.  阿里的源；<https://mirrors.aliyun.com/help/centos>, `curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo`
    2.  kiwi
        1.  和社区讨论解决系统安装后重新制作initrd的问题。-17:11
            1.  之前只看到microcode是因为initrd在micro code的initramfs后面，为了便于调试需要在/etc/dracut.conf, /etc/dracut.conf.d/*, /usr/lib/dracut/dracut.conf.d/*中把
                ```
                early_microcode="yes"
                ```
                改为
                ```
                early_microcode="no"
                ```
                这样就可以直接看到gzip压缩的initrd。
            2.  "/etc/dracut.conf.d/02-kiwi.conf"可以看到`omit_dracutmodules+=" kiwi-live kiwi-dump kiwi-repart kiwi-overlay " `，感觉是这个选项导致新作的initrd里面没有20-kiwi-repart-disk.sh。
            3.  邮件已回复。最终讨论结果计入文档。
6.  日记，心理学。14:40-15:02
7.  cubietruck wifi.
    1.  DONE 更新Linux。
    2.  NEXT: 尝试usb wifi dangle。
8.  hikey960
    1.  NEXT: 今天最好再试试。确实没时间就还了。

11:09 2018-02-09
----------------
GTD
---
1.  中软项目
    1.  在158部署环境。
    2.  把项目相关代码单独出来。并给QA。
2.  bagerIO
    1.  看bigtable论文。14:28-
    2.  TODO
        1.  haystack
        2.  compaction和snapshot很重要。
7.  cubietruck wifi.
    2.  NEXT: 尝试usb wifi dangle。
8.  hikey960
    1.  NEXT: 今天最好再试试。确实没时间就还了。

09:21 2018-02-11
----------------
GTD
---
1.  中软OFFSET64
    1.  技术分析：09:25-10:43 <http://aarch64.me/2018/02/Large-File-Support-In-Linux/>
    2.  review振尧总的客户文档 13:45-13:55
    3.  没发送：14:31-14:45
        我理解业界所谓的32位系统都是默认软件支持lpae，"-D_FILE_OFFSET_BITS=64"等能力的32位系统。补充三个技术信息，
        1.  原来在华为也遇到过类似的问题。解决办法是如果客户有大于4G的需求（比如要求nfs server提供大于4G空间的管理能力）都要求客户端要用上面"-D_FILE_OFFSET_BITS=64"编译。
        2.  刚才又确认下代码，不管glibc和ltp（内核测试套）都要求32位环境必须可以正确支持"-D_FILE_OFFSET_BITS=64"。
        3.  去年Linux内核已经开始要求新的32位移植必须默认就使用64bit off_t。
2.  杂
    1.  病假报备。10:48-11:09
    2.  午饭。11:29-12:10
    3.  午休 12:50-13:35
    4.  下楼活动 13:35-13:45
    5.  京东下单，周一白天送到。14:16-14:31 14:45-15:00
    6.  晚饭。16:20-17:12
2.  bagerIO
    1.  看levelDB文档: index。15:55-16:20
        1.  看设计: snapshots, slice.
        2.  performance tune: include/leveldb/options.h
    2.  CANCEL 整理周五的内容。
4.  回复kiwi邮件。15:27-15:40
    1.  暂时的方案就是系统启动后自己加一个脚本运行dracut -f。并保证这个脚本只执行一次（可以通过检测一个空文件是否存在判断）

14:35 2018-02-13
----------------
GTD
---
1.  杂
    1.  午饭: 12:40-13:25
    2.  午睡: 13:40-14:35
    3.  刷牙。健身：膝关节康复训练。14:35-15:18
    4.  记账。15:18-16:22 17:50-18:08
2.  存储脚本独立项目。16:40-17:02
3.  内核4.16. 17:15-17:50


