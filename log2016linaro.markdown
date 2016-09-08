
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

18:08 2016-02-03
----------------
1.  cover letter
Add gpio test framework

These series of patches try to add support for testing of gpio
subsystem based on the proposal from Linus Walleij. The first version
is here[1].

The basic idea is implement a virtual gpio device(gpio-mockup) base
on gpiolib. Tester could test the gpiolib by manipulating gpio-mockup
device through sysfs or char device and check the result from debugfs.
Reference the following figure:

   sysfs/char device  debugfs
     |                   |
  gpiolib----------------/
     |
 gpio-mockup

Currently, this test script will use sysfs interface by default. I
plan set char device as default after it upstreamed.

In order to avoid conflict with other gpio exist in the system,
only dynamic allocation is tested by default. User could pass -f to
do full test.

[1] http://comments.gmane.org/gmane.linux.kernel.gpio/11883

Changes since v1:
1.  Change value of gpio to boolean.
2.  Only test dynamic allocation by default.

2.  send them out:
`git send-email --no-chain-reply-to --annotate --to linux-gpio@vger.kernel.org --cc linus.walleij@linaro.org --cc broonie@kernel.org *.patch`

20:27 2016-02-03
----------------
hikey, kernel, upstream
-----------------------
hikey upstream discussion between Guodong and Mark.
```
On Wed, Feb 03, 2016 at 03:52:09PM +0800, Guodong Xu wrote:

> As of v4.4, already upstreamed:

> - clk, psci, basic dts, uart, cpufreq, cpuidle, mailbox, emmc, wifi driver
> fix, and tsensor (thermal)

Of these only the clock, PSCI and the UART appear to be included in the
DTS.  If a feature is not enabled in the DTS most people would not
understand it as being supported upstream for the board since there is
no way for someone to actually use any of these features if they use
mainline.

> - hikey can boot using vanilla v4.4 kernel and defconfig.

It can boot to serial console with a ramdisk, nothing else.  There is a
serious discrepency between the features you are reporting as supported
upstream and the features that are actually supported upstream, the set
supported upstream is has not changed substantially since merge.

> v4.5-rc1:

> USB: driver, 37dd9d6 usb: dwc2: add support of hi6220.

Again, this does not appear in the DT and is therefore unusable for
anyone using mainline.

> Slated for v4.6 merge-window:

> hisi-reset driver: in linux-next ( http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/drivers/reset/hisilicon?h=next-20160129
> )

This seems to already be in Linus' tree so unless some major problem is
discovered it should be in v4.5.

> DTS: in maintainer's git repo: <https://github.com/hisilicon/linux-hisi>
>
> - Including: gpio, pinctrl, i2c

This does not appear to be part of the kernel development process, it
does not appear in -next and I can't see any prior cases where a pull
request from this tree has made it into -next.  I don't see that there
is any reasonable expectation that anything there will make it into
mainline.

Like I said above there is a big difference between what you are
reporting as upstream and the features that are practically usable
upstream.  This is creating a lot of frustration on the part of
potential users who want to work on mainline, both with the lack of
features itself and with the fact that lists of supported features are
typically substantially inaccurate which makes people feel they are
being mislead.
```

16:50 2016-02-19
----------------
gpio, mockup
------------
```
<1>[  163.503994] Unable to handle kernel NULL pointer dereference at virtual address 0000007c
<1>[  163.504305] pgd = ffffffc0759df000
<1>[  163.504482] [0000007c] *pgd=00000000b5a20003, *pud=00000000b5a20003, *pmd=0000000000000000
<0>[  163.510154] Internal error: Oops: 94000006 [#1] PREEMPT SMP
<4>[  163.510399] Modules linked in: gpio_mockup(-) [last unloaded: gpio_mockup]
<4>[  163.510841] CPU: 0 PID: 1963 Comm: rmmod Not tainted 4.5.0-rc4+ #3
<4>[  163.511033] Hardware name: linux,dummy-virt (DT)
<4>[  163.511232] task: ffffffc077eb4800 ti: ffffffc07740c000 task.ti: ffffffc07740c000
<4>[  163.511761] PC is at gpiochip_sysfs_unregister+0x44/0xa4
<4>[  163.511944] LR is at gpiochip_sysfs_unregister+0x44/0xa4
<4>[  163.512104] pc : [<ffffffc0003719a0>] lr : [<ffffffc0003719a0>] pstate: 20000145
<4>[  163.512315] sp : ffffffc07740fcf0
<4>[  163.512438] x29: ffffffc07740fcf0 x28: ffffffc07740c000
<4>[  163.512667] x27: ffffffc0006db000 x26: 000000000000006a
<4>[  163.512977] x25: 000000000000011e x24: 0000000000000015
<4>[  163.513161] x23: 0000000000000000 x22: 0000000000000000
<4>[  163.513361] x21: ffffffc07869b000 x20: ffffffc07772c018
<4>[  163.513563] x19: ffffffc000aa5d90 x18: 0000000000000001
<4>[  163.513739] x17: 0000007fb56987d0 x16: ffffffc00011cd44
<4>[  163.513916] x15: 0000007fb55d0ce8 x14: ffffffffffffffff
<4>[  163.514092] x13: ffffffffffffffff x12: 0000000000000000
<4>[  163.514277] x11: 0000000000000000 x10: 0000000000000840
<4>[  163.514504] x9 : 0000000040000000 x8 : ffffffc0759fb6a8
<4>[  163.514685] x7 : ffffffc0759fbe28 x6 : 0000000000210d00
<4>[  163.514861] x5 : 0000000000000019 x4 : 0000000000000001
<4>[  163.515035] x3 : 0000000000000000 x2 : 0000000000000001
<4>[  163.515210] x1 : 0000000000000000 x0 : ffffffc000aa5d90
<4>[  163.515387]
<0>[  163.515475] Process rmmod (pid: 1963, stack limit = 0xffffffc07740c020)
<0>[  163.515724] Stack: (0xffffffc07740fcf0 to 0xffffffc077410000)
<0>[  163.516027] fce0:                                   ffffffc07740fd20 ffffffc00036f6a0
<0>[  163.516290] fd00: 0000000000000001 ffffffc07772c018 ffffffc07869b000 ffffffc07772c018
<0>[  163.516565] fd20: ffffffc07740fd50 ffffffbffc00f0a4 0000000000000001 ffffffbffc00f880
<0>[  163.516952] fd40: 0000000000000130 ffffffc07772c018 ffffffc07740fd80 ffffffc00042b4b4
<0>[  163.517205] fd60: ffffffc077787410 ffffffbffc00f4a0 ffffffc077787470 ffffffc000b10000
<0>[  163.517447] fd80: ffffffc07740fda0 ffffffc000429cc8 ffffffc077787410 ffffffbffc00f4a0
<0>[  163.517690] fda0: ffffffc07740fdc0 ffffffc000429e54 ffffffc077787410 ffffffbffc00f4a0
<0>[  163.517933] fdc0: ffffffc07740fdf0 ffffffc000429014 ffffffbffc00f4a0 ffffffc000ab6000
<0>[  163.518177] fde0: ffffffc000ab63c0 ffffffc000000001 ffffffc07740fe20 ffffffc00042a4cc
<0>[  163.518419] fe00: ffffffbffc00f4a0 ffffffbffc00f580 fffffffffffffff5 0000000000000000
<0>[  163.518662] fe20: ffffffc07740fe40 ffffffc00042b5c0 ffffffc000a88000 0000000000000015
<0>[  163.518903] fe40: ffffffc07740fe50 ffffffbffc00f340 ffffffc07740fe60 ffffffc00011cefc
<0>[  163.519146] fe60: 0000000000000000 ffffffc000085d8c 0000000000000200 0000000000000000
<0>[  163.519390] fe80: ffffffffffffffff 0000007fb56987d8 ffffffc07740fed0 636f6d5f6f697067
<0>[  163.519631] fea0: 000000000070756b ffffffc000085d5c 0000000000000200 0000000000000000
<0>[  163.519873] fec0: ffffffffffffffff 0000007fb56987d8 0000000016c40248 0000000000000800
<0>[  163.520112] fee0: 315df3e97fc66f00 0000007fcefc3139 0000007fb572f2c8 0000007fb559f6f0
<0>[  163.520352] ff00: fefefefeff6f746a 0000000000000000 000000000000006a 0000000000000000
<0>[  163.520592] ff20: 000000000000000a 0000000000000005 ffffffffffffffff 0000007fb55df7f8
<0>[  163.521024] ff40: 0000007fb57bc000 0000007fb55d0ce8 0000000000432fc8 0000007fb56987d0
<0>[  163.521282] ff60: 0000000000000001 0000000016c401e0 0000000000000000 0000007fcefc4878
<0>[  163.521524] ff80: 0000000000000000 0000000016c401e0 0000007fcefc4418 0000000016c3f010
<0>[  163.521763] ffa0: 0000000000000000 0000000000000000 0000000000417000 0000007fcefc4190
<0>[  163.522004] ffc0: 0000000000411d30 0000007fcefc4190 0000007fb56987d8 0000000000000000
<0>[  163.522246] ffe0: 0000000016c40248 000000000000006a 0000000000000000 0000000000000000
<4>[  163.522554] Call trace:
<4>[  163.522705] Exception stack(0xffffffc07740fb30 to 0xffffffc07740fc50)
<4>[  163.522911] fb20:                                   ffffffc000aa5d90 ffffffc07772c018
<4>[  163.523153] fb40: ffffffc07740fcf0 ffffffc0003719a0 ffffffc0006db000 ffffffc07740c000
<4>[  163.523395] fb60: ffffffc07740c000 ffffffc07740c000 ffffffc077401400 ffffffc07740c000
<4>[  163.523636] fb80: 000000017740fbf0 ffffffc077401400 ffffffc077401300 0000000180100007
<4>[  163.523878] fba0: ffffffc0009027d8 ffffffc07869b008 ffffffc07740fc00 0000000180200019
<4>[  163.524119] fbc0: ffffffc077401300 ffffffc000ab6398 ffffffc000aa5d90 0000000000000000
<4>[  163.524360] fbe0: 0000000000000001 0000000000000000 0000000000000001 0000000000000019
<4>[  163.524601] fc00: 0000000000210d00 ffffffc0759fbe28 ffffffc0759fb6a8 0000000040000000
<4>[  163.524937] fc20: 0000000000000840 0000000000000000 0000000000000000 ffffffffffffffff
<4>[  163.525183] fc40: ffffffffffffffff 0000007fb55d0ce8
<4>[  163.525394] [<ffffffc0003719a0>] gpiochip_sysfs_unregister+0x44/0xa4
<4>[  163.525611] [<ffffffc00036f6a0>] gpiochip_remove+0x24/0x154
<4>[  163.525861] [<ffffffbffc00f0a4>] mockup_gpio_remove+0x38/0x64 [gpio_mockup]
<4>[  163.526101] [<ffffffc00042b4b4>] platform_drv_remove+0x24/0x64
<4>[  163.526313] [<ffffffc000429cc8>] __device_release_driver+0x7c/0xfc
<4>[  163.526525] [<ffffffc000429e54>] driver_detach+0xbc/0xc0
<4>[  163.526700] [<ffffffc000429014>] bus_remove_driver+0x58/0xac
<4>[  163.526883] [<ffffffc00042a4cc>] driver_unregister+0x2c/0x4c
<4>[  163.527067] [<ffffffc00042b5c0>] platform_driver_unregister+0x10/0x18
<4>[  163.527284] [<ffffffbffc00f340>] mock_device_exit+0x10/0x38 [gpio_mockup]
<4>[  163.527593] [<ffffffc00011cefc>] SyS_delete_module+0x1b8/0x1fc
<4>[  163.527799] [<ffffffc000085d8c>] __sys_trace_return+0x0/0x4
<0>[  163.528049] Code: 940d74b4 f9019abf aa1303e0 940d7439 (7940fac0)
<4>[  163.536273] ---[ end trace 3d1329be504af609 ]---
```

21:02 2016-02-20
----------------
1.  change gpiochip path from
"/sys/devices/platform/gpio-mockup/gpio/gpiochip*"
to
"/sys/devices/platform/gpio-mockup/gpiochip*"

09:45 2016-02-27
----------------
kernel, gpio
------------
1.  Reply to Mark
```
Hi, Mark

>On Fri, Feb 26, 2016 at 09:06:14PM +0800, Bamvor Jian Zhang wrote:
>
>> --- a/drivers/gpio/gpiolib.c
>> +++ b/drivers/gpio/gpiolib.c
>> @@ -452,7 +452,6 @@ static void gpiodevice_release(struct device *dev)
>>  {
>>       struct gpio_device *gdev = dev_get_drvdata(dev);
>>
>> -     cdev_del(&gdev->chrdev);
>
>This seems weird - we're moving the deletion of the chardev (which is
>the route userspace has to opening the device) later which seems like it
>isn't relevant to the issue and is likely to create problems since it
>means userspace can start to try to use the device while we're in the
>process of trying to tear it down.  If this is needed it should probably
>be explicitly discussed in the changelog, it may be worth splitting into
>a separate patch.
>
>> @@ -633,7 +632,6 @@ int gpiochip_add_data(struct gpio_chip *chip, void *data)
>>
>>       /* From this point, the .release() function cleans up gpio_device */
>>       gdev->dev.release = gpiodevice_release;
>> -     get_device(&gdev->dev);
>>       pr_debug("%s: registered GPIOs %d to %d on device: %s (%s)\n",
>>                __func__, gdev->base, gdev->base + gdev->ngpio - 1,
>>                dev_name(&gdev->dev), chip->label ? : "generic");
>
>> +     device_del(&gdev->dev);
>
>We're removing a get but adding a delete?  Again this is surprising,
>explicitly saying what took the reference we're going to delete would
>probably make this a lot clearer.
>
>In general I'd say your changelog for a change like this should be in
>the form of "When $THING happens $PROBLEM occurs because $REASON,
>instead do $FIX which avoids that because $REASON".
As you said, the commit message is not clear enough to know what is
going on here. Try this one:

When gpiochip_remove is called the gpiochips is not removed because
the refcount is not going down to zero.

The issue I found is that after gpiochip_remove, the gpipchio is not
remove(in dangling state), the reference count in
gdev(gdev->dev->kobj->kref->refcount.count) is 4. So, my first thought
is that where the reference count came from.
On gpiochip_add_data:
refcount    after this function
1           device_initialize(&gdev->dev);
2           status = cdev_add(&gdev->chrdev, gdev->dev.devt, 1);
4           status = device_add(&gdev->dev);
5           get_device(&gdev->dev);
Notes: "gdev->chrdev.kobj.parent" is "&gdev->dev.kobj;"

On gpiochip_remove:
refcount    after this function
4           put_device(&gdev->dev);

And I also check the other code in which chardev is the children of
the device. I found that the flows of add and remove are(e.g.
evdev.c):
Add(e.g. evdev_connect):
device_initialize();
cdev_add();
device_add();

Remove(e.g. evdev_disconnect):
device_del();
cdev_del();
put_device();

If I change the flows in gpiochip_add_data and gpiochip_remove like
above. The gpiochip could be removed in the put_device. But it seems
that it conflict with the comment before put_device:
/*
 * The gpiochip side puts its use of the device to rest here:
 * if there are no userspace clients, the chardev and device will
 * be removed, else it will be dangling until the last user is
 * gone.
 */

So, I feel that maybe I do not fix root issue. Hope I could learn/
help.

Regards

Bamvor

```

17:29 2016-02-27
----------------
1.  gic_handle_irq->generic_handle_irq->handle_edge_irq/handle_fasteoi_irq->handle_irq_event->action->handler()
desc->handler is set by irq_set_handler_locked or irq_set_chip_handler_name_locked

gpiochip_set_chained_irqchip->

irq_chip->irq_set_type will set desc->handler: handle_edge_irq, handle_level_irq, handle_fasteoi_irq. All of them will call handle_irq_event and consequently action->handler()

typedef irqreturn_t (*irq_handler_t)(int, void *);

desc->handle_irq.

18:14 2016-02-29
----------------
kwg, activity
-------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-02-17 to 2016-02-29
= Bamvor Jian Zhang=

=== Highlights ===
* GPIO:
    Send 3 patch(need further discussion) for gpio core while rebasing my gpio-mockup driver.
    Send v2 patch: rewrite-gpiodev-add-to-list.

* Discuss my work with Mark.

* ARM32 meeting.
    - update document: add the source code of kernel for Hip05/D02, kirin 935/950.

* Discuss my work with Mark.

=== Plans ===
* Improve the gpio-mockup driver and sent out new verison.

17:33 2016-03-05
-----------------
1.  try to boot qemu-system-arm on my chromebook. But systemd said that dev.ttyAMA0 failed.
    add "rw" in cmdline, try it again. it do not works, the message is(still):
```
[ TIME ] Timed out waiting for device dev-ttyAMA0.device.
[DEPEND] Dependency failed for Serial Getty on ttyAMA0.
```
I had to connect to qemu through ssh, here is my current qemu parameters:
```
qemu-system-arm -M vexpress-a9 -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb --nographic -append "console=ttyAMA0 root=/dev/vda2 rw" -drive if=none,file=/var/host/media/removable/works/downloads/openSUSE-Tumbleweed-ARM-JeOS-vexpress.armv7l-1.12.1-Build375.1.raw,id=hd0 -device virtio-blk-device,drive=hd0 -device virtio-net-device,vlan=0,id=net0,mac=52:54:00:09:a4:37 -net user,vlan=0,name=hostnet0,hostfwd=tcp::2222-:22
```

11:43 2016-03-05
-----------------
kernel, LOCALVERION
--------------------
1.  CONFIG_LOCALVERSION: append a string to kernel version.
2.  CONFIG_LOCALVERSION_AUTO set localversion as first eight character of git commit id which is generated by "`git rev-parse --verify HEAD`".
3.  Do we use it in huawei?

21:18 2016-03-05
-----------------
kernel, kirin
-------------
<http://download-c.huawei.com/download/downloadCenter?downloadId=69166&version=240582&siteCode=cn>
There is not git tree at the monment. 935(http://emui.huawei.com/en/plugin.php?id=hwdownload&mod=detail&mid=90), 950(http://download-c.huawei.com/download/downloadCenter?downloadId=69166&version=240582&siteCode=cn)

09:32 2016-03-07
----------------
linaro, connect, notes
----------------------
1. the display for CE edition.
2. official anncounce hikey AOSP support.
2. 96board de mudi shi tigong yige jichu de qidian, bimian chongfu gongzuo.
4. IoT reference board will annourcen late this year.
5. 16.03 RPB kernel.
   unified kernel tree for CE and EE builds
6. Linaro developer cloud (arm device).
   in china, q2, q3 in this year.
7.  demo(two of demos base on hikey).
    1. lemaker: display board for 96boards(CE)
    2. VR demo(hikey 2G version).
    3. AMD ee board: ca57, acpi, usb3.0....
      1.  huskyboard(from cuircuitco) demo.
      2.  lemaker cello 299$. preorder. 
           openstack demo.
           bkkcloud.linaro.org/owncloud

8.  arm research:
    From sensors to Supercomputer Big Data Begins with Little Data.
    Focus on HPC at this time.
     focus on memory and interconnect; architecture and lots of area,
     IoT generate Big Data.

10:33 2016-03-07
----------------
discuss about ILP32 with Mark, Arnd.
1.  The progress really depend on the dicussion of ilp32.
2.  opensuse could not support aarch32, aarch64 ilp32, aarch64 lp64 at the same time because of the limitation of rpm package.
    deb package do not have this issue.
3.  Mark suggest me that send email to catalin about the ilp32.
Hi, Catalin

This is bamvor from linaro kwg(Huawei assignee). Glad to see lots of discussion in LKML in recent months. It seems that the community get generally agreement about the abi. Huawei wants to use ILP32 in the production environment in the near future after the ILP32 is ready. 

So, what is the blocker of getting ilp32 upstream(kernel part)?
IIUC, there are three things being discussed, please correct me I am wrong:
1.  Whether the abi get agreement?
    I have seen Yury are working on the patches of SYSCALL WRAP recently. And there are some discussion about the patches of glibc in LKML. Both of them seem not relative the abi of ilp32.
    Could I say that the abi have already got agreement if we do not find abi issue during ltp test?

2.  Whether LTP test pass?
    There are dozens of failures right now. Huawei are testing the ilp32 on our real hardware and qemu and are planning to fix these issue in our next steps. And we will send it out if we found something.
    If all the LTP syscall test pass(in a make sense way not tricky nor something), do you willing to accept the patches of whole ilp32?

3.  Whether we need a distribution of ilp32?
    I am not quite understand about this requirement. We should of course provide a build system to build filesytem and test ilp32. Any of buildroot, yocto/openembedded or obs, koji and others could do this. I understand that the more packages built pass the more confidencial. But how many packges do we really want? dozens, hundreds, thousands?
    I have patches to build ilp32 filesytem in buildroot. If we need build a filesytem including dozens packages, maybe I could try to do it. But if we want a real distribution. I do not know how should do it. Suse had a private obs for ilp32, I do not know the status of it.

Thanks in advance and looking forward your reply.

Regards

Bamvor

not send.
And it seems that there are lots
of work need to do(upstream, test, performance evalution ...).  I am
curios that if there is a discussion about ILP32 in this week.

Huawei plan to use ILP32 in next year or something.

15:24 2016-03-07
-----------------
BFQ
1.   do it support cgroup? yes. althrough there is maybe bugs in it
2.   very good test result with heavy background read/write.

16:13 2016-03-07
-----------------
glibc
1.  maybe upstream in 2.24.
    TODO check the code in soureware.org.
    select the different code path of glibc. PER_THREAD.

discuss with rayn.
1.  question:
    discuss with ilp32.
    send email to ryan.

09:00 2016-03-08
----------------
1.  coreos, security.
    1. we generated more data than ever before.
       we plac more trust in the system.
       provide guarantees to higher layers.
       UEFI.
       do not differentiate on fundamental security.

2.  Talk with Paul Liu(member serivce). He work on integration for 96boards. for action board.

3.  Talk with alex hung(hong) from canonical. hardware enablement team(x86 and arm).

4.  Gao Qingzhong.

5.  Security, IoT.
    1.  need generic device.
    2.  trustzone. OP-TEE.
    3.  arm and linaro do it together.

6.  Wuzhangjin: meizu. TSC.
    Update(2016-03-09): there are four people join this connect as far as I know.

7.  IoLT: Internet of Light Linux.

8.  Send email to catalin, ryan and Siddhesh Poyarekar.

9.  STILL TODO:
    Read the slide of LMG lighting talk.
    Talk with majun with irq relative topic.

09:19 2016-03-09
----------------
1.  Short talk with Andre wafa from ARM.

2.  Discuss with toolchain about ilp32 with Arnd and Mark.
	1.  5-10% performance improvement in gcc with developing patch.
        2.  kernel: stat64, sysvipc flag need to use the new layout?

3.  Tony chen.

4.  Face to face short talk with winnie.

5.  yinlingbing.

6.  EAS power model.
    1.  active idle.

7.  Discuss with arnd about the support in arm64 linux. Arnd said that it is supported at the beginning. It was a bug about set endian intruction(it could not be emulated because the endian is the optional in the architecture). arm64 kernel must support it unless the original arm32 application will be broken(usually the application is compiled with thumb2).

TODO
1.  collect the use of trinity in huawei and send to tylor discuss about it.
2.  collect the thoughts of ilp32 from huawei and discuss with Mark, Arnd and Catalin.
3.  ping alex about ilp32 later.
4.  talk with linus about gpio and bfq.
    1. bfq:
        <https://lwn.net/Articles/674300/>
        <https://lists.linux-foundation.org/pipermail/containers/2014-June/034704.html>
        [original bfq](https://lkml.org/lkml/2008/4/1/234)
        [BFQ-v7r6 versus CFQ, DEADLINE and NOOP on an SSD](https://www.youtube.com/watch?v=1cjZeaCXIyM&feature=youtu.be)
        [another introduction about bfq](http://algogroup.unimore.it/people/paolo/disk_sched/results.php)


09:40 2016-03-09
----------------
KEY NOTE
0.  I feel that I learn more than last connect. Because I take more clear task(ILP32) this time. It would be great if could continue working in the linaro.

1.  bfq: it maybe useful in our mobile?
2.  ilp32 discussion
3.  kernelci: add fuzz test.

18:27 2016-03-10
----------------
1.  there is a virtualization team and a IoT team in british.
2.  yiselie team work on smt(super thread) on cpu.

22:48 2016-03-10
-----------------
arm64, ilp32, kernel; glibc, ping maintainer
--------------------------------------------
1.  to glibc arm64 maintainer
Greeting from bamvor who care about ILP32
Hi,

This is Bamvor Jian Zhang from Linux kernel working group(Huawei assignee). Nice to talk with Joey about aarch64 ILP32 in linaro connect. I heard that you may be interested to review the patch of ilp32 of glibc if we send them to libc-alpha mailing list. As you may know, there was a abi discussion[1] about ilp32 in LKML one or two month ago. And there is a latest patch of ilp32 of glibc in github[2]. It maybe need to reorgnize before send it libc-alpha mailing list. I could discuss with cavium and kernel guys about the plan of sending it to glibc mailing list.

Here is some information of ilp32 in huawei: In 2014, we have a PoC work in huawei which pass all the syscall tests of LTP and could run the minimal system of our product. But the abi is not get agreement at that time. So we could not continue. Recently, We glad to see lots of discussion in LKML. And it seems that the kernel community get generally agreement for the abi of ILP32(maybe there is one or two item(s) need to futher discussion). We are thinking that if the ilp32(kernel and glibc) could be upstreamed in the next few months, it is a good chance to use it in our product. There are more than 1000 milion line of code need to migrate to ILP32 in Huawei.

Regards

Bamvor

[1]: http://thread.gmane.org/gmane.linux.kernel/2126946
[2]: https://github.com/norov/glibc/tree/new-api

2.  reply to catalin
Here is some information of ilp32 in huawei: In 2014, we have a PoC work in huawei which pass all the syscall tests of LTP and could run the minimal system of our product. But the abi is not get agreement at that time. So we could not continue. Recently, We glad to see lots of discussion in LKML, it is indeed a good progress. So, we plan to use it in our product. There are more than 1000 milion line of code need to migrate to ILP32 in Huawei. Whether the abi of ilp32 get agreement is very important for us.

09:57 2016-03-11
-----------------
1.  Ian Compbell went to unikernel. Julien is the xen arm maintainer, from citrix to arm.
1.  Talk with arnd: does he discuss with catalin? Is catalin willing to tak ethe patches in next month?
    1. Arnd will talk with catalin. I could ping him, there is no update from him in next week.
2.  Talk with Mark about my work.
    1.  Maybe in block layer.
    2.  Send to catalin about why huawei care about ilp32.
3.  Talk with Andy Gross again about Suspend to Idle. S2I is a suspend state in which not all the device freeze.
4.  Talk with Linus about gpio mockup driver and block layer.
    1.  I will send out new version.
        1.  implement the proper util in tools/gpio. my gpio-mockup script will call it.
    2.  block
        1.  look at the article in lwn.
        2.  plugin for scheduler.
        3.  multi queue.
            bamvor: how does the scheduler in block work with multi queue hardware?
5.  Hanjun is working on the RBP. RBP kernel is the lastest(1 or 2) release kernel. it is easy to do the development.
6.  kernelci:
    1.  Currently kernelci only support build and boot test. The next step is adding the kselftest. And if it works, we will add other test.
        E.g. LTP. For trinity, it will be added later.
    2.  The filesystem of kernelci is built by LAVA.
    3.  [This](https://kernelci.org/faq/) is how to build kernelci. But it is tagged as alpha/beta. It does not suggest to deploy it.
    4.  bisec://kernelci.org/faq/tion.

7.  ILP32
    1.  send hello email to glibc arm64 maintainer.
    2.  send hello email to alex graf.

09:22 2016-03-22
-----------------
1. activity
[ACTIVITY] (Bamvor Jian Zhang) 2016-03-14 to 2016-03-22

= Bamvor Jian Zhang=

=== Highlights ===
* ILP32:
    - Backport ILP32 patches to huawei stable kernel. It is seqfault even if I only print one line. After debugging I found that the reason is I do not write the proper tpidr_el0 in thread switch. The code in thread switch of kernel is a little bit different from the upstream kernel.
    - I also found another flush tls issue in kernel side, which may lead to some failure of testcases. I have already send such patch to LKML.
*.bfq(a io scheduler):
    - Read the relative documents of bfq, and discuss with Linus. I'd like to test it in our mobile.

* 1:1 with Mark.

=== Plans ===
* Improve the gpio-mockup driver and sent out new verison according to the discussion with Linus in bkk16.
* ILP32
  -  backport
     Do all the syscall test of LTP for aarch32 and aarch64 lp64 to ensure no regession after introduce ILP32 patches.
  -  Try to fix some failure of LTP in upstream kernel. I hope I could do something for the upstreaming progresss.
* bfq
  -  test bfq in our mobile.

2.  send to Mark
Hi, Mark

It may takes me some time for ILP32 and bfq recently. It may take me 50%-60% of time in next 2-4 weeks. I am not sure if you are ok.
For the ilp32, there is a internal request for speeding up the upstreaming progress. It seems that there are two things I could do. The first thing is that debug the ltp failure and discuss them with community. The second thing is that provide a minimal fileysystem for testing. I hope linaro openembedded could do it. Except the OE, there is a small set of patch of illp32 of buildroot wrote by me. Such series depends on the external toolchain(such as linaro ilp32 toolchain or toolchain from leapproject[1]).  The buildroot maintainer told me that they could not accept the patches until there is a toolchain in a public place. So, do you know the plan of tcwg? Should I send email to them(Ryan, Maxim, Adhemerval) directly?

Thanks

Bamvor

[1] https://hub.docker.com/r/leapproject/leap-aarch64_ilp32-toolchain/

12:45 2016-03-29
-----------------
1.  syscall
    __SYSCALL, __SC_COMP, __SC_COMP_3264, __SC_WRAP

13:55 2016-05-09
[ACTIVITY] (Bamvor Jian Zhang) 2016-05-03 to 2016-05-10
= Bamvor Jian Zhang=

=== Highlights ===
* ILP32
    - vdso:
      Fix vdso issue for ILP32.
      There are three issues in vdso of ILP32.
      1.  the version of vdso is not match between kernel and glibc.
          kernel define the version 2.6, while glibc want to the 2.6.39.
          IIUC, we should define 4.x(x=7, 8... depends on the version of
          kernel in which ILP32 get merged) in kernel. And update the
          code of glibc corrospondingly.
	  Due to this reason, we use the syscall instead of vsyscall
	  in previous version.
      2.  The size of time struct(timeval and timespec) is different
          between ILP32 and LP64. It leads to the wrong nsec or usec.
      3.  We do not zero upper 32bit of register in the entry of
          ILP32 functions.

    - Discuss about is_compat_task.

    - Discuss about off_t and mmap in LKML

=== Plan ===
* ILP32
    - Thinking how to speed up the upstream process. Maybe discuss
      with cavium and suse guys.
      It would be great it could be merged in next merge window.
      I do not know if it is possible.
    - Test automation.

* GPIO
    - Update the gpio mockup driver.

22:15 2016-05-17
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-05-10 to 2016-05-17
= Bamvor Jian Zhang=

=== Highlights ===
* ILP32
    - mmap2
      Send kernel and glibc patch to implement a real mmap2 syscall.
      Test pass in little endian.

    - off_t
      Arnd suggest that define the off_t as 64bit in glibc. I do it and
      revert two patches for fixing the off_t relative issue when off_t
      is 32bit. The glibc the more readable after define off_t as 64bit.

    - Backport the new-api patches of ILP32 to my glibc-2.20 repo. Huawei
      plan to use ILP32 in this version of glibc.

    - Testing
      Read the code of abi-complaince-checker and abi-dumper. It seems that
      I could make use of result of abi-dumper and generic the parameter of
      each syscall. If I could do this, I would like to improve trinity by
      adding those struct and do the fuzz test and parameter checking for
      ILP32.

* vdso remap
    - try the patch of enable vdso remap in arm64. It works. It is useful
      for criu(Checkpoint and Restore In Userspace) for docker.

=== Plan ===
* ILP32
   -  Wrote a script to extract all the parameter of all the syscall in ILP32.
   -  Fix the failure of ILP32 in LTP and other testsuite.
   -  Plan to discuss with community guys for how to improve glibc together.

=== Reference Link ===
* ACC
  <http://ispras.linuxbase.org/index.php/ABI_compliance_checker>
  <https://github.com/lvc/abi-compliance-checker>

* vdso remap
  <https://lkml.org/lkml/2016/4/28/541>
  <https://criu.org/Main_Page>
  <https://criu.org/Docker>

19:48 2016-06-02
----------------
Hi, Mark, Arnd

Here is some further update/question of my work.

1.  ILP32
    1.  As I said yesterday I am working on an automation test tools for testing the interface between kernel and glibc.
        I decide to work on it because I found that there are lots of wrapper function for syscall in both kernel and glibc. It is hard to examine whether the parameter is passed correctly through these wrappers. And I could not compare the parameter between kernel and glibc directly because the types may different(this is why we need the wrapper/converter functions). And at that time I am looking for the the fuzz tools like trinity, skzkaller, I found that these fuzz tools could fuzz the parameters but they could not fuzz the item the complex types(such as the items in struct stat which we discussed in LKML) which is an issue for ilp32 porting/testing. And the existing fuzz tools could not check whether kernel get the correct parameter. It is meaningless if kernel do not accept the correct parameter we do the fuzz test.
	So, my tools could:
	1.  Get the types and function prototype we need from dwarf and generate the fuzz function in userspace(it usually the glibc function). And generate the hook function like jprobe for kernel, e.g.
	    //userspace
	    struct timeval *get_tv()
	    {
                struct timeval *tv = malloc(sizeof(struct timeval));
		tv->tv_sec = get_tv_sec();//rand() inside
		tv->tv_usec = get_tv_usec();//rand() inside
		//print the values. in order to compare it later.
	    }

            struct timezone *get_tz()
	    {

               //
	    }

	    void fuzz_settimeofday() {
		struct timeval *tv = get_tv();
		struct timezone *tz = get_tz();
                settimeofday(tv, tz);//glibc function or syscall()
	    }

	    //kernel
	    //jprobe hook
	    staic int Jsettimeofday(struct timeval __user *, tv, struct timezone __user *, tz)

	    {
                //print the parameter.
                jprobe_return();
		return 0;
	    }

        2.  An script which collect the log in both kernel and userspace and compare whether we do pass the parameter correctly.

	3.  Test syscall return value through kretprobe.

	Now, there are a demo of my tools and I could test all the return value and some syscall parameter. Do this tools make sense to you?
And I found there is a cfp for linuxcon europe. Is it worth to try to submit a speaking proposal?

2.  A tls issue.
    As I said yeterday, we found a bug in tls.  it is only exist in some sinario(e.g. dlopen the library and run the function in that library, it could reproduce after do those steps several times). We could add one signed extension for ilp32 in _dl_tlsdesc_dynamic glibc, and do the similar work in gcc.  We are not sure where we should fix it. We plan to send this issue to glibc and gcc community, hope we could get more input. So, who should I send to?
    Cavium guys: Andrew, yury.
    Glibc: mailing list and arm64 maintainer(Marcus Shawcroft).
    Tcwg: Ryan, Maxim and ?
    GCC: mailing list and ?
    Kernel: Catalin, both of you. I do not know if kernel community care it or not.

3.  There are some discussion recently in ilp32 in community including the discussion of syscall wrapper, the width of off_t in glibc, the real mmap2 in both kernel and glibc. Given that huawei is working on Proof-of-Concept in this month. The delivery team could not take these to our kernel and glibc for now. So, I need to work on differnt versions of kerenl and glibc. I hope I could push it in huawei after they pass the first try(maybe later in this month).

4.  About the new task, I do not read them right now. maybe discuss it in next time?

16:40 2016-06-09
----------------
Quick note for today's 1:1, please correct if I misunderstand something.
Tasks and priorities:
1.  ILP32:
    1.  continue working on the bugfix or improvement, such as improving kernel wrappers.
    2.  About the automatically unit test.
        discuss with lkml. linux-arch. libc-alpha, trinity and skzkaller(?).
        try to submit a proposal to linuxcon europe.
    3.  We hope ILP32 would finish in the near future.
2.  GPIO mockup driver.
    update driver with latest Linus gpio chardev works.
3.  [Convert mmc to blk-mq](https://projects.linaro.org/browse/KWG-200)
    Talk to Ulf Hansson <ulf.hansson@linaro.org> when I start. Ulf worked on it a little bit.

00:24 2016-06-13
----------------
activity
[ACTIVITY] (Bamvor Jian Zhang) 2016-06-06 to 2016-06-13

= Bamvor Jian Zhang=

=== Highlights ===
* ILP32:
    - unwind:
      solve the gdb unwind issue[1].

    - review the code of ILP32
      I plan to review the code relative to architecture and 32bit application in arch/arm64 kernel.
      After review all the headers(~200 files), I found 4 minor issues for ILP32. Already send them
      to LKML. plan to read the c source code in this week.


* 1:1 with Mark
    Tasks and priorities:
    1.  ILP32:
        1.  continue working on the bugfix or improvement, such as improving kernel wrappers.
        2.  About the automatically unit test.
            discuss with lkml. linux-arch. libc-alpha, trinity and skzkaller(?).
            try to submit a proposal to linuxcon europe.
        3.  We hope ILP32 would finish in the near future.
    2.  GPIO mockup driver.
        update driver with latest Linus gpio chardev works.
    3.  [Convert mmc to blk-mq](https://projects.linaro.org/browse/KWG-200)
        Talk to Ulf Hansson <ulf.hansson@linaro.org> when I start. Ulf worked on it a little bit.

* Holiday(2016-06-08--2016-06-10).

=== Plan ===
* ILP32
    1.  code review.
* Submit a proposal to linuxcon in europe.


[1] [gdb unwind issue](http://www.gossamer-threads.com/lists/linux/kernel/2452466#2452466)

10:52 2016-06-16
-----------------
linaro, organization, Engineering Organization Update
Mark Orvek
15 June 2016 at 23:38
Principal Engineer is a new senior technical level in Linaro Engineering with responsibilities that include the development and leadership of larger multifunctional / multi-group programs that require solving complex technical problems and integration of a number of moving parts in close coordination.  A Linaro Principal Engineer is also a senior source of expertise across engineering and the company.  Tyler has already demonstrated his leadership, ability to solve complex problems and has proven he get things done.  I expect great things to come from the teamwork Alan and Tyler have shown in the past.

10:24 2016-06-20
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-06-14 to 2016-06-19

= Bamvor Jian Zhang=

=== Highlights ===
* ILP32:
    - Summary the unwind issue in ILP32. it is very interesting that the wrong frame pointer in signal frame will not lead to the wrong return addresss when function return. Function return rely on the lr and the fp generated by compiler.
    - Help other colleague debug semctl issue. It seems that it is a misuse of unoin.
* KWG-148 GPIO kselftest
    - Read the lastest code of gpio utils. It seems that the existing tools could not finish my work. Will discuss with Linus later.
* Working on merge the common mmap/mmap2 code in arch directory. Discuss with Arnd.
* Submit a proposal to linuxcon in europe.

=== Plan ===
* ILP32
    - review the latest patches of ILP32.
    - Think about the performance test of ILP32.
* KWG-148 GPIO kselftest: discuss with Linus.
* Working on merge the common mmap/mmap2 code in arch directory.

21:09 2016-06-21
----------------
1.  To Catalin
Hi, Catalin

As you may notice, we found signal, coredump, tls and other issues and discuss
with community, these issues are found after migrate the property software of
Huawei from aarch32 to aarch64 ILP32. There is no pending issue relative to
ILP32 including kernel, glibc gcc and gdb. The patches of kernel part looks
good to me. Maybe it is a good time to review the current status of upstream.
> Hi, catalin
>
> On 9 March 2016 at 00:41, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > Hi Bamvor,
> >
> > On Tue, Mar 08, 2016 at 07:06:53PM +0700, Bamvor Zhang Jian wrote:
> >> This is bamvor from linaro kwg(Huawei assignee). Glad to see lots of
> >> discussion in LKML in recent months. It seems that the community get
> >> generally agreement about the abi. Huawei wants to use ILP32 in the
> >> production environment in the near future after the ILP32 is ready.
> >
> > I haven't followed the details of the latest discussions, I think there
> > are still some things to sort out.
> >
> >> So, what is the blocker of getting ilp32 upstream(kernel part)?
> >> IIUC, there are three things being discussed, please correct me I am wrong:
> >> 1.  Whether the abi get agreement?
> >>     I have seen Yury are working on the patches of SYSCALL WRAP
> >> recently. And there are some discussion about the patches of glibc in
> >> LKML. Both of them seem not relative the abi of ilp32.
> >>     Could I say that the abi have already got agreement if we do not
> >> find abi issue during ltp test?
> >
> > The SYSCALL WRAP discussions are more of an kernel internal code reuse
> > aspect. I can't yet tell whether we have full agreement on the ABI, I
> > think Arnd raised something about stat64 but I haven't looked at the
> > details.
Yury remove the wrapper in RFC v7 patches. Even the 2% difference of
performance is meaningful for huawei if it does not break other thing. What
do you think about it?
> >
> > We also need the libc-alpha community to agree on the ABI, it's not a
> > kernel only decision. It was them who raised the non-POSIX compliance
> > aspect when we aimed for a mostly native (LP64) ABI.
> Agree. It would be if cavium guys could send patch of glibc early.
After some off-list discussion with yury, he send a patches of glibc yesterday.
We got some crash when porting to glibc master, 2.23 is the latest version of
glibc we could support ILP32 at this time. Hope we could get some input from
community.

Besides, I am working on an unit test for syscall which could validate whether
the parameter and return value is pass correctly between c library and kernel
core code. Base on the result of this tool, We found several endian issues of
syscall wrapper in glibc. I plan to send an introduction of these tools to
LKML and relative mailing list soon.

I understand that adding a new ABI like ILP32 is not an easy task. I hope I
could do something to help on this progress.

Looking forwand to you reply, Thanks.

Best wishes

Bamvor
> >
> >> 2.  Whether LTP test pass?
> >>     There are dozens of failures right now. Huawei are testing the
> >> ilp32 on our real hardware and qemu and are planning to fix these
> >> issue in our next steps. And we will send it out if we found
> >> something.
> >>     If all the LTP syscall test pass(in a make sense way not tricky
> >> nor something), do you willing to accept the patches of whole ilp32?
> >
> > Not necessarily. See below.
> Cool.
> Here is some information of ilp32 in huawei: In 2014, we have a PoC
> work in huawei which pass all the syscall tests of LTP and could run
> the minimal system of our product. But the abi is not get agreement at
> that time. So we could not continue. Recently, We glad to see lots of
> discussion in LKML, it is indeed a good progress. So, we plan to use
> it in our product. There are more than 1000 milion line of code need
> to migrate to ILP32 in Huawei. Whether the abi of ilp32 get agreement
> is very important for us.
>
> Regards

2.  Reply to marcus.shawcroft@arm.com. ref"22:48 2016-03-10".
Hi, Marcus

After some off-list discussion with yury, he send a patches of glibc yesterday.
We got some crash when porting to glibc master, 2.23 is the latest version of
glibc we could support ILP32 at this time. Hope we could get some input from
you and community.

Besides, I am working on an unit test for syscall which could validate whether
the parameter and return value is pass correctly between c library and kernel
core code. We found several endian issues of syscall wrapper in glibc by this
tools. I plan to send an introduction to LKML, glibc and relative mailing list
soon.

I understand that adding a new ABI like ILP32 is not an easy task. I hope I
could do something to help on this progress.

Best wishes

Bamvor

3.  Reply to Marcus. 20160623
> Hi,
>
> > After some off-list discussion with yury, he send a patches of glibc yesterday.
>
> Excellent!
Thanks.
>
> > We got some crash when porting to glibc master, 2.23 is the latest version of
> > glibc we could support ILP32 at this time. Hope we could get some input from
> > you and community.
>
> Looking in my inbox this morning I see there is already a lot of feedback from the community.  Iâd like to highlight Josephâs comment:
>
> https://sourceware.org/ml/libc-alpha/2016-06/msg00780.html
>
> .. particularly in with respect to:
>
> - getting the patches rebased on master
We are working on it. Hope we could fix issue soon.
> - providing feedback to the various issues raised in the previous round of reviews.
Yes, it is very important. Joseph give us lots of usefull overall suggestions.
We will review the all comments.

Fo the syscall wrappers in ilp32 directory, Joseph suggest that add common
function like Adhemerval does. It may takes some time to discuss it with
community. Is it make sense to you we postpone this work until we address
other comments?

Regards

Bamvor

12:42 2016-06-23
----------------
perf, bpf
---------
perf and eBPF training.

1.  perf support multi abi in the same time?
2.  throughout and .
3.  perf script.
4.  R
5.  /call-graph=no/
6.  perf probe -a
7.  --exclude-perf
8.  overwritable ring buffer:
    1. It was fix lengh ring buffer. When buffer is full, kernel will notify perf to collect the date. If perf could not collect the data, kernel will not write the new data.
    2. We could only collect the info when we found the specific event.
9.  perf need set llvm compiler in "~/.perfconfig".
10. llvm compile c source code to bytecode which is cross platform.
11. perf could be a deamon.
12. bpf could support kprobe and uprobe. One could use SEC to specify them.
13. decrease the impact on system.
    1. -F: low the frequency of perf: it is the frequency of writing to ring buffer.
    2. -m: size of ring buffer.
14. how to analysis high sys.
    1. high sys means sys call time is very long.
15. what is the status of NMI for profiling?

15:39 2016-06-28
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-06-20 to 2016-06-27

= Bamvor Jian Zhang=

=== Highlights ===
* ILP32:
    - Off-list Diccussion about upstream work of ILP32 with Catalin, Yury, Marcus Shawcroft@ARM, Thomas Molgaard@ARM. Base on the steps listed by Catalin[1], I realize that there is a big gap between my understanding and Catalin's. 3 and 4 seem not a big blocker. Since Huawei have migrated lots of private software from aarch32 to aarch64 ILP32 for evaluation. The overall usablility of ILP32 looks good. Regarding to the performance regression test, maybe I could talk with Fengguang Wu(The main contributor of lkp). Not sure if Linaro could help on do the performance test as well.
    - Syscall unit test:
      Discuss with Mark about my syscall unit test tools. Mark suggest that public the source code when discuss tools with community.
      Found a fuzz tools[2] Triforce which base on AFL. It could do the coverage without enable kASAN or other features in kernel. It seems that it is very useful for old 3.x kernel. It depends on an special instruction for community between guest and host. Not sure if it is a blocker for porting to arm64.

* KWG-148 GPIO kselftest
    - After discuss with Linus, wrote a set of basic gpio operations: gpio set(s), gpio get(s). Will send to Linus this week.

=== Plan ===
* ILP32
    - Considering lkp test.

* KWG-148 GPIO kselftest
    - Discuss my gpio basic operations with Linus.

* Huawei internal request
    - There is an internal request of evaluation of NEON support(performance, debug...) in kernel and userspace. Hope it will not take too much time.

[1] Steps of ILP32 upstream work from Catalin:
    1. Complete the review of the Linux patches and ABI (no merge yet)
    2. Review the corresponding glibc patches (no merge yet)
    3. Ask (Linaro, Cavium) for toolchain + filesystem (pre-built and more
       than just busybox) to be able to reproduce the testing in ARM
    4. More testing (LTP, trinity, performance regressions etc.)
    5. Move the ILP32 PCS out of beta (based on the results from 4)
    6. Check the market again to see if anyone still needs ILP32
    7. Based on 6, decide whether to merge the kernel and glibc patches
    We are pretty much around 1-2 currently and we would need to sort out 3.
    Point 5 is ARM's responsibility (the PCS ABI). Points 6-7 are again up
    for discussion with the wider kernel community.

[2] https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2016/june/project-triforce-run-afl-on-everything/

10:41 2016-06-30
-----------------
Add basic gpio operations

Hi, Linus

These paches add basic gpio set/get operations and use it in
gpio-hammer.c. It is RFD, because the test failed. I want to know
if this approach is generally ok.

In my test, the gpio-hammer could send the correct gpio values to
the kernel, it seems that my mockup driver does not work properly
which leads to gpio value stick to 1. I wil continue debugging it.

21:28 2016-07-07
----------------
arnd: I talk with agraf today. There is an internal obs(aka ibs) for ilp32. Currently 7805 packages build successful. But there is no plan to public it. Because there is no volunteer maintaining the ilp32 package tree. And there is no builing power for it on obs.
arnd: I am asking internally about if Huawei could help on maintain all or of some of the packages.

09:58 2016-07-12
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-06-28 to 2016-07-10

= Bamvor Jian Zhang=

=== Highlights ===
* KWG-148 GPIO kselftest
    - debug gpio set(s), gpio get(s).

* KWG-200: Convert mmc to blk-mq
     - Learn the basic idea of blkmq. will contact Ulf later.

* KWG-192: Use of contiguous page hint to create 64K pages
    - Read the page table test result from pingbo wen ILP32:

* Huawei:
    - Try to improve the NEON context switch performance in arm64 kernel with private aarch32 application, but there is no clear improvemen . Test two solutions with pure aarch32 application on arm64 kernelafter discuss with Arnd, Ard and Catalin.
      1.  Save.16 register for aarch32 applicaiton. Test result of context switch in lmbench show that it is worse than default.
      2.  Only save SIMD register when the application really use SIMD instruction. Add a new TIF_SIMD_NOT_USED flag record whether the thread use SIMD or not. This flag set after thread created. Clear this flag in SIMD access sync exception. Test result show that it is a little improvement(average 2%). Notes: the original context switch is removed in this test in order to compare with the original method.

=== Holiday ===
11, July to 18, July: go to Hulunbuir in the innner Mongoliar.

11:45 2016-07-25
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-07-19 to 2016-07-25

=== Highlights ===

* KWG-200: Convert mmc to blk-mq
     - Contact Ulf. Ulf suggestion take a look a blk-mq patch of ubi. It is a single patch.
     - Read the blk-mq relative code in loop.c and ubifs.
     - The key operation in blkmq is `struct blk_mq_tag_set` which is embedded in the device and blk_mq_ops which provide the opeartion for blk-mq.

* KWG-192: Use of contiguous page hint to create 64K pages
    - discuss with Arnd with Alex graf about this task in #armlinux irc channel.
      There is already a patch "66b3923 arm64: hugetlb: add support for PTE contiguous bit" which finish part of my task.
      We agree that I will test the performance when I wrote a worked patch. Reference the testsuite for hugepage.

* Syscall unit test
    - The proposal of linuxcon europe get accepted. My presentation "Efficient Unit Test and Fuzz Tools for Kernel/Libc Porting" is scheduled in 6, Oct. The the help from Mark.

=== Plans ===
* Prepare the visa for Germany.
* KWG-192: Use of contiguous page hint to create 64K pages
    - Read and test the patch 66b3923. Check if it finish my first two steps. If so, think about the third step.

The step suggested by Arnd:
maybe start working in this order then:
1. implement 64K hugepage size as a compile-time selection and test that with the new code in linux-mm / linux-next
2. get multiple concurrent page sizes to work
3. add an option to the anonymous page handling to always use hugepages instead of the base page size

```
static struct blk_mq_ops ubiblock_mq_ops = {
        .queue_rq       = ubiblock_queue_rq,
        .init_request   = ubiblock_init_request,
        .map_queue      = blk_mq_map_queue,
};
```
22:04 2016-07-26
----------------
1.  Ian C reply to me
Hi Bamvor,

Nice to hear from you. Sorry for the (very) late reply -- I saw your
mail on my phone at the time but put the reply aside until I had a
proper keyboard and then it got lost in the mess of my INBOX, sorry.

I did indeed move to Unikernel, who got acquired by Docker as I was
interviewing with them, we're still working out exactly where
Unikernels technologies are going to fit within the Docker stack, but
it's exciting times for sure!

Docker has a bit of a growth spurt earlier in the year so I don't think
we are hiring at the moment I'm afraid (at least not in Europe, looks
like there might be some openings in SF).

I think that Saumsing, Huawei (not 100% sure there) and Amazon all now
have development teams in/around Cambridge, but I don't have any
contacts at any of them and I'm not sure what sort of things they work
on. I don't think Amazon is an EC2 team, something to do with drones or
something I think. Of course there is always ARM here in Cambridge,
it's possible that Julien's new team might be expanding? ;-)

Julien, Stefano and myself all left Citrix in the last six months, so
there ought to be some gaps, but I'm afraid I don't know what the
hiring situation is there, you could maybe drop George (Dunlap) or Ian
(Jackson) a line and see what they think and if not for ther OSS team
they could connect you to the right people on the XenSeerver (AKA
product) team. My guess is that they are likely to expand the team in
Nanjing rather than Cambridge, which is a bit counter to you plans, but
it could be worth investigating.

You mentioned Germany, I think Amazon have an EC2 development office in
Dresden, Andre Pyrzwara who is now at ARM in Cambridge (do you know
him?) used to work for that team when it was part of AMD (when AMD
downsized theat office Amazon picked up most of the team) -- he might
be able to put you in touch with someone. I think Samsung also have a
dev site in Munich but I don't know much about what they are doing
(they sent me a mail a year or two ago asking if I would relocate but I
didn't want to so I didn't pursue it and it looks on linkedin like they
guy who approached me has moved on).

Anyway, I hope that's somehow helpful. If you'd like me to try and put
you in touch with anyone please do let me know.

Good luck!

2.  Reply to Ian
Hello

I plan to goto Berlin and Dresden(maybe) in Oct. I am thinking If I
could talk with the guys in Germany.

16:30 2016-08-04
----------------
1:1 with Mark
1.  Jira: sorry for not updating jira.
2.  gpio progress.
3.  ILP32.
    Mark will send to Ryan. For community, not for Huawei.
4.  Linaro connect: what I could do.
    presentation with kwg colleague.
5.  64k page hint.
    Talk to Arnd for technology.
6.  Talk to Arnd for Germany community.
7.  Mark think my work is going to good. He could understand that the internal task from huawei.

1.  TODO:
    I should ask if I could change the content of presentation of Linuxcon europe.

21:18 2016-08-05
----------------
Arnd: I talk with David Woods. He told me that the 64k page hint for linear mapping of kernel is upstreamed([1]) in v3. It seems that the annoymous in userspace(IIUC it could be used by malloc from brk and mmap syscall, correct?) is not implemented yet.
I am read the 64k page hint for hugetlb and read the code of memory mapping in kernel. I saw the HUGETLB code in mmap.
Is it make sense to force MAP_HUGE when the size is suitable for 64k?
[1] https://lkml.org/lkml/2015/9/16/715

20:40 2016-08-08
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-07-26 to 2016-08-08

=== Highlights ===
* KWG-148 GPIO kselftest
    - I found that I misuse the api from chardev. There is default values when open the chardev.
    - I encounter a refcount issue in unregister the gpio device. Linus said that this issus had already fixed by community. I will try the linux-next tree.

* KWG-192: Use of contiguous page hint to create 64K pages
    - Discuss with David[1] who were building an SOC with a custom network interface and various accelerators. The test suite from him is based on the libhugetlbfs test suite. He show me that kernel page ranges is already contiguous[2]. It seems that what I could do is check the alignment and add the HUGETLB flag for ANONYMOUS request.

* ILP32
     - Compare aarch64 LP64 performance between without ILP32 and ILP32 enabled in the upstream kernel. There is no performance regression. Plan to send the number to LKML.
     - Wrote a documents for Huawei to report the latest status of ILP32. It seems that there is no pending arugments of api of ILP32. IIUC, I would suggest huawei alignment with the community at this point. It may be a good time to do it before we deploy it. I also suggest Huawei that there should be dedicated person who join the discussion of glibc part of ILP32. Because I am working in the kernel department in Huawei, Glibc is not my area.
     - Huawei compare the aarch32 and aarch64 ILP32 in production environment. The cpu utilization of ILP32 is 5-10% lower than aarch32.

* 1:1 with Mark.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    - try to support the page hint for anonymous pages.

* KWG-148 GPIO kselftest
    - Debug refcount issue. If I could not find a way, plan to ask in mailing list.
    - Maybe I could send the gpio ops code in tools/gpio individually.

[1] David Woods <dwoods@ezchip.com> ("66b3923" arm64: hugetlb: add support for PTE contiguous bit)
[2] Jeremy Linton <jeremy.linton@arm.com ("348a65c" arm64: Mark kernel page ranges contiguous)

11:32 2016-08-09
----------------
Arnd suggest that I maybe start working in this order then:
1. implement 64K hugepage size as a compile-time selection and test that with the new code in linux-mm / linux-next
2. get multiple concurrent page sizes to work
3. add an option to the anonymous page handling to always use hugepages instead of the base page size
4. investigate the page hint for kernel mapping.

Later, we found that 1,2 are finished by David[1]. And 4 is finished by Jeremy. I will focus on 3 at this monment. I will do the performance test ASAP.

[1] David Woods <dwoods@ezchip.com> ("66b3923" arm64: hugetlb: add support for PTE contiguous bit)
[2] Jeremy Linton <jeremy.linton@arm.com ("348a65c" arm64: Mark kernel page ranges contiguous)

16:30 2016-08-11
----------------
void
attribute_hidden
_dl_tlsdesc_resolve_rela_fixup (struct tlsdesc *td, struct link_map *l)

          atomic_store_relaxed (&td->arg, p);
   14abc:       b9400b23        ldr     w3, [x25,#8]
   14ac0:       b9400441        ldr     w1, [x2,#4]
   14ac4:       0b010061        add     w1, w3, w1
   14ac8:       0b000020        add     w0, w1, w0
   14acc:       b90002a0        str     w0, [x21]
          /* This release store synchronizes with the ldar acquire load
             instruction in _dl_tlsdesc_return_lazy.  */
          atomic_store_release (&td->entry, _dl_tlsdesc_return_lazy);
   14ad0:       90000000        adrp    x0, 14000 <_dl_cache_libcmp+0xc0>
   14ad4:       1131b000        add     w0, w0, #0xc6c
   14ad8:       889ffe80        stlr    w0, [x20]

        cfi_startproc
        .align 2
_dl_tlsdesc_return_lazy:
        /* The ldar here happens after the load from [x0] at the call site
           (that is generated by the compiler as part of the TLS access ABI),
           so it reads the same value (this function is the final value of
           td->entry) and thus it synchronizes with the release store to
           td->entry in _dl_tlsdesc_resolve_rela_fixup ensuring that the load
           from [x0,#PTR_SIZE] here happens after the initialization of td->arg. */
        DELOUSE(0)
        ldar    PTR_REG (zr), [x0]
        ldr     PTR_REG (0), [x0, #PTR_SIZE]
        RET
        cfi_endproc
        .size   _dl_tlsdesc_return_lazy, .-_dl_tlsdesc_return_lazy

09:15 2016-08-12
----------------
KWG192, discuss with arnd
-------------------------
```
arnd> Arnd Bergmann
bamvor: you also need to check the alignment of 'addr', otherwise this seems like it should work
ah wait, you also need to check if a user is already asking for another hugepage size
if ((flags & (MAP_ANONYMOUS & MAP_HUGETLB)) == MAP_ANONYMOUS)
or even
if ((flags & (MAP_ANONYMOUS | MAP_HUGETLB | (MAP_HUGE_MASK << MAP_HUGE_SHIFT)) == MAP_ANONYMOUS)

arnd> Arnd Bergmann
bamvor: I think what it means is that you will have to implement a lot of extra code to make transparent hugepages work with the huge page sizes that are not just using a whole page table level
it may be better to build on top of your current hack if that works, e.g. as a compile-time option
unfortunately, the hack somewhat clashes with the way we use getpagesize() for the mmap() length
```

11:18 2016-08-16
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-08-09 to 2016-08-16

=== Highlights ===
* KWG-192: Use of contiguous page hint to create 64K pages
     - Discuss with Arnd about my work. Arnd help me fix some bug in my hack but I still could not boot a distribution (due to udev failure likely). I could boot a buildroot filesystem and do lmbench test. Lmbench show that mmap reread get 300% improvement other memory test get 5-20% improvement.

* ILP32
     - Backport current community version to 4.1 kernel and 2.20 glibc.
     - Join the discussion of ILP32 of hwcap.

* Arm32 team meeting.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    - Do other test and continue reading the mm code in kernel.

* KWG-148 GPIO kselftest
    - Debug refcount issue. If I could not find a way, plan to ask in mailing list.
    - Maybe I could send the gpio ops code in tools/gpio individually.

16:43 2016-08-31
----------------
1.  cover letter v3
Add gpio test framework

These series of patches try to add support for testing of gpio
subsystem based on the proposal from Linus Walleij. The first two
version is here[1][2].

The basic idea is implement a virtual gpio device(gpio-mockup) base
on gpiolib. Tester could test the gpiolib by manipulating gpio-mockup
device through sysfs or char device and check the result from debugfs.
Reference the following figure:

   sysfs/char device  debugfs
     |                   |
  gpiolib----------------/
     |
 gpio-mockup

Currently, this test script will use chardev interface by default.

In order to avoid conflict with other gpio exist in the system,
only dynamic allocation is tested by default. User could pass -f to
do full test.

[1] http://comments.gmane.org/gmane.linux.kernel.gpio/11883
[2] http://www.spinics.net/lists/linux-gpio/msg11700.html

Changes since v1:
1.  Change value of gpio to boolean.
2.  Only test dynamic allocation by default.
Changes since v2:
1.  Switch to chardev.
2.  Add basic gpio operation for chardev.

2.  send them out:
`git send-email --no-chain-reply-to --annotate --to linux-gpio@vger.kernel.org --cc linus.walleij@linaro.org --cc broonie@kernel.org *.patch`
 
16:19 2016-09-05
----------------
1.  The ILP32 plan in linaro connect
Hi, Mark, Arnd

One of my task in linaro connect is speed up the ILP32 upstream progress.
As I mentioned before, Huawei is willing use ILP32 in next year. My last change is the kernel-4.10 and glibc-2.25.

I do not know if it is necessary to discuss the current status of ILP32 in connect. If there are some open issue we know, Is it make sense to book a private meeting?

kernel part.
glibc part.

I could do the performance regression if I know what we want to test as I mentioned in the email.

2.  Send to suse guys
Hi, Andreas and Alex

Are you plan to join Linaro connect in Las vegas. I plan to host a private meeting for discuss for ILP32. So, I am trying to collect the information here.

Is there any open issue for ILP32 in your mind?


Regards

Bamvor

16:46 2016-09-05
----------------
1.  [ACTIVITY] (Bamvor Jian Zhang) 2016-08-17 to 2016-08-29
```
I am trying to clean up the easy task while I spent more time on the new task.
=== Highlights ===
* KWG-148 GPIO kselftest
    - Update the latest gpio-devel branch. The refcount issue have
been resolved as expected.
    - Write the test case for gpio chardev which need libmount for
reading the entry of debugfs. Maybe I should fail back to the default
mount point of debugfs when libmount is inexist. Cross-compiler a new
library for embedded device maybe not a easy task.
    - I found a crash when I try to insert number of gpio more than
supported. IIRC it is works on my old kernel. There is a changes for
gpiodev_add_to_list. I will revert it and test it again.

* Arm32 team meeting.

* ILP32
   - Give a presentation of ILP32 for new developer of ilp32 in Huawei.
   - Found an issue about sync_file_range2. It could be fixed after
define __ARCH_WANT_SYNC_FILE_RANGE and redirect such syscall.

=== Plans ===
* KWG-148 GPIO kselftest
   - send the patches to Linus.

* KWG-192: Use of contiguous page hint to create 64K pages
   - The hack code crash when do the specint test. Read the THP code
and try to support multiple page size of THP.

* ILP32
   - Performance test.
```

2.  [ACTIVITY] (Bamvor Jian Zhang) 2016-08-30 to 2016-09-04
=== Highlights ===
* KWG-148 GPIO kselftest
   - Send patch of gpio mockup driver and test script of chardev and sysfs.

* 1:1 with Mark

* ILP32
   - send patch for sync_file_range2 which reviewed by Arnd.
   - send a performance test result for aarch64 LP64 to LKML. There is
no performance regression after apply patch of ILP32.

=== Plans ===
* ILP32
   - There is a issue in mremap in aarch64 ILP32 in kernel part.
Investigate whether it is a bug or not.

* KWG 174: KBUILD_OUTPUT fix for kseltest
   - try to write the patch reference the existing code in tools/gpio/Makefile

* Wrote the slide for Linuxcon.

12:02 2016-09-07
----------------
cont page hint performance test(hack)
Context switching - times in microseconds - smaller is better
-------------------------------------------------------------------------
Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                         ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ------ ------ ------ ------ ------ ------- -------
localhost Linux 4.1.23+  3.2067 3.3333 3.7900 4.3133 4.4267 4.21333 3.95333
localhost Linux 4.1.23+  4.2780 3.9700 3.9080 4.3380 4.6760 4.04000 3.98600
localhost Linux 4.1.23+  -25.04% -16.04% -3.02% -0.57% -5.33% 4.29% -0.82%

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
localhost Linux 4.1.23+  1973 3456 1792 2355.5 13.5K 2686.3 3184.5 3627 4946.
localhost Linux 4.1.23+  1851 3158 1977 2063.0 3631.1 2604.7 2865.6 3513 4341.
localhost Linux 4.1.23+  6.59% 9.44% -9.36% 14.18% 271.79% 3.13% 11.13% 3.25% 13.94%

16:23 2016-09-07
----------------
已经有了output directory. 还需要install脚本么? 还需要install么?
 
19:19 2016-09-07
----------------
team meeting
-------------
1.  From arnd point of view, there is only one pending issue for ILP32: stat. 
2.  Arnd suggest me dig into the performance changes of LP64 after apply ILP32.
3.  Arnd told me there is a discussion about the Makefile in tools: "tools/Makefile: Fix Many Many problems and inconsistencies". It is relative to my work for kselftest.  
    1.  Send to Arnd
        arnd: I read the discussion of "[Ksummit-discuss] [TECH TOPIC] tools/Makefile: Fix Many Many problems and inconsistencies". It seems that people want to make kbuild usable for all the non-kernel project. If so, I think there is no need to continue my work for kselftest. Could/Should i join the discussion and confirm it?
    2.  Arnd add me to this thread. reply to the thread. ref"10:34 2016-09-08".
4.  Discuss with Yury
    1.  Create the trello for ILP32.
    2.  Add sob of bamvor

10:34 2016-09-08
----------------
kernel summit, tools, kselftest
-------------------------------
1.  reply to Arnaldo
> means Arnaldo Carvalho de Melo <acme@kernel.org>
>> means Ben Hutchings <ben@decadent.org.uk>

>> 1. Many different build systems
>>    - Inconsistent support for configuration variables (not just 'O')
>>    - usbip isn't included in a recursive build, presumably because
>>      it uses autotools
>
>Right, that needs improving, I haven't looked at anything outside
>tools/{arch,build,lib,include,objtool,perf}
I am working on enable O= support for kselftest(tools/testing/selftest).
Kbuild or tools/build/Makefile.include seems too heavy for kselftest.
Those Makefile could easily link lots of objects to single binary,
while in kselftest, almost all the single binary is compiled from one
single source respectively, I could redirect the output directory
through the explicit rules.
If there is a plan to build a generic build system(at least for tools),
I hope kselftest could be counted in. Then I could suspend my work and
waiting for this solutions.
>
>> 2. Tools include UAPI headers in one of two ways, neither of which is
>>    reliable:
>>    - Assume the current headers are on the system include path
>>    - Include unprocessed UAPI headers through a relative path
>>
>>    The right thing to do is to run 'make headers_install' and add
>>    usr/ to the front of the system include path.  But we'd want a
>>    way to avoid re-doing that when the UAPI headers haven't changed.
>
>Again, haven't checked outside the above list of directories, by now,
>tools/perf/ doesn't use anything outside tools/, are you talking about
>other tools that touch kernel source files outside tools/?
E.g. tools/gpio and some testcases in tools/testing/selftest


Regards

Bamvor

