
22:34 2016-01-01
----------------
try estuary
[estuary 2.1 releases notes](http://open-estuary.org/estuary-v2-1/)

1.  install repo
ref <https://source.android.com/source/downloading.html>
    ```
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    ```

2.  install and build estuary for hikey.
    ```
    mkdir ~/work/open-estuary
    cd ~/work/open-estuary
    repo init -u https://github.com/open-estuary/estuary.git
    repo sync
    cd estuary
    ./build.sh -p HiKey -d Ubuntu
    ```

17:30 2016-01-07
----------------
Meeting with Mark
-----------------
1.  do not send activity recently.
2.  pending: y2038: ppdev and printer.
3.  pending: gpio: fix warning.
4.  pending: gpio: mockup.
5.  about THP in glibc. Mark suggest that:
    1.  Ask Ryan Arnold(team leader of Ryan).
    2.  Steve Capper(LEG). kernel guy. Familiar with THP and memory things.

21:23 2016-01-18
----------------
1.  [ACTIVITY] (Bamvor Jian Zhang) 2016-01-11 to 2016-01-18
= Bamvor Jian Zhang=

=== Highlights ===
* Y2038
    - Send new version of parport device to LKML.

* 1:1 with Mark.

* GPIO:
    Try to re-write the gpiochip_add_to_list according to the suggestion
    from arnd.

* GPIO kselftest:
    Address the comment from maintainer.
    Re-write the gpio test script in c language.

* Kselftest improvement
    Support KBUILD_OUTPUT for kselftest
        There is no reply in LKML. Maybe I do not ask the right question.
        Will investigate it later.

=== Plans ===
* GPIO kselftest
Send out the new version of gpio mockup driver and testcases.

16:45 2016-01-24
----------------
Hi, Linux

I am re-writing the test in c language. When I do it, I found that the
script in c language is longer that bash script. What I do is as
follows:
1.  gpio-mockup.h
    1.  struct gpio_chip: define gpio_chip information for sysfs and
        chardev. It is *different* from such definition in kernel.
    2.  struct gpio_device: define function and value used by sysfs
        and chardev include the array of struct gpio_chip. Such array
        include information of gpio_chip attach to this gpio_device.

2.  gpio-mockup.c: main function with test framework and common
functions share with sysfs and chardev, user could select which
interface is used. Chardev will be default after it uptream. This file
includes:
    1.  struct gpio_testcase: testcases for testing.
    2.  main function for gpio test.
    3.  pin_get_debugfs: read pin status from debugfs which is used
        by both sysfs and chardev.

3.  gpio-mockup-sysfs.c: define and implement the function and
    variable defined by struct gpio_device.

4.  gpio-mockup-chardev.c: define and implement the function and
    variable defined by struct gpio_device.
    I do not if the utils of chardev(located in tools) will be a
    libray, if so, I could make use of the code to avoid duplicated
    code.

At the same time, I am thinking If I should wrote the test script in
shell and call the util of gpio chardev in the script.

Which one do you prefer?
1.  Full c languarges.
2.  Script for framework and sysfs, calling utils for chardev.

Regards

Bamvor

16:42 2016-01-25
----------------

> cat test.sh
#!/bin/bash

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8
killall qemu-system-aarch64
/home/z00293696/works/software/distribution/opensuse/13.1/boot.sh >> log_1531
make -C /home/z00293696/works/reference/code_collection/kernel_module_hello ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
while true; do
	scp -p /home/z00293696/works/reference/code_collection/kernel_module_hello/hello.ko root@qarm64:/root/ && break || sleep 1
done
ssh root@qarm64 'insmod /root/hello.ko'
if [ X$? != X0 ]; then
	#CAUTION: do not use 125 which mean untestable for 'git bisect'
	status=127
fi
ssh root@qarm64 'poweroff'
make -C /home/z00293696/works/reference/code_collection/kernel_module_hello ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean

exit $status

git bisect start hulk-4.1-bad hulk-4.1-good --
git bisect run `realpath test.sh`

17:41 2016-01-27
----------------
Hi, Linus

I am using this interface to do my gpio mockup test. I need to list
all the gpiochips attach to one gpio driver(aka gpio-mockup, there may
be more than one gpio drivers in the system). And then test some of the
pin of each gpio_chip.

From the api(ioctl GPIO_GET_CHIPINFO_IOCTL: gpiochip_info), it seems
that I could list all the gpiochips or list only one gpiochip. But
I could not list gpiochip belongs to one gpio driver.

Do I understand correctly?
Will we add a new api to do it?

Regards

Bamvor

19:07 2016-01-27
----------------
1.  gpio mockup
2.  ilp32
3.  lp.c pending
4.  kmerge config

18:11 2016-01-29
----------------
kernel, gpio, gpio-mockup
-------------------------
> I think you can get that information from parsing sysfs?
Yeap, I could get the directory:
"/sys/devices/platform/gpio-mockup/gpio/"

I notice that you mark the sysfs ABI as obsolete in these series. I
am not sure whether it is reasonable to read it from syfs when using
chardev.

11:27 2016-02-02
----------------
ilp32
-----
1.  kernel syscalls:
    1.  the base is include/uapi/asm-generic/unistd.h, it may support normal and optional compat syscall as follows `__SYSCALL(__NR_openat, sys_openat)`, `SC_COMP(__NR_openat, sys_openat, compat_sys_openat)`
        architecture could define it own unistd.h or overwrite the definition in it.
        E.g. for define the following two syscall as compat syscall.
        #define sys_openat             compat_sys_openat
        #define sys_open_by_handle_at  compat_sys_open_by_handle_at

2.  syscall wrapper
```
+/*
+ * The SYSCALL_DEFINE_WRAP macro generates system call wrappers to be used by
+ * compat tasks. These wrappers will only be used for system calls where only
+ * the system call arguments need sign or zero extension or zeroing of upper
+ * bits of pointers.
+ * Note: since the wrapper function will afterwards call a system call which
+ * again performs zero and sign extension for all system call arguments with
+ * a size of less than eight bytes, these compat wrappers only touch those
+ * system call arguments with a size of eight bytes ((unsigned) long and
+ * pointers). Zero and sign extension for e.g. int parameters will be done by
+ * the regular system call wrappers.
```

2.  TODO
    1.  cond_syscall
    2.  tls register
        ref: "d00a381 arm64: context-switch user tls register tpidr_el0 for compat tasks"
        change from int to unsigned long in commit "3033f14a" (clone: support passing tls argument via C rather than pt_regs magic). It seems that it is a big reason to do it!

3.  usefull: 
    1.  BUILD_BUG_ON
    2.  the stackop of compat mode in arm64 is AARCH32_VECTORS_BASE(0xffff0000).
        in arm (32bit) 3G:1G kernel, it is PAGE_OFFSET(0xc0000000) - 16M
    3.  how to access the compat register from native task.
        5d220ff arm64: Better native ptrace support for compat tasks


