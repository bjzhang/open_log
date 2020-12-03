
# 问题背景
愿意RTT RV64 port基于hack的qemu，调试和使用Linux kernel很不方便。所以基于upstrem qemu工作，修改RTT地址后，仍然有问题.

# 复线步骤
1.  启动qemu
qemu加gdb调试选项启动 `./scripts/boot.sh -s -S`

2.  启动gdb
gdb配置文件
```
bamvor@bamvor-PC:~/works/source2/rt-thread/bsp/riscv64-virt$ cat rtt.gdbinit
target remote :1234
add-symbol-file /home/bamvor/works/source2/rt-thread/bsp/riscv64-virt/rtthread.elf
break switch_pgdir
```
启动gdb（连接qemu并设置断点`switch_pgdir`:
`riscv64-unknown-elf-gdb -x  rtt.gdbinit`

3.  Linux启动RTT
`echo 1 > /sys/devices/system/cpu/cpu1/online`

4.  查看, pgdir是非法的0x1xxxxxxx地址
```
Thread 2 hit Breakpoint 1, switch_pgdir (pgdir=295698432) at driver/vm.c:90
90      void switch_pgdir(unsigned long pgdir) {
(gdb) x/w pgdir
0x11a00000:     Cannot access memory at address 0x11a00000
(gdb)
```
已经把能找到的原有0x10000000开始的地址都修改：
```
driver/board.h:#define RT_HW_HEAP_BEGIN    (void*)(0x90200000UL + 12 * 1024 * 1024) // about 12M above the kernel load address
driver/board.h:#define RT_HW_HEAP_END      (void*)(0x90200000UL + 20 * 1024 * 1024) // 8M in total
driver/board.c:#define PGDIR_PA (0x90200000UL + 24 * 1024 * 1024)
driver/vm.c:#define PGDIR_PA (0x90200000UL + 24 * 1024 * 1024) // 4MB above heap top
link.lds:   SRAM : ORIGIN = 0x90200000, LENGTH = 0x7FF000
link.lds:    . = 0x90200000 ;
pgtable.h:#define BOOT_PADDR 0x90200000
pgtable.h:#define BOOT_VADDR 0x90200000
```
可以从pgdir来源分析下，看看问题原因。

