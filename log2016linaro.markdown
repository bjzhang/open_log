
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

