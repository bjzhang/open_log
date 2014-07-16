
估计我写的内容80%大家都知道。基本这个文档就是笔记，像virt-manager大家常用软件我就不说了。

# different virtualization technologies 虚拟化技术比较
xen, kvm/qemu, container(lxc, openvz...), vmware.
hypervisor位置：xen在kernel下面。
kvm是ko. lxc利用了内kernel cgroup, namespace.

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
container没法换kernel; 记得要export port.

docker支持libcontainer, libxc, openvz等container技术，从1.0开始，默认使用自己的libcontainer(go语言).
docker有版本管理功能。
docker有自己的build系统，可以继承已有的image。
docker可以用dockerfile实现自动build。
这些特点让docker很适合部署，管理应用。

# virtualization management tools 虚拟化管理工具
## xen的toolstack xend, xm.  libxl, xl.
libvirt

## qemu管理工具
qemu monitor, qemu qmp.
libvirt

## container
lxc, openvz...
docker
libvirt

##libvirt
有了自己的管理工具为什么还需要libvirt?
没daemon是件痛苦的事情。

## 居然没有virt-manager?
![virt-manager](virt-manager.jpg)

virt-manager基本是个大杂烩，虚拟机管理部分通过libvirt的API.
后面说libvirt时它有时候会出现。

ps: 我都要走了，我才第一次用了screen shot的delay功能。。。

## xen. qemu比较
看起来用libvirt控制xen或kvm虚拟机是一样的. 其实libvirt控制xen经常要通过hypercall到xen hypervisor. 控制qemu多数是直接和qemu进程打交道. 如果有必要qemu或通过kvm fd和kernel kvm module说话.

插播: 啥时候说kvm, 啥时候说qemu?

libvirt如果找到默认hypervisor?
由于qemu可以没有kvm运行，所以如果先load qemu，必定成功。所以要检查xen。对于xen，没有xend就是libxl， 所以要先查xend。
    # ifdef WITH_XEN
        xenRegister();
    # endif # ifdef WITH_LIBXL
        libxlRegister();
    # endif
    # ifdef WITH_QEMU
        qemuRegister();
    # endif
    # ifdef WITH_LXC
        lxcRegister();
    # endif
    # ifdef WITH_UML
        umlRegister();
    # endif
    # ifdef WITH_VBOX
        vboxRegister();
    # endif
    # ifdef WITH_BHYVE
        bhyveRegister();
    # endif


## security
xen: stubdomain. howto
    device_model_stubdomain_override=1
it seems that should unset device_model and device_model_override

kvm: svirt. James Morris Red Hat Security Engineering

# useful libvirt command libvirt常用命令(rpc名称有所不同)
基本的管理功能，相当于对机箱说话。所以什么安装操作系统肯定是没有的。

## 开关
define/undefine, start
define+start=create
destroy

### 如何装OS?
xen/kvm/qemu: PXE, 光盘; direct kernel boot; kiwi/susestudio.
container: kiwi/susestudio.

没有网络安装？是的。对于libvirt来说其实只是direct kernel boot. TODO: 列出kernel，initrd在哪里。

### vm-install or virt-install
从SLE12, opensuse13.1开始，virt-install做为默认。vm-install在旁边的箭头里:
![vm install](virt-manager__using_vm_install.jpg "how to launch alternative OS installer")


## user interface
### serial console
### display
vnc, spice.
没有virt-manger的日子，可以用"virt-viewer domain\_name/domain\_id/domain\_uuid"看连接domain.
可以加上"-w -r"即使domain没启动或重启也不会退出。
    -w, --wait            Wait for domain to start
    -r, --reconnect       Reconnect to domain upon restart

如果是vnc, 也可以用vncviewer. 从"virsh vncdisplay"拿到5900+offset.
opensuse13.1默认用spice?

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
16:22 2014-07-08
linux-bjrd:~ # virsh vcpuinfo 3
VCPU:           0
CPU:            2
State:          running
CPU time:       0.3s
CPU Affinity:   yyyyyyyy

VCPU:           1
CPU:            1
State:          running
CPU time:       0.3s
CPU Affinity:   yyyyyyyy

VCPU:           2
CPU:            2
State:          running
CPU time:       0.3s
CPU Affinity:   yyyyyyyy

VCPU:           3
CPU:            0
State:          running
CPU time:       0.4s
CPU Affinity:   yyyyyyyy

linux-bjrd:~ # cat /proc/cpuinfo | less
linux-bjrd:~ # virsh help|grep vcpu
    maxvcpus                       connection vcpu maximum
    setvcpus                       change number of virtual CPUs
    vcpucount                      domain vcpu counts
    vcpuinfo                       detailed domain vcpu information
    vcpupin                        control or query domain vcpu affinity
linux-bjrd:~ # virsh vcpupin 3 0 0

linux-bjrd:~ # virsh vcpuinfo 3
VCPU:           0
CPU:            0
State:          running
CPU time:       0.3s
CPU Affinity:   y-------

VCPU:           1
CPU:            1
State:          running
CPU time:       0.3s
CPU Affinity:   yyyyyyyy

VCPU:           2
CPU:            3
State:          running
CPU time:       0.3s
CPU Affinity:   yyyyyyyy

VCPU:           3
CPU:            0
State:          running
CPU time:       0.4s
CPU Affinity:   yyyyyyyy

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

