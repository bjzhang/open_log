
15:57 2015-04-08
----------------
question for 1:1 with Mark
1.  A: What do you think about linaro.
       I heard that the kernel team lead shift.
       And sumsung quit from linaro.
    Mark: I think it is normal

2.  send weekly report in kwg mailing list.

3.  roadmap.linaro.org

4.  resources:
    https://wiki.linaro.org/Internal/hackbox



16:28 2015-04-08
----------------
1.  use kabi to trace embedded types.

    time make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 KBUILD_SYMTYPES=1

amazonaws:
    real    9m51.603s
    user    8m20.964s
    sys     0m39.904s

2.  filt the ioctl function.
    > grep "\.compat_ioctl" * -R --exclude="*.o.cmd" | sed "s/^\(.*\):.*=[\ \t]*\(.*\),/\1:\2/g" > ../compat_ioctl_list
    > grep "\.unlocked_ioctl" * -R --exclude="*.o.cmd" | sed "s/^\(.*\):.* =[\ \t]*\(.*\),/\1:\2/g" > ../ioctl_list

3.  use python and cscope to search the arg relative line. especially copy_from_user.

10:49 2015-04-15
----------------
GTD
---
1.  today
    1.  setup my laptop environment.
        TODO: add vpn.
    2.  2K38 compat_ioctl
        how do I know if I use the timeval or timespec?

18:07 2015-04-17
----------------
[jenkins doc](https://docs.google.com/document/d/151upFEv1fj67TXbzZT06wY4gBltPrEoA5wKAG8Ia2o4/edit)
<http://blog.mist.io/post/82383668190/move-fast-and-dont-break-things-testing-with>

22:36 2015-04-17
----------------
python, IO, redirection
-----------------------
1.  根据下文解决了问题
<http://www.cnblogs.com/turtle-fly/p/3280519.html>
2.  不知道为什么下面这个不行, 看起来和第一个一行.
<http://stackoverflow.com/questions/7152762/how-to-redirect-print-output-to-a-file-using-python>

08:51 2015-04-18
----------------
GTD
---
1.  today
    1.  2K38 compat_ioctl. see"08:52 2015-04-18"

08:52 2015-04-18
----------------
2K38, compat_iocl
-----------------
1.  need find the root the struct. Because I do not know if the driver will access the father type with something like "`container_of`"
2.  TODO: I could not handle the variable if it is global.

15:22 2015-04-18
----------------
colleague, Platform Engineering, Builds and Baselines
-----------------------------------------------------
1.  Fathi Boudra
BIO
Fathi has worked in the software development since 14 years. He started in the industrial computing for various industries (car, medical, etc...), using Linux technologies and promoting Free Software. He joined IT&L@bs in 2007 as a technical lead, focusing on Linux based solutions. Before joining Linaro, Fathi worked for Nokia as MeeGo SDK release team lead and maintainer of Qt/Qt WebKit/Qt Mobility stack. He's a Debian developer, KDE e.V. member and contributes to various open source projects.
ASK ME QUESTIONS ABOUT...
Embedded systems, Linux middleware, Debian, Qt, KDE, MeeGo, networking, open source software development, hardware, releasing
CONTACT DETAILS
* IRC: fabo
* Email: fathi.boudra@linaro.org
* Timezone: (UTC +2:00) Central Africa Time, Eastern European Time, Kaliningrad Time

17:02 2015-04-21
----------------
linaro, work, compat_ioctl
--------------------------
1.
        16:55 <arnd> you can work on these simultaneously, if you get stuck on one, work on the other 
        16:56 <arnd> some some point, we will have to add some infrastructure for handling the harder cases in a consistent way, but you can work on the easier ones first
        16:56 <arnd> the easy ones being the ones where you can tell from the ioctl command number what the layout is
        16:57 <arnd> it's much harder when the same ioctl command number is used for all possible layouts, because then the kernel has no way to find out which layout gets used by a given task, and we have to change the header files so user space gets a different command number at compile time

        17:40 <arnd> do you know coccinelle?
        17:40 <arnd> http://coccinelle.lip6.fr/
        17:41 <arnd> it can do very sophisticated pattern matching on C code, and even generate patches
        17:41 <arnd> extremely powerful, but take a bit of time to get used to the syntax

2.
        17:56 <bamvor> What's your mean "layout"?
        17:58 <arnd> I mean the way that a structure is represented in memory
        17:58 <bamvor> "16:56 <arnd> some some point, we will have to add some infrastructure for handling the harder cases in a consistent way, but you can work on the easier ones first
        17:58 <bamvor> 16:56 <arnd> the easy ones being the ones where you can tell from the ioctl command number what the layout is
        17:58 <bamvor> 16:57 <arnd> it's much harder when the same ioctl command number is used for all possible layouts, because then the kernel has no way to find out which layout gets used by a given task, and we have to change the header files so user space gets a different command number at compile tiem
        17:58 <bamvor> 16:57 <arnd> time"
        17:58 <bamvor> I could not follow you. 
        17:59 <arnd> like 'struct foo {int a; time_t b};' would be an example of an incompatible structure, because uses 8 bytes on current 32-bit machines, but 16 bytes (including padding) on 64-bit machines. 
        New messages
        18:01 <arnd> if an ioctl command is defined as '#define FOOIOC1 _IOR('F', 1, struct foo)', then the command will encode this size in the command code
        18:03 <arnd> in this case (2 << (14 + 8 + 8) | sizeof(struct foo) << (14 + 8) | 'F' << 8 | 1)
        18:04 <arnd> this means the ioctl handler can switch/case based on the command number and handle cmd (2 << (14 + 8 + 8) | 8 << (14 + 8) | 'F' << 8 | 1) different from  (2 << (14 + 8 + 8) | 16 << (14 + 8) | 'F' << 8 | 1)
        18:05 <arnd> (I replaced sizeof(struct foo) with 8 and 16 there, respectively)
            18:05 <arnd> but some older drivers would define the command number as ''#define FOOIOC1 0x1234", and then the handler does not know the size
            18:06 <arnd> there are also some broken drivers that use '#define FOOIOC1 _IOR('F', 1, struct foo *)'
            18:07 <arnd> which is broken because 'sizeof(struct foo *)' is always the same as 'sizeof(void *)', independent of the contents of struct foo

13:04 2015-04-23
----------------
software skill, qemu, aarch64
-----------------------------
    qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -m 1024  -kernel /home/bamvor/works/source/kernel/linux/arch/arm64/boot/Image -append "console=ttyAMA0 root=/dev/vda2 rw" -drive if=none,file=/home/bamvor/works/software/opensuse/openSUSE-13.1-ARM-JeOS-vexpress64.aarch64-1.12.1-Build37.15.raw,id=vda -device virtio-blk-device,drive=vda -net user -netdev user.id=net0,net=192.168.76.0/24,dchpstart=192.168.76.0,hostfwd=tcp:2222-:22 -device virtio-net-device,netdev=net0

10:10 2015-04-23
----------------
compat_ioctl
------------
1.  todo: 
    1.  add copy_to_user and put_user. Could find the type in these functions too.

2.  driver/md/md.c
    in function get_array_info, typedef struct mdu_array_info_s: c_time, u_time is int not time_t.

3.  change a new way
> grep "\(time_t\)\|\(timespec\)\|\(timeval\)" -l * -R > time_xxx_type_list
> grep _IO -l * -R > ioctl_cmd_file_list <abi_get_common_of_time_xxx_and_ioctl_file.py>
```python
    #!/usr/bin/env python

    ioctl_cmd_list = [line.strip() for line in open("ioctl_cmd_file_list")]
    time_xxx_list = [line.strip() for line in open("time_xxx_type_list")]

    common = set(ioctl_cmd_list) & set(time_xxx_list)
    print common
```
I could get the result:
set(['linux/input.h', 'linux/cyclades.h', 'linux/atm_zatm.h', 'linux/atm_nicstar.h', 'linux/coda.h', 'linux/videodev2.h', 'drm/msm_drm.h', 'linux/ppdev.h', 'sound/asound.h', 'sound/asequencer.h', 'linux/omap3isp.h', 'linux/pps.h', 'linux/dvb/video.h', 'linux/btrfs.h'])

15:40 2015-04-24
----------------
linaro, work reprot, weekly report
----------------------------------
1.  work repot
[ACTIVITY] 2015/04/13 to 2015/04/27
== Bamvor Jian Zhang (bamvor) ==

=== Highlights ===

* Working on 2K38 issue in ioctl
    - Object: fix the 2K38 issue in compat_ioctl(arm64) and ioctl(arm) which
      access time_t, timespec and timeval.

    - My approach:
        1.  the first method is that check if ioctl cmd live with time_xxx
            type in the same headers. Got 14 headers, including input
            device, btrfs and so on.
        2.  the second method is that grep the all
            "`copy_\(from\)\|\(to\)_user`", "`\(get\)\|\(put\)_user`" in the
            system and then get the 'real' type of arg in above kernel<->user
            functions. Finally, check if the time_xxx types in included in
            'real' type of arg. The final step need to check manually right
            now. It may take more time for checking these types. I will
            do the it again after I fix some ioctls.

    - Currently, I found two types of driver need to fix.
        1.  The driver access the time_xxx explicitly. E.g. input device.
        2.  The driver access the time_xxx but convert to other type(e.g.
            convert time_t to int) when return back to userspace. E.g.
            md driver define ctime and utime as int in mdu_array_info_t
            in "include/uapi/linux/raid/md_u.h"
            It is hard to search these type of driver automatically.

* Discuss v2 ilp32 patches in builroot mailing list.
    - These patches enable aarch64_be and enable ilp32 in aarch64 and
      aarch64_be in buildroot. Buildroot is an cross compile build system for
      embedded world. And Given that the ilp32 support for gcc is upstreamed
      and these patches do not reply on the ilp32 api between kernel and glibc.
      I feel it is ok to upstream the code before ilp32 is upstreamed in kernel
      and glibc. Currently, the main issue during review is lacking of ilp32
      enabled toolchain. The toolchain I used in Huawei could not send it
      out because of the security issues. Linaro abe system could built the
      ilp32 enabled toolchain. I talk with linaro toolchain group guys in IRC,
      then told me that linaro will not public the toolchain until the ilp32 is
      upstreamed in kernel and glibc. I hope we could find a way to just provide
      the toolchain to specific users(e.g. the maintainers of buildroot).

* Join ilp32 discussion in LKML.

=== Plans ===
* 2K38: try to fix one or two ioctl functions.
* work on v3 ilp32 patches for buildroot.

=== Issues ===
* Hope could find a way to provide ilp32 enabled toolchain for buildroot
  maintainers. I feel that with this toolchain and some minor improvement
  my ilp32 patches for buildroot could be upstreamed quickly.

=== Travel/Leave ===
* My younger daughter got sick last week. It takes some time to take care of her.
* 1th May - International Labor Day Holiday

BTW, this is the first time I send my work report. It seems that it is a little
bit longer than others. I guess it will be better in future.
Thanks for your patient.

2.  to arnd(not sent yet)
Hi,

The headers include time_xxx I found is 'linux/input.h', 'linux/cyclades.h', 'linux/atm_zatm.h', 'linux/atm_nicstar.h', 'linux/coda.h', 'linux/videodev2.h', 'drm/msm_drm.h', 'linux/ppdev.h', 'sound/asound.h', 'sound/asequencer.h', 'linux/omap3isp.h', 'linux/pps.h', 'linux/dvb/video.h', 'linux/btrfs.h'.
The most familar drivers for me is input and alsa. Maybe, I will try to work on one of two drivers later.
Suggestions?

best wishes.

bamvor

21:52 2015-04-29
----------------
2K38, compat_ioctl, input
-------------------------
1.  check input driver.
    It seems that I could modify the code in input_event_from_user(drivers/input/input-compat.c). There is already the COMPAT_USE_64BIT_TIME in that function. Besically, COMPAT_USE_64BIT_TIME for the arch that compat use 64bit time_t. But the requirement is same as my task.

2.  TODO: discuss with arnd
    I check the time_xxx in input drivers. And I found that the time issue is
    covered in "`input_event_\(from\)\|\(to\)_user`" by
    COMPAT_USE_64BIT_TIME.

10:14 2015-05-03
----------------
2K38, compat_ioctl, drivers
----------------------------
1.  linux/cyclades.h: "`\(in_use\)\|\(recv_idle\)\|\(xmit_idle\)`" in "`struct cyclades_idle_stats`"
    1.  drivers/tty/cyclades.c
        There is no interaction with userspace. So, there is no need to fix.
    2.  some jiffies in drivers is 32bit. But they do use the time_before, time_after, I guess that I do not need to fix them.

2.  linux/atm_zatm.h
    zatm_t_hist is not found in kernel code. I guess it is only defined in userspace.

3.  linux/atm_nicstar.h
    NOT FOUND.

4.  linux/coda.h
    coda is network filesystem. timespec is defined in coda attr. do not found it is relative to unlock_ioctl.
    But coda define the timespec by itself for cross platform. I am not if it will involved some issues. Will check it later.

5.  linux/videodev2.h
    1.  v4l2_buffer: get_v4l2_buffer32, put_v4l2_buffer32
    ```c
        #define VIDIOC_QUERYBUF         _IOWR('V',  9, struct v4l2_buffer)
        #define VIDIOC_QBUF             _IOWR('V', 15, struct v4l2_buffer)
        #define VIDIOC_DQBUF            _IOWR('V', 17, struct v4l2_buffer)
        #define VIDIOC_PREPARE_BUF      _IOWR('V', 93, struct v4l2_buffer)
    ```
    2.  v4l2_event: put_v4l2_event32


6.  drm/msm_drm.h
    SKIP.
```c
        /* timeouts are specified in clock-monotonic absolute times (to simplify
     * restarting interrupted ioctls).  The following struct is logically the
     * same as 'struct timespec' but 32/64b ABI safe.
     */
    struct drm_msm_timespec {
            int64_t tv_sec;          /* seconds */
            int64_t tv_nsec;         /* nanoseconds */
    };
```


7.  linux/ppdev.h
    arnd told me.

8.  sound(sound/asound.h, sound/asequencer.h):
    snd_pcm_status_user
    snd_pcm_sync_ptr
    To be continued.

9.  TODO: 'linux/omap3isp.h', 'linux/pps.h', 'linux/dvb/video.h', 'linux/btrfs.h'.

