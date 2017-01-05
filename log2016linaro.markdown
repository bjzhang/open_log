
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

Are you plan to join Linaro connect in Las vegas? There would be a private meeting for discussion of ILP32. So, I am trying to collect the information here.

Is there any open issues for ILP32 in your mind?

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

21:16 2016-09-09
----------------
software skill, ubuntu, apt-get
------------------------------
"Trouble downloading packages list due to a “Hash sum mismatch” error"
<http://askubuntu.com/questions/41605/trouble-downloading-packages-list-due-to-a-hash-sum-mismatch-error>
1.  
```
edited Sep 17 '15 at 15:21 sorin
answered May 9 '11 at 21:52 Lorem

Just remove all the content of /var/lib/apt/lists directory:

sudo rm -rf /var/lib/apt/lists/*
then run:

sudo apt-get update
```

2.  Behrang Jul 28 '13 at 12:51
If you remove all files, you have to download them again. You can just remove the invalid file to make this process faster.

8:27 2016-09-15
---------------
application in linux
---------------------
1.  image viewer
    gnome: eog
    xfce: ristretto

16:27 2016-09-16
----------------
1.  reply to Arnd
> A couple of things I noticed:
>
> - The unusual font for the large text is a bit distracting
> - The small text is a bit too small, especially in some of the
>   diagrams (e.g. page 25 "The test flow of syscall unit test")
Yeap. I will fix it later. This is a template I found from internet.
I need to figure out how to change it.
> - On page 5 ("data model"), the line wrap between "Arm/aarch32"
>   and "aarch64 ILP32" is wrong. Maybe list Windows x86-64 as
>   an example for LLP64 there.
Yeap, Good suggestion. I will update it in next version.
> - on page 10 ("There are actually lots of choices..."), replace
>   "delouse" with a more technical term, nobody will know this
>   word.
How about "sign extend for 32bit variable"?
> - On page 12 ("Version A"): you write "time_t should be 32bit
>   for 32bit application", this is incorrect, POSIX doesn't
>   specify it. The reason we went to 32-bit time_t is that
>   inconsistent ABIs between arm32-compat and ilp32 break
>   existing drivers that have a common ioctl handler for
>   both.
Ok. I will update it.
> - Before your version A/B/C, there was already an original
>   version that was similar to version B. Back then we asked
>   for what you call "Version A" to make it work like x86-x32
>   mode, but after a lot of discussion we went back to the
>   original approach as it is less error prone.
What's your mean "less error prone"?
Do you mean v1 or v2? I could not find such version right now.

So, I will list the following 4 version in the slide, is it
make sense to you?
### Version A
*   Most of syscall is compat syscall.
*   time_t and off_t is 32bit

### Version B
This vesion is very similar to x86-x32
*   Most of syscall is as same as 64bit syscall.
*   time_t and off_t is 64bit. It may break the compat ioctl.

### Version C
Come back to version A.
*   Most of syscall is compat syscall.
*   time_t and off_t is 32bit
*   Pass 64bit variable through one 64bit register.
*   Do the sign extend when enter into kernel.

### Version D
*   Most of syscall is compat syscall.
*   time_t is 32bit and off_t is 64bit
*   Pass 64bit variable through two 32bit register.
*   Clear the top-havies of of all the registers of syscall when enter kernel.

Regards

Bamvor
>
>         Arnd

2.   Update according to Arnd
> Hi Bamvor,
> 
> I have a few more comments, mostly about formatting and spelling this time.
> Overall: try to avoid full sentences, especially multi-line ones
> Overall: when you wrap lines, continue below the first character
>          of the starting line like this, not the
> left-indented like this
> Overall: 64bit -> 64-bit, 32bit -> 32-bit
DONE
> Overall: drop '.' at end of line
DONE
> Page 2, page 18: change alignment from center to left
DONE
Only h1 is centered. Downgrade page 2 and page 18 to h2.
> Page 11: developemnt -> development
DONE
> Page 13: don't mention POSIX for 32-bit time_t, instead mention
> incompatibility with arm33 compat-ioctl code
DONE
> Page 15: havies -> halves
DONE

19:21 2016-09-16
---------------
linuxcon, TODO
--------------
1.  ask syzkaller if I could use that picture.
2.  change my font(wenquanyi?)
2.  promote my talk?

18:17 2016-09-19
----------------
activity
--------
[ACTIVITY] (Bamvor Jian Zhang) 2016-09-04 to 2016-09-19
=== Highlights ===
* Wrote the slide for Linuxcon.
   - The source of this slide is [here](https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.md). Any suggestion is appreciated. Section start with "???" is note which is not existed in final slide.
   - I use remark to convert the markdown to html and use decktape to convert html to pdf. It is the first time I use css. It is hard but interesting for me because markdown is easy to maintain. The template is here[1](https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2016/remark-template.css)[2](https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2016/template.html). It takes me more than two days for getting the expected format for my slide.
     Maybe I should prepare slide early.
   - Thanks for Mark and Arnd for helping me reviewing this slide.

* ARM32 team meeting.

* 1:1 with Mark, discuss with Mark about my plan in connect
   - ILP32 collaboration meeting.
   - Discuss with Linus about my gpio-mockup driver.
   - Discuss with Arnd about my cont page hint.
   - Discuss about arm64 scalbiltity issue.

* Holiday: The mid-autumn holiday(14-17, Sep).

=== Plans ===
* KWG 174: KBUILD_OUTPUT fix for kseltest
   - Send the patch out and cc Kevin Hilman

* Discuss with Alex Shi about "Upstream session in Mandarin".

17:25 2016-09-20
----------------
kselftest
---------
1.  TODO
    1.  only convert the testcase which list in TARGETS in kselftest Makefile
    2.  fix the header issue.
2.  cover letter
```
Hi, Kevin, Mark

Here is my draft for enable the KBUILD_OUTPUT for kselftest. I only
test a few test case. I want to know if the idea is make sense to you.
I spend two much time for the slide of linuxcon europe in recent two
weeks. Sorry for the delay of these patches.

There are four patches in these series. And three of them clean up
the existing code. I split the clean up patches into three, hope it is
easy to review.

In the first patch, I split the test files into two types:
TEST_GEN_XXX means such file is generated during compiling. TEST_XXX
means there is no need to compile before use. The main reason of this
change is the enablement of KBUILD_OUTPUT only need to care about
TEST_GEN_XXX. I wanted to copy all the TEST_XXX with TEST_GEN_XXX,
but I give up this idea in the end. Because people may puzzle why
copy the file before installation.

Because of the introducing of TEST_GEN_XXX, I update the top-level
Makefile and lib.mk selftests directory.

The other cleanup in the first patch is I remove all the unnecessary
all and clean target.

The second and third patch do the similar clean up in powerpc and
futex directory.

The fourth patch introduce the KBUILD_OUTPUT and O for my own.
Because user may compile kselftest directly
(make -C tools/testing/selftests). This patch also introduce the
OUTPUT build target such as "$(OUTPUT)%:%.c".

I plan to test all the testcase then send out the patches.

This patch do not fix the dependency of header file as discussed
in kernel-summit mailing list. I may fix it in seperate patch.

Regards

Bamvor

3.  send out
`git send-email --no-chain-reply-to --annotate --to khilman@kernel.org --to broonie@kernel.org --cc bamvor.zhangjian@linaro.org *.patch`

18:15 2016-09-24
----------------
1.  Documentation/vm/pagemap.txt

15. COMPOUND_HEAD
16. COMPOUND_TAIL
    A compound page with order N consists of 2^N physically contiguous pages.
    A compound page with order 2 takes the form of "HTTT", where H donates its
    head page and T donates its tail page(s).  The major consumers of compound
    pages are hugeTLB pages (Documentation/vm/hugetlbpage.txt), the SLUB etc.
    memory allocators and various device drivers. However in this interface,
    only huge/giga pages are made visible to end users.

Before Linux 3.11 pagemap bits 55-60 were used for "page-shift" (which is
always 12 at most architectures). Since Linux 3.11 their meaning changes
after first clear of soft-dirty bits. Since Linux 4.2 they are used for
flags unconditionally.

2.  Documentation/vm/transhuge.txt
"mount -o remount,huge= /mountpoint" works fine after mount: remounting
huge=never will not attempt to break up huge pages at all, just stop more
from being allocated.

05:31 2016-09-26
-----------------
kselftest
---------
1.  rebasing
    1.  add the following things in dedicated commit:
        1.  %:%.c
        2.  CROSS_COMPILE
        3.  other in git diff

1.  TODO
    1.  check cflags and ldflags for fusemnt.o, fusemnt

12:31
1.  update doc according to kernel doc how.txt
2.  move doc to c source.

11:48 2016-09-28
----------------
ILP32
1.  About a public ILP32 build
to agraf
cc andrew wafaa, bamvor, hanjun, tianhong

Hi, Alex

I hope we could track it in email.

2.  Send Matt
Hi, Matt

Glad to discuss with you about ILP32 this morning. I put the Huawei guys who join the meeting in the loops.
Could you please send out the meeting minutes including action items and role/responsibility?

Regards

Bamvor

21:11 2016-09-28
----------------
1.  Changes since v3
    1.  remove name api in utils according the suggestion from Linus.
    2.  move the comment from header to implementation.
    3.  remove gpiotools_set_flags due to no one need this right now.
2.  I found that I have no time to finish this patch in connect.

16:42 2016-10-09
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-09-25 to 2016-10-01
Linaro connect report
*   ILP32 discussion
    1.  Goal: Discuss the upstream of ILP32 including upstream risk, performance regression, role/responsibilities

    2.  Everyone agree on that the target is 4.10 and 2.25. The merge windows of 4.10 for arm64 will open in next week, we need speed up or we will miss it. 4.11 is also possible.
        The kernel and glibc will merge only if kernel and glibc acknowledge at the same time.

    3.  Still want a distribution support(do not need to official version for upstreaming).
        1.  Suse: There is a internal build for ILP32 in suse. Suse will public it if there are enough hw resources. Huawei and Cavium could provide some. Suse hope there is commercial request for ILP32 build. Not sure if Huawei need this, will investigate internally.
            Notes: I do not sure if cavium really want to provide or just follow after Huawei say yes.
        2.  Debian: It seems that someone from ARM contacted debian community for an unofficial build. Not sure the latest progress.
        3.  Ubuntu: will contact ubuntu after ILP32 upstreamed.

    4.  ILP32 could be merged after there is no performance regression.

    5.  This meeting will hold one month once.

    6.  Role and responsbility
        1.  Two engineers from Cavium will work on the patches of kernel and glibc(excluding Andrew Pinski). Cavium will send out new patches after there is no performance regresssion.
        2.  Bamvor will compare the performance of LP64 between ILP32 unmerged and ILP32 disabled.
            The test suite is specint, lmbench and other reasonable benchmark. Bamvor will bring up D03 with upstream kernel and test specint as start point.

    7.  Attendee
        1.  ARM: Matt Spencer(organizer), Marc Zyngier, Andrew Wafaa, Mark Hambleton, Matthew Gretton-Dann;
        2.  Cavium: Andrew Pinski, Parsun Kapoor, Larry Wikelius;
        3.  Huawei: Bamvor Jian Zhang, Hanjun Guo, Tianhong Ding;
        4.  Linaro: Arnd Bergmann, Mark Brown, Ryan Arnold, Maxim Kuvyrkov, Adhemerval Zanella Netto.
        5.  Suse: not attend. But ask for the build resource for ILP32.

* KWG-192: Use of contiguous page hint to create 64K pages
    1.  The goal of this task is optimize performance of annoymous page for 4k.
    2.  Discuss design with Arnd. There are three methods.
        1.  The first method is force use hugetlb in mmap and brk if the lengh and alignment is multiple of 64k. This method consume the memory in hugetlb pool. It likes a hacking. And I wrote a patch with Arnd before connect, I would run lmbench in a filesystem built by buildroot. Some of memory relative performance improve a lot(reference the jira). But boot opensuse tumbleweed failed and run specint failed.
	2.  The second one is replace THP code of 2m bytes in pagefault with 64k page. At the beginning, it seems a generic function which make THP support all the size of page(like hugetlb). But later, I realize that replace 2m page with 64k could not get better performance, and hanlde in pmd level will not help handling the page in pte level.
	3.  So, we think about the third one. We plan to handle the 16 pages once in pte level when possible and set a flag to indicate it. We do not think clearly about how to handle it in SWAP, will deal with it later. We discuss this with Laura Abbott, Marc Zyngier and Christoffer Dall, no objection so far. Need performance benchmark such as specint to prove it. Maxim Kuvyrkov from tcwg hope we could find a way to improvement the result of specint for 4k page. I will contact Maxim again when I have some progress.
    3.  I am thinking if there is some senario suitable for this improvement.

* KWG-148 GPIO kselftest
    Discuss Linus about my patches. Linus accept the driver part and give some suggestion for userspace patch. I almost finish my new patches in travel. Hope I could send the new version this week.

* KWG 174: KBUILD_OUTPUT fix for kseltest
    Almost finish the code before connect. will work it later.

16:43 2016-10-09
----------------
Linaro connect总结(已发dingtianhong, 不要在原文修改)(已发dingtianhong, 不要在原文修改)(已发dingtianhong, 不要在原文修改)(已发dingtianhong, 不要在原文修改)
------------------
Performance regression of ILP32 seems the biggest blocker.
1.  讨论ILP32
    1.  参与人: ARM., Cavium, Huawei, Linaro
       ARM的networking manager Matt组织会议。Cavium Prasun, Andrew参会。arm和cavium还是比较重视的。
    2.  内核和glibc达成一致后会同时合入。以内核4.10和glibc2.25为目标. 由于4.10 arm64 merge windows下周会开始, 所以时间还是比较紧的.
    3.  Cavium会继续完善kernel和glibc的补丁(会有两个工程师投入，不算Andrew Pinski); 华为张健负责测试specint并解决performance regression问题（如果有）。
    4.  发行版支持:
        1.  华为会给suse提供D03用于公开原有suse内部的ILP32 build. Cavium也表示愿意提供板子。Commercial support?
        2.  和Debian联系，提供一个用于测试的build.
        3.  希望其它发行版(例如)ubuntu在glibc合入ILP2后支持。

2.  讨论Cont page hint
    1.  和Arnd讨论了三个方案，方案1是直接利用hugetlb，直接在mmap/brk中发现是64k对齐的64k页就强制使用hugetlk。方案2是把原有pmd层次的THP（2M映射）用64k page代替。方案3是在pte fault时，如果一个vma里面有足够的空间，每次连续分配16个pte，后面处理时如果没有特殊情况，都是16个pte统一处理。
    2.  经过分析，发现方案1比较简单，但是会占用hugetlb可用空间，lmbench测试表明有12%-18%（？）甚至300%的提升， 但是有些情况会出错，启动opensuse distribution失败。方案2修改THP不太划算，因为已有的THP工作的很好，修改后预期不到性能的改进。
    3.  方案3的优势是不论有没有cont page hint，因为节省了15次page fault都可以获得性能提升。对于arm/arm64有page hint bit，以及x86虽然没有hint但是会自动判断是否16个page映射相同，可以预期到性能会有提升.
    4.  方案3，Arnd和我一起与Laura Abbott, Marc Zyngier和Christoffer Dall讨论，目前没有反对意见，需要用性能测试证明有效。
    5.  和Geoff Levand讨论了我在做的这个事情。Geoff建议我看看我的工作对boltdb(一个go语言写的数据库, 现在用于CoreOS etcd)有没有帮助。这个数据库通常不会用到2M，1G这么大的页。64k对他来说是有好处的。cont page hint的场景会继续挖掘。

3.  Linaro在做bus scaling QoS和新的firmware标准。结合本部门arm64的计划，从系统角度看arm64还缺失什么东西也许是个切入点。
    1.  bus scaling qos. ELCE也有个topic, 可以再关注.
        是希望把NoC里面可配置的东西利用起来, 改善系统的功耗和性能.  胶片说现在的总线其实是个多层的环状或网状结构. 从cpu到设备其实需要经过多跳, 一般是有qos控制的, 但是现在硬件的这个能力内核是没用用起来的, 希望内核能初始化并且根据场景动态配置. 目前是打算用generic pm domain这个框架, 把总线的电源管理也管起来. ACPI maintainer Rafeal Wysocki在写部分补丁, 预计4.10合入. 考虑到我司芯片比较复杂, 感觉这个可能是改善arm性能的一个途径. 结合有人在把NUMA用在IO调度上. 感觉系统层次还有更多事情可做, 下一步打算和芯片同事交流下.

4.  Tianhong和Andrew Pinski讨论了Scalebility, Andrew建议看下v8.1 lse指令。我们想通过Mark Brown问LEG没有Cavium的板子可以用。LEG说有三个板子但是都在用，没有资源给我们用。

5.  和ARM，诺基亚等人讨论tickless，希望在某些核上把一秒的时钟中断也关闭。我们也有这个场景，表达了对这个特性的兴趣。

6.  Linaro又在尝试做新的东西，有人持观望态度，主要看linaro能不能把事情做成。
    1.  Linaro加入zephre, IoT操作系统。session里面比较强调安全。IoT demo包括用蓝牙BLE做的低功耗sensor，手机上有app可以直接控制，但是蓝牙距离比较近，目前的想法是用bluetooth to wifi和每个屋子的WiFi连接。
    2.  Linaro 96board新板子比较多，看起来Linaro想通过96board提高影响力，增加收入。
        1.  新增TV board（基于EE板子修改）；
        2.  AMD似乎不做arm64了（96板EE没有进展，Softiron做的AMD arm64盒子从6月份宣布后一直难产，已经两次宣布delay）；
        3  Linaro 96 board CE板子有两个新成员，一个是MTK的x20，10核芯片，据MTK合作方说现在都是海外客户，第一批2k已经卖完了。但是没有任何upstream想法，如果本身没有什么公用IP，这种情况下upstream会比较困难，这应该是目前upstream支持最差的96板，感觉这个板子可能会后劲不足。我司的hikey2 性能如果和MTK在一个量级，并且upstream预期比较好（因为有hikey upstream和AOSP的基础），还是比较有自己的特色。
            另一个是ST（？）的A9，特点是硬件video decoder是开源的。
        4.  看起来大家做96board都是把比较成熟的东西拿出来。

7.  自己感觉这是收获最大的connect，这次做的计划比较充分，在会议上交流观点效率比较高。有明确目标的话，去参会收获挺大的。

8.  需要追踪的:
    1.  ILP32每个月会有一定会议, 跟踪进展.
    2.  bus scaling qos补丁和Embedded Linux conference会议议题追踪.
    3.  5号dinner alex shi主动问到了华为待遇，感觉是有意愿动的，和linaro马上要上税有关(我以为早就上税了), 也许再看更合适的机会.

9.  需要个人追踪的:
    1.  uapi变更后需要更新编译器, 目前hulk没有这个流程.
    2.  了解社区补丁回合.
    3.  阅读gorman的Linux内存管理文章.

16:43 2016-10-09
----------------
linaro connect杂记
------------------
1.  问hanjun, tianhong和suse合作的事情，打算送更多的d03么？
DONE hanjun: Ask xinwei.
xinwei: It is ok. But maybe not 10 of D03. 160G harddisk is not problem.
In progess: ask alex about the D03 support for suse. Make sure D03 supporting before provide more D03.
2. DONE Ask Matt to add the Ryan, Maxim, Adhemal to ILP32 meeing.
3.  DONE discuss Andrew pinski and Andrew wafaa about ILP32 before Wednesday meeting. Prepare outline for wednesday meets.
4.  DONE: Wrote slide for kernel upstream
5.  NOT FINISH! kselftest. gpio.
6.  ILP32
      1.   Andrew will work on kernel and glibc.
      2.  Bamvor will work on the performance regression. Check the benchmark I need to run.
      3.  TODO: email Alex and Andrew Wafaa about ILP32 build for ILP32.
           It discussed on irc. It is better that in email. Loop tianhong and hanjun.
      4.  Andrew wafaa mentioned that it is glad if huawei could request commercial distro for ILP32. TODO: discuss with Hanjun, tianhong.
      5.  Doing: Find a guy in our team to help me run latest kernel in our hardware.
7.  FAIL: Tianhong will send me testcase and I will look for if the linaro employee could run the testcase on Cavium board.
8.  DONE: Tianhong discuss scalebility on arm64 with Andrew Pinski.  Andrew suggest that look into the lex instruction introduced by arm64.
9.  DONE: chat with Siddhesh Poyarekar who write glibc tunable configuration. Also do the plan for toolchain team.
10.  问下孙远，测试容器也能给开发用么？开发自测试，很不方便。
9.  TODO
    1.  DONE: discuss with rengeng about bus scaling QoS.
    2.  CANCEL: discuss with Christeoffer and Julien about the contigous page hint.
    3.  CORRECT: make sure there is not page hint in LKML.
        Arnd说社区没有.
    4.  DONE: 和alex shi/Mark Brown讨论ks补丁回合。
        alex说邮件讨论他和Mark赢了.  需要追踪.
    5.  TODO: Arnd told me that a guy(maxim) in toolchain hope kernel could improve the specint performance by enable the cont page hint of 64k pages. Try to catch this guy in dinner.  Discuss with Laura Abbott
https://www.kernel.org/doc/gorman/

AAR:
1.  ILP32
    1.  I should check the availability of toolchain guys as early as possible.
    2.  Ryan told me the TSC deny the request of working on the build of ILP32 in June or July. Xinwei forward the email of TSC at that time, I should suggest linaro do that at that time.


This week Linaro Power Team (PMWG) is having a set of themed hacking sessions focused on specific technical aspects of Linux power management. Here is the list of such sessions.

All the hacking sessions are going to be in the room named “Madrid”.

Mon, 26 Sep

16:00 / 4:00pm Update on LISA

Tue, 27 Sep

14:00 / 2:00pm Bus scaling QoS
15:00 / 3:00pm Cpuidle in details - theory
16:00 / 4:00pm Cpuidle in details - the code
17:00 / 5:00pm Towards an EAS energy model from DT

Wed, 28 Sep

14:00 / 2:00pm Benchmarking Schedutil in Android
15:00 / 3:00pm Coupling schedutil with EAS-core
16:00 / 4:00pm PELT behavior and known limitations

Thu, 29 Sep

14:00 / 2:00pm Don’t waste power when idle with runtime PM
15:00 / 3:00pm Power Farm Evolution
16:00 / 4:00pm Debugging PM with Jtag (hands-on) - 2 hours

NOTE: in case of any questions, please approach Vincent Guittot (PMWG TechLead) as I’m not at connect this time.

17:46 2016-10-11
----------------
„In theory, theory and practice are the same. In practice, they are not”
Albert Einstein

19:02 2016-10-13
----------------
Add gpio test framework

These series of patches try to add support for testing of gpio
subsystem based on the proposal from Linus Walleij. The first three
version is here[1][2][3].

The basic idea is implement a virtual gpio device(gpio-mockup) base
on gpiolib. Tester could test the gpiolib by manipulating gpio-mockup
device through chardev(default) or sysfs and check the result from
debugfs. Reference the following figure:

   sysfs/chardev      debugfs
     |                   |
  gpiolib----------------/
     |
 gpio-mockup

In order to avoid conflict with other gpio exist in the system,
only dynamic allocation is tested by default. User could pass -f to
do full test.

The test script could also test other (real) gpio device, such as
pl061 in my qemu:
./gpio-mockup.sh -m 9030000.pl061

Originally, there are 5 patches. 2 of them are merged by Linus:
a6a1cf3 gpio: MAINTAINERS: Add an entry for GPIO mockup driver
0f98dd1 gpio/mockup: add virtual gpio device

There series only include the others:
tools/gpio: add gpio basic opereations
tools/gpio: re-work gpio hammer with gpio operations
selftest/gpio: add gpio test case

[1] http://comments.gmane.org/gmane.linux.kernel.gpio/11883
[2] http://www.spinics.net/lists/linux-gpio/msg11700.html
[2] http://www.spinics.net/lists/linux-gpio/msg16255.html

Changes since v3:
1.  Rename the api in gpio-utils.[ch] with gpiotools.
2.  Update in kernel document according to the
    "Documentation/kernel-docs.txt", and move it to implementation.
3.  Remove useless label of goto according to the suggestion from
    Michael Welling.

Changes since v2:
1.  Switch to chardev.
2.  Add basic gpio operation for chardev.

Changes since v1:
1.  Change value of gpio to boolean.
2.  Only test dynamic allocation by default.

2.  send them out:
`git send-email --no-chain-reply-to --annotate --to linus.walleij@linaro.org --cc linux-gpio@vger.kernel.org --cc broonie@kernel.org --cc mwelling@ieee.org --cc shuahkh@osg.samsung.com *.patch`

11:05 2016-10-14
----------------
1.  There is a prot in vma. But I could not set the hint in prot. Because I do not know how many vma is 64k aligned. TODO check it.
2.  need to understand the mm_struct and vma
3.  read the code in do_anonymous_page:
    1.  It is a non-exclusive mmap_sem which mean I should lock all the 16 pages as soon as possible?
    2.  `__pte_alloc`:
        1.  It seems that __pte_alloc allocate a page and write to the specific pmd entry. I suppose this pmd should be offset of the pmd table.
        2.  pte_alloc_one: I need to alloc 16 pages if there is enough in vma.
            There are vm in fault_env.vma. I could check range.
            There is a fault_env.prealloc_pte could I pre allocated here? If I set the cont hint in pre-allocate, I may need invalidate the tlb entry if I could not allocate the cont 16 pages.
        3.  pmd_lock is a spinlock which is mm->page_table_lock. My understand is we need lock pmd when we want to change one of the pte in this pmd. Correct?
    3.  What does PTE_SPECIAL mean?

17:32 2016-10-14
----------------
software, skill, markdown to word, pandoc
-----------------------------------------
<http://hi.ktsee.com/383.html>: `pandoc -f markdown -t html ./report.md | pandoc -f html -t docx -o report.docx`

20:26 2016-10-14
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-10-09 to 2016-10-14
=== Highlights ===
* KWG-148 GPIO kselftest
    - Address the comment from Linus and Micheal Welling
    - Send out v4 patches today.

* ILP32
    - Spend some time to set up the test machine with uptream kernel with my colleague. Eventually, it works and test lmbench tonight. Hope could get the first version of lmbench result on next Monday.

* Conference summary
    - Spend hours to summary the linaro connect(Chinese and English) and LCE(Chinese).

* KWG-192: Use of contiguous page hint to create 64K pages
    - Read part of the book in  https://www.kernel.org/doc/gorman/.
    - Some notes when read the code:
      * Read the `do_anonymous_page`. I should take care the difference lock when I change the code.
      * There is vma in fault_env. I think I could check range here.
      * There is a fault_env.prealloc_pte. Could I pre allocated here? If I set the cont hint in pre-allocate, I may need invalidate the tlb entry if I could not allocate the cont 16 pages in the next comming page fault.

=== Plans ===
ILP32 performance test
  - Test lmbench and fix the bug if found.

* KWG-192: Use of contiguous page hint to create 64K pages
  - Continue read the code in wp and other case.

* KWG 174: KBUILD_OUTPUT fix for kseltest
  - Send out the patches.

10:06 2016-10-17
----------------
1.  las16需要追踪的:
    1.  ILP32每个月会有一定会议, 跟踪进展.
    2.  bus scaling qos补丁和Embedded Linux conference会议议题追踪.
    3.  5号dinner alex shi主动问到了华为待遇，感觉是有意愿动的，和linaro马上要上税有关(我以为早就上税了), 也许再看更合适的机会.
2.  LCE2016
    1.  关注memory barrier测试工具.
    2.  建议hanjun和jiri提前讨论living patch for arm64.

20:10 2016-10-17
----------------
(18:47 2016-10-21)update

Subject: [PATCH RFC 0/6] enable O and KBUILD_OUTPUT for kselftest

Here is my first version for enabling the KBUILD_OUTPUT for kselftest.
I fix and test all the TARGET in tools/testing/selftest/Makefile. For
ppc, I test through fake target.

There are six patches in these series. And five of them clean up the
existing code. I split the clean up patches into five, hope it is easy
to review.

selftests: remove duplicated all and clean target
selftests: remove useless TEST_DIRS
selftests: add pattern rules
selftests: remove CROSS_COMPILE in dedicated Makefile
selftests: add EXTRA_CLEAN for clean target
selftests: enable O and KBUILD_OUTPUT

In the first patch, I split the test files into two types:
TEST_GEN_XXX means such file is generated during compiling. TEST_XXX
means there is no need to compile before use. The main reason of this
is the enablement of KBUILD_OUTPUT only need to care about TEST_GEN_XXX.
I wanted to copy all the TEST_XXX with TEST_GEN_XXX, but I give up this
idea in the end. Because people may puzzle why copy the file before
installation.

Because of the introducing of TEST_GEN_XXX, I update the top-level
Makefile and lib.mk selftests directory. After introduce TEST_GEN_XXX I
could remove all the unnecessary all and clean targets.

The second patch remove TEST_DIRS variable. And third patch add the
pattern for compiling the c sourc code. The fourth patch remove the
useless CROSS_COMPILE variable as it aleady exists in
"tools/testing/selftests/lib.mk".

Further more, The fifth patch add the EXTRA_CLEAN variable to clean up
the duplicated clean target

The last patch introduce the KBUILD_OUTPUT and O for kselftest instead
using the existing kbuild system because user may compile kselftest
directly (make -C tools/testing/selftests).

git send-email --no-chain-reply-to --annotate --to shuahkh@osg.samsung.com --cc linux-api@vger.kernel.org --cc linux-kernel@vger.kernel.org --cc khilman@kernel.org --cc broonie@kernel.org --cc mpe@ellerman.id.au 000*.patch

14:54 2016-10-18
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.
 * do_fault_around() tries to map few pages around the fault address. The hope
 * is that the pages will be needed soon and this will lower the number of
 * faults to handle.

I think I could ignore prealloc_pte later as do_fault_around will allocate and map(through map_pages).
do_fault_around is called by do_fault which is the non-anonymous page in handle_pte_fault.

2.  Read do_wp_page()

16:03 2016-10-18
----------------
int fd;
char path[PATH_MAX];

fd = open(".", O_TMPFILE | O_RDWR , 07777);
snprintf(path, PATH_MAX, "/proc/self/fd/%d", fd);
linkat(AT_FDCWD, path, AT_FDCWD, "/tmp/tmpfile", AT_SYMLINK_FOLLOW);

testcases/kernel/syscalls/open/open14.c

man 2 open
       O_CREAT
              If the file does not exist it will be created.  The owner (user ID) of the file is set to the  effec-
              tive  user ID of the process.  The group ownership (group ID) is set either to the effective group ID
              of the process or to the group ID of the parent directory (depending on file system  type  and  mount
              options,  and  the  mode  of  the  parent  directory,  see the mount options bsdgroups and sysvgroups
              described in mount(8)).

              mode specifies the permissions to use in case a new file is created.  This argument must be  supplied
              when O_CREAT is specified in flags; if O_CREAT is not specified, then mode is ignored.  The effective
              permissions are modified by the process's umask in the usual way: The permissions of the created file
              are  (mode & ~umask).  Note that this mode applies only to future accesses of the newly created file;
              the open() call that creates a read-only file may well return a read/write file descriptor.

glibc 2.11
#### CALL=open NUMBER=2 ARGS=i:siv SOURCE=-
ifeq (,$(filter open,$(unix-syscalls)))
unix-syscalls += open
$(foreach p,$(sysd-rules-targets),$(foreach o,$(object-suffixes),$(objpfx)$(patsubst %,$p,open)$o)): \
                $(..)sysdeps/unix/make-syscalls.sh
        $(make-target-directory)
        (echo '#define SYSCALL_NAME open'; \
         echo '#define SYSCALL_NARGS 3'; \
         echo '#define SYSCALL_SYMBOL __libc_open'; \
         echo '#define SYSCALL_CANCELLABLE 1'; \
         echo '#include <syscall-template.S>'; \
         echo 'weak_alias (__libc_open, __open)'; \
         echo 'libc_hidden_weak (__open)'; \
         echo 'weak_alias (__libc_open, open)'; \
         echo 'libc_hidden_weak (open)'; \
         echo 'weak_alias (__libc_open, __open64)'; \
         echo 'libc_hidden_weak (__open64)'; \
         echo 'weak_alias (__libc_open, open64)'; \
         echo 'libc_hidden_weak (open64)'; \
        ) | $(compile-syscall) $(foreach p,$(patsubst %open,%,$(basename $(@F))),$($(p)CPPFLAGS))
endif

commit 65f6f938cd562a614a68e15d0581a34b177ec29d
Author: Eric Rannaud <e@nanocritical.com>
Date:   Tue Feb 24 13:12:26 2015 +0530

    linux: open and openat ignore 'mode' with O_TMPFILE in flags

    Both open and openat load their last argument 'mode' lazily, using
    va_arg() only if O_CREAT is found in oflag. This is wrong, mode is also
    necessary if O_TMPFILE is in oflag.

    By chance on x86_64, the problem wasn't evident when using O_TMPFILE
    with open, as the 3rd argument of open, even when not loaded with
    va_arg, is left untouched in RDX, where the syscall expects it.

    However, openat was not so lucky, and O_TMPFILE couldn't be used: mode
    is the 4th argument, in RCX, but the syscall expects its 4th argument in
    a different register than the glibc wrapper, in R10.

http://man7.org/linux/man-pages/man2/open.2.html
 The mode argument specifies the file mode bits be applied when a new file is created.  This argument must be supplied when O_CREAT or O_TMPFILE is specified in flags; if neither O_CREAT nor O_TMPFILE is specified, then mode is ignored.

[Unreviewed code in 3.11](https://lwn.net/Articles/562294/)
The O_TMPFILE option to the open() system call was pulled into the mainline during the 3.11 merge window; prior to that pull, it had not been posted in any public location. There is no doubt that it provides a useful feature; it allows an application to open a file in a given filesystem with no visible name. In one stroke, it does away with a whole range of temporary file vulnerabilities, most of which are based on guessing which name will be used. O_TMPFILE can also be used with the linkat() system call to create a file and make it visible in the filesystem, with the right permissions, in a single atomic step. There can be no doubt that application developers will want to make good use of this functionality once it becomes widely available.

[open() flags: O_TMPFILE and O_BENEATH](https://lwn.net/Articles/619146/)
 Amusingly, the original bug was discovered while digging into a related glibc bug. It seems that, when O_TMPFILE is used, the mode argument isn't passed into the kernel at all. In the case of open() on x86-64 machines, things work out of sheer luck: the mode argument just happens to be sitting in the right register when glibc makes the call into the kernel. Things do not work as well with openat(), though, with the result that, in current glibc installations, O_TMPFILE cannot be used with openat() at all. The bug is well understood and should be fixed soon.

15:43 2016-10-19
----------------
1.  Compare the first 5 in each kernel, list all the ILP32_disabled worse than ILP32_unmerged above 1%.
    1.  Processor, Processes - times in microseconds - smaller is better
        *   open clos: 5.46%
        *   Fork proc: 4.32%

    2.  File & VM system latencies in microseconds - smaller is better
        *   0K Create: 4.44%
        *   File Delete: 1.83%

    3.  *Local* Communication bandwidths in MB/s - bigger is better
        *   TCP: -1.30%
        *   Bcopy(libc): -1.32%

2.  all the 15 test result: list all the ILP32_disabled worse than ILP32_unmerged above 1%.
    The "sh proc" seem abnormal. I plan to test such case again.
    1.  Processor, Processes - times in microseconds - smaller is better
        *   open clos: 4.04%
        *   sh proc: 14.47%

    2.  Context switching - times in microseconds - smaller is better
        *   8p/16k ctxsw: 2.27%

    3.  File & VM system latencies in microseconds - smaller is better
        *   0K Create: 3.68%
        *   File Delete: 1.83%
        *   Prot Fault: 1.82%

    4.  *Local* Communication bandwidths in MB/s - bigger is better
        *   Pipe: -1.70%

3.  cmd
    1.  open/close: mkdir -p /usr/tmp; touch /usr/tmp/lmbench; lat_syscall -P 1 open /usr/tmp/lmbench
    2.  0k create: lat_fs /usr/tmp


4.  specint
                (ILP32_disabled-ILP32_unmerged)/ILP32_unmerged
400.perlbench       0%
401.bzip2       -0.65%
403.gcc          0.26%
429.mcf          2.75%
445.gobmk           0%
456.hmmer       -4.34%
458.sjeng           0%
462.libquantum      0%
471.omnetpp      0.59%
473.astar       -0.34%
483.xalancbmk   -0.90%

5.  arnd:
bamvor: if the .config is identical, the two tests that stick out most (mcf and hmmer) would be candidates for looking at with perf as well. probably the lmbench tests that show a big difference are easier to analyse, so maybe look at them first

6. (19:17 2016-10-24)update
    1.  lmbench
                    enable_aarch32_el0   disable_aarch32_el0
         open clos               4.04%                 1.89%
         0K Create               3.68%                 2.14%

    2.  specint
    (ILP32_disabled-ILP32_unmerged)/ILP32_unmerged
                    enable_aarch32_el0   disable_aarch32_el0
    400.perlbench                   0%                 0.22%
    401.bzip2                   -0.65%                 0.95%
    403.gcc                      0.26%                 0.20%
    429.mcf                      2.75%                 0.76%
    445.gobmk                       0%                 0.36%
    456.hmmer                   -4.34%                -2.06%
    458.sjeng                       0%                -0.27%
    462.libquantum                  0%                -1.28%
    471.omnetpp                  0.59%                 0.86%
    473.astar                   -0.34%                -0.85%
    483.xalancbmk               -0.90%                 0.08%

21:04 2016-10-19
----------------
1.  2/6 TEST_DIR
    ```
    The TEST_DIRS was introduced in Commit e8c1d7cdf137 ("selftests: copy
    TEST_DIRS to INSTALL_PATH") for coping a whole directory in ftrace.
    After rsync(with -a) is introduced by Commit 900d65ee11aa ("selftests:
    change install command to rsync"). Rsync could handle the directory
    without the definition of TEST_DIRS.

    This patch simply replace TEST_DIRS with TEST_FILES in ftrace and remove
    the TEST_DIRS in tools/testing/selftest/lib.mk
    ```

2.  3/6 add pattern ruls
    ```
    [PATCH RFD 3/6] selftests: add default rules for c source file

    There are difference rules for compiling c source file in different
    testcases. In order to enable KBUILD_OUTPUT support in later patch,
    this patch introduce the default rules in
    "tools/testing/selftest/lib.mk" and remove the existing rules in each
    testcase.
    ```

3.  4/6. CROSS_COMPILE
    ```
    After previous clean up patches, memfd and timers could get
    CROSS_COMPILE from tools/testing/selftest/lib.mk. There is no need to
    preserve these definition. So, this patch remove them.
    ```
4.  5/6 EXTRA_CLEAN
    ```
    Some testcases need the clean extra data after running. This patch
    introduce the "EXTRA_CLEAN" variable to address this requirement.

    After KOUTPUT_BUILD is enabled in later patch, it will be easy to
    decide to if we need do the cleanup in the KOUTPUT_BUILD path, if the
    testcase ran immediately after compiled.
    ```

20:35 2016-10-20
----------------
z00293696@d03-02:~/works/source/kernel/hulk> ./tools/perf/perf top
Error:
You may not have permission to collect system-wide stats.

Consider tweaking /proc/sys/kernel/perf_event_paranoid,
which controls use of the performance events system by
unprivileged users (without CAP_SYS_ADMIN).

The current value is 2:

  -1: Allow use of (almost) all events by all users
>= 0: Disallow raw tracepoint access by users without CAP_IOC_LOCK
>= 1: Disallow CPU event access by users without CAP_SYS_ADMIN
>= 2: Disallow kernel profiling by users without CAP_SYS_ADMIN
z00293696@d03-02:~/works/source/kernel/hulk> cat /proc/sys/kernel/perf_event_paranoid
2
z00293696@d03-02:~/works/source/kernel/hulk> echo -1 > /proc/sys/kernel/perf_event_paranoid
-bash: /proc/sys/kernel/perf_event_paranoid: Permission denied
z00293696@d03-02:~/works/source/kernel/hulk> sudo echo -1 > /proc/sys/kernel/perf_event_paranoid
-bash: /proc/sys/kernel/perf_event_paranoid: Permission denied
z00293696@d03-02:~/works/source/kernel/hulk> su
Password:
d03-02:/home/z00293696/works/source/kernel/hulk # echo -1 > /proc/sys/kernel/perf_event_paranoid

21:09 2016-10-20
----------------
1.  I hope you could add s-o-b in the following patch. And I suggest add s-o-b of Chengming Zhou <zhouchengming1@huawei.com> for 16/18.
Subject: [PATCH 07/18] arm64: introduce is_a32_task and is_a32_thread (for AArch32 compat)
`Subject: [PATCH 08/18] arm64: ilp32: add is_ilp32_compat_{task,thread} and TIF_32BIT_AARCH64`
Subject: [PATCH 10/18] arm64: ilp32: introduce binfmt_ilp32.c
Subject: [PATCH 12/18] arm64: ilp32: add sys_ilp32.c and a separate table (in entry.S) to use it
Subject: [PATCH 13/18] arm64: signal: share lp64 signal routines to ilp32
Subject: [PATCH 16/18] arm64: ptrace: handle ptrace_request differently for aarch32 and ilp32
Subject: [PATCH 17/18] arm64:ilp32: add vdso-ilp32 and use for signal return

2.  Do we need add more comment in the following patch?
    1.  for the newly introduced USE_AARCH64_GREG:
        Subject: [PATCH 10/18] arm64: ilp32: introduce binfmt_ilp32.c
    2.  Subject: [PATCH 13/18] arm64: signal: share lp64 signal routines to ilp32

3.  little suggestion for comments:
    1.  Subject: [PATCH 16/18] arm64: ptrace: handle ptrace_request differently for aarch32 and ilp32
        Here new aarch32 ptrace syscall handler is introsuced to avoid run-time
        s/introsuced/introduced
    2.  Subject: [PATCH 17/18] arm64:ilp32: add vdso-ilp32 and use for signal return
        Usually, the kernel use the following format of Commit in commit message:
        commit 601255ae3c98 ("arm64: vdso: move data page before code pages")

4.  remove the tab in the doc:
diff --git a/Documentation/arm64/ilp32.txt b/Documentation/arm64/ilp32.txt
index d39ae82..3be35cb 100644
--- a/Documentation/arm64/ilp32.txt
+++ b/Documentation/arm64/ilp32.txt
@@ -22,8 +22,8 @@ Syscalls which pass 64bit values are handled by the code shared from
 AARCH32 and pass that value as a pair. Next syscalls are affected:
 fadvise64_64()
 fallocate()
-ftruncate64()
-pread64        ()
+ftruncate64()
+pread64()
 pwrite64()
 readahead()
 sync_file_range()

10:55 2016-10-21
----------------
syscall unit test
1.  用途: 内核和glibc接口一致性检查
    1.  设计系统调用的特性合入检查, 例如ILP32, kexec.
    2.  内核和glibc版本升级检查.
2.  TODO
    1.  提高测试速度, 能不能快速测试提前暴露问题?

16:43 2016-10-21
----------------
perf record -g -e "syscall:*" -e "sched:sched_switch" lat_syscall -P 1 open /usr/tmp/lmbench

19:32 2016-10-21
----------------
only test open/close and 0K file create
1.  ilp32 disabled no aarch32
    1.  open/close
    [z00293696@d03-02 lmbench-3.0-a9]$ lat_syscall -P 1 open /usr/tmp/lmbench
    Simple open/close: 3.0099 microseconds
    Simple open/close: 2.9817 microseconds
    Simple open/close: 2.9477 microseconds
    Simple open/close: 3.0199 microseconds
    Simple open/close: 2.9374 microseconds
    Simple open/close: 3.0864 microseconds
    Simple open/close: 2.9706 microseconds
    Simple open/close: 2.9440 microseconds
    Simple open/close: 2.9600 microseconds
    Simple open/close: 2.9308 microseconds

    (3.0099+ 2.9817+ 2.9477+ 3.0199+ 2.9374+ 3.0864+ 2.9706+ 2.9440+ 2.9600+ 2.9308)/10=2.9788
    2.  0k create
    0k      392     71260   92005
    1k      212     38552   53650
    4k      207     37595   53390
    10k     127     23466   43802
    0k      418     72218   89792
    1k      214     38126   53948
    4k      205     38055   54103
    10k     128     23512   44471
    0k      414     71863   91863
    1k      216     37968   53745
    4k      215     37568   54114
    10k     128     23503   44186
    0k      395     72570   91154
    1k      209     38483   53782
    4k      222     38302   54183
    10k     129     23942   43896
    0k      405     71923   89850
    1k      211     38128   53379
    4k      211     38392   53953
    10k     134     23742   43636
    0k      428     72261   90176
    1k      213     38247   53849
    4k      216     37709   54816
    10k     130     23564   44018
    0k      410     72336   92064
    1k      192     38224   53772
    4k      211     38156   54217
    10k     131     23966   44112
    0k      395     71910   90811
    1k      211     38032   53571
    4k      211     38350   54849
    10k     130     23675   44205
    0k      429     73358   90247
    1k      215     38188   54101
    4k      214     37650   54200
    10k     129     23814   43989
    0k      402     71658   92263
    1k      212     37993   53910
    4k      217     37713   54344
    10k     133     23869   43677


    (1000000.0 / 71260 + 1000000.0 / 72218 + 1000000.0 / 71863 + 1000000.0 / 72570 + 1000000.0 / 71923 + 1000000.0 / 72261 + 1000000.0 / 72336 + 1000000.0 / 71910 + 1000000.0 / 73358 + 1000000.0 / 71658 ) / 10 = 13.86

2.  ilp32-unmerged-no-aarch32
    1.  open/close
    [z00293696@d03-02 lmbench-3.0-a9]$ for i in `seq 1 10`; do lat_syscall -P 1 open /usr/tmp/lmbench; done
    Simple open/close: 2.9459 microseconds
    Simple open/close: 3.0377 microseconds
    Simple open/close: 2.9295 microseconds
    Simple open/close: 2.9037 microseconds
    Simple open/close: 2.9434 microseconds
    Simple open/close: 2.8373 microseconds
    Simple open/close: 2.9010 microseconds
    Simple open/close: 2.9028 microseconds
    Simple open/close: 2.8775 microseconds
    Simple open/close: 2.9579 microseconds

    (2.9459 + 3.0377 + 2.9295 + 2.9037 + 2.9434 + 2.8373 + 2.9010 + 2.9028 + 2.8775 + 2.9579) / 10 = 2.9237

    1.89%

    2.  0k create

    [z00293696@d03-02 lmbench-3.0-a9]$ for i in `seq 1 10`; do lat_fs /usr/tmp; done
    0k      398     72707   91511
    1k      202     37821   54081
    4k      216     37875   54461
    10k     127     23703   44571
    0k      429     74080   93682
    1k      214     37689   54348
    4k      218     38205   54769
    10k     127     23703   44235
    0k      429     73991   91102
    1k      201     37683   53938
    4k      216     37474   54114
    10k     128     23603   44436
    0k      426     74190   92743
    1k      218     38212   54196
    4k      214     37570   53985
    10k     132     23991   45067
    0k      423     73706   91587
    1k      221     38163   53714
    4k      210     37453   54425
    10k     133     23844   44920
    0k      432     73821   91348
    1k      219     38307   53873
    4k      216     37809   54673
    10k     127     23681   44137
    0k      415     73791   91571
    1k      217     37779   54134
    4k      214     38139   54801
    10k     128     23599   44624
    0k      425     73913   91151
    1k      223     38231   54249
    4k      208     37464   54433
    10k     133     23573   44153
    0k      426     73639   91183
    1k      217     38258   54087
    4k      217     37543   54605
    10k     135     23680   44412
    0k      407     73639   91737
    1k      212     37945   54350
    4k      212     37877   54589
    10k     127     23545   44619

    (1000000.0 / 72707 + 1000000.0 / 74080 + 1000000.0 / 73991 + 1000000.0 / 74190 + 1000000.0 / 73706 + 1000000.0 / 73821 + 1000000.0 / 73791 + 1000000.0 / 73913 + 1000000.0 / 73639 + 1000000.0 / 73639)/10=13.56

    (13.85-13.56)/13.56 = 2.14%

21:33 2016-10-21
----------------
kernel, gpio
------------
KWG-148 GPIO kselftest
----------------------
```
>> +CFLAGS += -O2 -g -std=gnu99 -Wall -I../../../../usr/include/
>Is this really what people are doing?
>Isn't -I/usr/include the right way to express this?
"/usr/include" is not correct for cross-compiling.

>> +LDLIBS += -lmount -I/usr/include/libmount
>> +
>> +$(BINARIES): ../../../gpio/gpio-utils.o ../../../../usr/include/linux/gpio.h
>> +
>> +../../../gpio/gpio-utils.o:
>> +       make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C ../../../gpio
>Ah, that is clever. I hope I can get an ACK from Shuah if this is
>how we're supposed to handle cross dependencies of common
>helper code in the kernel.
There are similar code in "tools/perf/tests/make". But I am not sure
if it is who I suppose to do.

>It looks a bit spaghetti, unfortunately.
>> +../../../../usr/include/linux/gpio.h:
>> +       make -C ../../../.. headers_install
>Don't do this please, you would have to be root and it's very
>fragile.
Sorry for this. At least, I should make use of INSTALL_HDR_PATH.

>How does tests in general resolve dependencies on
>kernel headers? Please look around a bit and check what
>they do. I think they just expect them to be installed.
I check the relative file through "grep usr.include tools/ -R -l",
there are three types:
1.  Use relative path like me but do not "make headers_install"
2.  Like my patch: use relative path and install headers when missing.
3.  Use /usr/include

And there is a discussion from Ben Hutchings[1]:
   Tools include UAPI headers in one of two ways, neither of which is
   reliable:
   - Assume the current headers are on the system include path
   - Include unprocessed UAPI headers through a relative path

   The right thing to do is to run 'make headers_install' and add
   usr/ to the front of the system include path.  But we'd want a
   way to avoid re-doing that when the UAPI headers haven't changed.

And there is a checker in "tools/perf/Makefile.perf" for $(PERF_IN)
target. But it is very long. We definitely need a better solution.
It may be in seperate patch.

how about introduce a dedicate Makefile in tools directory which
install necessary header to user defined path
(path/to/linux/usr/include by default)?

Or I just remove the following lines in this patch, and update it after
we find better solution?
../../../../usr/include/linux/gpio.h:
       make -C ../../../.. headers_install

cc: Ben Hutchings, Randy Dunlap and Arnaldo Carvalho de Melo.

>I like the tests overall, but I'm a bit suspicious about the
>sysfs tests. Maybe these should atleast print something
>about the sysfs ABI being deprecated.
Sound reasonable. I could add a prompt and wait user confirm when user
want to test through sysfs. Is it what you want?
I think we could remove the sysfs script when we remove the sysfs
interface of gpio in kernel.
>
>Anyways I merged the first two patches so now we only have to
>figure out this final patch!
Thanks all your help:)

Regards

Bamvor
>
>Yours,
>Linus Walleij

[1] https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2016-August/003270.html

Ben Hutchings <ben@decadent.org.uk>
Randy Dunlap <rdunlap@infradead.org>
Arnaldo Carvalho de Melo <acme@redhat.com>
```

19:48 2016-10-24
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-10-15 to 2016-10-24
=== Highlights ===
* KWG-148 GPIO kselftest
    - Linus ack another two patches. Only one patch need to discuss.
      Thanks all the help from Linus and Mark:)

    - One of the comment from Linus actually out of the scope of my
      single patch, it may need more time to discuss with Shuah or other
      maintainers. It is about how to update/install kernel headers for
      tools. There is a discussion[1] in ksummit-discuss(cced them in
      our discussion). The thing is we could not check the header in
      either "/usr/include" nor "linux/usr/include" and we should only
      update the headers when it changes

      I am thinking if we could introduce a dedicate Makefile in tools
      directory which install necessary header to user defined path
      (path/to/linux/usr/include by default).

      Hope we could find a solution for it.

* ILP32
    - Performance test for LP64
      Compare the performance of aarch64 LP64 between mainline kernel
      (4.8-rc6 actually due to some downupstream patch of D03) and
      ILP32 merged but disabled kernel. The test show that some of the
      testcases get visiable worse. After discuss with Arnd and Mark,
      I compare the kernel config, there is no difference except
      changing COMPAT to AARCH32_EL0(We had to change it because ILP32
      is another COMPAT(32bit) application). I planed to perf the
      testcase but after enable some debug features our network driver
      crash.

      Another test I do in the weekend is disabled aarch32 el0/compat.
      The result show that the difference decreased. The big difference
      is 2.14% of 0K file create in lmbench and -2.06% of specint.

      2% is a small difference for me(correct?). I plan to bisect the
      patches of ILP32 to find out which patch affect result.(e.g.
      the differnce between 4.04% and 1.89% for open/close). My feeling
      and hoping is that the result of enable_aarch32_el0 is a
      reasonable changes.

      The percentagge equals (ILP32_disabled-ILP32_unmerged)/ILP32_unmerged

      1.  lmbench(smaller is better)
                      enable_aarch32_el0   disable_aarch32_el0
           open clos               4.04%                 1.89%
           0K Create               3.68%                 2.14%

      2.  specint(bigger is better)
                      enable_aarch32_el0   disable_aarch32_el0
      400.perlbench                   0%                 0.22%
      401.bzip2                   -0.65%                 0.95%
      403.gcc                      0.26%                 0.20%
      429.mcf                      2.75%                 0.76%
      445.gobmk                       0%                 0.36%
      456.hmmer                   -4.34%                -2.06%
      458.sjeng                       0%                -0.27%
      462.libquantum                  0%                -1.28%
      471.omnetpp                  0.59%                 0.86%
      473.astar                   -0.34%                -0.85%
      483.xalancbmk               -0.90%                 0.08%

    - Add S-o-B in some of patches before yury send out rfc3 of v7
      last week. Thanks for yury.

* KWG-192: Use of contiguous page hint to create 64K pages
    - Read the code. No much progress.

* Found a unmerged bug for openat in our glibc which fix missing mode if
  flag is O_TMPFILE. X86 is not affected by this bug. Reference the
  notes in my blog:
  <http://aarch64.me/2016/10/2016-10-18-openat-and-open-a-close-lookat-in-kernel-and-glibc/>

* Setup my own vpn because the other two vpns are not very stable today.

=== Plans ===
ILP32 performance test
  - Bisect the performance changes patch by patch.
  - Fix the crash of network driver lead by profiling feature.

* KWG-192: Use of contiguous page hint to create 64K pages
  - Continue read the code.

* KWG 174: KBUILD_OUTPUT fix for kseltest
  - Ask Shuah Khan if she could give me some suggestion about how to
    update the headers.

[1] https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2016-August/003270.html

10:53 2016-10-27
----------------
arm64, ILP32
------------
1.  merge the updated patch which is introduced by Commit dbd4d7ca563f ("arm64: Rework valid_user_regs")
```
diff --git a/arch/arm64/kernel/ptrace.c b/arch/arm64/kernel/ptrace.c
index 083dc71..2cc8d6c 100644
--- a/arch/arm64/kernel/ptrace.c
+++ b/arch/arm64/kernel/ptrace.c
@@ -1448,7 +1448,7 @@ int valid_user_regs(struct user_pt_regs *regs, struct task_struct *task)
        if (!test_tsk_thread_flag(task, TIF_SINGLESTEP))
                regs->pstate &= ~DBG_SPSR_SS;

-       if (is_compat_thread(task_thread_info(task)))
+       if (is_a32_compat_thread(task_thread_info(task)))
                return valid_compat_regs(regs);
        else
                return valid_native_regs(regs);
```

16:29 2016-10-27
----------------
specint, LP64 performance regresssion
-------------------------------------
1.  Test the mid commit
"8947bfe arm64:uapi: set __BITS_PER_LONG correctly for ILP32 and LP64"
misc> python specint_get_data.py ~/works/source/testsuite/testresult/ilp32/20161026_1027_lmbench_specint_LP64/specint/8947bfe_aarch32_enable/ ~/works/source/testsuite/testresult/ilp32/20161022_1024_specint_LP64/ILP32_
unmerged/
       401.bzip2:  1.03%
         429.mcf: -0.74%
       456.hmmer: -2.88%
  462.libquantum: -1.72%

summary
         name        | enabled_aarch32_el0_bit_per_long  | enable_aarch32_el0  | disable_aarch32_el0
---------------------|-----------------------------------|---------------------|--------------------
      401.bzip2      |                            1.03%  |             -0.65%  |               0.95%
      429.mcf        |                           -0.74%  |              2.75%  |               0.76%
      456.hmmer      |                           -2.88%  |             -4.34%  |              -2.06%
      462.libquantum |                           -1.72%  |                 0%  |              -1.28%

2.  (10:25 2016-10-28)retest yesterday
```
z00293696@linux696:20161027_lmbench_specint_LP64> ~/works/reference/small_tools_collection/misc/specint_get_data.py afb510f_ilp32_disabled__aarch32_on_specint a5ba168_ilp32_unmerged__aarch32_on_specint
diff: (afb510f_ilp32_disabled__aarch32_on_specint - a5ba168_ilp32_unmerged__aarch32_on_specint) / a5ba168_ilp32_unmerged__aarch32_on_specint
total 1 tests
total 1 tests
{'429.mcf': 8.57, '401.bzip2': 9.23, '462.libquantum': 16.7, '456.hmmer': 13.6}
{'429.mcf': 8.52, '401.bzip2': 9.19, '462.libquantum': 16.0, '456.hmmer': 13.4}
       401.bzip2:  0.44%
         429.mcf:  0.59%
       456.hmmer:  1.49%
  462.libquantum:  4.37%
z00293696@linux696:20161027_lmbench_specint_LP64> ~/works/reference/small_tools_collection/misc/specint_get_data.py 8947bfe_bit_per_long__aarch32_on_specint/ a5ba168_ilp32_unmerged__aarch32_on_specint
diff: (8947bfe_bit_per_long__aarch32_on_specint/ - a5ba168_ilp32_unmerged__aarch32_on_specint) / a5ba168_ilp32_unmerged__aarch32_on_specint
total 1 tests
total 1 tests
{'429.mcf': 8.34, '401.bzip2': 9.2, '462.libquantum': 16.0, '456.hmmer': 13.9}
{'429.mcf': 8.52, '401.bzip2': 9.19, '462.libquantum': 16.0, '456.hmmer': 13.4}
       401.bzip2:  0.11%
         429.mcf: -2.11%
       456.hmmer:  3.73%
  462.libquantum: 0.00%
```

            name | enabled_aarch32_el0_bit_per_long | enable_aarch32_el0
-----------------|----------------------------------|--------------------
       401.bzip2 |                            0.11% |              0.44%
         429.mcf |                           -2.11% |              0.59%
       456.hmmer |                            3.73% |              1.49%
  462.libquantum |                            0.00% |              4.37%

The bzip2 and mcf just have 1% difference. But hmmer and libquantum is change a lot. I test hammer again with --size=test,train,ref and --tune=base,peak which is similar to reportable run: "runspec --config=Arm64-single-core-linux64-arm64-lp64-gcc49.cfg --size=test,train,ref --noreportable --tune=base,peak --iterations=3 --verbose 1 hmmer"

(16:09 2016-10-29)update
(11:31 2016-10-31)update
z00293696@linux696:20161028_specint_LP64> ~/works/reference/small_tools_collection/misc/specint_get_data.py b5107ca__introduce_binfmt_ilp32__ilp32_disabled_aarch32_on a5ba168_ilp32_unmerged__aarch32_on
diff: (b5107ca__introduce_binfmt_ilp32__ilp32_disabled_aarch32_on - a5ba168_ilp32_unmerged__aarch32_on) / a5ba168_ilp32_unmerged__aarch32_on
Original numbers:
{'462.libquantum': 16.0, '429.mcf': 8.59, '401.bzip2': 9.25, '456.hmmer': 13.8}
{'462.libquantum': 16.0, '456.hmmer': 13.8, '429.mcf': 8.37, '401.bzip2': 9.15}

Diff:
b5107ca__introduce_binfmt_ilp32__ilp32_disabled_aarch32_off
       401.bzip2:  1.09%
         429.mcf:  2.63%
       456.hmmer: 0.00%
  462.libquantum: 0.00%
z00293696@linux696:20161028_specint_LP64> ~/works/reference/small_tools_collection/misc/specint_get_data.py afb510f_ilp32_full_merged__ilp32_disabled_aarch32_on a5ba168_ilp32_unmerged__aarch32_on
diff: (afb510f_ilp32_full_merged__ilp32_disabled_aarch32_on - a5ba168_ilp32_unmerged__aarch32_on) / a5ba168_ilp32_unmerged__aarch32_on
Original numbers:
{'429.mcf': 8.34, '456.hmmer': 14.1, '462.libquantum': 16.0, '401.bzip2': 9.28}
{'462.libquantum': 16.0, '456.hmmer': 13.8, '429.mcf': 8.37, '401.bzip2': 9.15}

Diff:
afb510f_ilp32_full_merged__ilp32_disabled_aarch32_off
       401.bzip2:  1.42%
         429.mcf: -0.36%
       456.hmmer:  2.17%
  462.libquantum: 0.00%

aarch32-disabled
                   introduce_binfmt_ilp32 ilp32-merged-disabled
       401.bzip2:  1.09%                   1.42%
         429.mcf:  2.63%                  -0.36%
       456.hmmer:  0.00%                   2.17%
  462.libquantum:  0.00%                   0.00%

3.  Analysis above result:
```
afb510f fix stat
adae8a0 arm64:ilp32: add ARM64_ILP32 to Kconfig
5a3a2c9 arm64:ilp32: add vdso-ilp32 and use for signal return
6f346a0 arm64: ptrace: handle ptrace_request differently for aarch32 and ilp32
71e8487 arm64: ilp32: introduce ilp32-specific handlers for sigframe and ucontext
0bb5267 arm64: signal32: move ilp32 and aarch32 common code to separated file
209fd42 arm64: signal: share lp64 signal routines to ilp32
149d0db arm64: ilp32: add sys_ilp32.c and a separate table (in entry.S) to use it
f791ec5 arm64: ilp32: share aarch32 syscall handlers
b5107ca arm64: ilp32: introduce binfmt_ilp32.c
99e9119 arm64: introduce binfmt_elf32.c
464c58d arm64: ilp32: add is_ilp32_compat_{task,thread} and TIF_32BIT_AARCH64
2607ec2 arm64: introduce is_a32_task and is_a32_thread (for AArch32 compat)
4622f2c thread: move thread bits accessors to separated file
8947bfe arm64:uapi: set __BITS_PER_LONG correctly for ILP32 and LP64
31b690e arm64: rename COMPAT to AARCH32_EL0 in Kconfig
de08b73 arm64: ensure the kernel is compiled for LP64
2f2523a arm64: ilp32: add documentation on the ILP32 ABI for ARM64
b43c4a1 32-bit ABI: introduce ARCH_32BIT_OFF_T config option
d2f5228 fiz set_personality by Catalin
```
Reference "15:38 2016-10-31"

4.  lmbench(more than 3%): I could not trust my test result...
    1.  Processor, Processes - times in microseconds - smaller is better
        *   open clos: 3.42%
        *   sig hndl: -3.09%

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------------------
Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                         ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ------ ------ ------ ------ ------ ------- -------
d03-02    Linux 4.8.0-r 2.9560 3.0460 2.9980 4.2860 4.8060 3.94800 8.57200
d03-02    Linux 4.8.0-r 2.7840 2.9880 2.9040 4.8160 3.7760 3.95600 8.26200
d03-02    Linux 4.8.0-r 6.18% 1.94% 3.24% -11.00% 27.28% -0.20% 3.75%

    2.  File & VM system latencies in microseconds - smaller is better
        *   Prot Fault: 30.60%

    3.  *Local* Communication bandwidths in MB/s - bigger is better
*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
d03-02    Linux 4.8.0-r 1750 2760 2144 1953.8 3311.1 2345.6 2749.2 3382 3135.
d03-02    Linux 4.8.0-r 1693 2779 2137 1997.9 3040.5 2241.9 2563.3 3129 3131.
d03-02    Linux 4.8.0-r 3.37% -0.68% 0.33% -2.21% 8.90% 4.63% 7.25% 8.09% 0.13%

5.  The difference decreased when aarch32-enabled and ilp32 enabled.
> ~/works/reference/small_tools_collection/misc/specint_get_data.py afb510f_aarch32_on_ilp32_on a5ba168_aarch32_on_ilp32_on
diff: (afb510f_aarch32_on_ilp32_on - a5ba168_aarch32_on_ilp32_on) / a5ba168_aarch32_on_ilp32_on
Original numbers:
{'429.mcf': 8.59, '401.bzip2': 9.25, '462.libquantum': 16.8, '456hmmer': 13.8}
{'429.mcf': 8.59, '401.bzip2': 9.16, '462.libquantum': 16.9, '456.hmmer': 13.9}

Diff:
afb510f_aarch32_on_ilp32_on
       401.bzip2:  0.98%
         429.mcf:  0.00%
       456.hmmer: -0.72%
  462.libquantum: -0.59%

###the table may not correct!
                  |introduce_binfmt_ilp32_aarch32-disabled|ilp32-merged-disabled_aarch32-disabled|ilp32-merged-enabled_aarch32-enabled
------------------|---------------------------------------|--------------------------------------|------------------------------------
       401.bzip2  |1.09%                                  |                    1.42%             |             0.98%
         429.mcf  |2.63%                                  |                   -0.36%             |             0.00%
       456.hmmer  |0.00%                                  |                    2.17%             |            -0.72%
  462.libquantum  |0.00%                                  |                    0.00%             |            -0.59%
###the table may not correct!###end
(15:06 2016-11-04)update
Compare the aarch32 disable, ilp32 disable in 28, Oct and 4, Nov.
diff: (20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/ - 20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/) / 20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/
Original numbers:
{'429.mcf': 8.34, '456.hmmer': 14.1, '462.libquantum': 16.0, '401.bzip2': 9.28}
{'462.libquantum': 16.0, '456.hmmer': 13.8, '429.mcf': 8.37, '401.bzip2': 9.15}

Diff:
20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/
       401.bzip2:  1.42%
         429.mcf: -0.36%
       456.hmmer:  2.17%
  462.libquantum: 0.00%
z00293696@linux696:ilp32> ~/works/reference/small_tools_collection/misc/specint_get_data.py 20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/ 20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/
diff: (20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/ - 20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/) / 20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/
Original numbers:
{'429.mcf': 8.6, '401.bzip2': 9.22, '462.libquantum': 16.6, '456.hmmer': 13.7}
{'429.mcf': 8.35, '401.bzip2': 9.2, '462.libquantum': 15.9, '456.hmmer': 13.7}

Diff:
20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/
       401.bzip2:  0.22%
         429.mcf:  2.99%
       456.hmmer: 0.00%
  462.libquantum:  4.40%
(15:06 2016-11-04)end
(11:13 2016-11-07)
z00293696@linux696:20161104_specint_LP64_ilp32_on_aarch32_on> ~/works/reference/small_tools_collection/misc/specint_get_data.py a5ba168_ilp32_unmerged/ afb510f_ilp32_merged/
diff: (a5ba168_ilp32_unmerged/ - afb510f_ilp32_merged/) / afb510f_ilp32_merged/
Original numbers:
{'429.mcf': 8.31, '401.bzip2': 9.2, '462.libquantum': 16.6, '456.hmmer': 13.7}
{'429.mcf': 8.34, '401.bzip2': 9.26, '462.libquantum': 16.0, '456.hmmer': 13.7}

Diff:
a5ba168_ilp32_unmerged/
       401.bzip2: -0.65%
         429.mcf: -0.36%
       456.hmmer: 0.00%
  462.libquantum:  3.75%


z00293696@linux696:ilp32> ~/works/reference/small_tools_collection/misc/specint_get_data.py --testresult 20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/ --testresult 20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/ --testbase  20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/ --testbase  20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/
The test result:
['20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/', '20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/']
The test base:
['20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/', '20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/']
z00293696@linux696:ilp32> ~/works/reference/small_tools_collection/misc/specint_get_data.py --testresult 20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/ --testresult 20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/ --testbase  20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/ --testbase  20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/
The test result:
['20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/', '20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/']
The test base:
['20161028_specint_LP64/a5ba168_ilp32_unmerged__aarch32_disabled/', '20161103_specint_LP64_aarch32_disable/a5ba168_ilp32_unmerged_aarch32_disable/']
Original numbers:
{'429.mcf': 8.469999999999999, '456.hmmer': 13.899999999999999, '462.libquantum': 16.3, '401.bzip2': 9.25}
{'462.libquantum': 15.95, '456.hmmer': 13.75, '429.mcf': 8.36, '401.bzip2': 9.175}

Diff:
['20161028_specint_LP64/afb510f_ilp32_full_merged__ilp32_disabled_aarch32_disabled/', '20161103_specint_LP64_aarch32_disable/afb510f_ilp32_disable_aarch32_disable/']
       401.bzip2:  0.82%
         429.mcf:  1.32%
       456.hmmer:  1.09%
  462.libquantum:  2.19%
z00293696@linux696:ilp32> ~/works/reference/small_tools_collection/misc/specint_get_data.py --testresult 20161031_specint_LP64_aarch32_enable/afb510f_aarch32_on_ilp32_on/ --testresult 20161104_specint_LP64_ilp32_on_aarch32_on/afb510f_ilp32_merged/ --testbase 20161031_specint_LP64_aarch32_enable/a5ba168_aarch32_on_ilp32_on/ --testbase 20161104_specint_LP64_ilp32_on_aarch32_on/a5ba168_ilp32_unmerged/
The test result:
['20161031_specint_LP64_aarch32_enable/afb510f_aarch32_on_ilp32_on/', '20161104_specint_LP64_ilp32_on_aarch32_on/afb510f_ilp32_merged/']
The test base:
['20161031_specint_LP64_aarch32_enable/a5ba168_aarch32_on_ilp32_on/', '20161104_specint_LP64_ilp32_on_aarch32_on/a5ba168_ilp32_unmerged/']
Original numbers:
{'429.mcf': 8.465, '401.bzip2': 9.254999999999999, '462.libquantum': 16.4, '456.hmmer': 13.75}
{'429.mcf': 8.45, '401.bzip2': 9.18, '462.libquantum': 16.75, '456.hmmer': 13.8}

Diff:
['20161031_specint_LP64_aarch32_enable/afb510f_aarch32_on_ilp32_on/', '20161104_specint_LP64_ilp32_on_aarch32_on/afb510f_ilp32_merged/']
       401.bzip2:  0.82%
         429.mcf:  0.18%
       457.hmmer: -0.36%
  462.libquantum: -2.09%
(11:13 2016-11-07)end

6.  Comapre the commit:
    1.  changes from ilp32 unmerged to b5107ca ("arm64: ilp32: introduce binfmt_ilp32.c")
        ```
        -#define SET_PERSONALITY(ex)            clear_thread_flag(TIF_32BIT);
        +#define SET_PERSONALITY(ex)            \
        +do {                                           \
        +       clear_thread_flag(TIF_32BIT_AARCH64);   \
        +       clear_thread_flag(TIF_32BIT);           \
        +} while (0)

        STACK_RND_MASK() take 2x time when aarch32 and ilp32 is enabled. Similar to TASK_SIZE
        -#define STACK_RND_MASK                 (test_thread_flag(TIF_32BIT) ? \
        +#define STACK_RND_MASK                 (is_compat_task() ? \
                                                        0x7ff >> (PAGE_SHIFT - 12) : \
                                                        0x3ffff >> (PAGE_SHIFT - 12))
        ```

    2.  changes from b5107ca ("arm64: ilp32: introduce binfmt_ilp32.c") to ilp32 fully merged
        The changes in arch/arm64/kernel/entry.S will not affect the LP64 apps.
        There is some changs in arch/arm64/kernel/signal.c, but the logic is same.

17:45 2016-10-28
----------------
1.  What I could ignore at this point
    1.  feature
        1.  CONFIG_TRANSPARENT_HUGEPAGE
            1.  pmd_trans_unstable():

    2.  header
        1.  arm64 do not use 4level-fixup.h
            ```
            z00293696@linux696:upstream-cont-page> grep_kernel 4level-fixup.h arch/
            arch/m32r/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/microblaze/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/sparc/include/asm/pgtable_32.h:#include <asm-generic/4level-fixup.h>
            arch/arm/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/alpha/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/parisc/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/blackfin/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/c6x/include/asm/pgtable.h:#include <asm-generic/4level-fixup.h>
            arch/m68k/include/asm/pgtable_mm.h:#include <asm-generic/4level-fixup.h>
            arch/m68k/include/asm/pgtable_no.h:#include <asm-generic/4level-fixup.h>
            ```

2.  I should take into account:
    1.  PTE_SPECIAL: for zero page.

3.  TODO:
    1.  print the fe->vma. Is it the whole vma?
    2.  How should I deal with the pte_lockptr? Should I lock the pte depends on the cont flag?
        Where should I define the cont flag?
    3.  I need find out where should I put the cont page track. It seems that anon_vma is a good candicate. But I do not fully understand it.
    4.  need more understand for fe->pmd, do I need 16 pmds or one pmd?

15:38 2016-10-31
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-10-25 to 2016-10-30
* ILP32
    - Update is_compat_thread to is_a32_compat_thread in arch/arm64/kernel/ptrace.c after LTS patch merged into our stable kernel.
    - Performance test for LP64
      * Yury send the lmbench result which seems difference from my test(I will test it with the specific kernel config)

      * specint
        Re-test the specint with reportable flow(--size=test,train,ref --tune=base,peak --iterations=3) for bzip2 mcf hmmer libquantum. The result show that enabled/disabled aarch32 el0 is -5.33 max difference in libquantum:
       401.bzip2: -0.11%
         429.mcf: -2.56%
       456.hmmer: -0.72%
  462.libquantum: -5.33%

        But if I compare the result between ILP32 (merged and enabled) and ILP32 unmerged.(Both enable aarch32 el0 and compat respectively). There is no much difference:
                  |ilp32-merged-enabled_aarch32-enabled
------------------|------------------------------------
       401.bzip2  |             0.98%
         429.mcf  |             0.00%
       456.hmmer  |            -0.72%
  462.libquantum  |            -0.59%
* Misc
    - Investigate writev fails in LTP in both ILP32 and LTP. The behavivor of writev changed slightly for invalid buffer. After the changes, the writev will write 0 and raise EFAULT which is as same as write. The new testcase of LTP is commited either. Reference the details in my blog[1].

[1] http://aarch64.me/2016/10/writev-behavior-change-a-little-bit/

* KWG-192: Use of contiguous page hint to create 64K pages
    - No big progress this week. Hope could focus on this in next week.

* 1:1 with Mark

=== Plans ===
ILP32 performance test
  - Dicuss with Mark/Arnd. Do more test if needed.

* KWG-192: Use of contiguous page hint to create 64K pages
  - Started to write patch in do_anonymous_page().


11:54 2016-11-02
I do not know I could get_pty. 
#       -D -m   This  also starts screen in "detached" mode, but doesn't fork a new process.
#               The command exits if the session terminates.
                        #c = "screen -D -m " + c

The following things works:
                channel = transport.open_session()
                if detach:
                        c = "screen -L " + c

                print(c)
                #channel.get_pty(term="vt100", width=80, height=24)
                channel.get_pty()
                channel.exec_command(c)

10:37 2016-11-04
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  Why is MM_MMUFLAGS relative to 64k page. It is pte level when enable 64k page, otherwise it is pmd level. Is it because 64k page need 2 or 3 level compare to 3 or 4 for 4k page?
2.  pmd from `handle_pte_fault()`->`do_anonymous_page()` is allocated in `__handle_mm_fault()`.
3.  TODO walk the page table by hand. Understand how many pgd, pud, pmd, pte is used. Including 2, 3 and 4 levels.
4.  (14:46 2016-11-05)
    After read the code again, I realize that I should allocate more page in one pte entry. Not allocate more pte entries. Because the pte point to the pages.
    I need to check whether the address overflow in vma and one pte index(512 entries).
5.
    ```
    /*
     * We could change fe->pte safely because we exit handle_pte_fault
     * after exit do_anonymous_page. And fe is allocated in
     * __handle_mm_fault.
     * There is no need to set the flat of cont pte because we only do the
     * cont when 16 contiguous pages align with 16 * PAGE_SIZE of start address.
     */
#define max_num_of_pte (16)
    static int do_anonymous_page(struct fault_env *fe)
    ```
6.  dead lock after changes:
    ```
    [    2.565831] random: fast init done
    [    2.888652]
    [    2.888777] =============================================
    [    2.888919] [ INFO: possible recursive locking detected ]
    [    2.889121] 4.9.0-rc2-next-20161028-00004-g36adf46-dirty #9 Not tainted
    [    2.889297] ---------------------------------------------
    [    2.889456] systemd/1 is trying to acquire lock:
    [    2.889672]  ([    2.889787] &(ptlock_ptr(page))->rlock
    ){+.+...}[    2.889975] , at:
    [    2.890326] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [    2.890513]
    [    2.890513] but task is already holding lock:
    [    2.890705]  ([    2.890786] &(ptlock_ptr(page))->rlock
    ){+.+...}[    2.890968] , at:
    [    2.891067] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [    2.891230]
    [    2.891230] other info that might help us debug this:
    [    2.891439]  Possible unsafe locking scenario:
    [    2.891439]
    [    2.891607]        CPU0
    [    2.891694]        ----
    [    2.891781]   lock([    2.891857] &(ptlock_ptr(page))->rlock
    [    2.891983] );
    [    2.892054]   lock([    2.892130] &(ptlock_ptr(page))->rlock
    [    2.892256] );
    [    2.892327]
    [    2.892327]  *** DEADLOCK ***
    [    2.892327]
    [    2.892499]  May be due to missing lock nesting notation
    [    2.892499]
    [    2.892711] 2 locks held by systemd/1:
    [    2.892831]  #0: [    2.892901]  (
    &mm->mmap_sem[    2.893028] ){++++++}
    , at: [    2.893192] [<ffff000008097874>] do_page_fault+0xd4/0x360
    [    2.893363]  #1: [    2.893431]  (
    &(ptlock_ptr(page))->rlock[    2.893582] ){+.+...}
    , at: [    2.893718] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [    2.893897]
    [    2.893897] stack backtrace:
    [    2.894135] CPU: 0 PID: 1 Comm: systemd Not tainted 4.9.0-rc2-next-20161028-00004-g36adf46-dirty #9
    [    2.894375] Hardware name: linux,dummy-virt (DT)
    [    2.894609] Call trace:
    [    2.894720] [<ffff000008088ad0>] dump_backtrace+0x0/0x1b0
    [    2.894906] [<ffff000008088c94>] show_stack+0x14/0x20
    [    2.895066] [<ffff0000083cea44>] dump_stack+0xb4/0xf0
    [    2.895226] [<ffff00000810dbdc>] __lock_acquire+0x51c/0x18e0
    [    2.895397] [<ffff00000810f2fc>] lock_acquire+0x4c/0x70
    [    2.895583] [<ffff0000089487bc>] _raw_spin_lock+0x4c/0x90
    [    2.895750] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [    2.895920] [<ffff0000081c6a28>] handle_mm_fault+0x728/0xd40
    [    2.896100] [<ffff000008097a18>] do_page_fault+0x278/0x360
    [    2.896272] [<ffff0000080812d4>] do_mem_abort+0x44/0xb0
    [    2.896509] Exception stack(0xffff80007c47bc80 to 0xffff80007c47bdb0)
    [    2.896788] bc80: 0000000000000ba0 0001000000000000 ffff80007c47be50 ffff000008235f18
    [    2.897014] bca0: ffff80007c47bce0 ffff00000810d920 ffff80007c4707f8 ffff000009db9000
    [    2.897229] bcc0: 0000000000000013 ffff000009026000 ffff0000092f8bd0 0000000000000000
    [    2.897443] bce0: ffff80007c47bde0 ffff00000810f2fc ffff80007c478000 0000000000000140
    [    2.897658] bd00: ffff80007b1d2540 00000000000001ed 00000000ffffff9c 000000003d8567b0
    [    2.897875] bd20: ffff80007bf1f460 0000000000000000 0000000000000000 0000000000000000
    [    2.898086] bd40: 0001000000000000 ffff80007b200407 ffff80007b200407 fefefefefefefeff
    [    2.898300] bd60: 0000000000000000 0000000000000000 622e6f746e716662 7f7f7f7f7f7f7f7f
    [    2.898512] bd80: 0101010101010101 0000000000000007 ffffffffffffffff 0000ffff9dee2580
    [    2.898718] bda0: ffff000008236ef0 0000ffff9de4a000
    [    2.898889] [<ffff0000080825c4>] el1_da+0x18/0x78
    [    2.899043] [<ffff000008236f44>] SyS_mount+0x54/0xe0
    [    2.899214] [<ffff000008082ef0>] el0_svc_naked+0x24/0x28
    [   14.221107] BUG: spinlock lockup suspected on CPU#0, systemd/1
    [   14.221372]  lock: 0xffff80007b1e0168, .magic: dead4ead, .owner: systemd/1, .owner_cpu: 0
    [   14.221604] CPU: 0 PID: 1 Comm: systemd Not tainted 4.9.0-rc2-next-20161028-00004-g36adf46-dirty #9
    [   14.221829] Hardware name: linux,dummy-virt (DT)
    [   14.221967] Call trace:
    [   14.222091] [<ffff000008088ad0>] dump_backtrace+0x0/0x1b0
    [   14.222247] [<ffff000008088c94>] show_stack+0x14/0x20
    [   14.222387] [<ffff0000083cea44>] dump_stack+0xb4/0xf0
    [   14.222571] [<ffff000008112a08>] spin_dump+0x68/0x90
    [   14.222728] [<ffff000008112c4c>] do_raw_spin_lock+0x17c/0x1b0
    [   14.222902] [<ffff0000089487dc>] _raw_spin_lock+0x6c/0x90
    [   14.223073] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [   14.223246] [<ffff0000081c6a28>] handle_mm_fault+0x728/0xd40
    [   14.223414] [<ffff000008097a18>] do_page_fault+0x278/0x360
    [   14.223578] [<ffff0000080812d4>] do_mem_abort+0x44/0xb0
    [   14.223733] Exception stack(0xffff80007c47bc80 to 0xffff80007c47bdb0)
    [   14.223917] bc80: 0000000000000ba0 0001000000000000 ffff80007c47be50 ffff000008235f18
    [   14.224135] bca0: ffff80007c47bce0 ffff00000810d920 ffff80007c4707f8 ffff000009db9000
    [   14.224345] bcc0: 0000000000000013 ffff000009026000 ffff0000092f8bd0 0000000000000000
    [   14.224556] bce0: ffff80007c47bde0 ffff00000810f2fc ffff80007c478000 0000000000000140
    [   14.224767] bd00: ffff80007b1d2540 00000000000001ed 00000000ffffff9c 000000003d8567b0
    [   14.224979] bd20: ffff80007bf1f460 0000000000000000 0000000000000000 0000000000000000
    [   14.225213] bd40: 0001000000000000 ffff80007b200407 ffff80007b200407 fefefefefefefeff
    [   14.225429] bd60: 0000000000000000 0000000000000000 622e6f746e716662 7f7f7f7f7f7f7f7f
    [   14.225642] bd80: 0101010101010101 0000000000000007 ffffffffffffffff 0000ffff9dee2580
    [   14.225850] bda0: ffff000008236ef0 0000ffff9de4a000
    [   14.225998] [<ffff0000080825c4>] el1_da+0x18/0x78
    [   14.226149] [<ffff000008236f44>] SyS_mount+0x54/0xe0
    [   14.226305] [<ffff000008082ef0>] el0_svc_naked+0x24/0x28
    [   28.102585] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [systemd:1]
    [   28.102819] Modules linked in:
    [   28.103003] irq event stamp: 207211
    [   28.103125] hardirqs last  enabled at (207211): [   28.103288] [<ffff00000813521c>] current_kernel_time64+0xac/0xc0
    [   28.103456] hardirqs last disabled at (207210): [   28.103596] [<ffff00000813519c>] current_kernel_time64+0x2c/0xc0
    [   28.103754] softirqs last  enabled at (207036): [   28.103881] [<ffff0000080c64dc>] __do_softirq+0x20c/0x280
    [   28.104026] softirqs last disabled at (206999): [   28.104151] [<ffff0000080c68c4>] irq_exit+0xc4/0xf0
    [   28.104297]
    [   28.104392] CPU: 0 PID: 1 Comm: systemd Not tainted 4.9.0-rc2-next-20161028-00004-g36adf46-dirty #9
    [   28.104602] Hardware name: linux,dummy-virt (DT)
    [   28.104731] task: ffff80007c470000 task.stack: ffff80007c478000
    [   28.104900] PC is at do_raw_spin_lock+0x1a0/0x1b0
    [   28.105034] LR is at do_raw_spin_lock+0x17c/0x1b0
    [   28.105167] pc : [<ffff000008112c70>] lr : [<ffff000008112c4c>] pstate: 20000145
    [   28.105344] sp : ffff80007c47b960
    [   28.105459] x29: ffff80007c47b960 x28: 000000003d85a000
    [   28.105653] x27: ffff80007c47bbc8 x26: ffff80007b1f2d10
    [   28.105819] x25: ffff00000900f000 x24: ffff000008feb000
    [   28.105983] x23: ffff000008caa000 x22: 0000000000000008
    [   28.106150] x21: 0000000003b9aca0 x20: 0000000003b9aca0
    [   28.106313] x19: ffff80007b1e0168 x18: ffff000009ad85a0
    [   28.106476] x17: 00000000000016df x16: 0000000000000002
    [   28.106639] x15: 00000000000016e2 x14: 6666663030303020
    [   28.106801] x13: 0000000000000000 x12: 000000000000000f
    [   28.106963] x11: ffff80007c47b5c0 x10: ffff80007c47b5c0
    [   28.107147] x9 : 0000000000000130 x8 : 0000000000000000
    [   28.107313] x7 : ffff80007ee16090 x6 : 0000000000003ff0
    [   28.107476] x5 : ffff80007c47be90 x4 : ffff80007ee16090
    [   28.107640] x3 : ffff80007c47bfe0 x2 : 0000000000000004
    [   28.107802] x1 : 0000000000000001 x0 : 0000000000050004
    [   28.107969]
    [   28.894593] INFO: rcu_preempt detected stalls on CPUs/tasks:
    [   28.894884]  (detected by 0, t=6502 jiffies, g=447, c=446, q=1)
    [   28.895170] All QSes seen, last rcu_preempt kthread activity 6502 (4294899511-4294893009), jiffies_till_next_fqs=1, root ->qsmask 0x0
    [   28.895506] systemd         R  running task        0     1      0 0x00000002
    [   28.895786] Call trace:
    [   28.895881] [<ffff000008088ad0>] dump_backtrace+0x0/0x1b0
    [   28.896024] [<ffff000008088c94>] show_stack+0x14/0x20
    [   28.896164] [<ffff0000080f04ec>] sched_show_task+0x11c/0x220
    [   28.896312] [<ffff00000812b090>] rcu_check_callbacks+0xa40/0xa50
    [   28.896467] [<ffff00000812f3b4>] update_process_times+0x34/0x60
    [   28.896620] [<ffff00000813fe9c>] tick_sched_handle.isra.16+0x2c/0x70
    [   28.896779] [<ffff00000813ff24>] tick_sched_timer+0x44/0x90
    [   28.896924] [<ffff00000812fca8>] __hrtimer_run_queues+0xa8/0x170
    [   28.897079] [<ffff0000081302e4>] hrtimer_interrupt+0xa4/0x1e0
    [   28.897231] [<ffff0000087c74bc>] arch_timer_handler_virt+0x2c/0x40
    [   28.897389] [<ffff00000811f3a8>] handle_percpu_devid_irq+0x78/0x120
    [   28.897549] [<ffff000008119ff4>] generic_handle_irq+0x24/0x40
    [   28.897698] [<ffff00000811a6bc>] __handle_domain_irq+0x5c/0xc0
    [   28.897848] [<ffff0000080815c8>] gic_handle_irq+0x58/0xb0
    [   28.897993] Exception stack(0xffff80007c47b830 to 0xffff80007c47b960)
    [   28.898173] b820:                                   0000000000050004 0000000000000001
    [   28.898362] b840: 0000000000000004 ffff80007c47bfe0 ffff80007ee16090 ffff80007c47be90
    [   28.898550] b860: 0000000000003ff0 ffff80007ee16090 0000000000000000 0000000000000130
    [   28.898738] b880: ffff80007c47b5c0 ffff80007c47b5c0 000000000000000f 0000000000000000
    [   28.898930] b8a0: 6666663030303020 00000000000016e2 0000000000000002 00000000000016df
    [   28.899122] b8c0: ffff000009ad85a0 ffff80007b1e0168 0000000003b9aca0 0000000003b9aca0
    [   28.899310] b8e0: 0000000000000008 ffff000008caa000 ffff000008feb000 ffff00000900f000
    [   28.899500] b900: ffff80007b1f2d10 ffff80007c47bbc8 000000003d85a000 ffff80007c47b960
    [   28.899688] b920: ffff000008112c4c ffff80007c47b960 ffff000008112c70 0000000020000145
    [   28.899876] b940: ffff80007c47b960 ffff000008112c4c 0001000000000000 0000000003b9aca0
    [   28.900066] [<ffff0000080827b4>] el1_irq+0xb4/0x12c
    [   28.900198] [<ffff000008112c70>] do_raw_spin_lock+0x1a0/0x1b0
    [   28.900350] [<ffff0000089487dc>] _raw_spin_lock+0x6c/0x90
    [   28.900497] [<ffff0000081c5d6c>] do_anonymous_page+0x18c/0x720
    [   28.900649] [<ffff0000081c6a28>] handle_mm_fault+0x728/0xd40
    [   28.900798] [<ffff000008097a18>] do_page_fault+0x278/0x360
    [   28.900954] [<ffff0000080812d4>] do_mem_abort+0x44/0xb0
    [   28.901092] Exception stack(0xffff80007c47bc80 to 0xffff80007c47bdb0)
    [   28.901258] bc80: 0000000000000ba0 0001000000000000 ffff80007c47be50 ffff000008235f18
    [   28.901454] bca0: ffff80007c47bce0 ffff00000810d920 ffff80007c4707f8 ffff000009db9000
    [   28.901648] bcc0: 0000000000000013 ffff000009026000 ffff0000092f8bd0 0000000000000000
    [   28.901845] bce0: ffff80007c47bde0 ffff00000810f2fc ffff80007c478000 0000000000000140
    [   28.902039] bd00: ffff80007b1d2540 00000000000001ed 00000000ffffff9c 000000003d8567b0
    [   28.902237] bd20: ffff80007bf1f460 0000000000000000 0000000000000000 0000000000000000
    [   28.902434] bd40: 0001000000000000 ffff80007b200407 ffff80007b200407 fefefefefefefeff
    [   28.902627] bd60: 0000000000000000 0000000000000000 622e6f746e716662 7f7f7f7f7f7f7f7f
    [   28.902824] bd80: 0101010101010101 0000000000000007 ffffffffffffffff 0000ffff9dee2580
    [   28.903017] bda0: ffff000008236ef0 0000ffff9de4a000
    [   28.903154] [<ffff0000080825c4>] el1_da+0x18/0x78
    [   28.903287] [<ffff000008236f44>] SyS_mount+0x54/0xe0
    [   28.903426] [<ffff000008082ef0>] el0_svc_naked+0x24/0x28
    [   28.903679] rcu_preempt kthread starved for 6502 jiffies! g447 c446 f0x2 RCU_GP_WAIT_FQS(3) ->state=0x0
    [   28.903909] rcu_preempt     R  running task        0     7      2 0x00000000
    [   28.904151] Call trace:
    [   28.904248] [<ffff0000080858d8>] __switch_to+0x88/0xb0
    [   28.904469] [<ffff000008941ce4>] __schedule+0x1e4/0x720
    [   28.904614] [<ffff00000894225c>] schedule+0x3c/0xb0
    [   28.904749] [<ffff000008948080>] schedule_timeout+0x170/0x2d0
    [   28.904901] [<ffff00000812a014>] rcu_gp_kthread+0x534/0x7c0
    [   28.905049] [<ffff0000080e36c0>] kthread+0xd0/0xf0
    [   28.905186] [<ffff000008082e80>] ret_from_fork+0x10/0x50
    ```

12:28 2016-11-07
----------------
kernel, ILP32
-------------
20161104_lmbench_LP64_ilp32_on_aarch32_on
1.  Processor, Processes - times in microseconds - smaller is better
    1.  null call -3.70%
    2.  stat 4.76%
    3.  open close 3.99%
    4.  select TCP -4.02%
    5.  exec proc 2.64%
    6.  original data:
        ```
        Host                 OS  Mhz null null      open slct sig  sig  fork exec sh  
                                     call  I/O stat clos TCP  inst hndl proc proc proc
        --------- ------------- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
        d03-02    Linux 4.8.0-r 2099 0.26 0.36 1.32 3.13 5.01 0.44 1.63 300. 778. 2198
        d03-02    Linux 4.8.0-r 2099 0.27 0.36 1.26 3.01 5.22 0.44 1.66 302. 758. 2168
        d03-02    Linux 4.8.0-r 0.00% -3.70% 0.00% 4.76% 3.99% -4.02% 0.00% -1.81% -0.66% 2.64% 1.38%
        ```

2.  Context switching - times in microseconds - smaller is better
    1.  original data:
        ```
        Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                                 ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
        --------- ------------- ------ ------ ------ ------ ------ ------- -------
        d03-02    Linux 4.8.0-r 2.6200 2.9520 2.7860 4.0940 3.8120 3.90200 7.63200
        d03-02    Linux 4.8.0-r 2.8780 3.0180 2.9520 4.0240 3.5800 4.28800 6.82600
        d03-02    Linux 4.8.0-r -8.96% -2.19% -5.62% 1.74% 6.48% -9.00% 11.81%
        ```

3.  *Local* Communication latencies in microseconds - smaller is better
    1.  original data:
        ```
        Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                                ctxsw       UNIX         UDP         TCP conn
        --------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
        d03-02    Linux 4.8.0-r 2.620 7.717 9.28  16.6        21.3        36.
        d03-02    Linux 4.8.0-r 2.878 8.133 9.29  17.1        21.8        37.
        d03-02    Linux 4.8.0-r -8.96% -5.11% -0.11%  -2.92%        -2.29%        -2.70%
        ```

4.  File & VM system latencies in microseconds - smaller is better
    1.  Page Fault: 4.21%
    2.  100fd select: -8.44%
    3.  original data:
        ```
        Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
                                Create Delete Create Delete Latency Fault  Fault  selct
        --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
        d03-02    Linux 4.8.0-r   13.9   10.8   41.0   22.2   14.4K 0.213 0.77612 1.854
        d03-02    Linux 4.8.0-r   13.7   10.6   41.0   22.4   14.5K 0.216 0.74480 2.025
        d03-02    Linux 4.8.0-r   1.46%   1.89%   0.00%   -0.89%   -0.69% -1.39% 4.21% -8.44%
        ```

5.  *Local* Communication bandwidths in MB/s - bigger is better
    1.  File reread: 5.79%
        ```
        -----------------------------------------------------------------------------
        Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                                     UNIX      reread reread (libc) (hand) read write
        --------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
        d03-02    Linux 4.8.0-r 1689 2782 2144 1940.6 3148.8 2253.5 2571.7 3136 3138.
        d03-02    Linux 4.8.0-r 1719 2779 2134 1834.4 3150.6 2247.6 2567.4 3131 3136.
        d03-02    Linux 4.8.0-r -1.75% 0.11% 0.47% 5.79% -0.06% 0.26% 0.17% 0.16% 0.06%
        ```

16:33 2016-11-07
----------------
KWG-192: Use of contiguous page hint to create 64K pages, log
--------------------------------------------------------
[    2.870208] entries: 0x1600000410e0f53; ptes: 0xffff80007b1f6870.
[    2.870545] entries: 0x1600000410e0f53; ptes: 0xffff80007b1f6860.
[    2.882744] entries: 0x1600000410e0f53; ptes: 0xffff80007b1f6868.
[    2.891052] entries: 0x1600000410e0f53; ptes: 0xffff80007b1f5280.
[    2.979048] entries: 0x1600000410e0f53; ptes: 0xffff80007b2159b0.
[    3.012586] entries: 0x1600000410e0f53; ptes: 0xffff80007b2159b8.
[    3.093627] entries: 0x1600000410e0f53; ptes: 0xffff80007b20b638.
[    3.115952] systemd[1]: systemd 210 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX -IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ -SECCOMP +APPARMOR)
[    3.120064] systemd[1]: Detected architecture 'arm64'.

Welcome to openSUSE Leap 42.1 (aarch64)!

[    3.144189] systemd[1]: Failed to insert module 'ipv6'
[    3.150175] systemd[1]: Set hostname to <linux>.
[    3.468686] entries: 0x1600000410e0f53; ptes: 0xffff80007b2fcc60.
[    3.481145] entries: 0x1600000410e0f53; ptes: 0xffff80007b2d1ab0.
[    3.482911] entries: 0x1600000410e0f53; ptes: 0xffff80007b2d1dc8.
[    3.548576] entries: 0x1600000410e0f53; ptes: 0xffff80007b30bb48.
[    3.550200] entries: 0x1600000410e0f53; ptes: 0xffff80007b30be60.

11:20 2016-11-09
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  It seems that it fail in print? I could not understand why it happened.
    No. after diasble the print, it still fail.
2.  it seems that there is a bug in release.
```
[  199.771287] fe<0xffff80007b3eba48>: do_anonymous_page write successful with 1 pte(s): pmd<0xb723d003>, addr<0xfffffc947000>, vma <0xfffffc927000> to <0xfffffc949000>
[  199.771339] fe<0xffff80007b3eba48>: 0 entry<0xe80000b645ff53>, pte<0xe80000b645ff53>, page<0xffff7e0001d917c0>
```

```
[  199.908808] fe<0xffff80007b3ebd58>->addres<0x1da02000> will try to allocate 16 pages
[  199.909002] fe<0xffff80007b3ebd58>: do_anonymous_page write successful with 16 pte(s): pmd<0xb7249003>, addr<0x1da02000>, vma <0x1d9f8000> to <0x1da19000>
[  199.909020] fe<0xffff80007b3ebd58>: 0 entry<0xe80000b5c60f53>, pte<0xe80000b5c60f53>, page<0xffff7e0001d71800>
[  199.909033] fe<0xffff80007b3ebd58>: 1 entry<0xe80000b5c61f53>, pte<0xe80000b5c61f53>, page<0xffff7e0001d71840>
[  199.909046] fe<0xffff80007b3ebd58>: 2 entry<0xe80000b5c62f53>, pte<0xe80000b5c62f53>, page<0xffff7e0001d71880>
[  199.909059] fe<0xffff80007b3ebd58>: 3 entry<0xe80000b5c63f53>, pte<0xe80000b5c63f53>, page<0xffff7e0001d718c0>
[  199.909072] fe<0xffff80007b3ebd58>: 4 entry<0xe80000b5c64f53>, pte<0xe80000b5c64f53>, page<0xffff7e0001d71900>
[  199.909084] fe<0xffff80007b3ebd58>: 5 entry<0xe80000b5c65f53>, pte<0xe80000b5c65f53>, page<0xffff7e0001d71940>
[  199.909097] fe<0xffff80007b3ebd58>: 6 entry<0xe80000b5c66f53>, pte<0xe80000b5c66f53>, page<0xffff7e0001d71980>
[  199.909109] fe<0xffff80007b3ebd58>: 7 entry<0xe80000b5c67f53>, pte<0xe80000b5c67f53>, page<0xffff7e0001d719c0>
[  199.909123] fe<0xffff80007b3ebd58>: 8 entry<0xe80000b5c68f53>, pte<0xe80000b5c68f53>, page<0xffff7e0001d71a00>
[  199.909136] fe<0xffff80007b3ebd58>: 9 entry<0xe80000b5c69f53>, pte<0xe80000b5c69f53>, page<0xffff7e0001d71a40>
[  199.909149] fe<0xffff80007b3ebd58>: 10 entry<0xe80000b5c6af53>, pte<0xe80000b5c6af53>, page<0xffff7e0001d71a80>
[  199.909162] fe<0xffff80007b3ebd58>: 11 entry<0xe80000b5c6bf53>, pte<0xe80000b5c6bf53>, page<0xffff7e0001d71ac0>
[  199.909175] fe<0xffff80007b3ebd58>: 12 entry<0xe80000b5c6cf53>, pte<0xe80000b5c6cf53>, page<0xffff7e0001d71b00>
[  199.909187] fe<0xffff80007b3ebd58>: 13 entry<0xe80000b5c6df53>, pte<0xe80000b5c6df53>, page<0xffff7e0001d71b40>
[  199.909200] fe<0xffff80007b3ebd58>: 14 entry<0xe80000b5c6ef53>, pte<0xe80000b5c6ef53>, page<0xffff7e0001d71b80>
[  199.909213] fe<0xffff80007b3ebd58>: 15 entry<0xe80000b5c6ff53>, pte<0xe80000b5c6ff53>, page<0xffff7e0001d71bc0>
```

```
[  199.956627] BUG: Bad page map in process ls  pte:e80002b5c65f53 pmd:b723d003
[  199.956667] page:ffff7e0001d71940 count:0 mapcount:-1 mapping:          (null) index:0x1
[  199.956679] flags: 0x14(referenced|dirty)
[  199.956686] page dumped because: bad pte
[  199.956700] addr:0000fffffc944000 vm_flags:00100173 anon_vma:ffff80007b3860c8 mapping:          (null) index:ffffffffb
[  199.956712] file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
[  199.956736] CPU: 0 PID: 2298 Comm: ls Tainted: G    B           4.9.0-rc2-next-20161028-00006-g47ae210-dirty #56
[  199.956745] Hardware name: linux,dummy-virt (DT)
[  199.956754] Call trace:
[  199.956782] [<ffff000008088ac0>] dump_backtrace+0x0/0x1b0
[  199.956798] [<ffff000008088c84>] show_stack+0x14/0x20
[  199.956821] [<ffff0000083b9044>] dump_stack+0xb4/0xf0
[  199.956837] [<ffff0000081bb1f4>] print_bad_pte+0x174/0x210
[  199.956850] [<ffff0000081bd210>] unmap_page_range+0x550/0x720
[  199.956864] [<ffff0000081bd42c>] unmap_single_vma+0x4c/0xa0
[  199.956876] [<ffff0000081bd758>] unmap_vmas+0x58/0xd0
[  199.956891] [<ffff0000081c5f9c>] exit_mmap+0x9c/0x120
[  199.956906] [<ffff0000080bd8a8>] mmput+0x68/0x140
[  199.956920] [<ffff0000080c39fc>] do_exit+0x2ac/0x9a0
[  199.956934] [<ffff0000080c5668>] do_group_exit+0x48/0xb0
[  199.956949] [<ffff0000080d1764>] get_signal+0x214/0x710
[  199.956964] [<ffff000008087e3c>] do_signal+0x19c/0x570
[  199.956978] [<ffff000008088450>] do_notify_resume+0xa0/0xb0
[  199.956991] [<ffff000008082ddc>] work_pending+0x8/0x14
[  199.957813] BUG: Bad rss-counter state mm:ffff800079c45200 idx:0 val:-13
[  199.957834] BUG: Bad rss-counter state mm:ffff800079c45200 idx:1 val:-2
```
3.  TODO
    1.  could I use alloc_zeroed_user_highpage_movable? I need to prevent the single page move.

4.  The above error fail in zap_pte_range because of mapcount < 0.

5.  discuss with Arnd
do_anonymous_page, do_wp_page
I do not split the page after allocation. Maybe it is why it fails.

6.  current fail: "[   94.230998] BUG: Bad rss-counter state mm:ffff800079c51b00 idx:1 val:-15", in commit "7630224 put page when we could not allocate 16 pages; split_page after alloc"

7.  Dicuss with Arnd
    ```
    <bamvor> Bamvor Jian Zhang arnd: About the current status of my contiguous page hint work. After fix the refcount for page and add split_page after page allocation. I could run basic command in my system. But it will report "BUG: Bad rss-counter state mm:ffff800079c51b00 idx:1 val:-15" sometimes. I will check it later. I suspect there is still some issue in do_anonymous_page. I just
    22:30 allocate 16 pages when possible but I do not set the hint of contiguous pages. Is it true that I do not need to look at other functions at this point? I do not take a look about do_wp_page right now.
    22:30 arnd: my plan is that read and change the code piece by piece as it is the first time I touch these parts of kernel. I will ignore the userfaultfd, memcg and swap before the whole things work.
    22:30 A<arnd> though his solution doesn't apply here (CONFIG_FHANDLE is already enabled in multi_v7_defconfig)
    22:30 B<bamvor> Bamvor Jian Zhang arnd: I plan working on in three steps:
    22:30 arnd: 1.  Grouping 16 pages when possible, I need to understand and work on do_anonymous_page(currently I am working on), do_wp_page and other code in handle_pte_fault.
    22:31 A<arnd> bamvor: good idea leaving out the hint for now, that clearly simplifies the prototyping
    22:31 ⇐ mcoquelin_ quit (~mcoquelin@104.79.140.88.rev.sfr.net) Ping timeout: 256 seconds
    22:31 B<bamvor> Bamvor Jian Zhang arnd: 2.  Seting contiguous page hint: Allocate the 16 pages when possible and split them in the first fault page. Set the hint in the secon
    22:31 d time of page fault.
    22:31 arnd: 3.  Deal with spliting the 64k page when needed, e.g. mprotect, mremap, munmap, LRU handling. Maybe reference how trans-huge pages are being split up into small pages, and doing the same here for each caller.
    22:34 A<arnd> step 2 also requires the do_fault_around() when setting the hint: the idea is to only set one PTE at first and then fill the other ones for the second fault (I assume that's what you meant)
    22:34 bamvor: at some point before step 3 there should also be a proper specint run
    22:35 bamvor: you mentioned that you couldn't get specint working properly. what problem did you run into?
    22:35 did it work in some configurations but not others?
    22:36 B<bamvor> Bamvor Jian Zhang no. it seems that it just crash with our hack code. (not my current code). I think explicit compile and use hugetlb ld should works. 
    22:36 A<arnd> for the start, we mainly need to know the potential gains, comparing the three cases that already work (pure 4k page, pure 64k page, 4k+trans-huge)
    22:36 B<bamvor> Bamvor Jian Zhang understand.
    22:37  i will try to test them. maybe start this week. if ILP32 performance test finish. 
    22:38 A<arnd> if 4k+trans-huge is already faster than 64k, there won't be much to gain by having 4k+page-hint+trans-huge
    22:39 B<bamvor> Bamvor Jian Zhang the thing is trans huge only works for 2m, correct? 
    22:39 A<arnd> also, if 64k is not much faster than 4k, then 4k+hint won't be very valuable because it's likely slower than 64k
    22:40 B<bamvor> Bamvor Jian Zhang maybe our case is the apps which could not allocate 2m huge page or trans page but could get benefit from 64k pages? 
    22:40 <arnd> bamvor: correct, and Mel Gorman also said that extending trans-huge to pagehint for 64k TLBs would not be a good idea because of all the extra complexity
    22:41 bamvor: right, but that case may be exceptionally rare
    22:42 64k pagehint will clearly waste less memory than trans-huge, but also require more TLBs for a given working-set
    22:43 B<bamvor> Bamvor Jian Zhang Yes. At that point, maybe I could analysis the popular apps in server, desktop and android. 
    22:44 A<arnd> I think we should look at the specint results (and share them with Mel) once you have measured the existing cases, and then decide whether doing more tests is needed or not
    22:45 B<bamvor> Bamvor Jian Zhang yes. understand. it is reasonable for me. 
    22:46 arnd: do_fault_around will pre-allocate the pages but I only saw this function in do_fault which is file backed. it seems that it is not the anonymous page cases. 
    22:46 A<arnd> specint is exactly the kind of test that benefits most of reduced TLB pressure while not being severely memory limited, other tests likely just show smaller differences or won't even run on 64k pages
    22:46 → mcoquelin_ joined (~mcoquelin@104.79.140.88.rev.sfr.net)
    22:47 A<arnd> bamvor: hmm, I thought that was the function that Mel recommended. if that doesn't work, look for something similar, or use it as a template for writing the function you actually need
    22:49 B<bamvor> Bamvor Jian Zhang oh. that sound reasonable. We need the function similar to do_fault_around:) 
    ```

8.  I guess that rss_stat.counter decreased 16 times and get -15.
    1.  read the code relative to `dec_mm_counter_fast()`, `inc_mm_counter_fast()`.
    2.  read the commit in `struct mm_struct`:
        ```
        /*
         * Special counters, in some configurations protected by the
         * page_table_lock, in other configurations by being atomic.
         */
        struct mm_rss_stat rss_stat;
        ```
       the `page_table_lock` is the lock locked by `pte_lockptr`. Read the code in `do_anonymous_page()` which use this lock.
    3.   after move inc_mm_counter_fast into for loop. There is no rss_stat.counter report. But "time cnf cnf" segfault:
        ```
        [  153.767200] cnf[2344]: unhandled level 0 translation fault (11) at 0x100004346f8c4, esr 0x90000004
        [  153.767244] pgd = ffff80007943f000
        [  153.767409] [100004346f8c4] *pgd=00000000b7e61003
        [  153.767430] , *pud=0000000000000000
        [  153.767435]
        [  153.767454]
        [  153.767616] CPU: 0 PID: 2344 Comm: cnf Not tainted 4.9.0-rc2-next-20161028-00007-g7630224-dirty #65
        [  153.767642] Hardware name: linux,dummy-virt (DT)
        [  153.767717] task: ffff800077eb9880 task.stack: ffff800077e40000
        [  153.767936] PC is at 0xffff7ef9a138
        [  153.767954] LR is at 0xffff7ef9a16c
        [  153.767970] pc : [<0000ffff7ef9a138>] lr : [<0000ffff7ef9a16c>] pstate: 80000000
        [  153.767981] sp : 0000ffffd60e11e0
        [  153.768104] x29: 0000ffffd60e11e0 x28: 0000000039596cb0
        [  153.768146] x27: 0000000000035e62 x26: 0000ffff7e9bcde0
        [  153.768167] x25: 00000000393ac408 x24: 0000000000000000
        [  153.768187] x23: 0000ffff7f029000 x22: 0000000000000000
        [  153.768207] x21: 00000000393eb850 x20: 00000000393ac400
        [  153.768228] x19: 0000ffffd60e13c0 x18: 000000000000c004
        [  153.768253] x17: 0000ffff7fc6bdc0 x16: 0000ffff7f02a0d8
        [  153.768273] x15: 0000ffff7fd50580 x14: 2e6e6f6974617275
        [  153.768294] x13: 6769666e6f635f65 x12: 0000000000000038
        [  153.768314] x11: 0101010101010101 x10: 7f7f7f7f7f7f7fff
        [  153.768357] x9 : ff676271606e6dfe x8 : ffffffffffffffff
        [  153.768391] x7 : fefefefefefefefe x6 : 0000ffff7e9bc010
        [  153.768420] x5 : 0000000000000007 x4 : 0000ffff7e8e3010
        [  153.768440] x3 : 00000000312e322d x2 : 0000000000009f7e
        [  153.768460] x1 : 0000ffff7e9bcde0 x0 : 0000000000000000
        [  153.768469]
        Segmentation fault
        ```
    4.  I need a better test case to debug the issue. I could reproduce it by "zypper se cnf". Similar issuse(pud is empty).

    1.  add a stats for 16 pages allocate successful and fail.

9.  (11:15 2016-11-11)
    Think about the translation fault.
    1.  The next level entry is empty. Could I reproduce how does the page table entry add?
    2.  Same code path with one page is correct but 16 pages fault.
        1.  Does anon_vma_prepare need to care about more than one page?
        2.  Is that possible there is a race condition when do_anonymous_page handle the 16 pages and other code in handle_pte_fault try to deal with same pte?
    3.  Current test base one the qemu. Should I tested in the real hardware?
    4.  Arnd mentioned NOWAIT in last meeting. Do I need this right now?

    5.  About"2.1". `anon_vma_chain()` is relative to COW. It may share by other process(parent or children).

17:32 2016-11-10
----------------
the time of compile the kernel
------------------------------
1.  arm(asus chromebook 4G memory.
    1.  kernel
        ```
        Kernel: arch/arm/boot/Image is ready
        (trusty)bamvor@localhost:~/works/source/kernel/linux$ ll arch/arm/boot/Image
        -rwxrwxr-x. 1 bamvor bamvor 18952192 Nov 10 09:13 arch/arm/boot/Image
        ```
    2.  In sd
        ```
        Kernel: arch/arm/boot/Image is ready
        real    14m58.796s
        user    46m38.430s
        sys     3m44.100s
        ```

    3.  emmc
        ```
        Kernel: arch/arm/boot/Image is ready

        real    14m27.411s
        user    46m50.080s
        sys     3m29.550s
        ```
2.  arm64(D03)
    1.  Image
        ```
        real    3m37.178s
        user    34m32.720s
        sys     3m8.548s
        ~/works/source/kernel/hulk> ll arch/arm64/boot/Image
        -rwxr-xr-x 1 z00293696 users 13771264 Nov 17 20:08 arch/arm64/boot/Image
        ```

17:59 2016-11-10
----------------
1:1 with Mark
-------------
ask arnd
send out the specint if lmbench could not get quickly.
test multi-process for mm.

12:14 2016-11-11
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
[  139.103954] cnf[2347]: unhandled level 0 translation fault (11) at 0x100014fdc10b4, esr 0x90000004
[  139.103986] pgd = ffff800077eb3000
[  139.104199] [100014fdc10b4] *pgd=00000000b7d4a003
[  139.109528] , *pud=0000000000000000
[  139.109537]
[  139.109565]
[  139.109846] CPU: 0 PID: 2347 Comm: cnf Not tainted 4.9.0-rc2-next-20161028-00002-g8c80679-dirty #70
[  139.109873] Hardware name: linux,dummy-virt (DT)
[  139.109927] task: ffff80007b11c980 task.stack: ffff800077d64000
[  139.110076] PC is at 0xffff9c3b8138
[  139.110094] LR is at 0xffff9c3b816c
[  139.110110] pc : [<0000ffff9c3b8138>] lr : [<0000ffff9c3b816c>] pstate: 80000000
[  139.110120] sp : 0000ffffc19e0940
[  139.110230] x29: 0000ffffc19e0940 x28: 0000000032170fe0
[  139.110271] x27: 0000000000035e62 x26: 0000ffff9bddade0
[  139.110292] x25: 0000000032002818 x24: 0000000000000000
[  139.110313] x23: 0000ffff9c447000 x22: 0000000000000000
[  139.110334] x21: 0000000031fdc9a0 x20: 0000000032002810
[  139.110354] x19: 0000ffffc19e0b20 x18: 000000000000c004
[  139.110375] x17: 0000ffff9d089dc0 x16: 0000ffff9c4480d8
[  139.110396] x15: 0000ffff9d16e580 x14: 2e6e6f6974617275
[  139.110435] x13: 6769666e6f635f65 x12: 0000000000000038
[  139.110472] x11: 0101010101010101 x10: 7f7f7f7f7f7f7fff
[  139.110515] x9 : ff676271606e6dfe x8 : ffffffffffffffff
[  139.110535] x7 : fefefefefefefefe x6 : 0000ffff9bdda010
[  139.110556] x5 : 0000000000000007 x4 : 0000ffff9bd01010
[  139.110577] x3 : 000000006d030029 x2 : 0000000000009f7e
[  139.110597] x1 : 0000ffff9bddade0 x0 : 0000000000000000

19:13 2016-11-14
kernel, ILP32
-------------
1.  send to LKML
Hi, all

I test specint of aarch64 LP64 when aarch32 el0 disable/enabled respectively
and compare with ILP32 unmerged kernel(4.8-rc6) in our arm64 board. I found
that difference(ILP32 disabled/ILP32 unmerged) is bigger when aarch32 el0 is
enabled, compare with aarch32 el0 disabled kernel. And bzip2, mcg, hmmer,
libquantum are the top four differences[1]. Note that bigger is better in
specint test.

In order to make sure the above results, I retest these four testcases in
reportable way(reference the command in the end). The result[2] show that
libquantum decrease -2.09% after ILP32 enabled and aarch32 on. I think it is in
significant.

The result of lmbench is not stable in my board. I plan to dig it later.

[1] The following test result is tested through --size=ref --iterations=3.
1.1 Test when aarch32_el0 is enabled.
                        ILP32 disabled        base line
      400.perlbench            100.00%             100%
      401.bzip2                 99.35%             100%
      403.gcc                  100.26%             100%
      429.mcf                  102.75%             100%
      445.gobmk                100.00%             100%
      456.hmmer                 95.66%             100%
      458.sjeng                100.00%             100%
      462.libquantum           100.00%             100%
      471.omnetpp              100.59%             100%
      473.astar                 99.66%             100%
      483.xalancbmk             99.10%             100%

1.2 Test when aarch32_el0 is disabled
                        ILP32 disabled         base line
      400.perlbench            100.22%              100%
      401.bzip2                100.95%              100%
      403.gcc                  100.20%              100%
      429.mcf                  100.76%              100%
      445.gobmk                100.36%              100%
      456.hmmer                 97.94%              100%
      458.sjeng                 99.73%              100%
      462.libquantum            98.72%              100%
      471.omnetpp              100.86%              100%
      473.astar                 99.15%              100%
      483.xalancbmk            100.08%              100%

[2] The following test result is tested through: runspec --config=my.cfg --size=test,train,ref --noreportable --tune=base,peak --iterations=3 bzip2 mcf hmmer libquantum
2.1 Test when aarch32_el0 is enabled.
                         ILP32_enabled         base line
      401.bzip2                100.82%              100%
      429.mcf                  100.18%              100%
      456.hmmer                 99.64%              100%
      462.libquantum            97.91%              100%

2.  Maxim
3.  Reply to Maxim
                    ILP32_merged    ILP32_unmerged
      401.bzip2            0.31%            0.26%
      429.mcf              1.61%            1.36%
      456.hmmer            1.37%            1.57%
      462.libquantum       0.29%            0.28%

    1.  ILP32
        ```
        >>> numpy.std([9.26, 9.29, 9.22])/9.26*100
        0.3096589368985761
        >>> numpy.std([8.59, 8.34, 8.28])/8.34*100
        1.6096747054837965
        >>> numpy.std([13.7, 13.7, 14.1])/13.7*100
        1.3763635643533785
        >>> numpy.std([16.0, 16.0, 15.9])/16.0*100
        ```
    2.  ILP32 unmerged
        ```
        >>> numpy.std([9.20,9.20,9.15])/9.20*100
        0.25619810912555524
        >>> numpy.std([8.31,8.31,8.55])/8.31*100
        1.3614570997574935
        >>> numpy.std([13.7,14.1,13.6])/13.7*100
        1.5768225543571441
        >>> numpy.std([16.6,16.6,16.5])/16.6*100
        0.28397862698255327
        ```

15:01 2016-11-15
---------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  disable swap and try again.
    1.  similiar error: three times empty pmd.
2.  disable hugetlb and transhuge:
    1.  disable HUGETLBFS will disable CGROUP_HUGETLB and HUGETLB_PAGE automatically.
    2.  disable CONFIG_TRANSPARENT_HUGEPAG.

14:32 2016-11-16
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2016-10-31 to 2016-11-15
=== Highlights ===
* KWG-192: Use of contiguous page hint to create 64K pages
    * Discuss with Arnd.
        The plan is that read and change the code piece by piece as it is the first time I touch these parts of kernel. I will ignore the userfaultfd, memcg and swap before the whole things work.
        I plan working on in three steps:
        1.  Grouping 16 pages when possible, I need to understand and work on do_anonymous_page(currently I am working on), do_wp_page and other code in handle_pte_fault.
        2.  Spliting 16 pages when needed: e.g. mprotect, mremap, munmap, LRU handling. Need add pointers to track the contiguous pages.
        3.  Setting the cont page hint. Add a function like do_fault_around to preallocate the contiguous pages and set the hint when hit the same range twice; Invalid tlb and deal with the other pages in the second time hit in the same contiguous range.
        Draw a mindmap to track it: <https://github.com/bjzhang/bjzhang.github.io/blob/master/public/images/pagetable/cont_page_development.svg>. The blue one is what I am working on. The gray one is not relative to the contiguous page hint.
    *  Fix some issues in do_anonymous_page of my work. There are still a lots of crash when I try to compile the lmbench binary. But it could run lmbench successful (I do not mean to test the performance by lmbench).
       The crash is lead by some empty pmd or pgd in userspace. I plan to learn more about how does the kernel set the pgd and pmd for userspace.
    *  I write a test code which could malloc and set memory parallel. But I could not reproduce the above crash through a simple test program right now.

* ILP32 performance regression.
    * Test specint and lmbench.
      There is no regression in specint. Reference the following data(aarch32 el0 is enabled) for the top four differences.
                         ILP32_enabled         base line
      401.bzip2                100.82%              100%
      429.mcf                  100.18%              100%
      456.hmmer                 99.64%              100%
      462.libquantum            97.91%              100%

      The result of lmbench is not stable, I plan to test it more.

* Gpio selftest
    There is only one patch left. Discuss with Shuah today.

* Enable KBUILD_OUTPUT for kselftest
    No progress. Plan to work on these after gpio selftest fully merged.

* 1:1 with Mark

* Arm32 meeting.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    Work on group pages.

* ILP32 performance test
    Lmbench

* Gpio selftest
    Discuss with Shuah.

16:14 2016-11-16
----------------
(10:12 2016-11-23)update
[ACTIVITY] (Bamvor Jian Zhang) 2016-11-16 to 2016-11-22
* Gpio selftest
    Discuss with Shuah, She ack if I could address the existing comment from Linus. I send v5 to mailing list this week.
* KWG 174: KBUILD_OUTPUT fix for kseltest
    Discuss with Michael Ellerman. I need write better comment next time. Better ChangeLog/Commit message will save the time of review.

* KWG-192: Use of contiguous page hint to create 64K pages
    Read the code in do_wp_page and try to modify it.

* ILP32 performance test
    Send out the specint test result. But no response exept Maxim.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    Think about how to debug the existing empty pgd/pmd entry produced by my patch.

* ILP32 performance test
    Test Lmbench.

* KWG 174: KBUILD_OUTPUT fix for kseltest
    Work on new version, hope could send out this week.

Not send: Get specint from lianro. I could setup a specint environment in my home now. It is a backup when I could not get machine from huawei.

16:27 2016-11-17
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  test on d03. fail. same log.
2.  git clone also failed:
    ```
    ~/works/source/kernel> git clone git@code.huawei.com:z00293696/hulk.git
    Cloning into 'hulk'...
    remote: Counting objects: 5129446, done.
    remote: Compressing objects: 100% (805702/805702), done.
    fatal: BUG: parse_object_buffer transmogrified our buffer
    fatal: index-pack failed
    ```
3.  install the following package when compile perf:
    ` zypper in libdwarf libdwarf-devel libelf libelf-dvel libelf-devel libdw-devel systemtap-sdt-devel libnuma-devel audit audit-devel libunwind-devel python-devel git2-devel gtk2-devel slang-devel`

20:16 2016-11-18
----------------
kselftest, KBUILD_OUTPUT, discuss with Micheal
----------------------------------------------
1.  1/6
Hi, Micheal
>Hi Bamvor,
>
>bamvor.zhangjian@huawei.com writes:
>
>> From: Bamvor Jian Zhang <bamvor.zhangjian@linaro.org>
>>
>> Currently, kselftest use TEST_PROGS, TEST_PROGS_EXTENDED, TEST_FILES to
>> indicate the default test program, extended test program and test files.
>> These lead to duplicated all and clean targets.
>>
>> In order to remove them, introduce TEST_GEN_PROGS,
>> TEST_GEN_PROGS_EXTENDED, TEST_GEN_FILES to indicate the compiled
>> objected.
>
>It's nice to be able to drop the clean rules, but renaming all those
>variables causes a lot of churn.
>
>I think it would be better if we add a new variable, maybe NO_CLEAN,
>which can be used to specify anything in TEST_PROGS/EXTENDED which
>should *not* be cleaned.
>
>And then the default clean rule will just do:
>
>clean:
>    $(RM) -fr $(filter-out $(NO_CLEAN),$(TEST_PROGS))
Maybe I lost somewhere. I add these variable for all and
clean target. They will be used to output the objects to OUTPUT
directory. Could you please explain in details how should I do it for
"all" target if I do not introduce TEST_GEN_PROGS,
TEST_GEN_PROGS_EXTENDED and TEST_GEN_FILES?

Regards

Bamvor
>
>
>I think that would require less changes overall, because most tests just
>want to build some files, run them, and then clean them. The tests that
>need to do more elaborate things are the exception.
>
>cheers

1.  6/6
Hi, Macheal

Thanks your reply.

On 2016/11/18 19:29, Michael Ellerman wrote:
>> From: Bamvor Jian Zhang <bamvor.zhangjian@linaro.org>
>>
>> Enable O and KBUILD_OUTPUT for kselftest. User could compile kselftest
>> to another directory by passing O or KBUILD_OUTPUT. And O is high
>> priority than KBUILD_OUTPUT.
>
>We end up saying $(OUTPUT) a lot, kbuild uses $(obj), which is shorter
>and less shouty and reads nicer I think ?
I agree that we need a clearly name. Meanwhile the $(obj) sounds like
compile objects. But it is actually a directory which we put objs to
there. I am wondering if people may confuse about he name. Given that
kbuild make KBUILD_OUTPUT work by defining the srctree. How about pick
up dst (means dsttree) instead of OUTPUT?
>
>> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
>> index a3144a3..79c5e97 100644
>> --- a/tools/testing/selftests/Makefile
>> +++ b/tools/testing/selftests/Makefile
>> @@ -47,29 +47,47 @@ override LDFLAGS =
>>  override MAKEFLAGS =
>>  endif
>>
>> +ifeq ($(O)$(KBUILD_OUTPUT),)
>> +        BUILD :=$(shell pwd)
>> +else
>> +        ifneq ($(O),)
>> +                BUILD := $(O)
>> +        else
>> +                ifneq ($(KBUILD_OUTPUT),)
>> +                        BUILD := $(KBUILD_OUTPUT)
>> +                endif
>> +        endif
>> +endif
>
>That should be equivalent to:
>
>BUILD := $(O)
>ifndef BUILD
>  BUILD := $(KBUILD_OUTPUT)
>endif
>ifndef BUILD
>  BUILD := $(shell pwd)
>endif
Thanks. It works for me. I will update in my next version.
>
>> diff --git a/tools/testing/selftests/exec/Makefile b/tools/testing/selftests/exec/Makefile
>> index 48d1f86..fe5cdec 100644
>> --- a/tools/testing/selftests/exec/Makefile
>> +++ b/tools/testing/selftests/exec/Makefile
>> @@ -5,18 +5,19 @@ TEST_GEN_FILES := execveat.symlink execveat.denatured script subdir
>>  # Makefile is a run-time dependency, since it's accessed by the execveat test
>>  TEST_FILES := Makefile
>>
>> -EXTRA_CLEAN := subdir.moved execveat.moved xxxxx*
>> +EXTRA_CLEAN := $(OUTPUT)subdir.moved $(OUTPUT)execveat.moved $(OUTPUT)xxxxx*
>
>It reads strangely to not have a slash after the output I think it would
>be better if you used a slash everywhere you use it, like:
>
>EXTRA_CLEAN := $(OUTPUT)/subdir.moved $(OUTPUT)/execveat.moved $(OUTPUT)/xxxxx*
>
>That makes it clear that it's a directory, and not some other prefix.
Oh, yes. The origin code is not work if remove the slash. I eventually
found that it is because I do the wrong replacement in TEST_GEN_PROGS
and TEST_GEN_FILES. They should be:
TEST_GEN_PROGS := $(patsubst %,$(OUTPUT)/%,$(TEST_GEN_PROGS))
TEST_GEN_FILES := $(patsubst %,$(OUTPUT)/%,$(TEST_GEN_FILES))
>
>
>Having said that, I think for EXTRA_CLEAN it should just be defined that
>the contents are in $(OUTPUT), and so we can just do that in lib.mk, eg:
>
>EXTRA_CLEAN := $(addprefix $(OUTPUT)/,$(EXTRA_CLEAN))
>
>clean:
>    $(RM) -r $(TEST_GEN_PROGS) $(TEST_GEN_PROGS_EXTENDED) $(TEST_GEN_FILES) $(EXTRA_CLEAN)
The OUTPUT is the directory we build. It may be not be not the
directory we run the test. For example, pstore do not need compile.
It could run in the source directory.
>
>
>>  include ../lib.mk
>>
>> -subdir:
>> +$(OUTPUT)subdir:
>>   mkdir -p $@
>> -script:
>> +$(OUTPUT)script:
>>   echo '#!/bin/sh' > $@
>>   echo 'exit $$*' >> $@
>>   chmod +x $@
>> -execveat.symlink: execveat
>> - ln -s -f $< $@
>> -execveat.denatured: execveat
>> +$(OUTPUT)execveat.symlink: execveat
>> + cd $(OUTPUT) && ln -s -f $< `basename $@`
>> +$(OUTPUT)execveat.denatured: execveat
>>   cp $< $@
>>   chmod -x $@
>
>Do those work? I would have thought you'd need $(OUTPUT) on the right
>hand side also?
It works because execveat will generate twice which is wrong. I will
fix in next version.
>
>> diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
>> index 0f7a371..fa87f98 100644
>> --- a/tools/testing/selftests/lib.mk
>> +++ b/tools/testing/selftests/lib.mk
>> @@ -33,19 +34,29 @@ endif
>>
>>  define EMIT_TESTS
>>   @for TEST in $(TEST_GEN_PROGS) $(TEST_PROGS); do \
>> -     echo "(./$$TEST && echo \"selftests: $$TEST [PASS]\") || echo \"selftests: $$TEST [FAIL]\""; \
>> +     BASENAME_TEST=`basename $$TEST`;    \
>> +     echo "(./$$BASENAME_TEST && echo \"selftests: $$BASENAME_TEST [PASS]\") || echo \"selftests: $$BASENAME_TEST [FAIL]\""; \
>>   done;
>>  endef
>>
>>  emit_tests:
>>   $(EMIT_TESTS)
>>
>> +TEST_GEN_PROGS := $(patsubst %,$(OUTPUT)%,$(TEST_GEN_PROGS))
>> +TEST_GEN_FILES := $(patsubst %,$(OUTPUT)%,$(TEST_GEN_FILES))
>
>You should just be able to use addprefix there.
Yes.
>
>> +
>>  all: $(TEST_GEN_PROGS) $(TEST_GEN_PROGS_EXTENDED) $(TEST_GEN_FILES)
>>
>>  clean:
>>   $(RM) -r $(TEST_GEN_PROGS) $(TEST_GEN_PROGS_EXTENDED) $(TEST_GEN_FILES) $(EXTRA_CLEAN)
>>
>> -%: %.c
>> - $(CC) $(CFLAGS) $(LDFLAGS) $(LDLIBS) -o $@ $^
>> +$(OUTPUT)%:%.c
>> + $(CC) $(CFLAGS) $(LDFLAGS) $(LDLIBS) $< -o $@
>
>I think it reads better with a space after the ":"
Sure

Regards

Bamvor

>
>$(OUTPUT)/%: %.c
>    $(CC) $(CFLAGS) $(LDFLAGS) $(LDLIBS) $< -o $@
>

18:05 2016-11-21
----------------
git send-email --in-reply-to=7e8cac40-ccf1-d4c3-5a08-09969b273b11@osg.samsung.com --from bamvor.zhangjian@huawei.com --to shuahkh@osg.samsung.com --to linus.walleij@linaro.org --cc linux-gpio@vger.kernel.org --cc bamvor.zhangjian@huawei.com --cc broonie@kernel.org --cc mwelling@ieee.org --cc shuah@kernel.org --cc bamvor.zhangjian@linaro.org

11:03 2016-11-23
----------------
即使是有脚本的情况下, 编译内核还是用了20分钟时间(我的时间, 不是机器的时间). 工作方法还是很有问题.
每次都要折腾板子, 给我的感觉很不好. hikey还不能连大网. 后面用d03启动kvm虚拟机内核需要用旧的内核.

12:19 2016-11-23
----------------
kernel_build --path $PWD --extra kernel_disable_arm_smmu_v3_config --extra kernel_disable_hugetlb_config --extra kernel_disable_memcg_config --extra kernel_disable_swap_config --extra kernel_disable_transhuge_config  --disable install_header_to_cc

10:53 2016-11-25
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  There is no progress in recent two weeks. I still do not understand how the page allocated when a process forked.
    And I need to understand each function I used in do_anonymous_page. Do I use them corrrently?
2.  Thinking in handle_pte_fault, `pmd_trans_unstable(fe->pmd) make suse it is safe for transhuge. I am thinking if I need to do similar for contiguous pages.
3.  In __pte_alloc,  there is another pmd_none check. Is it lead to the crash(pmd empty?).
4.  There are two type of lock. The first one is mm_sem which is belong to the process. The other is the lock in page table. e.g. pmd lock, pte lock which lock the page and page table belong to it. The latter one is used when differnce process/thread share the memory(COW after fork is the typical one, share memory is another, not sure if there are others).
    I suspect the I do not protect the latter one correctly. It lead to the current crash.
5.  Does the process copy the pgd or copy the page table belong to pgd when fork a process?
6.  Maybe there is some comments of function need to update according to the kernel docs. Could I do it for mm subsystem when I reading the code?

10:57 2016-11-26
----------------
KWG-192: Use of contiguous page hint to create 64K pages
--------------------------------------------------------
1.  plan to figure out the failure of memsize.c, step:
    1.  run malloc and memsize, compare the result. Maybe the issue in touch memory?
    2.  25minutes to get the first result.
2.  Eventually, I found that memsize fail because my vm is too slow to timeout.
    So, I go back the issue in compile of lmbench.

11:44 2016-11-26
----------------
ILP32 regression, ftest02, sync_file_range01
--------------------------------------------
1.  compile fail in latest LTP.
    Download latest linaro toolchain. If confirm ask in ltp mailing list.
2.  compile pass in ltp tag 20150903.
3.  sync_file_range2: It is my mistake I could

11:36 2016-11-29
----------------
1.  tools/testing/selftests/vDSO/Makefile and  tools/testing/selftests/prctl/Makefile is not included in selftests suite. deal with them later.
2.  TODO track the new case in tools/testing/selftests/Makefile. e.g. tools/testing/selftests/nsfs/Makefile, bpf, sigaltstack.
3.  cover lettter
[PATCH v2 0/6] enable O and KBUILD_OUTPUT for kselftest

Here is my second version for enabling the KBUILD_OUTPUT for kselftest.
The first version could be found here[1]. I fix and test all the TARGET
in tools/testing/selftest/Makefile. For ppc, I test through fake target.

There are six patches in these series. And five of them clean up the
existing code. I split the clean up patches into five, hope it is easy
to review.

  selftests: remove duplicated all and clean target
  selftests: remove useless TEST_DIRS
a selftests: add pattern rules
A selftests: remove CROSS_COMPILE in dedicated Makefile
A selftests: add EXTRA_CLEAN for clean target
  selftests: enable O and KBUILD_OUTPUT

Notes:
  A: Ack by Michael.
  a: ack by Michael. Minor update after rebase.

In the first patch, I split the test files into two types:
TEST_GEN_XXX means such file is generated during compiling. TEST_XXX
means there is no need to compile before use. The main reason of this
is the enablement of KBUILD_OUTPUT only need to care about TEST_GEN_XXX.
I wanted to copy all the TEST_XXX with TEST_GEN_XXX, but I give up this
idea in the end. Because people may puzzle why copy the file before
installation.

Because of the introducing of TEST_GEN_XXX, I update the top-level
Makefile and lib.mk selftests directory. After introduce TEST_GEN_XXX, I
could remove all the unnecessary all and clean targets.

The second patch remove TEST_DIRS variable. And third patch add the
pattern for compiling the c sourc code. The fourth patch remove the
useless CROSS_COMPILE variable as it aleady exists in
"tools/testing/selftests/lib.mk".

Further more, The fifth patch add the EXTRA_CLEAN variable to clean up
the duplicated clean target

The last patch introduce the KBUILD_OUTPUT and O for kselftest instead
using the existing kbuild system because user may compile kselftest
directly (make -C tools/testing/selftests).

Changes:
1.  remove the useless *.o target in the following file suggested by
    Michael:
    tools/testing/selftests/powerpc/benchmarks/Makefile
    tools/testing/selftests/powerpc/copyloops/Makefile
    tools/testing/selftests/powerpc/dscr/Makefile
    tools/testing/selftests/powerpc/math/Makefile
    tools/testing/selftests/powerpc/primitives/Makefile
    tools/testing/selftests/powerpc/stringloops/Makefile
    tools/testing/selftests/powerpc/syscalls/Makefile
    tools/testing/selftests/powerpc/tm/Makefile

2.  remove the useless "all" and "clean" target in bpf and nsfs which
    are added after my previous patch.

3.  Improve the commit message.

[1] http://www.spinics.net/lists/linux-api/msg20789.html

git send-email --no-chain-reply-to --annotate --to shuahkh@osg.samsung.com --cc linux-api@vger.kernel.org --cc linux-kernel@vger.kernel.org --cc khilman@kernel.org --cc broonie@kernel.org --cc mpe@ellerman.id.au 000*.patch

08:54 2016-11-30
----------------
git send-email activity --to "Private Kernel Alias" <private-kwg@linaro.org> --cc "Mark Brown" <broonie@linaro.org> --cc "Linus Walleij" <linus.walleij@linaro.org> --cc "Arnd Bergmann" <arnd@arndb.de> --cc "Bamvor Jian Zhang" <bamvor.zhangjian@linaro.org>

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2016-11-23 to 2016-11-29

* KWG 174: KBUILD_OUTPUT fix for kseltest
    Rebase to latest linux-next and send v2 yesterday(29 Dec).

* KWG-192: Use of contiguous page hint to create 64K pages
    Read the code in do_wp_page and try to modify it.
    About the current crash:
        - After analysis the code, I realize that there are two locks when hanlding the page table fault. The one is mm semaphore in mm_struct which belong to each process. The other is lock of page which is used for lock the entire (sub) page table of belong to this page. Currently, single thread is good. I think the semaphore of mm_struct is not relative to my issue. The question is whether there is some misuse the lock of page. After read the code in handle_pte_fault. I notice that there is a pmd check(pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd)) in handle_pte_fault. I am thinking if i should add a similar protect for my contiguous pages. (Maybe I could share some code with transhuge eventually).
        - There was a failure of memory allocation test(memsize) in lmbench. I found that this is because the timeout in memsize is too small for my vm.

* Gpio selftest
    No response.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    Think about how to debug the existing empty pgd/pmd entry produced by my patch.

* ILP32 performance test
    Test Lmbench.

11:12 2016-11-30
----------------
TODO
  VG     #PV #LV #SN Attr   VSize   VFree 
  system   1   4   0 wz--n- 460.00g 81.00g

  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home  system -wi-a-----  15.00g                                                    
  root  system -wi-a-----  30.00g                                                    
  swap  system -wi-a-----   4.00g                                                    
  works system -wi-ao---- 320.00g                                                    
    1  2016-11-30 10:30:44 ls
    2  2016-11-30 10:30:46 df -h
    3  2016-11-30 10:30:49 lvs
    4  2016-11-30 10:43:21 ls
    5  2016-11-30 10:46:16 vgs
    6  2016-11-30 10:47:07 vgextend --help
    7  2016-11-30 10:47:42 vgreduce --help
    8  2016-11-30 10:47:56 vgchange --help
    9  2016-11-30 10:48:33 lvextend -L 10G system/root
   10  2016-11-30 10:48:57 lvextend --help
   11  2016-11-30 10:49:12 lvextend -L 10G root system
   12  2016-11-30 10:49:22 lvextend -L10G system/root system
   13  2016-11-30 10:49:32 vgs
   14  2016-11-30 10:49:40 lvextend -L10G system/root 
   15  2016-11-30 10:49:42 lvs
   16  2016-11-30 10:49:46 vgs
   17  2016-11-30 10:50:14 lvextend -L+10G system/root 
   18  2016-11-30 10:50:19 lvs
   19  2016-11-30 10:50:33 resize2fs /dev/mapper/system-root 
   20  2016-11-30 10:50:43 e2fsck -f /dev/mapper/system-root 
   21  2016-11-30 10:51:05 resize2fs /dev/mapper/system-root 
   22  2016-11-30 10:51:12 e2fsck -f /dev/mapper/system-root 
   23  2016-11-30 10:51:50 mount|grep mnt
   24  2016-11-30 10:51:58 mount /dev/mapper/system-root /mnt/
   25  2016-11-30 10:52:11 df -h
   26  2016-11-30 10:52:14 umount /mnt 
   27  2016-11-30 10:58:54 mount /dev/mapper/system-root /mnt/
   28  2016-11-30 10:59:01 umount /mnt 
   29  2016-11-30 10:59:10 mount /dev/mapper/system-works /mnt/
   30  2016-11-30 10:59:49 vim /mnt/reference/open_log/1057
   31  2016-11-30 10:59:59 history | less
   32  2016-11-30 11:00:11 vgs >>  /mnt/reference/open_log/1057
   33  2016-11-30 11:00:17 lvs >>  /mnt/reference/open_log/1057
   34  2016-11-30 11:00:25 history >>   /mnt/reference/open_log/1057

  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home  system -wi-a-----  15.00g                                                    
  root  system -wi-a-----  30.00g                                                    
  swap  system -wi-a-----   4.00g                                                    
  works system -wi-ao---- 320.00g                                                    

19:12 2016-11-30
----------------
1.  read file after type "vim filename"
```
[<0000000000000000>] wait_transaction_locked+0x7e/0xb0 [jbd2]
[<0000000000000000>] add_transaction_credits+0x207/0x2a0 [jbd2]
[<0000000000000000>] start_this_handle+0x100/0x3f0 [jbd2]
[<0000000000000000>] jbd2__journal_start+0xe7/0x210 [jbd2]
[<0000000000000000>] __ext4_journal_start_sb+0x6d/0x110 [ext4]
[<0000000000000000>] ext4_dirty_inode+0x32/0x70 [ext4]
[<0000000000000000>] __mark_inode_dirty+0x1c6/0x3f0
[<0000000000000000>] generic_update_time+0x79/0xd0
[<0000000000000000>] touch_atime+0x88/0xa0
[<0000000000000000>] generic_file_read_iter+0x508/0x5d0
[<0000000000000000>] new_sync_read+0x85/0xb0
[<0000000000000000>] __vfs_read+0x26/0x40
[<0000000000000000>] vfs_read+0x86/0x130
[<0000000000000000>] SyS_read+0x46/0xa0
[<0000000000000000>] entry_SYSCALL_64_fastpath+0x16/0x6a
```
open ~/.vimin*.tmp when exit vim
```
z00293696@linux696:open_log> cat /proc/4155/stack
[<0000000000000000>] wait_transaction_locked+0x7e/0xb0 [jbd2]
[<0000000000000000>] add_transaction_credits+0x207/0x2a0 [jbd2]
[<0000000000000000>] start_this_handle+0x100/0x3f0 [jbd2]
[<0000000000000000>] jbd2__journal_start+0xe7/0x210 [jbd2]
[<0000000000000000>] __ext4_journal_start_sb+0x6d/0x110 [ext4]
[<0000000000000000>] __ext4_new_inode+0x6ac/0x1450 [ext4]
[<0000000000000000>] ext4_create+0x10e/0x190 [ext4]
[<0000000000000000>] vfs_create+0xc2/0x120
[<0000000000000000>] path_openat+0x1393/0x14a0
[<0000000000000000>] do_filp_open+0x7e/0xe0
[<0000000000000000>] do_sys_open+0x12c/0x210
[<0000000000000000>] SyS_open+0x1e/0x20
[<0000000000000000>] tracesys_phase2+0x88/0x8d
[<0000000000000000>] 0xffffffffffffffff
```
2.  fragment?
    e4defrag -c /home/z00293696/works/

    1 score

3.  
```
z00293696@linux696:open_log> balooctl status
Baloo File Indexer is running
Indexer state: Indexing file content
Indexed 485286 / 1011001 files
Current size of index is 3.27 GiB
```

4.  (10:07 2016-12-01)
    It indexed 10 thousands files tonight.
    ```
    z00293696@linux696:open_log> balooctl status
    Baloo File Indexer is running
    Indexer state: Indexing file content
    Indexed 559879 / 994074 files
    Current size of index is 5.05 GiB
    ```
    After one night indexing, it seems that the frequent of hang is lowing. I test open 10 new(means not opened recently) files and exit from vim, no hang more than 1 seconds. It was more than 4 seconds.

17:19 2016-12-01
----------------
1.  no find the pgd in gdb.txt
```
[  325.144585] cc1[2408]: unhandled level 2 translation fault (11) at 0xffff84bbf70f, esr 0x90000006
[  325.145791] pgd = ffff800079cd5000
[  325.145971] [ffff84bbf70f] *pgd=00000000b9e05003[  325.146231] , *pud=00000000bb3fc003
, *pmd=0000000000000000[  325.146416]
[  325.146472]
[  325.146674] CPU: 0 PID: 2408 Comm: cc1 Not tainted 4.9.0-rc2-next-20161028-00005-ge292d1a #77
[  325.146887] Hardware name: linux,dummy-virt (DT)
[  325.147029] task: ffff800079ed8000 task.stack: ffff800078260000
[  325.147243] PC is at 0x61ab14
[  325.147332] LR is at 0x61aad4
[  325.151838] pc : [<000000000061ab14>] lr : [<000000000061aad4>] pstate: 60000000
[  325.152028] sp : 0000fffff33c2770
[  325.152132] x29: 0000fffff33c2770 x28: 0000000000cc79c8
[  325.152372] x27: 0000000000000000 x26: 0000000000000200
[  325.152515] x25: 0000000000000000 x24: 0000000000000000
[  325.152655] x23: 0000000000000a00 x22: 0000000000000000
[  325.152778] x21: 0000000000d77130 x20: 0000000000d77130
[  325.152901] x19: 0000ffff84bbf707 x18: 0000fffff33c2620
[  325.153023] x17: 0000ffffabc16d80 x16: 0000000000cc01f8
[  325.153177] x15: 0000ffffabcf9580 x14: 0000000000000000
[  325.153310] x13: 0000000000000000 x12: 0000000000000010
[  325.153433] x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f
[  325.153572] x9 : 6564631f71647254 x8 : 0000fffff33c2840
[  325.153698] x7 : 697461746e656d67 x6 : 000000000cb37702
[  325.153828] x5 : 000000000cb374f0 x4 : 0000000000000000
[  325.153946] x3 : 0000000000000000 x2 : 0000000000000000
[  325.154065] x1 : 0000000000000000 x0 : 0000000000d5f000
```

2.  print pgd_alloc:
```
[ 1902.889211] cc1[2501]: unhandled level 3 permission fault (11) at 0xff000008c90a08, esr 0x9000000f
[ 1902.890405] pgd = ffff80007b3e2000
[ 1902.890579] [ff000008c90a08] *pgd=00000000b829b003[ 1902.890878] , *pud=00000000bb349003
, *pmd=0000000000000000[ 1902.891148]
[ 1902.891218]
[ 1902.895781] CPU: 0 PID: 2501 Comm: cc1 Not tainted 4.9.0-rc2-next-20161028-00005-ge292d1a #77
[ 1902.895972] Hardware name: linux,dummy-virt (DT)
[ 1902.896122] task: ffff800079c98000 task.stack: ffff80007c494000
[ 1902.896373] PC is at 0x61ab14
[ 1902.896464] LR is at 0x61aad4
[ 1902.896575] pc : [<000000000061ab14>] lr : [<000000000061aad4>] pstate: 60000000
[ 1902.896705] sp : 0000ffffc5bb4a10
[ 1902.896794] x29: 0000ffffc5bb4a10 x28: 0000000000d76000
[ 1902.897009] x27: 0000000000cc0000 x26: 00000000db3a9f1d
[ 1902.897140] x25: 0000000000000000 x24: 0000000000000000
[ 1902.897278] x23: 0000000035c4af20 x22: 0000000000000000
[ 1902.897412] x21: 0000000000d77130 x20: 0000000000d77130
[ 1902.897554] x19: ffff000008c90a00 x18: 0000ffffc5bb48c0
[ 1902.897700] x17: 0000ffff884ccd80 x16: 0000000000cc01f8
[ 1902.897841] x15: 0000ffff885af580 x14: 0000000000000000
[ 1902.897983] x13: 0000000000000000 x12: 0000000000000010
[ 1902.898126] x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f
[ 1902.898281] x9 : 6564631f71647254 x8 : 0000ffffc5bb4ae0
[ 1902.898426] x7 : 697461746e656d67 x6 : 0000000035c47702
[ 1902.898564] x5 : 0000000035c474f0 x4 : 0000000000000000
[ 1902.898703] x3 : 0000000000000000 x2 : 0000000000000000
[ 1902.898838] x1 : 0000000000000000 x0 : 0000000000d5f000
```

It is created by not enter copy_page_range.
"mm("0xffff800079f5c900")->pgd: ("0xffff80007b3e2000)

14:41 2016-12-02
----------------
runltplite: mmap16 fail

I think I should check how does hugetlb create the page table.

14:55 2016-12-02
----------------
patch series
------------
1.  gpio mockup test script: v5: wait for ack from Linusw.
2.  KBUILD_OUTPUT: rebase after 4.10-rc1 is out.
3.  rewrite mmap.
4.  gpio-mockup interrupt test.

04:21 2016-12-05
----------------
network, ssh, reverse agent
-----------------
1.  run in the machine in localnetwork.
ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26

2.  check in the server
$ netstat -anltp
(No info could be read for "-p": geteuid()=1001 but you should be root.)
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:20322         0.0.0.0:*               LISTEN      - 

3.  usage:
    ssh -p 20322 localhost

4.  reference:
    <http://blog.chinaunix.net/uid-30243292-id-5031363.html>
    <http://daaoao.blog.51cto.com/2329117/614698>

5. systemd service
    1.  systemd service, ref<https://wiki.archlinux.org/index.php/Systemd#Writing_unit_files>
        ```
        root@linaro-developer:/etc/systemd/system# cat /lib/systemd/system/ssh_reverse_agent.service
        [Unit]
        Description=SSH Reverse Agent

        [Service]
        ExecStart=/usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
        ExecReload=/bin/kill -HUP $MAINPID
        KillMode=process
        Restart=always
        Type=forking

        [Install]
        WantedBy=multi-user.target
        ```

root@linaro-developer:/etc/systemd/system# systemctl enable ssh_reverse_agent.service
Created symlink from /etc/systemd/system/multi-user.target.wants/ssh_reverse_agent.service to /lib/systemd/system/ssh_reverse_agent.service.


note: if change the service file after enable. Should run systemctl daemon-reload

root@linaro-developer:/etc/systemd/system# systemctl status -l ssh_reverse_agent.service
● ssh_reverse_agent.service - SSH Reverse Agent
   Loaded: loaded (/lib/systemd/system/ssh_reverse_agent.service; enabled)
   Active: activating (start) since Tue 2016-12-06 14:08:55 UTC; 436ms ago
 Main PID: 4514 (code=exited, status=255);         : 4555 (ssh)
   CGroup: /system.slice/ssh_reverse_agent.service
           └─4555 /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
root@linaro-developer:/etc/systemd/system# ps -ef|grep ssh
root      4408     1  0 13:51 ?        00:00:00 sshd: bamvor [priv]
bamvor    4414  4408  0 13:51 ?        00:00:01 sshd: bamvor@pts/0
root      4564  4420  0 14:09 pts/0    00:00:00 grep ssh

passwd needed:
root@linaro-developer:/etc/systemd/system# /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
bamvor@182.61.59.26's password:

root@linaro-developer:/etc/systemd/system# ssh-copy-id bamvor@182.61.59.26
/usr/bin/ssh-copy-id: ERROR: No identities found
root@linaro-developer:/etc/systemd/system# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
e3:e3:b1:bc:6c:fb:6d:cb:69:ed:3d:2b:5c:83:a5:96 root@linaro-developer
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|                 |
|                 |
|               . |
|        S     =  |
|       . .   E o |
|        +   o.. .|
|       +.+ oo+.o |
|       .B+.o=oo.+|
+-----------------+
root@linaro-developer:/etc/systemd/system#
root@linaro-developer:/etc/systemd/system#
root@linaro-developer:/etc/systemd/system# ssh-copy-id bamvor@182.61.59.26
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
bamvor@182.61.59.26's password:
Permission denied, please try again.
bamvor@182.61.59.26's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'bamvor@182.61.59.26'"
and check to make sure that only the key(s) you wanted were added.

root@linaro-developer:/etc/systemd/system#
root@linaro-developer:/etc/systemd/system#
root@linaro-developer:/etc/systemd/system# /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
root@linaro-developer:/etc/systemd/system# ps -ef|grep ssh
root      4408     1  0 13:51 ?        00:00:00 sshd: bamvor [priv]
bamvor    4414  4408  0 13:51 ?        00:00:01 sshd: bamvor@pts/0
root      4628     1  0 14:10 ?        00:00:00 /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
root      4630  4420  0 14:10 pts/0    00:00:00 grep ssh
root@linaro-developer:/etc/systemd/system# kill 4628
root@linaro-developer:/etc/systemd/system# systemctl restart ssh_reverse_agent.service
root@linaro-developer:/etc/systemd/system# systemctl status -l ssh_reverse_agent.service
● ssh_reverse_agent.service - SSH Reverse Agent
   Loaded: loaded (/lib/systemd/system/ssh_reverse_agent.service; enabled)
   Active: active (running) since Tue 2016-12-06 14:11:05 UTC; 3s ago
  Process: 4633 ExecStart=/usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26 (code=exited, status=0/SUCCESS)
 Main PID: 4634 (ssh)
   CGroup: /system.slice/ssh_reverse_agent.service
           └─4634 /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26


# while true; do ps -ef|grep ssh; sleep 2; done
root      4408     1  0 13:51 ?        00:00:00 sshd: bamvor [priv]
bamvor    4414  4408  0 13:51 ?        00:00:01 sshd: bamvor@pts/0
root      4673     1  0 14:12 ?        00:00:00 /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
root      4693  4420  0 14:12 pts/0    00:00:00 grep ssh
root      4408     1  0 13:51 ?        00:00:00 sshd: bamvor [priv]
bamvor    4414  4408  0 13:51 ?        00:00:01 sshd: bamvor@pts/0
root      4695     1  0 14:12 ?        00:00:00 /usr/bin/ssh -fNR 182.61.59.26:20322:192.168.1.200:22 bamvor@182.61.59.26
root      4697  4420  0 14:13 pts/0    00:00:00 grep ssh

12:14 2016-12-06
----------------
1.  add a pte_to_page to track the page use?  print pmd_to_page and pte_to_page?
2.  do i need to check the pte stable or not?

14:46 2016-12-06
----------------
1.  11/18 do not reply
> For compat sys_mmap2, the pgoff argument is in multiples of 4K. This was
> traditionally used for architectures where off_t is 32-bit to allow
> mapping files to 2^44.
>
> Since off_t is 64-bit with AArch64/ILP32, should we just pass the off_t
> as a 64-bit value in two different registers (w5 and w6)?
Is there a requirement to make use of 64bit off_t in mmap?

17:09 2016-12-07
----------------
linux:/home/z00293696/work/source # ./malloc 132000
pgd = ffff800077daa000 [ffff923bc000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa0f53
pgd = ffff800077daa000 [ffff923bd000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa1f53
pgd = ffff800077daa000 [ffff923be000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa2f53
pgd = ffff800077daa000 [ffff923bf000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa3f53
pgd = ffff80007b212000 [ffffb1951000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb0f53
pgd = ffff80007b212000 [ffffb1952000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb1f53
pgd = ffff80007b212000 [ffffb1953000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb2f53
pgd = ffff80007b212000 [ffffb1954000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb3f53
pgd = ffff80007b212000 [ffffb1955000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb4f53
pgd = ffff80007b212000 [ffffb1956000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb5f53
pgd = ffff80007b212000 [ffffb1957000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb6f53
pgd = ffff80007b212000 [ffffb1958000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb7f53
pgd = ffff80007b212000 [ffffb1959000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb8f53
pgd = ffff80007b212000 [ffffb195a000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fb9f53
pgd = ffff80007b212000 [ffffb195b000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbaf53
pgd = ffff80007b212000 [ffffb195c000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbbf53
pgd = ffff80007b212000 [ffffb195d000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbcf53
pgd = ffff80007b212000 [ffffb195e000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbdf53
pgd = ffff80007b212000 [ffffb195f000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbef53
pgd = ffff80007b212000 [ffffb1960000] *pgd=00000000bb259003 , *pud=00000000bb22a003 , *pmd=00000000bb31a003 , *pte=00e80000b6fbff53
pgd = ffff800077daa000 [ffff923c0000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa4f53
pgd = ffff800077daa000 [ffff923c1000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa5f53
pgd = ffff800077daa000 [ffff923c2000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa6f53
pgd = ffff800077daa000 [ffff923c3000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa7f53
pgd = ffff800077daa000 [ffff923c4000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa8f53
pgd = ffff800077daa000 [ffff923c5000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fa9f53
pgd = ffff800077daa000 [ffff923c6000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6faaf53
pgd = ffff800077daa000 [ffff923c7000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fabf53
pgd = ffff800077daa000 [ffff923c8000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6facf53
pgd = ffff800077daa000 [ffff923c9000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fadf53
pgd = ffff800077daa000 [ffff923ca000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6faef53
pgd = ffff800077daa000 [ffff923cb000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6faff53
pgd = ffff800077daa000 [ffff923cc000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc0f53
pgd = ffff800077daa000 [ffff923cd000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc1f53
pgd = ffff800077daa000 [ffff923ce000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc2f53
pgd = ffff800077daa000 [ffff923cf000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc3f53
pgd = ffff800077daa000 [ffff923d0000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc4f53
pgd = ffff800077daa000 [ffff923d1000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc5f53
pgd = ffff800077daa000 [ffff923d2000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc6f53
pgd = ffff800077daa000 [ffff923d3000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc7f53
pgd = ffff800077daa000 [ffff923d4000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc8f53
pgd = ffff800077daa000 [ffff923d5000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fc9f53
pgd = ffff800077daa000 [ffff923d6000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fcaf53
pgd = ffff800077daa000 [ffff923d7000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fcbf53
pgd = ffff800077daa000 [ffff923d8000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fccf53
pgd = ffff800077daa000 [ffff923d9000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fcdf53
pgd = ffff800077daa000 [ffff923da000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fcef53
pgd = ffff800077daa000 [ffff923db000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6fcff53
pgd = ffff800077daa000 [ffff923dc000] *pgd=00000000b6f2f003 , *pud=00000000b6f55003 , *pmd=00000000b6ecc003 , *pte=00e80000b6f49f53

17:18 2016-12-07
# ./malloc 132000
pgd = ffff800075ea2000 [ffffa886a000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e3df53
pgd = ffff800075ea2000 [ffffa886b000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5eacf53
pgd = ffff800075ea2000 [ffffa886c000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e3cf53
pgd = ffff800075ea2000 [ffffa886d000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5d2ff53
pgd = ffff800075ea2000 [ffffa886e000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5ccaf53
pgd = ffff800075ea2000 [ffffa886f000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e3af53
pgd = ffff800075ea2000 [ffffa8870000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e38f53
pgd = ffff800075ea2000 [ffffa8871000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e32f53
pgd = ffff800075ea2000 [ffffa8872000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e31f53
pgd = ffff800075ea2000 [ffffa8873000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5ea5f53
pgd = ffff800075ea2000 [ffffa8874000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5cc6f53
pgd = ffff800075ea2000 [ffffa8875000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e30f53
pgd = ffff800075ea2000 [ffffa8876000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5de7f53
pgd = ffff800075ea2000 [ffffa8877000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5de6f53
pgd = ffff800075ea2000 [ffffa8878000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5de1f53
pgd = ffff800075ea2000 [ffffa8879000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e33f53
pgd = ffff800075ea2000 [ffffa887a000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e34f53
pgd = ffff800075ea2000 [ffffa887b000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e35f53
pgd = ffff800075ea2000 [ffffa887c000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e36f53
pgd = ffff800075ea2000 [ffffa887d000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e37f53
pgd = ffff800075ea200q [ffffa887e000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e08f53
pgd = ffff800075ea2000 [ffffa887f000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e09f53
pgd = ffff800075ea2000 [ffffa8880000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e0af53
pgd = ffff800075ea2000 [ffffa8881000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e0bf53
pgd = ffff800075ea2000 [ffffa8882000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e0cf53
pgd = ffff800075ea2000 [ffffa8883000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b67dcf53
pgd = ffff800075ea2000 [ffffa8884000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5cc8f53
pgd = ffff800075ea2000 [ffffa8885000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5deff53
pgd = ffff800075ea2000 [ffffa8886000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5eabf53
pgd = ffff800075ea2000 [ffffa8887000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5e91f53
pgd = ffff800075ea2000 [ffffa8888000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5ea1f53
pgd = ffff800075ea2000 [ffffa8889000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5d2ef53
pgd = ffff800075ea2000 [ffffa888a000] *pgd=00000000b5c37003 , *pud=00000000b67d9003 , *pmd=00000000b5e39003 , *pte=00e80000b5de3f53

19:52 2016-12-07
----------------
```
linux:~ # [  118.025213] Current address of pte already alloc, release, unlock and exit
[  118.027563] Unable to handle kernel NULL pointer dereference at virtual address 00000018
[  118.027993] pgd = ffff80007664d000
[  118.028188] [00000018] *pgd=00000000b664b003[  118.028624] , *pud=00000000b739c003
, *pmd=0000000000000000[  118.028847]
[  118.029033] Internal error: Oops: 94000006 [#1] PREEMPT SMP
[  118.029241] Modules linked in:
[  118.029720] CPU: 0 PID: 2444 Comm: ls Not tainted 4.9.0-rc8-next-20161205-00003-g8068166-dirty #87
[  118.029906] Hardware name: linux,dummy-virt (DT)
[  118.030057] task: ffff80007aef4980 task.stack: ffff800076644000
[  118.030631] PC is at __lock_acquire+0xbc/0x1768
[  118.030786] LR is at lock_acquire+0x48/0x70
[  118.030890] pc : [<ffff00000810b91c>] lr : [<ffff00000810d310>] pstate: 000001c5
[  118.031039] sp : ffff800076647bb0
[  118.031142] x29: ffff800076647bb0 x28: 0000000000020000
[  118.031359] x27: 0000000000000018 x26: ffff800076e0a790
[  118.031503] x25: 0000000000000001 x24: 0000000000000000
[  118.031651] x23: 0000000000000000 x22: ffff800076e0a790
[  118.031800] x21: 0000000000000000 x20: ffff0000081b7540
[  118.031957] x19: ffff80007aef4980 x18: 0000fffff5c06370
[  118.032118] x17: 0000000000002710 x16: 0000ffff90315658
[  118.032278] x15: 000000000000578b x14: 0000ffff90306a94
[  118.032432] x13: 0000000000000000 x12: 0000000000000024
[  118.032566] x11: 0000000000000018 x10: ffff000009e3b000
[  118.032707] x9 : ffff0000090a0000 x8 : 0000000000000001
[  118.032827] x7 : ffff0000081b7540 x6 : 0000000000000000
[  118.032942] x5 : 0000000000000000 x4 : 0000000000000001
[  118.033058] x3 : 0000000000000000 x2 : 0000000000000000
[  118.033172] x1 : 0000000000000000 x0 : ffff000009bf9000

[  118.041496] [<ffff00000810b91c>] __lock_acquire+0xbc/0x1768
[  118.041653] [<ffff00000810d310>] lock_acquire+0x48/0x70
[  118.041810] [<ffff0000089b37ec>] _raw_spin_lock+0x4c/0x88
[  118.041934] [<ffff0000081b7540>] handle_mm_fault+0x1d0/0xc60
[  118.042074] [<ffff000008096710>] do_page_fault+0x2b8/0x358
[  118.042227] [<ffff0000080812a8>] do_mem_abort+0x40/0x98
```

20:33 2016-12-07
----------------
use the similar way with hugetlb still segfault:
linux:~ # [  184.253414] cc1[2471]: unhandled level 2 translation fault (11) at 0x34b003c8, esr 0x90000006
[  184.253699] pgd = ffff800074601000
[  184.253764] [34b003c8] *pgd=00000000b54fa003[  184.253831] , *pud=00000000b54e0003
, *pmd=0000000000000000[  184.253926]
[  184.253982]
[  184.262682] CPU: 0 PID: 2471 Comm: cc1 Not tainted 4.9.0-rc8-next-20161205-00003-g0dc9613-dirty #90
[  184.262911] Hardware name: linux,dummy-virt (DT)
[  184.263064] task: ffff80007ab14980 task.stack: ffff80007455c000
[  184.263331] PC is at 0x61ab14
[  184.263421] LR is at 0x61aad4
[  184.263507] pc : [<000000000061ab14>] lr : [<000000000061aad4>] pstate: 60000000
[  184.263650] sp : 0000ffffd960eaa0
[  184.263744] x29: 0000ffffd960eaa0 x28: 0000000000cc79c8
[  184.264023] x27: 0000000000000000 x26: 0000000000000200
[  184.264165] x25: 0000000000000000 x24: 0000000000000000
[  184.264308] x23: 000000000974a250 x22: 0000000000000000
[  184.264440] x21: 0000000000d77130 x20: 0000000000d77130
[  184.264578] x19: 0000000034b003c0 x18: 0000ffffd960e950
[  184.264700] x17: 0000ffffb43b8d80 x16: 0000000000cc01f8
[  184.264795] x15: 0000ffffb449b580 x14: ffffffffffffffff
[  184.264889] x13: 0000000000000008 x12: 0000000000000010
[  184.264982] x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f
[  184.265122] x9 : 6564631f71647254 x8 : 0000ffffd960eb70
[  184.265244] x7 : 697461746e656d67 x6 : 000000000974b092
[  184.265364] x5 : 000000000974ae80 x4 : 0000000000000000
[  184.265485] x3 : 0000000000000000 x2 : 0000000000000000
[  184.265611] x1 : 0000000000000000 x0 : 0000000000d5f000

21:10 2016-12-07
----------------
arnd: Here is my current patch[1], could you please take a look? It look good when I run basic comand, and allocate and set memory in multi process. It will crash when I compile the lmbench. I suspect there is some sort of race condition. But I could not figure out the reason.

18:02 2016-12-08
----------------
1:1 with Mark
1.  ILP32
    1.  Do the performance test of aarch32. Discuss with Mark if it is not easy.
    2.  follow up the glibc test failure if got some progress.
    3.  Reply to Catalin about current performance test result.
2.  apply attendee for linux storage, filesytem and memory conference.

11:08 2016-12-09
----------------
1.  `__get_user_pages()` -> `follow_hugetlb_page()`
Is it another chance to allocate the cont page? It seems that it is the hugetlb way to do it.
Do I need do the similar things for 16pages in the future? Maybe not.


2.  `hugetlb_fault()`
```
    /*
     * Serialize hugepage allocation and instantiation, so that we don't
     * get spurious allocation failures if two CPUs race to instantiate
     * the same page in the page cache.
     */
    hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, address);
    mutex_lock(&hugetlb_fault_mutex_table[hash]);
```

3.  About the lock, currently, only pte lock is used by copy_page_range. And hugepge will use huge_pte_lock. I should use the corresponding lock.
    And I could not understand the pte_lockptr(), why use *pmd?
    ```
    static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
    {
        return ptlock_ptr(pmd_page(*pmd));
    }

    static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
    {
        return ptlock_ptr(pmd_to_page(pmd));
    }
    ```
static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)

4.  About the crash
    1.  Show pte when enter do_anonymous_page. I do not understand why it allocate new pgd.
    2.  Should I lock the in the beginning of copy_page_range to avoid the incomplete copy of pgd?

5.  TODO
    1.  fix the wrong counter.
    2.  performance test:
        A<arnd> for the start, we mainly need to know the potential gains, comparing the three cases that already work (pure 4k page, pure 64k page, 4k+trans-huge)
        A<arnd> if 4k+trans-huge is already faster than 64k, there won't be much to gain by having 4k+page-hint+trans-huge
        A<arnd> also, if 64k is not much faster than 4k, then 4k+hint won't be very valuable because it's likely slower than 64k

09:28 2016-12-10
----------------
感觉自己节奏不太好. 每天到公司是否可以做一个25分钟可以做完的技术工作.

14:50 2016-12-12
----------------
Board farm in my home
----------------
1.  I was thinking buy a wifi power module for safe. Now I think only need a temperature sensor to monitor the temperature in the first step.
2.  Environment build up
    1.  Use the reply to console my board instead of buying a new wifi relay.
    2.  collect the sd card in my home.
    4.  Setup two ssh reverse agent for 'HA': Hikey and Pine64.
3.  For my baby project:
    1.  Use existing rfid/nfc reader/writer(or buy a new one) to test the report the wether, play the music.
    2.  Use one (usb) microphone to try to Amazon Echo/Google home. And then decided if I need buy a microphone array such as respeaker.
    3.  Read the book?
4.  For my arm64 high performance board:
    1.  Test performance(May need buy a sata ssd disk) with existing opensuse benchmark repo. Ask Mark Brown if I could test specint from Linaro on my board.
    2.  Try to setup a smart proxy with cow proxy to access the internet without enable vpn in mobile. Considering, there are only one 1G port. I may need another one to connect to my router.

15:01 2016-12-12
----------------
GTD
1.  today
    0.  I do not find the benifit for my works when I use trello.com and toggl.com. Plan to use these tools for non-work things.
    1.  Wrote baidu vm conf.
        14:56-15:52 I think it is more reasonable if I could finish it within 30 miutes. I just finish this work and there is no much characters actually.
    2.  Think about my board farm
        16:20-16:35

16:47 2016-12-12
----------------
1.  4.18-4.20. 4.18.19 last year. 4.20 this year.
2.  5.12,16 last year.
3.  5.23, 5.23 grand mather.
4.  7.11-7.15, 7.18. 7.11 last year. 7.12-7.15, 7.18 this year leave.

14:32 2016-12-13
----------------
GTD
---
1.  today
    1.  cont page hint. send patch to Arnd and Mark.
        1.  do anon_vma_prepare num_of_page times. no works.
            14:40-15:25
        2.  reorganize the patch.
        3.  send patch.
    2.  specint test for aarch32 on arm64 kernel.
        1.  more than 1 hour to prepare the environment.
    3.  I almost finish the job, except the specint one.

15:00 2016-12-13
Hi, Arnd, Mark

Here is part of my patch for contiguous page hint. I still encounter emptry page table entries. And I thought about the page table lock and misuse of some api. But no progress in recent weeks.

There are two debug flags. cont_page_order set the current order of page which will allocated during one hanle_pte_fault. The default value of cont_page_order is 0 which fall back to original code. cont_page_debug indicate the debug level.

Currently, I disable memcg, hugetlb, swap, transhuge, ksm in my test. There are empty entries when I compile lmbench. Could you please give me some suggestions? Thanks
[  275.021096] cc1[2721]: unhandled level 2 translation fault (11) at 0x3e9606b0, esr 0x90000006
[  275.022501] pgd = ffff80006e920000
[  275.022674] [3e9606b0] *pgd=00000000af020003[  275.022995] , *pud=00000000ada10003
, *pmd=0000000000000000[  275.023247]
[  275.027644]
[  275.027926] CPU: 0 PID: 2721 Comm: cc1 Not tainted 4.9.0-next-20161212-00001-g231b910-dirty #115
[  275.028126] Hardware name: linux,dummy-virt (DT)
[  275.028285] task: ffff8000768d1880 task.stack: ffff80006fa0c000
[  275.028593] PC is at 0x61ab14
[  275.028689] LR is at 0x61aad4
[  275.028772] pc : [<000000000061ab14>] lr : [<000000000061aad4>] pstate: 60000000
[  275.028918] sp : 0000ffffc3624c00
[  275.029021] x29: 0000ffffc3624c00 x28: 0000000000d76000
[  275.029284] x27: 0000000000cc0000 x26: 00000000ffc8968d
[  275.029446] x25: 0000000000000000 x24: 0000000000000000
[  275.029586] x23: 0000000020a1f880 x22: 0000000000000000
[  275.029714] x21: 0000000000d77130 x20: 0000000000d77130
[  275.029842] x19: 000000003e9606a8 x18: 0000ffffc3624ab0
[  275.029970] x17: 0000ffff99ae8d80 x16: 0000000000cc01f8
[  275.030099] x15: 0000ffff99bcb580 x14: ffffffffffffffff
[  275.030227] x13: 0000000000000008 x12: 0000000000000010
[  275.030362] x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f
[  275.030506] x9 : 6564631f71647254 x8 : 0000ffffc3624cd0
[  275.030640] x7 : 697461746e656d67 x6 : 0000000020a1c092
[  275.030767] x5 : 0000000020a1be80 x4 : 0000000000000000
[  275.030894] x3 : 0000000000000000 x2 : 0000000000000000
[  275.031050] x1 : 0000000000000000 x0 : 0000000000d5f000
[  275.031194]


What we could do for check_stack_guard_page? We could ignore it safely
when stack is grow down, we coud propbably not allocate the more than one
page. But we could also allocate 16 page by growing down the stack 16 pages.
Given that the stack may grow up quickly. It maybe worth to do it.
mmu_notifier_invalidate_range_start(src_mm, mmun_start, mmun_end);

git send-email --to  broonie@linaro.org --to arnd@arndb.de --cc bamvor.zhangjian@linaro.org --from bamvor.zhangjian@huawei.com

10:01 2016-12-14
----------------
GTD
---
1.  today
    0.  GTD and misc
        10:01-10:31 Is it possible use less than 20 minutes?
        20'         recover the network in blue area.
    1.  cont page hint.
        1.  Check the vma and page table and its parent when the process segfault. And print the corresponding page table in its parent.
            10:32-10:46 11:33-11:51 14:45-15:23
        2.  Write malloc, fork and access code to try to reproduce the failure. Could not reproduce.
            15:29-16:02 16:09-16:21
        3.  Run selftest for vm.
            16:21-16:28
        4.  Discuss with Arnd
            18:20-
    2.  specint test for aarch32 on arm64 kernel.
        1.  Ask if there is a native aarch32 compiler in huawei and/or opensuse.
            My colleague of huawei will help on it.
        2.  rebase ILP32 to our latest upstream branch for D03.
            1.  Test current kernel.
            2.  rebase.
        3.  run the current specint case in my company.
            1.  There are so many errors only sjeng is successful. give it up.
        4.  Test specint on aarch32 board(cubietruck) in my home farm.
            1.  (Tonight) Deploy opensuse tumbleweed.
                delayed.
            2.  (Tomorrow) compile specint testcase (I suppose there are spectools in linaro private repo).
            3.  (Friday) Test specint.
    3.  Linaro arm32 meeting.
        17:04-17:50
    4.  Public (performance) test framework for developer.
        1.  Discuss with test manager and project manager in Huawei if there is/will be.
        2.  (Tomorrow) If not build my own one(not script, It should be based on obs). Ask in opensuse mailing list before I started to do it.
    5.  When should I rebase the kselftest output?

10:35 2016-12-14
----------------
cont page hint
--------------
1.  check vma and mapping in `__do_user_fault()`. Check the parent from task_struct.real_parent
    I found that the invalid access is came from load/store. How should I know where does this access came from?
    Maybe I should write a test case which malloc memory in parent and access in child.
    If fail, find another fail senario.
2.  Run selftest for vm: it mainly for hugetlb.
3.  looking for memtester in opensuse repo.
4.  
```
"vma<"0x400000" -- "0xcaf000">, addr<"0x501d8c>
"ret<"0x204>

Breakpoint 2, __do_user_fault (tsk=0xffff80007aa96200, addr=44392332482589349, esr=2415919108, sig=11, code=196609, regs=0xffff80007420bec0) at arch/arm64/mm/fault.c:197
```


17:05 2016-12-14
----------------
I am working on cont page hint and ILP32 recently.
For cont page hint, there are stills segfault with empty. Such segfault is failed at load/store. Which is outside any vma of this process. I would image there are some wrong memory mapping with my patch, but I do not find a better way to check the mapping.

20:23 2016-12-14
----------------
debugging, gdb, user-defined commands
-------------------------------------
ref<https://sourceware.org/gdb/onlinedocs/gdb/Define.html>
```
define recursive_vma
set $gdb_vma=$arg0
while($gdb_vma->vm_next)
        output "vma<"
        output/x $gdb_vma->vm_start
        output " -- "
        output/x $gdb_vma->vm_end
        printf ">\n"
        set $gdb_vma=$gdb_vma->vm_next
end
```

(gdb) recursive_vma tsk->mm->mmap
"vma<"0x400000" -- "0xcaf000>
"vma<"0xcbe000" -- "0xcc0000>
"vma<"0xcc0000" -- "0xcd0000>
"vma<"0xcd0000" -- "0xd78000>
"vma<"0x2dacf000" -- "0x2db01000>
"vma<"0xffff96382000" -- "0xffff965a3000>
"vma<"0xffff965a3000" -- "0xffff965e2000>
"vma<"0xffff965e2000" -- "0xffff9672e000>
"vma<"0xffff9672e000" -- "0xffff9673d000>
"vma<"0xffff9673d000" -- "0xffff96741000>
"vma<"0xffff96741000" -- "0xffff96743000>
"vma<"0xffff96743000" -- "0xffff96747000>
"vma<"0xffff96747000" -- "0xffff967e1000>
"vma<"0xffff967e1000" -- "0xffff967f0000>
"vma<"0xffff967f0000" -- "0xffff967f1000>
"vma<"0xffff967f1000" -- "0xffff967f2000>
"vma<"0xffff967f2000" -- "0xffff96806000>
"vma<"0xffff96806000" -- "0xffff96815000>
"vma<"0xffff96815000" -- "0xffff96816000>
"vma<"0xffff96816000" -- "0xffff96817000>
"vma<"0xffff96817000" -- "0xffff96883000>
"vma<"0xffff96883000" -- "0xffff96892000>
"vma<"0xffff96892000" -- "0xffff96893000>
"vma<"0xffff96893000" -- "0xffff9689c000>
"vma<"0xffff9689c000" -- "0xffff968f9000>
"vma<"0xffff968f9000" -- "0xffff96908000>
"vma<"0xffff96908000" -- "0xffff9690a000>
"vma<"0xffff9690a000" -- "0xffff9690b000>
"vma<"0xffff9690b000" -- "0xffff96923000>
"vma<"0xffff96923000" -- "0xffff96932000>
"vma<"0xffff96932000" -- "0xffff96933000>
"vma<"0xffff96933000" -- "0xffff96934000>
"vma<"0xffff96938000" -- "0xffff96944000>
"vma<"0xffff96944000" -- "0xffff96962000>
"vma<"0xffff96962000" -- "0xffff96963000>
"vma<"0xffff96963000" -- "0xffff9696a000>
"vma<"0xffff9696a000" -- "0xffff9696f000>
"vma<"0xffff9696f000" -- "0xffff96970000>
"vma<"0xffff96970000" -- "0xffff96971000>
"vma<"0xffff96971000" -- "0xffff96972000>
"vma<"0xffff96972000" -- "0xffff96973000>
"vma<"0xffff96973000" -- "0xffff96974000>

12:09 2016-12-15
----------------
GTD
---
1.  today
    0.  GTD and misc
        1.  Not actually work in whole morning.
        2.  Started to work from 14:45.
    1.  cont page hint.
        1.  Summary for the discussion of yesterday
            14:45-14:56 ref"14:28 2016-12-15"
        2.  Start to write the other code.
            Delayed.
    2.  specint test for aarch32 on arm64 kernel.
        1.  Ask if there is a native aarch32 compiler in huawei and/or opensuse.
            Ask in next week: My colleague of huawei will help on it.
            Ask in opensuse: If I fail in try the cubieboard JeOS.
        2.  rebase ILP32 to our latest upstream branch for D03.
            1.  rebase.
                15:11-15:25
                16:04-16:11  compile
            2.  Test
                Test tonight.
        3.  run the current specint case in my company.
            1.  There are so many errors only sjeng is successful. give it up.
        4.  Test specint on aarch32 board(cubietruck) in my home farm.
            1.  (Tonight) Deploy opensuse tumbleweed.
                delayed.
            2.  (Friday) compile specint testcase (I suppose there are spectools in linaro private repo).
            3.  (Friday) Test specint.
    4.  Public (performance) test framework for developer.
        1.  Discuss with test manager and project manager in Huawei if there is/will be.
        2.  Ask developer of kselftest.
        3.  If not build my own one(not script, It should be based on obs). Ask in opensuse mailing list before I started to do it.
    5.  Fix the issue in ssh.py.
        15:35-16:04 ref"15:40 2016-12-15"
        16:30-17:02 It should be worked.
        17:06-17:20 Add commit message.
        17:50-18:08 Fix the fake failure of ssh.
    6.  When should I rebase the kselftest output?

14:28 2016-12-15
----------------
1.  Chat with Arnd(#arm-linux at freenode).
    ```
    [2016-12-14 05:19:48] <arnd> bamvor: regarding your patch to do_anonymous_page, I wonder if you could be hitting a race there, and multiple CPUs are trying to modify the same ptes at the same time
    [2016-12-14 05:20:49] <bamvor> yes. I think about it. But there is pte_lock when I modify the entry of page.
    [2016-12-14 05:20:57] <bamvor> is it enough?
    [2016-12-14 05:21:20] <arnd> I also see that the page fault you get is for level 2, but I assume you are running four-level  page tables, so the fault is for the pmd, not the pte level
    [2016-12-14 05:21:29] <bamvor> I also try the mm->page_table_lock, but no difference .
    [2016-12-14 05:21:58] <bamvor> yes. usually pmd level fault. sometimes pgd.
    [2016-12-14 05:22:15] <arnd> ok
    [2016-12-14 05:24:36] <bamvor> currently, I get pte from pte_offset_map_lock and then pte++ to get other pte. Because I aleady check such address in the single pmd entry. It is similar to hugetlb way. Do you think it is ok?
    [2016-12-14 05:25:28] <arnd> I think we also hold mm->mmap_sem, which is probably sufficient here
    [2016-12-14 05:25:58] <bamvor> yes. I think so.
    [2016-12-14 05:26:48] <bamvor> And another question is I do not understand the anon_vma_prepare. Does anon_vma_prepare relative to one page? I do not see any code in it rely on the address or num of page.
    [2016-12-14 05:30:53] <arnd> bamvor: looking at the error message, it's clear that handle_mm_fault() returned one of VM_FAULT_ERROR , VM_FAULT_BADMAP, or VM_FAULT_BADACCESS, so I'd try to find out where they are returned
    [2016-12-14 05:34:43] <bamvor> I think I could confirm it in my environment.
    [2016-12-14 05:35:38] <arnd> and the most likely candidate for returning one of them would be do_wp_page, so it's probably a write access following the read access that fails
    [2016-12-14 05:38:56] <arnd> bamvor: one thing I don't see is where you align vmf->address to the lower 64k boundary
    [2016-12-14 05:39:52] <bamvor> I do not align it. I just allocate the 64k page when it align with 64k boundary.
    [2016-12-14 05:40:23] <arnd> ah, I see
    [2016-12-14 05:41:07] <bamvor> maybe I could optimize as you said. I am just not sure whether it will improve or not.
    [2016-12-14 05:41:46] <bamvor> i do not understand why the fault address is outside all the vma. I do not think it is possible. correct?
    [2016-12-14 05:46:15] <arnd> why would it be? I don't see any indication that it is
    [2016-12-14 05:46:33] <arnd> bamvor: the in_pte() check is redundant, right?
    [2016-12-14 05:46:48] <arnd> since you already check the alignment
    [2016-12-14 05:48:45] <bamvor> yes. I could remove the in_pte.
    [2016-12-14 05:48:52] <arnd> ah wait, you don't check the alignment, the 'if (ALIGN(vmf->address, PAGE_SIZE * cont_page_num))' check won't do anything really since vmf->address is always a number larger than the first few pages
    [2016-12-14 05:50:28] <arnd> I think the check you need here is 'vmf->address < ALIGN(vmf->address, PAGE_SIZE * cont_page_num) + PAGE_SIZE'
    [2016-12-14 05:50:36] <arnd> to check that you are within the first page
    [2016-12-14 05:51:11] <arnd> bamvor: at least I think that is what you intended
    [2016-12-14 05:51:47] <bamvor> not sure if I could follow you. before enter handle_mm_fault, address already align to PAGE_MASK.
    [2016-12-14 05:52:58] <bamvor> And it will align again when create vmf.
    [2016-12-14 05:53:34] <arnd> ah, then you just need to check 'if (!(vmf->address & (PAGE_MASK << cont_page_order))
    [2016-12-14 05:53:40] <arnd> )'
    [2016-12-14 05:54:20] <bamvor> oh, yes.
    [2016-12-14 05:54:42] <arnd> but it would be better to not limit yourself to that special case at all
    [2016-12-14 05:55:00] <arnd> and instead align the address down:
    [2016-12-14 05:55:10] <arnd> address = ALIGN(vmf->address, PAGE_SIZE * cont_page_num);
    [2016-12-14 05:56:06] <arnd> then check that address..address+64k is within the vma and fault all 16 pages
    [2016-12-14 05:56:16] <arnd> independent of where within that range the faulting address was
    [2016-12-14 05:56:23] <arnd> so faulting both before and after
    [2016-12-14 05:57:23] <bamvor> understand.
    [2016-12-14 05:58:06] <arnd> for the initial testing, either way should work, but I see no reason to not just do it the full way already
    [2016-12-14 06:02:38] <arnd> bamvor: I think I see another problem: the !FAULT_FLAG_WRITE case is interesting, as you change that to have 16 copies of the zero-page
    [2016-12-14 06:03:42] <bamvor> arnd: the return value of handle_mm_fault is 0x204: VM_FAULT_LOCKED &&  VM_FAULT_MAJOR.
    [2016-12-14 06:03:45] <arnd> this is probably where things go wrong in the do_wp_page later. I don't see a specific problem here, but you can probably skip that for now and only worry about do_anonymous_page() with FAULT_FLAG_WRITE for the start
    [2016-12-14 06:05:45] <arnd> bamvor: I don't see how VM_FAULT_LOCKED or VM_FAULT_MAJOR would cause the warning message to be printed. Are you sure this isn't just the initial fault that is successful?
    [2016-12-14 06:19:34] <bamvor> arnd: I came back. i am checking it.
    [2016-12-14 06:24:47] <bamvor> I do not find that mmap_mm is release after __do_page_fault, i will retest it.
    ```

2.  suggestion from Arnd:
    1.  Ignore the current failure, only work for write of do_anonymous_page. Work on do_wp_page.
    2.  Allocate the contiguous pages no mather current address is the beginning page or not. Remove useless alignment check.

15:40 2016-12-15
----------------
fix the issue in ssh.py
-----------------------
1.  Error
    ```
    Traceback (most recent call last):
      File "./ssh.py", line 332, in <module>
        test()
      File "./ssh.py", line 293, in test
        ssh_transport(host, host_user, ["ls"])
      File "./ssh.py", line 98, in ssh_transport
        ssh.load_system_host_keys()
      File "/usr/lib/python2.7/site-packages/paramiko/client.py", line 101, in load_system_host_keys
        self._system_host_keys.load(filename)
      File "/usr/lib/python2.7/site-packages/paramiko/hostkeys.py", line 101, in load
        e = HostKeyEntry.from_line(line, lineno)
      File "/usr/lib/python2.7/site-packages/paramiko/hostkeys.py", line 331, in from_line
        key = RSAKey(data=decodebytes(key))
      File "/usr/lib/python2.7/site-packages/paramiko/rsakey.py", line 58, in __init__
        ).public_key(default_backend())
      File "/usr/lib64/python2.7/site-packages/cryptography/hazmat/backends/__init__.py", line 35, in default_backend
        _default_backend = MultiBackend(_available_backends())
      File "/usr/lib64/python2.7/site-packages/cryptography/hazmat/backends/__init__.py", line 22, in _available_backends
        "cryptography.backends"
    AttributeError: 'EntryPoint' object has no attribute 'resolve'
    ```

2.  Someone in internet said I should downgrade cryptography. But I do not know how.

19:38 2016-12-15
----------------
From: Bamvor Jian Zhang <bamvor.zhangjian@linaro.org>
Subject: [RFD] bamvor's work and priority

Hi, Arnd, Mark

I feel the progress of my work is not good in recent one month. I am re-thinking what I need to do and priorities, any feedback or suggestion is welcome. Thanks.
1.  ILP32:
    1.  I need test lmbench and specint for arm32.
        1.  lmbench: I am looking for help from my colleague.
        2.  specint: After I read the script of from tcwg, I get the idea how to test aarch32 specint on arm64 kernel. I think I could get the result in early next week.
    2.  Minor maintainance work internally in huawei. It will not take too much time, 0.5 day or so.
    3.  Is there anything I could do with regard to upstreaming?

2.  Cont page hint:
    1.  After discuss with Arnd this week, I start to write the code in do_wp_page. Hope I could send a new version of patch in the end of next week.
    2.  I plan to test 4k page, 4k page with transhuge, 64k page hugetlb on 4k page in next week. And compare the result from [1]
        Once I got the performance numbers I will send to you. I think a positive number may help me apply as attendee of linux mm conference.

Regards

Bamvor

[1] http://users.ece.utexas.edu/~ljohn/teaching/382m-15/reading/korn.pdf, Got this paper from Maxim
[1] https://www.cs.utexas.edu/~yjkwon/pdf/kwon16osdi-ingens.pdf

09:58 2016-12-16
----------------
GTD
---
1.  today
    0.  rest and/or leave the desk
        11:29-11:35
    1.  ILP32
        1.  performance:
            1.  ssh.py
                10:03-10:36 add env check in ssh.py
                10:42-10:50 minor fix for above changes.
            2.  specint for arm:
                1.  compile specint in 32bit arm environment.
                    11:21-11:29 make toolsinstall
                    11:36-12:02
                2.  copy the object to arm64 board and do the test.
            3.  lmbench for arm(wrote script).
                Cancel. Looking for the resouce in huawei.
    1.  Think about the plan of today.
        10:52-11:21
    2.  Send email to Mark and Arnd about my confuse of priority.
    3.  cont_page_hint: "10:57 2016-12-16".
    4.  KBUILD_OUTPUT: "11:28 2016-12-16"

10:57 2016-12-16
----------------
cont page hint
--------------
1.  Performance proof:
    1.  Ask performance comparision of 4k and 64k from Maxim Kuvyrkov
    2.  Run 4k, 4k with transhuge, 64k for specint(64k hugetlb on 4k?).
        1.  1219: Discuss with Arnd. Arnd suggest pure 64k.
                  Environment setup finish.
        2.  1220: Verity the hugetlb environment.
                  Test pure 64k environment.

2.  linux mm conference.
    1.  possible requirement:
        1.  performance proof.
        2.  current patch(?)

3.  Coding
    1.  do_wp_page.
    2.  Arnd: allocate the 64k in the twice request. This is essential for sending to list.

11:28 2016-12-16
----------------
KBUILD_OUTPUT
-------------
1.  Ask Shuah if I could rebase to her next branch now.

11:40 2016-12-19
----------------
GTD
---
1.  today
    1.  send patch to guohanun. DONE
    2.  Process the ticket of sync_file_range2 in huawei internally.
        15:19-15:50 17:03-17:20
    2.  read reply from arnd and mark DONE
    3.  linaro activity. DONE(On my way home and at home)

12:07 2016-12-19
----------------
TODO
---
add to ssh.py
ssh.py is not intened to as a build system. It is a glue for kernel testing.
1.  ltp
    1.  env_check
        rpm -qa |grep ltp -w
    2.  env_setup
        zypper addrepo -c -f -r http://download.opensuse.org/repositories/benchmark/openSUSE_Factory_ARM/benchmark.repo
        zypper -v --non-interactive install ltp

    add ssh no key check: -o "StrictHostKeyChecking=no"
    compile kernel add kernel config.

15:28 2016-12-19
----------------
learning syscall, file, sync
----------------------------
1.  sync_file_range
    1.  Learned:
        1.  Sync and Async.
        2.  Metadata and data.

    2.  Useful flag:
        ```
         * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE: ensures that all pages
         * in the range which were dirty on entry to sys_sync_file_range() are placed
         * under writeout.  This is a start-write-for-data-integrity operation.
        ```
        SYNC_FILE_RANGE_WAIT_AFTER
        2.  Do not write the metadata
            ```
             * It should be noted that none of these operations write out the file's
             * metadata.  So unless the application is strictly performing overwrites of
             * already-instantiated disk blocks, there are no guarantees here that the data
             * will be available after a crash.
            ```

20:15 2016-12-19
----------------
git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc linus.walleij@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2016-12-12 to 2016-12-19

* KWG 174: KBUILD_OUTPUT fix for kseltest
    Got confict when Shuah merge them. Will rebase and send to LKML after 4.10-rc1 is out.

* KWG-192: Use of contiguous page hint to create 64K pages
    Discuss with Arnd and Mark. Arnd suggest skip the current segfault temperary and work on the do_wp_page.
    Read the doc in libhugetlbfs to learn how to test 64k hugetlb performance of speccpu.
    Discuss with Maxim(from tcwg). Maxim share me a paper[1] which is shown that the benefit of 64k page.

* Gpio selftest
    Shuah merge the last(5/5) patch.

* ILP32
    Two issues from huawei:
        sync_file_range2: I forget to cc our(Huawei) stable kernel after discuss with LKML. It is merged to huawei stable kernel this week.
        Input test case: The input01-input06 of LTP failed in our system because the wrong INPUT_COMPACT_TEST for ILP32. It is not existed in upstream kernel because INPUT_COMPAT_TEST is replaced by is_compat_syscall().
    Performance test: looking for the internal resource for test lmbench of aarch32 on arm64 kernel.

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    Write the code in do_wp_page
    Performance test to evaluate whether it is worth to do this.

* ILP32 performance test
    Test Lmbench and specint.

[1] http://users.ece.utexas.edu/~ljohn/teaching/382m-15/reading/korn.pdf

11:09 2016-12-20
----------------
GTD
---
1.  today
    1.  Upstream kernel: hikey.
        Plan: 10min
        11:19-11:45 upstream kernel boot successful. But forget to build usb net. And there are hangtask.
        16:08-16:54
    1.  Performance test.
        1.  ILP32:
            1.  Think about how to test in batch mode.
                17:11-17:59 My colleague help me on it, test stream,hackbench,libMicro-0.4.0,bonnie-1.03e,lmbench3,netperf-2.7.0,sysbench,tiobench-0.3.3. Running except lmbench build failure.
                            Running. Check result tomorrow.
            2.  Run specint(from linaro) on hikey upstream kernel.
                Running.
        2.  cont page hint(DELAY)
            1.  64k hugetlb need boot with 64k hugetlb only mode.
    1.  Reply to Patent.
        14:29-14:57 15:02-15:15
    1.  huawei:
        14:57-15:02 15:30-15:42 ILP32 issue. ILP32 performance regression.
        15:13-15:30 page dirty.
    1.  Excise
        15:42-16:08
    1.  do_wp_page(DELAY).
    1.  Summay:
        18:20-
        1.  do not write the code for cont page hint. This is the second day not wrote the code:(
        2.  Not test the performance of cont page hint.
        3.  ILP32 performance regression seems a good start.

2.  Next
    1.  Share build method of specint with my colleague.
        Cancel. Already fix it by colleague.

10:34 2016-12-21
----------------
GTD
---
1.  today
    1.  Huawei: discuss with our pl.
        10:34-10:57
    2.  Huawei: discuss about my cont page hint and linux-mm in our department.
        11:04-11:22 I should quickly if I want to attend the linux-mm.
    3.  Internal issue.
        14:08-14:17
    4.  cont page hint
        1.  performance test
            1.  64k hugetlb need boot with 64k hugetlb only mode.
        2.  pure 4k, 4k transtlb, pure 64k, 64k transtlb.
            14:37-15:24
            15:35-15:55
            19:19-19:40 There is not differece between 4k and 64k if transhuge opened. Run all the specint to verify this conclusion.
    1.  continue to ILP32 performance test
        1.  Check the previous result and patch ILP32 patches, run specint.
            16:17-17:21
    1.  do_wp_page.
        Cancel. The third day do not work on the code.

1.  Next
    1.  cont page hint:
        1. Test with defragment.
    1.  gpio patch: ask mark: should I said s-o-b if I think it is ok?
    1.  abi checker. two versions
    2.  issue of ilp32 in huawei.

09:42 2016-12-22
----------------
GTD
---
1.  today
    1.  cont page hint:
        1.  Improve specint script to support *.ref.txt directly(It only support directory till now) and get the yesterday. ref"10:14 2016-12-22"1
            9:54-10:15
        2.  Prepare the environment to run specint in hikey.
        2.  Try the hack patch.
            14:44-15:16 Could not focus. Stop the timer.
        2.  Ask my colleagues about FMFI.
    1.  ssh tools
        Json dump to the wrong directory.
    1.  同样是出错: 在restore_sigframe里面有打印, 但是在handle_signal里面没有. 要不要给社区发个补丁?

10:14 2016-12-22
----------------
(17:12 2016-12-27)
Reference the result and analysis in "17:46 2016-12-27"
1.  specint single core(20161222) compare with 4k pure(dis transtlb)
2.  specint single core(20161226) compare with 4k with transhuge:

10:29 2016-12-23
----------------
GTD
---
1.  today
    1.  Discuss with my colleague about how to migrate legacy arm 32bit apps to arm64 SOC which without aarch32 EE.
        ILP32, qemu-system, qemu-linux-user.

10:55 2016-12-24
----------------
GTD
---
1.  today
    1.  Test ILP32 on hikey, lmbench, specint(aarch32, aarch64), upstream kernel, with disabled ILP32, enable ILP32.
        11:02: run aarch64 specint on when ILP32 enabled.
        how to run aarch32 specint? set ext to aarch32 or aarch64 or what ever you set in build.
        next: run aarch32 specint on when ILP32 enabled.
    2.  cont page hint: hack.
        11:46-
    3.  make use of hugetlb.
        15:01-15:52 The reason libhugetlbfs do not work is that I do not mount hugetlbfs.
        16:45-

2.  Plan
    1.  Timesheet:
        1.  cont page hint: more than 4h.
        2.  other work: 1h. Security and patches review.
        3.  ILP32: other.

16:03 2016-12-27
----------------
<https://bugs.96boards.org/show_bug.cgi?id=467>

Hi, I also find this issue in my hikey. It will show hung task when I compile kernel on hikey with -j4[1].
I try to disable the uhs hung tasks still exist[2].

There are similar interrupt storm in my board. It just cpu4 instead of CPU0.
bamvor@localhost:~> A=$(cat /proc/interrupts | grep "38:" | awk '{ print $6 }'); sleep 1; B=$(cat /proc/interrupts | grep "38:" | awk '{ print $6 }'); echo "$((B - A)) irq/sec"
8173 irq/sec

My kernel is master of kernel: "59331c215daf Merge tag 'ceph-for-4.10-rc1' of git://github.com/ceph/ceph-client""""
My hikey is lemaker 2G version with 100M usb ethernet. My rootfs(opensuse tumbleweed) on sd card.

[1] hung_task_log_from_bamvor
[2] hung_task_wo_uhs_log_from_bamvor

17:46 2016-12-27
----------------
git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2016-12-20 to 2016-12-27

* KWG-192: Use of contiguous page hint to create 64K pages
    - Current performance test
        Arnd suggest test pure 4k/64k and/or transhuge. We could see that the performance of 4k with transhuge improved a lot. But it is insignificant on 64k page. Compare with 4k(transhuge), only libquantum gets improved in 64k. And hmmer is decreased a lot. The result is as follows. Note that all the test is running only once, for a reportable run, it should be 3. So, the result may be not very acurate.
        specint single core compare with 4k disable transtlb
                        4k with transtlb      64k(transtlb disable)  64k with transtlb  Mark
         400.perlbench:  1.59%                  2.38%                    2.38%
             401.bzip2:  0.53%                  2.88%                    3.21%
               403.gcc:  1.58%                  3.16%                    3.29%
               429.mcf: 19.65%                 17.26%                    18.33%
             445.gobmk:  0.88%                  1.77%                    1.77%
             456.hmmer:  0.00%                -39.61%                   -40.33%          ---
             458.sjeng:  2.88%                  3.85%                    1.92%
        462.libquantum:  5.88%                  9.80%                    14.38%          ++
           471.omnetpp: 12.54%                 13.04%                    12.04%
             473.astar:  8.59%                 10.59%                    9.76%
         483.xalancbmk:  8.11%                  5.41%                    6.31%           -

        So, I continue to test with hugetlb on 4k. hmmer and libquantum get significantly improved. And hugetlb 64k is better than hugetlb 2048k in hmmer and libquantum.
        Specint single core compare with 4k with transhuge:
                           hugetlb_64k   hugetlb_2048k    Mark
               401.bzip2:        2.34%           3.72%      +
                 403.gcc:        0.39%           0.90%
                 429.mcf:        0.55%           0.89%
               445.gobmk:        0.88%           0.88%
               456.hmmer:       10.34%           8.97%      ++
               458.sjeng:       -1.87%           0.93%
          462.libquantum:       10.49%           4.32%      ++
             471.omnetpp:       -0.45%           2.84%
               473.astar:        1.30%           2.70%
           483.xalancbmk:       -1.67%           0.83%

    - libquantum is a library for the simulation of a quantum computer, and hmmer is "Search a gene sequence database". I am not sure if these numbers are enough. And there is another advantages of 64k hugepage is the less memory waste. I test the waste of memory through malloc.
    malloc 3000000Bytes
    size  | Actual allocated       |   waste
    ------|------------------------|--------
    2048k | 10485760(5 hugepages)  |    249%
    64k   | 3145728(48 hugepages)  |   0.49%

    malloc 30000000Bytes
    size  | Actual allocated       |  waste
    ------|------------------------|-------
    2048k | 37748736(18 hugepages) |    25%
    64k   | 30146560(460 hugepages)| 0.049%

    We could see that 2048k in hugetlb will waste lots memories, and potentially lead to more fragment. I am thinking if I should evaluate by FMFI(Free Memory Fragmentation Index).

    - I also investigate the kernel config in mobile. I found that both HUGETLB and TRANSHUGE are disabled. My colleague told me that enable transhuge will use ~800M more memory after system boot. There is a discussion about if android should make use of 64k/16k page or remain 4k page internally. Is it a better solution that mobile stay 4k page with 64k contiguous page hint compare with migrating to pure 64k page?

* ILP32
    - Performance test:
        When I do the ILP32 performance regression test on my hikey board, I found a hungtask issue which is as same as Denial: [Bug 467 - mainline kernel (4.9-rc8) shows a task hung warning related to MMC](https://bugs.96boards.org/show_bug.cgi?id=467). This issue seems not affect the correctness of test.
        There is a benchmark test suite which could support stream,hackbench,libMicro-0.4.0,bonnie-1.03e,lmbench3,netperf-2.7.0,sysbench,tiobench-0.3.3 and other testcases, plan to test them after finish the performance test of cont page hint.
    - Misc support for my colleague in huawei.

=== Plans ===
* KWG 174: KBUILD_OUTPUT fix for kseltest
    Rebase and send to LKML based on 4.10-rc1.

* KWG-192: Use of contiguous page hint to create 64K pages
    Write the code in do_wp_page
    Continue to performance test to evaluate whether it is worth to do this. Finish the lmbench test on above hugetlb 4k/2048k on 4k page size. Test specpu float.

* ILP32 performance test
    Test Lmbench, specint and other testsuite.


DO NOT SEND
    I check the hugetlb usage in try run. I found that there is not much 64k hugetlb allocated compare with hugetlb 2048k and THP. E.g. there are totally 8MBytes 64k-sized hugepage allocated in mcf test which is much smaller in 2048k hugetlb and THP. And I test the memory consumption with malloc:

11:06 2016-12-28
----------------
GTD
---
1.  today
    1.  Plan
        11:07-11:14
    1.  Linaro activity.  11:14
    2.  cont page hint:
        1.  do_wp_page(more than 3h)
        2.  Performance test result.
    3.  ILP32 performance regression test
        11:24-11:27
    3.  Discuss with Ming Ling about 4k and 64k page?
    4.  DONE: Discuss about education of children and/or new (IT/embedded) technology in traditional industry at lunch.
    5.  Finish record for Kameila.
    6.  Send out the wechat for vocore and earbon.

2.  Next
    1.  security
        1.  ask my colleague in suse and linaro.

10:30 2016-12-30
----------------
GTD
---
1.  today
    1.  short summary of my work in this year.
        10:31-11:58
    2.  check the result of lmbench.

