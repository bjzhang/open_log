
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
3.	chubby(使用paxos协议)是啥？
4.	Each row range is called a tablet, which is the unit of distribution and load balancing. 

