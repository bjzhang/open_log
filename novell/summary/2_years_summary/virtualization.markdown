
估计我写的内容80%大家都知道。基本这个文档就是笔记，像virt-manager大家常用软件我就不说了。

# different virtualization technologies 虚拟化技术比较
xen, kvm/qemu, container(lxc, openvz...), vmware.
hypervisor位置：xen在kernel下面。
kvm是ko. lxc利用了kernel cgroup, namespace等技术.

简单来说xen的架构如下

![type 1 hypervisor](hypervisor_based.jpg)

详细如下:

![xen框图](xen_architecture.png)

from sle12 document(Virtualization Guide SUSE Linux Enterprise Server 12)

教科书上一般说hypervisor有type 1, type 2两种，kvm是type 2么?

![type 1 vs type 2](Hyperviseur.png)

其实，kvm似乎更接近type 1. kvm架构如下

![kvm architecture](kvm_based_architecture.jpg)

## docker
container + build service + kiwi

- docker支持libcontainer, libxc, openvz等container技术，从1.0开始，默认使用自己的libcontainer(go语言).
- docker有版本管理功能。
- docker有自己的build系统，可以继承已有的image。
- docker可以用dockerfile实现自动build。
- container没法换kernel
- 记得要export port.
这些特点让docker很适合部署，管理应用。

# virtualization management tools 虚拟化管理工具
## xen的toolstack
- xend, xm
- libxl, xl. xen4.2和4.1接口不同，libvirt只支持xen4.2后的libxl，编译时确定libxl具体feature.
- libvirt

## qemu管理工具
- qemu monitor
- qemu qmp.
- libvirt

## container
- lxc, openvz...
- docker
- libvirt

##libvirt
有了自己的管理工具为什么还需要libvirt?
没daemon是件痛苦的事情。

## 居然没有virt-manager?
![virt-manager](virt-manager.jpg)

virt-manager基本是个大杂烩，虚拟机管理部分通过libvirt的API.
后面说libvirt时它有时候会出现。

## xen. qemu比较
看起来用libvirt控制xen或kvm虚拟机是一样的. 其实libvirt控制xen经常要通过hypercall到xen hypervisor. 控制qemu多数是直接和qemu进程打交道. 如果有必要qemu或通过kvm fd和kernel kvm module说话.

插播: 啥时候说kvm, 啥时候说qemu?

libvirt如果找到默认hypervisor?
由于qemu可以没有kvm运行，所以如果先load qemu，必定成功。所以要检查xen。对于xen，没有xend就是libxl， 所以要先查xend。
>     # ifdef WITH_XEN
>         xenRegister();
>     # endif # ifdef WITH_LIBXL
>         libxlRegister();
>     # endif
>     # ifdef WITH_QEMU
>         qemuRegister();
>     # endif
>     # ifdef WITH_LXC
>         lxcRegister();
>     # endif

## security
xen: stubdomain. howto
    device_model_stubdomain_override=1
it seems that should unset device_model and device_model_override

kvm: svirt. James Morris Red Hat Security Engineering

# useful libvirt command libvirt常用命令(rpc名称有所不同)
基本的管理功能，相当于对机箱说话。所以什么安装操作系统肯定是没有的。

## 开关
- define/undefine, start
- define+start=create
- destroy
- /etc/libvirt/qemu/\*.xml

define后，自己的xml就不会更新了，虚拟机xml位置：/etc/libvirt/qemu/\*.xml。建议用"virsh edit domain\_name"修改。"virsh dumpxml domain\_name"备份。

### 如何装OS?
xen/kvm/qemu: PXE, 光盘; direct kernel boot; kiwi/susestudio.
container: kiwi/susestudio.

没有网络安装？是的。对于libvirt来说其实只是direct kernel boot. TODO: 列出kernel，initrd在哪里。

### vm-install or virt-install
从SLE12, opensuse13.1开始，virt-install做为默认。vm-install在旁边的箭头里:
![vm install](virt-manager__using_vm_install.jpg "how to launch alternative OS installer")

>    software skill, network, get guest ip address, nmap; arp
>    1, nmap, ref"15:13 2012-11-22"1
>    SLES11Host:~ # nmap -sP -n 147.2.207.0/24 | grep 93 -B 1
>    Host 147.2.207.79 appears to be up.
>    MAC Address: 00:19:D1:E8:93:35 (Intel)
>    -- >    Host 147.2.207.123 appears to be up.
>    MAC Address: 52:54:00:42:54:93 (QEMU Virtual NIC)
>    --
>    Host 147.2.207.134 appears to be up.
>    MAC Address: 52:54:00:F6:C0:93 (QEMU Virtual NIC)
>    --
>    Host 147.2.207.156 appears to be up.
>    MAC Address: 00:21:70:93:B7:2D (Dell)
>    --
>    MAC Address: 78:2B:CB:7F:FD:3B (Unknown)
>    Host 147.2.207.193 appears to be up.
>
>    2, arp
>    SLES11Host:~ # arp -a | grep 93

## user interface
### serial console
### display
vnc, spice.
没有virt-manger的日子，可以用"virt-viewer domain\_name/domain\_id/domain\_uuid"看连接domain.
可以加上"-w -r"即使domain没启动或重启也不会退出。
    -w, --wait            Wait for domain to start
    -r, --reconnect       Reconnect to domain upon restart

如果是vnc, 也可以用vncviewer. 从"virsh vncdisplay"拿到5900+offset.
opensuse13.1默认用spice? vncviewer肯定没法用了，virt-viewer还是可以用的, yeah!

## storage
###文脉网(文件关系网)
backing file
snapshot
blockcommit

### storage pool
directory, lvm ...

### blockcopy

## network
bridge, nat...

## migration
migration注意事项
如果从较弱的cpu迁移到较强的cpu，没问题。反之不行，因为restore时cpu flag时dst cpu没法支持src cpu的flag.

## vcpu pin
0, # virsh help|grep vcpu
    maxvcpus                       connection vcpu maximum
    setvcpus                       change number of virtual CPUs
    vcpucount                      domain vcpu counts
    vcpuinfo                       detailed domain vcpu information
    vcpupin                        control or query domain vcpu affinity
1, vcpuinfo show per vcpu status including vcpu-pcpu relation.
>    linux-bjrd:~ # virsh vcpuinfo 3
>    VCPU:           0
>    CPU:            2
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   yyyyyyyy
>    
>    VCPU:           1
>    CPU:            1
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   yyyyyyyy
>    
>    VCPU:           2
>    CPU:            2
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   yyyyyyyy
>    
>    VCPU:           3
>    CPU:            0
>    State:          running
>    CPU time:       0.4s
>    CPU Affinity:   yyyyyyyy

2, vcpupin examples
>    # virsh vcpupin 3 0 0
>    # virsh vcpuinfo 3
>    VCPU:           0
>    CPU:            0
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   y-------
>    
>    VCPU:           1
>    CPU:            1
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   yyyyyyyy
>    
>    VCPU:           2
>    CPU:            3
>    State:          running
>    CPU time:       0.3s
>    CPU Affinity:   yyyyyyyy
>    
>    VCPU:           3
>    CPU:            0
>    State:          running
>    CPU time:       0.4s
>    CPU Affinity:   yyyyyyyy

# 虚拟化的工具说也说不完。virt-xxxx
virt-manager, virt-install/vm-install, virt-viewer, virt-ls, virt-edit, virt-filesystems, virt-clone, virt-host-validate, virt-viewer virt-convert, virt-image, virt-login-shell, virt-pki-validate, virt-xml-validate.

# virtualization packages in sle and opensuse 虚拟化有哪些repo哪些package
obs: Devel:Virt:xxxx
ibs: Virtualization:xxxx

# where is the log? log在哪里?
## debug log
### virt-manager
    virt-manager --debug
    vm-install --debug
## libvirtd
    /var/log/message
### change debug level
    # diff -urN libvirtd.conf libvirtd_debug_log.conf
    --- libvirtd.conf       2014-06-13 12:27:31.073824150 +0800
    +++ libvirtd_debug_log.conf     2014-07-14 20:55:59.936583327 +0800
    @@ -309,7 +309,7 @@

     # Logging level: 4 errors, 3 warnings, 2 information, 1 debug
     # basically 1 will log everything possible
    -#log_level = 3
    +log_level = 1

 # Logging filters:
 # A filter allows to select a different logging level for a given category

### hypervisor log
    laptop-work:/var/log/libvirt # ls */
    libxl/:
    04_sles11_sp2_02.log      05_sles11_sp3.log      libxl.log       ubuntu1210_201404.log
    04_sles11_sp2.log         libxl-driver.log       opensuse12.log
    qemu/:
    01_opensuse_13.1.log  02_opensuse_13.1.log

#### libxl
    domain log: domain_name.log
    libxl global log(except driver): libxl.log
    libxl global driver log: libxl-driver.log
#### qemu
    domain log: domain_name.log

例子
- 启动时间
    2014-07-16 14:11:06.317+0000: starting up
- 带环境变量的qemu命令行参数
    LC_ALL=C PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin QEMU_AUDIO_DRV=spice /usr/bin/qemu-system-x86_64 -name 01_opensuse_13.1 -S -machine pc-i440fx-2.1,accel=kvm,usb=off -cpu Penryn -m 1024 -realtime mlock=off -smp 1,sockets=1,cores=1,threads=1 -uuid 5d7180cb-9a70-428a-a25d-d9dadd15369d -no-user-config -nodefaults -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/01_opensuse_13.1.monitor,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc,driftfix=slew -global kvm-pit.lost_tick_policy=discard -no-hpet -no-shutdown -global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 -boot strict=on -device ich9-usb-ehci1,id=usb,bus=pci.0,addr=0x5.0x7 -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pci.0,multifunction=on,addr=0x5 -device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pci.0,addr=0x5.0x1 -device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pci.0,addr=0x5.0x2 -device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x6 -drive file=/home/bamvor/laptop/images/kvm/01_opensuse_13.1/disk0.raw,if=none,id=drive-ide0-0-0,format=raw -device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 -drive file=/home/bamvor/laptop/kiwi/JeOS_test/LimeJeOS-openSUSE-13.1.x86_64-1.13.1.iso,if=none,id=drive-ide0-0-1,readonly=on,format=raw -device ide-cd,bus=ide.0,unit=1,drive=drive-ide0-0-1,id=ide0-0-1,bootindex=1 -netdev tap,fd=22,id=hostnet0 -device rtl8139,netdev=hostnet0,id=net0,mac=52:54:00:d5:9f:3a,bus=pci.0,addr=0x3 -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -chardev spicevmc,id=charchannel0,name=vdagent -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0 -spice port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=on -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,bus=pci.0,addr=0x2 -device intel-hda,id=sound0,bus=pci.0,addr=0x4 -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 -chardev spicevmc,id=charredir0,name=usbredir -device usb-redir,chardev=charredir0,id=redir0 -chardev spicevmc,id=charredir1,name=usbredir -device usb-redir,chardev=charredir1,id=redir1 -chardev spicevmc,id=charredir2,name=usbredir -device usb-redir,chardev=charredir2,id=redir2 -chardev spicevmc,id=charredir3,name=usbredir -device usb-redir,chardev=charredir3,id=redir3 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x7 -msg timestamp=on
    ...
- 虚拟机的串口映射到物理机哪个pts设备。
    char device redirected to /dev/pts/7 (label charserial0)
    ...
- 关机时间
    2014-07-16 23:50:26.980+0000: shutting down


# 如何提供服务?
![XaaS](IaaS_PaaS_SaaS.jpg)

IaaS

PaaS: docker, openshift(redhat), cloud foundry(was Vmware).

![docker](docker.jpg "docker")
![application on openshift](application_on_openshift.jpg "application on openshift")
www.openshift.com

SaaS

# 值得一试
libvirt除了支持上面“常规”的管理功能，还有其它不是通过控制libxl，qemu，实现的功能。
## kvm data plane

![kvm io architecture](kvm_io_architecture.jpg)
from Khoa IBM[2]

![kvm io data plane](kvm_io__data_plane.jpg)
from Khoa IBM[2]
block: qemu data plane：多线程。性能regression, coroutine pool限制。
COLO: COarse-grain LOck-stepping Virtual Machine for Non-stop Service

引出coroutine。进程，线程，coroutine。

## ksm

Documentation/vm/ksm.txt
    KSM is a memory-saving de-duplication feature, enabled by CONFIG_KSM=y,
    added to the Linux kernel in 2.6.32.  See mm/ksm.c for its implementation,
    and http://lwn.net/Articles/306704/ and http://lwn.net/Articles/330589/

    KSM only merges anonymous (private) pages, never pagecache (file) pages.
    KSM's merged pages were originally locked into kernel memory, but can now
    be swapped out just like other user pages (but sharing is broken when they
    are swapped back in: ksmd must rediscover their identity and merge again).

    KSM only operates on those areas of address space which an application
    has advised to be likely candidates for merging, by using the madvise(2)
    system call: int madvise(addr, length, MADV_MERGEABLE).

### how to use
http://itxx.sinaapp.com/blog/content/122

### user experence
http://blog.chinaunix.net/uid-20794164-id-3601786.html

### Ultra KSM
http://kerneldedup.org/projects/uksm/introduction/
http://kerneldedup.org/forum/forum.php?mod=forumdisplay&fid=52

### test
>     #top
>       40 root      25   5       0      0      0 S 4.304 0.000   0:52.31 ksmd
>     4522 bamvor    20   0 2618368 120284  23768 S 2.980 2.997   1:27.31 virt-manager
>     5123 qemu      20   0 1751524 739164   6208 S 2.649 18.42   2:32.86 qemu-system-x86
>     5212 qemu      20   0 1747528 792108   8820 S 1.986 19.73   2:06.89 qemu-system-x86
>     3583 bamvor    20   0  579304 149080  48228 S 1.655 3.714   1:46.12 groupwise-bin

    #cat: /sys/kernel/mm/ksm/page_sharing
    239131

## transcendental memory
the transcendental memory implementation can try to optimize its management of the memory pools. Guests which are more active (or which have been given a higher priority) might be allowed to allocate more pages from the pools. Duplicate pages can be coalesced; KSM-like techniques could be used, but the use of object IDs could make it easier to detect duplicates in a number of situations.

lwn.net, Transcendent memory. Kindle Edition. loc. on 42-45. Accessed: 6/27/2014

## virlockd

## libguestfs design
libguestfs C library has been designed to safely and securely create access and modify vir-
tual machine disk images. It provides also additional language bindings: Perl, Python, PHP, Ruby. libguestfs can access VM disk image without
needing root and with multiple layers of defense against rogue disk images.
libguestfs has been designed for accessing and modifying virtual machine (VM) disk images.
You can use this tool for viewing and editing files inside guests, scripting changes to VMs,
monitoring disk used/free statistics, creating guests, doing V2V, performing backups, cloning
VMs, formatting disks, resizing disks.
from sles virt 12 doc 15.1.2

## VirtFS
kvm的共享文件夹，没用过。

## nested virtualization
xen
kvm

## qemu backfile
    # qemu-img create -b ../kiwi_images/openSUSE_13.1_KDE_4_desktop.x86_64-0.0.1.raw -f qcow2 disk0.qcow2
    Formatting 'disk0.qcow2', fmt=qcow2 size=1799356416 backing_file='../kiwi_images/openSUSE_13.1_KDE_4_desktop.x86_64-0.0.1.raw' encryption=off cluster_size=65536 lazy_refcounts=off

## 看看vhost-net

# libvirt编程

## 编程规范
.lvimrc
## libvirt一般会封装系统api。

# libxl编程

## IDL
IDL似乎是为了方便binding不同语言时生成不同格式的数据结构？TODO: 确认。
下面的代码说明了如何定义枚举，结构体；如何设置初始值；如何嵌套数组.
tools/libxl/libxl\_types.idl
libxl_snapshot_type = Enumeration("snapshot_type", [
(0, "ANY"),
(1, "INTERNAL"),
(2, "EXTERNAL"),
        ], init_val = "LIBXL_SNAPSHOT_TYPE_ANY")

    libxl_disk_snapshot = Struct("disk_snapshot",[
        ("device",        string),
        ("name",          string),
        ("file",          string),
        ("format",        libxl_disk_format),
        ("path",          string),
        ("type",          libxl_snapshot_type),
        ])

    libxl_domain_snapshot = Struct("domain_snapshot",[
        ("name",          string),
        ("description",   string),
        ("creation_time", uint64),
        ("memory",        string),
        ("type",          libxl_snapshot_type),
        ("running",       bool),
        ("blocked",       bool),
        ("paused",        bool),
        ("shutdown",      bool),
        ("dying",         bool),
        ("disks", Array(libxl_disk_snapshot, "num_disks")),
        ])

结果在 tools/libxl/\_libxl\_types.h/c
    typedef enum libxl_snapshot_type {
        LIBXL_SNAPSHOT_TYPE_ANY = 0,
        LIBXL_SNAPSHOT_TYPE_INTERNAL = 1,
        LIBXL_SNAPSHOT_TYPE_EXTERNAL = 2,
    } libxl_snapshot_type;
    char *libxl_snapshot_type_to_json(libxl_ctx *ctx, libxl_snapshot_type p);
    int libxl_snapshot_type_from_json(libxl_ctx *ctx, libxl_snapshot_type *p, const char *s);
    const char *libxl_snapshot_type_to_string(libxl_snapshot_type p);
    int libxl_snapshot_type_from_string(const char *s, libxl_snapshot_type *e);
    extern libxl_enum_string_table libxl_snapshot_type_string_table[];

    typedef struct libxl_disk_snapshot {
        char * device;
        char * name;
        char * file;
        libxl_disk_format format;
        char * path;
        libxl_snapshot_type type;
    } libxl_disk_snapshot;
    void libxl_disk_snapshot_dispose(libxl_disk_snapshot *p);
    void libxl_disk_snapshot_copy(libxl_ctx *ctx, libxl_disk_snapshot *dst, libxl_disk_snapshot *src);
    void libxl_disk_snapshot_init(libxl_disk_snapshot *p);
    char *libxl_disk_snapshot_to_json(libxl_ctx *ctx, libxl_disk_snapshot *p);
    int libxl_disk_snapshot_from_json(libxl_ctx *ctx, libxl_disk_snapshot *p, const char *s);

    typedef struct libxl_domain_snapshot {
        char * name;
        char * description;
        uint64_t creation_time;
        char * memory;
        libxl_snapshot_type type;
        bool running;
        bool blocked;
        bool paused;
        bool shutdown;
        bool dying;
        int num_disks;
        libxl_disk_snapshot * disks;
    } libxl_domain_snapshot;
    void libxl_domain_snapshot_dispose(libxl_domain_snapshot *p);
    void libxl_domain_snapshot_copy(libxl_ctx *ctx, libxl_domain_snapshot *dst, libxl_domain_snapshot *src);
    void libxl_domain_snapshot_init(libxl_domain_snapshot *p);
    char *libxl_domain_snapshot_to_json(libxl_ctx *ctx, libxl_domain_snapshot *p);
    int libxl_domain_snapshot_from_json(libxl_ctx *ctx, libxl_domain_snapshot *p, const char *s);

## ao
## gc

# qemu编程
## hmp
## qmp and json

# 虚拟化分模块
cpu, time/timer, interrupt, memory, device(network, block).

# memory
live migration, lazy restore

memory overcommitment

围绕cpu, timer/time, interrupt, memory, block, network, 介绍virsh和原理。

vcpu pin.


# 草稿

summay, virtualization, kernel; qemu; management tools
1, 从虚拟化技术看内核的新feature.
1), memory relative
tmem: 最开始为了xen引入.
ksm: for kvm?
huge tlb, transparent tlb.
2), pvops

2, qemu
multi data pane.

3, management tools

# reference doc
architectural comparison of virtualization technologies(vmware)
    http://wenku.it168.com/d_000439248.shtml

[1]
Copyright © 2006– 2014 SUSE LLC and contributors. All rights reserved.
Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation
License, Version 1.2 or (at your option) version 1.3; with the Invariant Section being this copyright notice and license.
A copy of the license version 1.2 is included in the section entitled “GNU Free Documentation License”.

[2] Khoa IBM
license UNKNOWN
it is from LINUXCON2013 CloudOpen. the license should be ok.
Exploiting The Latest KVM Features For Optimized virtualized Enterprise Storage Performance  CloudOpen2013 Khoa Huynh v3.pdf

[3] suse doc
https://www.suse.com/de-de/documentation/sles11/

