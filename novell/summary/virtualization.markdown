
# 虚拟化技术比较
xen, kvm/qemu, container(why not lxc?).
hypervisor位置：xen在kernel下面。
kvm是ko. lxc利用了内kernel cgroup, namespace.


![xen框图](tmux.jpg)
from sle12 document(Virtualization Guide SUSE Linux Enterprise Server 12)

缺kvm arch.

![kvm io architecture](kvm_io_architecture.jpg)
from Khoa IBM[2]

![kvm io data plane](kvm_io__data_plane.jpg)
from Khoa IBM[2]

## xen的toolstack
xend, xm.
libxl, xl.
libvirt.

## qemu管理工具
qemu monitor, qemu qmp.
libvirt.
插播啥时候说kvm, 啥时候说qemu?

## xen. qemu比较
看起来用libvirt控制xen或kvm虚拟机是一样的. 其实libvirt控制xen经常要通过hypercall到xen hypervisor. 控制qemu多数是直接和qemu进程打交道. 如果有必要qemu或通过kvm fd和kernel kvm module说话.

## security
xen: stubdomain. howto
    device_model_stubdomain_override=1
it seems that should unset device_model and device_model_override

kvm: svirt. James Morris Red Hat Security Engineering

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


由于qemu可以没有kvm运行，所以如果先load qemu，必定成功。所以要检查xen。对于xen，没有xend就是libxl， 所以要先查xend。
# ifdef WITH_XEN
    xenRegister();
# endif
# ifdef WITH_LIBXL
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

# libvirt编程

.lvimrc

libvirt一般会封装系统api。

# libxl编程
ao
gc

# 虚拟化分模块
cpu, time/timer, interrupt, memory, device(network, block).

# memory
live migration, lazy restore 

memory overcommitment

围绕cpu, timer/time, interrupt, memory, block, network, 介绍virsh和原理。

vcpu pin.

block: qemu data plane：多线程。性能regression, coroutine pool限制。

引出coroutine。进程，线程，coroutine。

[1]
Copyright © 2006– 2014 SUSE LLC and contributors. All rights reserved.
Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation
License, Version 1.2 or (at your option) version 1.3; with the Invariant Section being this copyright notice and license.
A copy of the license version 1.2 is included in the section entitled “GNU Free Documentation License”.

[2] Khoa IBM
license UNKNOWN
it is from LINUXCON2013 CloudOpen. the license should be ok.
Exploiting The Latest KVM Features For Optimized virtualized Enterprise Storage Performance  CloudOpen2013 Khoa Huynh v3.pdf

