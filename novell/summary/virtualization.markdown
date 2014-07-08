
# 虚拟化技术比较
xen, kvm/qemu, container(why not lxc?).
hypervisor位置：xen在kernel下面。
kvm是ko. lxc利用了内kernel cgroup, namespace.

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
