
# 
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
看起来用libvirt控制xen或kvm虚拟机是一样的. 其实libvirt控制xen经常要通过hypercall到xen hypervisor. 控制qemu多数是直接和qemu进程打交道. 如果有必要qemu或通过kvm fd和kernel kvm module说话.

