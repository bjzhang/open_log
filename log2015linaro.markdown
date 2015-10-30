
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
    qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -m 1024  -kernel /home/bamvor/works/source/kernel/linux/arch/arm64/boot/Image -append "console=ttyAMA0 root=/dev/vda2 rw" -drive if=none,file=/home/bamvor/works/software/opensuse/openSUSE-13.1-ARM-JeOS-vexpress64.aarch64-1.12.1-Build37.15.raw,id=vda -device virtio-blk-device,drive=vda -net user -netdev user.id=net0,net=192.168.76.0/24,dchpstart=192.168.76.0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0

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

19:06 2015-05-06
----------------
lianro, arm32, meeting
----------------------
1.  baolin wang
    1.  arnd explain the git skill
        1.  how to split the existing patches.
        2.  how to reuse the original commit message
            "`git commit -c HEAD`"
1.  bamvor
    1.  2K38
        working on 2K38 ioctl driver: check the file which include the "`\<time_t\>\|\<timespec\>\|\<timeval\> and _IOxxx definition. Right now, I have checked the following files: 'linux/input.h', 'linux/cyclades.h', 'linux/atm_zatm.h', 'linux/atm_nicstar.h', 'linux/coda.h', 'linux/videodev2.h', 'linux/ppdev.h', 'sound/asound.h', 'sound/asequencer.h'.
        Some of these driver may need the "#ifdef" as discuss with arnd before.
        And at the same time, I am reading the 2K38 patches from arnd. I will try to write the ioctl patches base on them.
        I will check the other headers('linux/pps.h', 'linux/dvb/video.h', 'linux/btrfs.h') later.
    2.  ILP32
        write v3 patches for buildroot.

15:06 2015-05-15
----------------
linaro, Y2038, compat_ioctl
----------------------------
1.  "y2038: introduce struct __kernel_timespec"
        A lot of system calls pass a 'struct timespec' from or to user space,
        and we want to change that type to be based on a 64-bit time_t by
        default.

        This introduces a new type struct __kernel_timespec, which has the
        format we want to use eventually, but also has an override so all
        architectures that do not define CONFIG_COMPAT_TIME yet still get the
        old behavior.
        Once all architectures set this, we can remove that override.

        This also introduces a get_timespec64/put_timespec64 set of functions
        that convert between a __kernel_timespec in user space and a timespec64
        in kernel space.

        The current behavior of get_timespec64 explicitly zeroes the upper half
        of the tv_nsec member, to allow user space to define its own 'struct
        timespec' with some padding in it. Whether this is a good or bad idea
        is open for discussion.

2.  "y2038: use timespec64 for poll/select/recvmmsg"
        There may be a small slowdown from using timespec64_sub and
        timespec64_add_safe instead of the 32-bit variants, so any
        suggestion for how to avoid that overhead would be welcome.

11:47 2015-06-16
----------------
linaro connect, invitation letter, tracking
-----------------------------------
1.  <http://www.trackitonline.ru/?service=track> could track the item no matter the vendor.
2.  <https://www.royalmail.com/track-your-item>

15:48 2015-06-16
----------------
kwg, y2038
----------
On Thursday 11 June 2015 17:47:48 Bamvor Zhang Jian wrote:
> Firstly enable ioctl in ppdev and then Keep par_timeout as timeval in
> compat ioctl in order to use the 64bit time type.
>
> Signed-off-by: Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>
> ---
> This is my first time to try to upstream some code in kernel. Any commit
> and feedback is welcome.

I'm officially on parental leave now, but let me try to get you started
a bit as I still have time to look into things.

First of all, you need to explain in the changelog what the specific problem
in this driver is and why you picked the solution at hand. This probably
requires a couple of paragraphs here. Try to think of how someone who
knows the driver but does not know of how the y2038 problem affects it yet.
The logic that you add here seems wrong to me: The structure format
really should not depend on whether you have a compat task or not, but
only on whether you use PPSETTIME32 or PPSETTIME64.

In particular, we want both 32-bit and 64-bit tasks to use the same
structures. With your current approach, I don't see how a 32-bit
task could ever pass a 64-bit time_t value here.

>       default:
> @@ -744,6 +763,7 @@ static const struct file_operations pp_fops = {
>       .write          = pp_write,
>       .poll           = pp_poll,
>       .unlocked_ioctl = pp_ioctl,
> +     .compat_ioctl   = pp_ioctl,
>       .open           = pp_open,
>       .release        = pp_release,
>  };

This should be a separate patch, because the implications of this are
much wider than the rest of the patch. In that patch, explain how
you verified that all ioctl commands that might get called by 32-bit
tasks are handled correctly on a 64-bit kernel. If some additional
commands are handled by pp_ioctl and need conversion, then add another
patch to handle those.
This has multiple problems:

- header files in include/uapi/ cannot use CONFIG_* symbols because
  the program that sees the header is supposed to run on kernels
  with any configuration.

- compat_timeval is not defined in a uapi header file and is used
  only internally in the kernel, so you cannot refer to that.

- Introducing new command names in a uapi header is pointless because
  there is no user space source code that refers to them.

- CONFIG_COMPAT_TIME only exists in a patch set I made that has
  not been merged yet. Try to define your patch in a way that works
  independent of my patch set.

We should really treat the two problems as separate issues with
different fixes:

a) make the driver handle all user space independent of the definition
   it uses for 'struct timespec', which may not match what the kernel
   uses internally.
b) define PPGETTIME/PPSETTIME in the header file in a way that does
   not refer to timespec at all. We still need to come up with a strategy
   for how to do this across the uapi headers, and it may take a longer
   discussion with the libc maintainers. Most importantly, we need to
   come up with a rule for when to expose the new command number to
   user space.

15:54 2015-06-16
----------------
1.  ppdev compat测试比较苦难, 而且解决了也意义不大.
    考虑先不解决ppdev的compat驱动问题. 只看arm 32bit的y2038问题.
2.  或者是先看v4l2. 这个似乎有意义一些.

3.

18:24 2015-06-17
----------------
1.  after discuss with arnd, I guess that I should add something like timeval64, "`__kernel_timeval64`"
    0001-time64-Add-time64.h-header-and-define-struct-timespe.patch
    0002-time-More-core-infrastructure-for-timespec64.patch
    0003-y2038-introduce-struct-__kernel_timespec.patch
    0004-y2038-use-timespec64-for-poll-select-recvmmsg.patch

2.  compare with ppdev, it seem that sound(alsa) is another good start point.
    timespec is used by "struct snd_timer_status" in alsa driver.

15:52 2015-06-18
----------------
1.  could I send the patches after compile pass before test?
    It is a little harder to test.
2.  alsa refacoring.
3.  linaro hiring.
4.  Linaro lead project.
    work on the code and communicate with members.

07:22 2015-06-19
----------------
kernel
1.  I found some file is missing in 'make cscope ARCH=arm64'
    E.g. <arch/arm64/include/asm/compat.h>
    Later, I found that it is my mistake that I use the ARCH=arm instead of ARCH=arm64.

10:34 2015-06-19
----------------
1.  arnd reply to me(v2):
```
This has multiple problems:

- header files in include/uapi/ cannot use CONFIG_* symbols because
  the program that sees the header is supposed to run on kernels
  with any configuration.

- compat_timeval is not defined in a uapi header file and is used
  only internally in the kernel, so you cannot refer to that.

- Introducing new command names in a uapi header is pointless because
  there is no user space source code that refers to them.

- CONFIG_COMPAT_TIME only exists in a patch set I made that has
  not been merged yet. Try to define your patch in a way that works
  independent of my patch set.
```
2.  So, I could not use "`CONFIG_XXX`" and "`compat_timeval`"(or other kernel internal definition).

3.  TODO:
    1.  I need to learn more about the rules in the uapi headers.
    2.  I need to familar with the kernel headers.
    3.  PPFCONTROL convert arg to "`char*`" and read twice. I think it is ok.
```c
        case PPFCONTROL:
                if (copy_from_user (&mask, argp,
                                    sizeof (mask)))
                        return -EFAULT;
                if (copy_from_user (&reg, 1 + (unsigned char __user *) arg,
                                    sizeof (reg)))
                        return -EFAULT;
                parport_frob_control (port, mask, reg);
                return 0;
```

12:09 2015-06-23
----------------
1.
```c
struct snd_pcm_status;
#define SNDRV_PCM_IOCTL_STATUS          _IOR('A', 0x20, struct snd_pcm_status)
#define SNDRV_PCM_IOCTL_STATUS_EXT      _IOWR('A', 0x24, struct snd_pcm_status)

struct snd_pcm_mmap_status;
#define SNDRV_PCM_IOCTL_SYNC_PTR        _IOWR('A', 0x23, struct snd_pcm_sync_ptr)

struct snd_rawmidi_status;
#define SNDRV_RAWMIDI_IOCTL_STATUS      _IOWR('W', 0x20, struct snd_rawmidi_status)

struct snd_timer_status;
#define SNDRV_TIMER_IOCTL_STATUS        _IOR('T', 0x14, struct snd_timer_status)

struct snd_ctl_elem_value;
#define SNDRV_CTL_IOCTL_ELEM_READ       _IOWR('U', 0x12, struct snd_ctl_elem_value)
#define SNDRV_CTL_IOCTL_ELEM_WRITE      _IOWR('U', 0x13, struct snd_ctl_elem_value)
```

2.  Given the above struct is heavily used in sound subsystem, if I change the above
struct directly, I will need to change the core of sound subsystem?

3.  There are two approaches to update the sound subsystem to y2038 safe:
    1.  update all the timespec relative struct to "`__kernel_timespec`", kernel and
userspace use these structs. This will affect all the code in sound subsystem and alsa lib.
    2.  only update the timespec reletive struct in sound ioctl thin layer. This method
affect the minium area in kernel and alsa lib. Only ioctl relative layer is affected. But
not sure the additional panelty(convert between "`timespec64`" and "`__kernel_timespec`").
    3.  time.c need to update.

4.  search string

"\(timespec\)\|\(snd_pcm_status\)\|\(snd_pcm_sync_ptr\)\|\(snd_rawmidi_status\)\|\(snd_timer_status\)\|\(snd_ctl_elem_value\)\|\(snd_pcm_mmap_status\)\
|\(snd_timer_tread\)\|\(snd_timer_user\)"

5.  sound subsystem is complex than I thought.

14:44 2015-06-28
----------------
1.  cover letter
Hi, guys

This is my second attempt to convert ppdev to y2038 safe. The first
version is here[1].

There are two parts in my patches.
01/02 introduce timeval relative 64bit time_t types.
03/04 convert ppdev to y2038 safe in both native 32bit and compat.

My patches try to follow the idea from arnd y2038 syscalls patches[2],
but my patches not depend on them.

And I do not test it.
Compile pass on arm and arm64 on each patches.

[1] https://lists.linaro.org/pipermail/y2038/2015-June/000522.html
[2] http://git.kernel.org/cgit/linux/kernel/git/arnd/playground.git/log/?h=y2038-syscalls

2.  git send-email
Arnd Bergmann <arnd@arndb.de> (supporter:CHAR and MISC DRIVERS)
John Stultz <john.stultz@linaro.org> (supporter:TIMEKEEPING, CLOCKSOURCE CORE, NTP,commit_signer:6/5=100%,authored:3/5=60%,added_lines:191/210=91%)
Thomas Gleixner <tglx@linutronix.de> (supporter:TIMEKEEPING, CLOCKSOURCE CORE, NTP,commit_signer:3/5=60%,commit_signer:1/4=25%,authored:1/4=25%,added_lines:21/44=48%,removed_lines:3/8=38%)

"`git send-email --no-chain-reply-to --annotate --to arnd@arndb.de --to john.stultz@linaro.org --to tglx@linutronix.de --cc y2038@lists.linaro.org --cc linux-kernel@vger.kernel.org *.patch`"

16:25 2015-07-01
----------------
linaro, arm, meeting
--------------------
1.  baolin
    1.  k_clock patch for y2038
    2.  dm-crypt.

2.  bamvor
    1.  convert ppdev to y2038 safe.
        re-write the whole patches according to arnd's suggestion.
    2.  think about convert sound subsystem to y2038 safe.
        after read the code, I feel that timer in sound subsystem is a better start point.

10:26 2015-07-02
----------------
y2038, sound, timer
-------------------
1.  "`snd_timer_tread`":
    1.  this struct is only used in "`snd_timer_user_read`" by "`copy_to_user`" functions.
        While in userspace, "`snd_timer_read`" will read both "`snd_timer_tread`" and "`snd_timer_read`". I would suggest alsa lib define the same timespec struct as __kernel_timespec. The code is unchanged although it waste one word on 32bit application.

    2.
    ```c
    /*
     * both count and result is the count for userspace, So, It should be counted by
     * __kernel_timespec.
     */
    static ssize_t snd_timer_user_read(struct file *file, char __user *buffer,
                                       size_t count, loff_t *offset)
    ```

2.  ask arnd when sent this patches.
    1.  why define "`timespec64`" and "`__kernel_timespec`" repectively, for saving the memory in 32bit kernel/application?

3.  TODO
    1.  add "`__kernel_timespec`" backward compatibility. My patches should not depend on arnd patches.
        FIXME: right now, my patch depends on "[RFC 08/37] y2038: introduce struct __kernel_timespec".

16:01 2015-07-04
----------------
linaro, work reprot, weekly report
----------------------------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-06-29 to 2015-07-05

=== Highlights ===

1.  send y2038 patches for ppdev(v2). no one reply to me yet.
2.  work on fixing y2038 issue in sound subsystem, I started from timer in sound subsystem. Because it use the time_xxx struct directly in ioctl functions, it is easy to fix them.
3.  arm32 meeting.
4.  1:1 with Mark. I may work on kselftest later.

=== Plans ==

1.  send the y2038 patch for timer in sound subsys.
    I may need a test environment for 32bit and compat on 64bit system if maintainers ack my idea. I guess that running a x32/x64 vm in qemu could do it for me.
2.  kselftest: hope I could understand the task.

=== Issues ===

BTW: Does anyone familar with thinkpad e440? I found that the acpi(suspend/resume, turn of/off the screen) is broken and touchpad is unstable in my openSUSE 13.2(kernel 3.16.7).

21:31 2015-07-04
----------------
kernel, KASan
-------------
KASan
KernelAddressSanitizer (KASan) is a dynamic memory error detector. It provides a fast and comprehensive solution for finding use-after-free and out-of-bounds bugs in Linux kernel.

Currently KASan supports x86_64 architecture and SLUB allocator.

AddressSanitizer for Linux kernel:

Is based on compiler instrumentation (fast)
Detects OOB for both writes and reads
Provides strong UAF detection (based on delayed memory reuse)
Does prompt detection of bad memory accesses
Prints informative reports

12:04 2015-07-05
----------------
=== David Long ===

=== Highlights ===
I replied to more email on the kprobes64 work.  Powerpc has been regression tested.  No problems yet.
uprobes32-thumb work continues.
Interviewed an assignee.


=== Plans ==

Address any more kprobes64 patch feedback.
Finish uprobes32-thumb.

=== Issues ===

15:56 2015-07-07
----------------
y2038, sound, timer, TODO
-------------------------
1.  check all the EXPORT SYMBOLS. DONE
2.  all the "`*.c`" outside timer should not be touched. DONE.

11:04 2015-07-08
----------------
kernel, arm64, kselftest
------------------------
1.  Mark create a card for kselftest
    <https://cards.linaro.org/browse/CARD-1962>

    from:	Mark Brown <broonie@linaro.org>
    to:	Serge Broslavsky <serge.broslavsky@linaro.org>,
    David Griego <david.griego@linaro.org>,
    Tyler Baker <tyler.baker@linaro.org>,
    Kevin Hilman <khilman@linaro.org>,
    Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>
    cc:	Alan Bennett <alan.bennett@linaro.org>

    1.  Serge Broslavsky: Core Development, Project Manager [irc: ototo]
    2.  David Griego: Core Development, Engineering Manager [irc: dgriego]
    3.  Tyler Baker: Product Technology, LAVA Software, Tech Lead [irc: tyler-baker]
    4.  Kevin Hilman: Product Technology, LKP, Tech Lead [irc: khilman].

11:15 2015-07-09
----------------
time, y2038, ppdev
------------------
1.  John Stultz
    Sorry for not replying yet on y2038 patches. Will look into it today.

2.
```
Hi, John

Thanks your reply.
I realized that it is merge window when I sent the patches. I am not sure
if I should ping it in LKML.

regards

bamvor
```

3.  reply to LKML(01)
    1.  john
```
> +       tv->tv_sec = ktv.tv_sec;
> +       if (!IS_ENABLED(CONFIG_64BIT)
> +#ifdef CONFIG_COMPAT
> +          || is_compat_task()
> +#endif

These sorts of ifdefs are to be avoided inside of functions.

Instead, it seems is_compat_task() should be defined to 0 in the
!CONFIG_COMPAT case, so you can avoid the ifdefs and the compiler can
still optimize it out.

Otherwise this looks similar to a patch Baolin (cc'ed) has been working on.

thanks
```

    2.  reply
```
Hi, John
> These sorts of ifdefs are to be avoided inside of functions.

> Instead, it seems is_compat_task() should be defined to 0 in the
> !CONFIG_COMPAT case, so you can avoid the ifdefs and the compiler can
> still optimize it out.
I add this ifdef because I got compile failure on arm platform. This
file do not include the <linux/compat.h> directly. And in arm64,
compat.h is included implicitily.
So, I am not sure what I should do here. Include <linux/compat.h> in
this file directly or add this check at the beginning of this file?

#ifndef is_compat_task
#define is_compat_task() (0)
#endif

> Otherwise this looks similar to a patch Baolin (cc'ed) has been working on.
Yes.

```

    3.
        1.  build log(arm)
```
make -f ./scripts/Makefile.build obj=kernel/time
  arm-linux-gnueabihf-gcc -Wp,-MD,kernel/time/.time.o.d  -nostdinc -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/include -I./arch/arm/include -Iarch/arm/include/generated/uapi -Iarch/arm/include/generated  -Iinclude -I./arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -fno-dwarf2-cfi-asm -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a -msoft-float -Uarm -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer -fno-var-tracking-assignments -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(time)"  -D"KBUILD_MODNAME=KBUILD_STR(time)" -c -o kernel/time/time.o kernel/time/time.c
kernel/time/time.c: In function 'get_timeval64':
kernel/time/time.c:777:5: error: implicit declaration of function 'is_compat_task' [-Werror=implicit-function-declaration]
     || is_compat_task()
     ^
```

```
bamvor@linux-j170:~/works/source/kernel/linux_2K38> arm-linux-gnueabihf-gcc -Wp,-MD,kernel/time/.time.o.d  -nostdinc -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/include -I./arch/arm/include -Iarch/arm/include/generated/uapi -Iarch/arm/include/generated  -Iinclude -I./arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -fno-dwarf2-cfi-asm -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a -msoft-float -Uarm -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer -fno-var-tracking-assignments -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(time)"  -D"KBUILD_MODNAME=KBUILD_STR(time)" -c -o kernel/time/time.o kernel/time/time.c --verbose
Using built-in specs.
COLLECT_GCC=arm-linux-gnueabihf-gcc
Target: arm-linux-gnueabihf
Configured with: /home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/snapshots/gcc-linaro-4.9-2014.11/configure SHELL=/bin/bash --with-bugurl=https://bugs.linaro.org --with-mpc=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/builds/destdir/x86_64-unknown-linux-gnu --with-mpfr=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gmp=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gnu-as --with-gnu-ld --disable-libstdcxx-pch --disable-libmudflap --with-cloog=no --with-ppl=no --with-isl=no --disable-nls --enable-multiarch --disable-multilib --enable-c99 --with-tune=cortex-a9 --with-arch=armv7-a --with-fpu=vfpv3-d16 --with-float=hard --with-mode=thumb --disable-shared --enable-static --with-build-sysroot=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/sysroots/arm-linux-gnueabihf --enable-lto --enable-linker-build-id --enable-long-long --enable-shared --with-sysroot=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/builds/destdir/x86_64-unknown-linux-gnu/libc --enable-languages=c,c++,fortran,lto -enable-fix-cortex-a53-835769 --enable-checking=release --with-bugurl=https://bugs.linaro.org --with-pkgversion='Linaro GCC 2014.11' --build=x86_64-unknown-linux-gnu --host=x86_64-unknown-linux-gnu --target=arm-linux-gnueabihf --prefix=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/arm-linux-gnueabihf/_build/builds/destdir/x86_64-unknown-linux-gnu
Thread model: posix
gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11)
COLLECT_GCC_OPTIONS='-nostdinc' '-isystem' '/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/include' '-I' './arch/arm/include' '-I' 'arch/arm/include/generated/uapi' '-I' 'arch/arm/include/generated' '-I' 'include' '-I' './arch/arm/include/uapi' '-I' 'arch/arm/include/generated/uapi' '-I' './include/uapi' '-I' 'include/generated/uapi' '-include' './include/linux/kconfig.h' '-D' '__KERNEL__' '-mlittle-endian' '-Wall' '-Wundef' '-Wstrict-prototypes' '-Wno-trigraphs' '-fno-strict-aliasing' '-fno-common' '-Werror=implicit-function-declaration' '-Wno-format-security' '-std=gnu90' '-fno-dwarf2-cfi-asm' '-mabi=aapcs-linux' '-mno-thumb-interwork' '-mfpu=vfp' '-funwind-tables' '-marm' '-D' '__LINUX_ARM_ARCH__=7' '-march=armv7-a' '-mfloat-abi=soft' '-U' 'arm' '-fno-delete-null-pointer-checks' '-O2' '--param' 'allow-store-data-races=0' '-Wframe-larger-than=1024' '-fno-stack-protector' '-Wno-unused-but-set-variable' '-fomit-frame-pointer' '-fno-var-tracking-assignments' '-Wdeclaration-after-statement' '-Wno-pointer-sign' '-fno-strict-overflow' '-fconserve-stack' '-Werror=implicit-int' '-Werror=strict-prototypes' '-Werror=date-time' '-D' 'CC_HAVE_ASM_GOTO' '-D' 'KBUILD_STR(s)=#s' '-D' 'KBUILD_BASENAME=KBUILD_STR(time)' '-D' 'KBUILD_MODNAME=KBUILD_STR(time)' '-c' '-o' 'kernel/time/time.o' '-v' '-mtune=cortex-a9' '-mtls-dialect=gnu'
 /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../libexec/gcc/arm-linux-gnueabihf/4.9.3/cc1 -quiet -nostdinc -v -I ./arch/arm/include -I arch/arm/include/generated/uapi -I arch/arm/include/generated -I include -I ./arch/arm/include/uapi -I arch/arm/include/generated/uapi -I ./include/uapi -I include/generated/uapi -imultilib . -imultiarch arm-linux-gnueabihf -iprefix /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/ -isysroot /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../libc -D __KERNEL__ -D __LINUX_ARM_ARCH__=7 -U arm -D CC_HAVE_ASM_GOTO -D KBUILD_STR(s)=#s -D KBUILD_BASENAME=KBUILD_STR(time) -D KBUILD_MODNAME=KBUILD_STR(time) -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/include -include ./include/linux/kconfig.h -MD kernel/time/.time.o.d kernel/time/time.c -quiet -dumpbase time.c -mlittle-endian -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -marm -march=armv7-a -mfloat-abi=soft -mtune=cortex-a9 -mtls-dialect=gnu -auxbase-strip kernel/time/time.o -O2 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -Werror=implicit-function-declaration -Wno-format-security -Wframe-larger-than=1024 -Wno-unused-but-set-variable -Wdeclaration-after-statement -Wno-pointer-sign -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -std=gnu90 -version -fno-strict-aliasing -fno-common -fno-dwarf2-cfi-asm -funwind-tables -fno-delete-null-pointer-checks -fno-stack-protector -fomit-frame-pointer -fno-var-tracking-assignments -fno-strict-overflow -fconserve-stack --param allow-store-data-races=0 -o /tmp/ccnoTReP.s
GNU C (Linaro GCC 2014.11) version 4.9.3 20141031 (prerelease) (arm-linux-gnueabihf)
        compiled by GNU C version 4.8.2, GMP version 5.1.3, MPFR version 3.1.2, MPC version 1.0.1
GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
ignoring duplicate directory "arch/arm/include/generated/uapi"
#include "..." search starts here:
#include <...> search starts here:
 ./arch/arm/include
 arch/arm/include/generated/uapi
 arch/arm/include/generated
 include
 ./arch/arm/include/uapi
 ./include/uapi
 include/generated/uapi
 /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/../lib/gcc/arm-linux-gnueabihf/4.9.3/include
End of search list.
GNU C (Linaro GCC 2014.11) version 4.9.3 20141031 (prerelease) (arm-linux-gnueabihf)
        compiled by GNU C version 4.8.2, GMP version 5.1.3, MPFR version 3.1.2, MPC version 1.0.1
GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
Compiler executable checksum: 04ceca25b5cb142ec19ca875fd0015c1
kernel/time/time.c: In function 'get_timeval64':
kernel/time/time.c:777:5: error: implicit declaration of function 'is_compat_task' [-Werror=implicit-function-declaration]
     || is_compat_task()
     ^
cc1: some warnings being treated as errors
```
        2.  build log(aarch64)
```
aarch64-linux-gnu-gcc -Wp,-MD,kernel/time/.time.o.d  -nostdinc -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include -I./arch/arm64/include -Iarch/arm64/include/generated/uapi -Iarch/arm64/include/generated  -Iinclude -I./arch/arm64/include/uapi -Iarch/arm64/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -mgeneral-regs-only -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -Wframe-larger-than=2048 -fno-stack-protector -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(time)"  -D"KBUILD_MODNAME=KBUILD_STR(time)" -c -o kernel/time/time.o kernel/time/time.c
```
```
bamvor@linux-j170:~/works/source/kernel/linux_2K38> aarch64-linux-gnu-gcc -Wp,-MD,kernel/time/.time.o.d  -nostdinc -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include -I./arch/arm64/include -Iarch/arm64/include/generated/uapi -Iarch/arm64/include/generated  -Iinclude -I./arch/arm64/include/uapi -Iarch/arm64/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -mgeneral-regs-only -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -Wframe-larger-than=2048 -fno-stack-protector -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(time)"  -D"KBUILD_MODNAME=KBUILD_STR(time)" -c -o kernel/time/time.o kernel/time/time.c --verbose
Using built-in specs.
COLLECT_GCC=aarch64-linux-gnu-gcc
Target: aarch64-linux-gnu
Configured with: /home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/snapshots/gcc-linaro-4.9-2014.11/configure SHELL=/bin/bash --with-bugurl=https://bugs.linaro.org --with-mpc=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/builds/destdir/x86_64-unknown-linux-gnu --with-mpfr=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gmp=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gnu-as --with-gnu-ld --disable-libstdcxx-pch --disable-libmudflap --with-cloog=no --with-ppl=no --with-isl=no --disable-nls --enable-multiarch --disable-multilib --enable-c99 --with-arch=armv8-a --disable-shared --enable-static --with-build-sysroot=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/sysroots/aarch64-linux-gnu --enable-lto --enable-linker-build-id --enable-long-long --enable-shared --with-sysroot=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/builds/destdir/x86_64-unknown-linux-gnu/libc --enable-languages=c,c++,fortran,lto -enable-fix-cortex-a53-835769 --enable-checking=release --with-bugurl=https://bugs.linaro.org --with-pkgversion='Linaro GCC 2014.11' --build=x86_64-unknown-linux-gnu --host=x86_64-unknown-linux-gnu --target=aarch64-linux-gnu --prefix=/home/buildslave/workspace/BinaryRelease/label/x86_64/target/aarch64-linux-gnu/_build/builds/destdir/x86_64-unknown-linux-gnu
Thread model: posix
gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11)
COLLECT_GCC_OPTIONS='-nostdinc' '-isystem' '/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include' '-I' './arch/arm64/include' '-I' 'arch/arm64/include/generated/uapi' '-I' 'arch/arm64/include/generated' '-I' 'include' '-I' './arch/arm64/include/uapi' '-I' 'arch/arm64/include/generated/uapi' '-I' './include/uapi' '-I' 'include/generated/uapi' '-include' './include/linux/kconfig.h' '-D' '__KERNEL__' '-mlittle-endian' '-Wall' '-Wundef' '-Wstrict-prototypes' '-Wno-trigraphs' '-fno-strict-aliasing' '-fno-common' '-Werror=implicit-function-declaration' '-Wno-format-security' '-std=gnu90' '-mgeneral-regs-only' '-fno-delete-null-pointer-checks' '-O2' '--param' 'allow-store-data-races=0' '-Wframe-larger-than=2048' '-fno-stack-protector' '-Wno-unused-but-set-variable' '-fno-omit-frame-pointer' '-fno-optimize-sibling-calls' '-fno-var-tracking-assignments' '-g' '-Wdeclaration-after-statement' '-Wno-pointer-sign' '-fno-strict-overflow' '-fconserve-stack' '-Werror=implicit-int' '-Werror=strict-prototypes' '-Werror=date-time' '-D' 'CC_HAVE_ASM_GOTO' '-D' 'KBUILD_STR(s)=#s' '-D' 'KBUILD_BASENAME=KBUILD_STR(time)' '-D' 'KBUILD_MODNAME=KBUILD_STR(time)' '-c' '-o' 'kernel/time/time.o' '-v' '-mabi=lp64'
 /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/4.9.3/cc1 -quiet -nostdinc -v -I ./arch/arm64/include -I arch/arm64/include/generated/uapi -I arch/arm64/include/generated -I include -I ./arch/arm64/include/uapi -I arch/arm64/include/generated/uapi -I ./include/uapi -I include/generated/uapi -imultiarch aarch64-linux-gnu -iprefix /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/ -isysroot /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc -D __KERNEL__ -D CC_HAVE_ASM_GOTO -D KBUILD_STR(s)=#s -D KBUILD_BASENAME=KBUILD_STR(time) -D KBUILD_MODNAME=KBUILD_STR(time) -isystem /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include -include ./include/linux/kconfig.h -MD kernel/time/.time.o.d kernel/time/time.c -quiet -dumpbase time.c -mlittle-endian -mgeneral-regs-only -mabi=lp64 -auxbase-strip kernel/time/time.o -g -O2 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -Werror=implicit-function-declaration -Wno-format-security -Wframe-larger-than=2048 -Wno-unused-but-set-variable -Wdeclaration-after-statement -Wno-pointer-sign -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -std=gnu90 -version -fno-strict-aliasing -fno-common -fno-delete-null-pointer-checks -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -fno-strict-overflow -fconserve-stack --param allow-store-data-races=0 -o /tmp/ccNOiT6S.s
GNU C (Linaro GCC 2014.11) version 4.9.3 20141031 (prerelease) (aarch64-linux-gnu)
        compiled by GNU C version 4.8.2, GMP version 5.1.3, MPFR version 3.1.2, MPC version 1.0.1
GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
ignoring duplicate directory "arch/arm64/include/generated/uapi"
#include "..." search starts here:
#include <...> search starts here:
 ./arch/arm64/include
 arch/arm64/include/generated/uapi
 arch/arm64/include/generated
 include
 ./arch/arm64/include/uapi
 ./include/uapi
 include/generated/uapi
 /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include
End of search list.
GNU C (Linaro GCC 2014.11) version 4.9.3 20141031 (prerelease) (aarch64-linux-gnu)
        compiled by GNU C version 4.8.2, GMP version 5.1.3, MPFR version 3.1.2, MPC version 1.0.1
GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
Compiler executable checksum: 54b78edc55bb841925a0c35e511e706d
COLLECT_GCC_OPTIONS='-nostdinc' '-isystem' '/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include' '-I' './arch/arm64/include' '-I' 'arch/arm64/include/generated/uapi' '-I' 'arch/arm64/include/generated' '-I' 'include' '-I' './arch/arm64/include/uapi' '-I' 'arch/arm64/include/generated/uapi' '-I' './include/uapi' '-I' 'include/generated/uapi' '-include' './include/linux/kconfig.h' '-D' '__KERNEL__' '-mlittle-endian' '-Wall' '-Wundef' '-Wstrict-prototypes' '-Wno-trigraphs' '-fno-strict-aliasing' '-fno-common' '-Werror=implicit-function-declaration' '-Wno-format-security' '-std=gnu90' '-mgeneral-regs-only' '-fno-delete-null-pointer-checks' '-O2' '--param' 'allow-store-data-races=0' '-Wframe-larger-than=2048' '-fno-stack-protector' '-Wno-unused-but-set-variable' '-fno-omit-frame-pointer' '-fno-optimize-sibling-calls' '-fno-var-tracking-assignments' '-g' '-Wdeclaration-after-statement' '-Wno-pointer-sign' '-fno-strict-overflow' '-fconserve-stack' '-Werror=implicit-int' '-Werror=strict-prototypes' '-Werror=date-time' '-D' 'CC_HAVE_ASM_GOTO' '-D' 'KBUILD_STR(s)=#s' '-D' 'KBUILD_BASENAME=KBUILD_STR(time)' '-D' 'KBUILD_MODNAME=KBUILD_STR(time)' '-c' '-o' 'kernel/time/time.o' '-v' '-mabi=lp64'
 /home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/bin/as -v -I ./arch/arm64/include -I arch/arm64/include/generated/uapi -I arch/arm64/include/generated -I include -I ./arch/arm64/include/uapi -I arch/arm64/include/generated/uapi -I ./include/uapi -I include/generated/uapi -EL -mabi=lp64 -o kernel/time/time.o /tmp/ccNOiT6S.s
GNU assembler version 2.24.0 (aarch64-linux-gnu) using BFD version (GNU Binutils) Linaro 2014.11-3-git 2.24.0.20141017
COMPILER_PATH=/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/4.9.3/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/bin/
LIBRARY_PATH=/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/lib/../lib64/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/lib/../lib64/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/usr/lib/../lib64/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/lib/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/lib/:/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/usr/lib/
COLLECT_GCC_OPTIONS='-nostdinc' '-isystem' '/home/bamvor/works/software/toolchain/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/include' '-I' './arch/arm64/include' '-I' 'arch/arm64/include/generated/uapi' '-I' 'arch/arm64/include/generated' '-I' 'include' '-I' './arch/arm64/include/uapi' '-I' 'arch/arm64/include/generated/uapi' '-I' './include/uapi' '-I' 'include/generated/uapi' '-include' './include/linux/kconfig.h' '-D' '__KERNEL__' '-mlittle-endian' '-Wall' '-Wundef' '-Wstrict-prototypes' '-Wno-trigraphs' '-fno-strict-aliasing' '-fno-common' '-Werror=implicit-function-declaration' '-Wno-format-security' '-std=gnu90' '-mgeneral-regs-only' '-fno-delete-null-pointer-checks' '-O2' '--param' 'allow-store-data-races=0' '-Wframe-larger-than=2048' '-fno-stack-protector' '-Wno-unused-but-set-variable' '-fno-omit-frame-pointer' '-fno-optimize-sibling-calls' '-fno-var-tracking-assignments' '-g' '-Wdeclaration-after-statement' '-Wno-pointer-sign' '-fno-strict-overflow' '-fconserve-stack' '-Werror=implicit-int' '-Werror=strict-prototypes' '-Werror=date-time' '-D' 'CC_HAVE_ASM_GOTO' '-D' 'KBUILD_STR(s)=#s' '-D' 'KBUILD_BASENAME=KBUILD_STR(time)' '-D' 'KBUILD_MODNAME=KBUILD_STR(time)' '-c' '-o' 'kernel/time/time.o' '-v' '-mabi=lp64'
```

4.  reply to 03
    1.  John, Arnd
```
On Wednesday 08 July 2015 13:17:18 John Stultz wrote:
> On Mon, Jun 29, 2015 at 7:23 AM, Bamvor Zhang Jian
> <bamvor.zhangjian@linaro.org> wrote:
> > Add compat ioctl in ppdev in order to solve the y2038 issue in
> > later patch.
> > This patch simply add pp_do_ioctl to compat_ioctl, because I found
> > that all the ioctl access the arg as a pointer.
> >
> > Signed-off-by: Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>

I just saw this mail fly by when you replied, but I guess it would
have been better to reply when the original mail came.

The description above makes no sense: The problem for compat ioctl
is not whether the argument is a pointer or not, but rather what
data structure it points to. In this case, we already know that
it is /not/ compatible between 32-bit and 64-bit user space, because
at least two commands need special handling for the timespec
argument, which gets added in patch 4 of the series.

This means patches 3 and 4 have to be swapped in order to allow
bisection and not introduce a bug when only this one gets applied
but patch 4 is missing.

Moreover, all other ioctl commands that are handled in pp_ioctl
need to be checked regarding what their arguments are, including
data structures pointed to by the arguments (recursively, if there
are again pointers in those structures).

> >         unsigned int minor = iminor(inode);
> > @@ -744,6 +750,9 @@ static const struct file_operations pp_fops = {
> >         .write          = pp_write,
> >         .poll           = pp_poll,
> >         .unlocked_ioctl = pp_ioctl,
> > +#ifdef CONFIG_COMPAT
> > +       .compat_ioctl   = pp_compat_ioctl,
> > +#endif

The #ifdef here is not necessary, but will cause a warning on kernels
that do not define CONFIG_COMPAT, in particular all 32-bit ones.

> Does adding this patch w/o the following patch break 32bit apps using
> this on 64bit kernels?

Without the patch, those apps will all get -EINVAL from the ioctl
handler. With the patch, the kernel actually performs the ioctl
that was requested, but that may use the wrong data structure.
```

    2.  reply
```
> I just saw this mail fly by when you replied, but I guess it would
> have been better to reply when the original mail came.
>
> The description above makes no sense: The problem for compat ioctl
> is not whether the argument is a pointer or not, but rather what
> data structure it points to.
My original thoughts is that the compat_ioctl could reuse
unlocked_ioctl function with special code for PP[GS]ETTIME after
checked all the data structure it points to(the data type is int,
unsigned int, unsigned char and timeval).
TODO
> In this case, we already know that
> it is /not/ compatible between 32-bit and 64-bit user space, because
> at least two commands need special handling for the timespec
> argument, which gets added in patch 4 of the series.
>
> This means patches 3 and 4 have to be swapped in order to allow
> bisection and not introduce a bug when only this one gets applied
> but patch 4 is missing.
Ok.
>
> Moreover, all other ioctl commands that are handled in pp_ioctl
> need to be checked regarding what their arguments are, including
> data structures pointed to by the arguments (recursively, if there
> are again pointers in those structures).
>
> > >         unsigned int minor = iminor(inode);
> > > @@ -744,6 +750,9 @@ static const struct file_operations pp_fops = {
> > >         .write          = pp_write,
> > >         .poll           = pp_poll,
> > >         .unlocked_ioctl = pp_ioctl,
> > > +#ifdef CONFIG_COMPAT
> > > +       .compat_ioctl   = pp_compat_ioctl,
> > > +#endif
>
> The #ifdef here is not necessary, but will cause a warning on kernels
> that do not define CONFIG_COMPAT, in particular all 32-bit ones.
When I write this code I found that there are less than 50% compat_ioctl
defined in "#ifdef CONFIG_COMPAT".
>
> > Does adding this patch w/o the following patch break 32bit apps using
> > this on 64bit kernels?
>
> Without the patch, those apps will all get -EINVAL from the ioctl
> handler. With the patch, the kernel actually performs the ioctl
> that was requested, but that may use the wrong data structure.
```

5.  reply to 04
    ```
    > As commented before, these definitions should probably not be part of the
    > user-visible header file.
    >
    > The main reason for using an __s64[2] array instead of struct __kernel_timeval
    > is to avoid adding __kernel_timeval: 'timeval' is thoroughly deprecated
    > and we don't want to establish new interfaces with that.
    >
    > In case of this driver, nobody would ever want to change their user
    > space to use a 64-bit __kernel_timeval instead of timeval and explicitly
    > call PPGETTIME64 instead of PPGETTIME, because we are only dealing with
    > an interval here, and a 32-bit second value is sufficient to represent
    > that. Instead, the purpose of your patch is to make the kernel cope with
    > user space that happens to use a 64-bit time_t based definition of
    > 'struct timeval' and passes that to the ioctl.
    I define PP[GS]ETTIME as PP[GS]ETTIME64, so I guess the 64bit app will not
    need to change the code.
    ```

10:51 2015-07-15
----------------
time, y2038, ppdev
------------------
1.  1/4 reply to arnd
    ```
    > Actually I think we can completely skip this test here: Unlike
    > timespec, timeval is defined in a way that always lets user space
    > use a 64-bit type for the microsecond portion (suseconds_t tv_usec).
    I do not familar with this type. I grep the suseconds_t in glibc, it
    seems that suseconds_t(__SUSECONDS_T_TYPE) is defined as
    __SYSCALL_SLONG_TYPE which is __SLONGWORD_TYPE(32bit on 32bit
    architecture).
    >
    > I think we should simplify this case and just assume that user space
    > does exactly that, and treat a tv_usec value with a nonzero upper
    > half as an error.
    >
    > I would also keep this function local to the ppdev driver, in order
    > to not proliferate this to generic kernel code, but that is something
    > we can debate, based on what other drivers need. For core kernel
    > code, we should not need a get_timeval64 function because all system
    > calls that pass a timeval structure are obsolete and we don't need
    > to provide 64-bit time_t variants of them.
    Got it.
    ```

15:57 2015-07-15
----------------
time, y2038, sound, timer
-------------------------
1.  cover letter
    ```
    Hi,

    This is my first attempt to convert sound subsystem to year 2038 safe.
    In these series patches I focus on the timer.

    When check the time relative code in timer of sound subsystem, I
    feel that I could easy split 64bit time_xxx type in kernel and in
    userspace (__kernel_time_xxx) according to arnd's approach[1] in
    comparison with other parts of sound subsys(e.g. pcm). Whether I
    should follow the same approach in the whole sound subsystem is an
    open issue for me.

    On the other hand, there are difference approaches for dealing with
    the code in userspace. It seems that snd_timer_read is the only api
    for other parts of alsa. It share the same code no matter tread is
    true or false.

    The fisrt approach is hide __kernel_time_xxx inside snd_timer_read,
    although the code may be a little bit ugly.

    The second approach is that force userspace migration to 64bit
    time on all 32bit(including compat) system by re-definition the
    following types in alsa-lib/include/global.h:
    typedef struct __kernel_timespec snd_htimestamp_t;
    This approach will not affect the 64bit application.

    regards

    bamvor

    [1] http://git.kernel.org/cgit/linux/kernel/git/arnd/playground.git/log/?h=y2038-syscalls
    ```

16:34 2015-07-16
----------------
1:1, mark
---------
1.  send the patches of sound to y2038 mailing list first.

2.  build and run kselftest in upstream kernel.
    keep in touch with Tylor.
    only work on upstream kernel. Lsk team may run upstream kselftest on lsk.

3.  move 1:1 to difference week(it is same week with arm32 team meeting right now).

15:18 2015-07-17
----------------
"`git send-email --no-chain-reply-to --annotate --to arnd@arndb.de --to john.stultz@linaro.org --to tglx@linutronix.de --cc y2038@lists.linaro.org --to broonie@linaro.org --cc baolin.wang@linaro.org`"

15:22 2015-07-17
----------------
GTD
---
1.  today
    1.  -15:22 y2038: sound: timer.

11:55 2015-07-21
----------------
linaro, work reprot, weekly report
----------------------------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-07-13 to 2015-07-19

=== Highlights ===
1.  Send out y2038 patch for sound subsystem. Only timer is in consideration at this time.
    Arnd and Mark gave me lots of suggestions:
    1.  headers in uapi should not depends on the kernel config.
    2.  do not break the existing 32bit code/binary while migrate the 64bit time.
2.  1:1 with Mark.

=== Plans ==
1.  kselftest:
    1.  Build and run kselftest for arm and arm64 on the upstream kernel.
    2.  Try to fix the issues.
    3.  Keep in touch with Tylor.

2.  Write new vesion of alsa y2038 patches.

=== Issues ===

19:18 2015-07-21
----------------
kernel, y2038, driver, sound
----------------------------
1.  1/2 arnd
```
> On Friday 17 July 2015 15:21:07 Bamvor Zhang Jian wrote:
> > diff --git a/include/sound/timer.h b/include/sound/timer.h
> > index 7990469..2cfee32 100644
> > --- a/include/sound/timer.h
> > +++ b/include/sound/timer.h
> > @@ -120,6 +120,12 @@ struct snd_timer_instance {
> >      struct snd_timer_instance *master;
> >  };
> >
> > +struct snd_timer_tread {
> > +    int event;
> > +    struct timespec64 tstamp;
> > +    unsigned int val;
> > +};
> > +
> >  /*
> >   *  Registering
> >   */
> > diff --git a/include/uapi/sound/asound.h b/include/uapi/sound/asound.h
> > index a45be6b..f7e3793 100644
> > --- a/include/uapi/sound/asound.h
> > +++ b/include/uapi/sound/asound.h
> > @@ -29,6 +29,9 @@
> >  #include <stdlib.h>
> >  #endif
> >
> > +#ifndef CONFIG_COMPAT_TIME
> > +# define __kernel_timespec timespec
> > +#endif
>
> CONFIG_COMPAT_TIME cannot be used in a uapi header: whether user space uses
> a 64-bit or 32-bit time_t is independent of what gets implemented in the
> kernel.
Oh, sorry for doing this again.
Originally, I want to follow your approach in "include/linux/time64.h" in
patch[1] in order to work with(for y2038 safe) and without(for keeping abi
unchaged) your patch[1].
On the other hand, when I write this commit, I found that there are some headers
include the <linux/time.h>(most them are drivers):
include/uapi/linux/videodev2.h, include/uapi/linux/input.h,
include/uapi/linux/timex.h, include/uapi/linux/elfcore.h,
include/uapi/linux/resource.h, include/uapi/linux/dvb/dmx.h,
include/uapi/linux/dvb/video.h,
include/uapi/linux/coda.h. CONFIG_COMPAT_TIME is used indirectly in uapi
files. Do we need to fix these issues?
>
> >   *  protocol version
> >   */
> > @@ -739,7 +742,7 @@ struct snd_timer_params {
> >  };
> >
> >  struct snd_timer_status {
> > -    struct timespec tstamp;        /* Timestamp - last update */
> > +    struct __kernel_timespec tstamp;/* Timestamp - last update */
> >      unsigned int resolution;    /* current period resolution in ns */
> >      unsigned int lost;        /* counter of master tick lost */
> >      unsigned int overrun;        /* count of read queue overruns */
> > @@ -787,9 +790,9 @@ enum {
> >      SNDRV_TIMER_EVENT_MRESUME = SNDRV_TIMER_EVENT_RESUME + 10,
> >  };
> >
> > -struct snd_timer_tread {
> > +struct __kernel_snd_timer_tread {
> >      int event;
> > -    struct timespec tstamp;
> > +    struct __kernel_timespec tstamp;
> >      unsigned int val;
> >  };
>
> Also, __kernel_timespec is defined to be always 64-bit wide. This means
> if we do this change (assuming we drop the #define above), then user space
> will always see the new definition of this structure, and programs
> compiled against the latest header will no longer work on older kernels.
>
> Is this what you had in mind?
Yes. It was what in my head. But I do not whether it ought to be.
>
> We could decide to do it like this, and we have historically done changes
> to the ioctl interface this way, but I'm not sure if we want to do it
> for all ioctls.
>
> The alternative is to leave the 'timespec' visible here for user space,
> so user programs will see either the old or the new definition of struct
> depending on their timespec definition, and only programs built with
> 64-bit time_t will require new kernels.
Do you mean we leave snd_timer_tread unchanged and introduce a new struct?
(assuming we drop the #define above).
struct snd_timer_tread64 {
    int event;
    struct timespec tstamp;
    struct __kernel_timespec tstamp;
    unsigned int val;
};

#if BITS_PER_TIME_T == BITS_PER_LONG
#define SNDRV_TIMER_IOCTL_TREAD         _IOW('T', 0x02, int)
#else
#define SNDRV_TIMER_IOCTL_TREAD64       _IOW('T', 0x15, int)
#endif

snd_timer_tread64 is used by SNDRV_TIMER_IOCTL_TREAD64.

IIUC, we should define SNDRV_TIMER_IOCTL_TREAD64 instead keep the same name for
differenct ioctl, otherwise it is hard to support the old and new application
binary in new kernel.

>
> >
> > +void snd_timer_notify(struct snd_timer *timer, int event, struct timespec *tstamp)
> > +{
> > +    struct timespec64 tstamp64;
> > +
> > +    tstamp64.tv_sec = tstamp->tv_sec;
> > +    tstamp64.tv_nsec = tstamp->tv_nsec;
> > +    snd_timer_notify64(timer, event, &tstamp64);
> > +}
>
> This works, but I'd leave it up to Mark if he'd prefer to do the conversion
> bit by bit and change over all users of snd_timer_notify to use
> snd_timer_notify64, or to move them all at once and leave the function
> name unchanged.
Yes, understand. I want to keep the function name unchanged too. I guess I will
do it when pcm part of y2038 patches is ready. Otherwise, the sound subsystem
is broken.
>
> I can see six callers of snd_timer_notify, but they are all in the same
> file, so I'd expect it to be possible to convert them all together,
> e.g. by adding a patch that changes the prototype in all these
> callers after changing the ccallback prototype.
Got you.
>
> > @@ -1702,7 +1712,8 @@ static int snd_timer_user_status(struct file *file,
> >      if (!tu->timeri)
> >          return -EBADFD;
> >      memset(&status, 0, sizeof(status));
> > -    status.tstamp = tu->tstamp;
> > +    status.tstamp.tv_sec = tu->tstamp.tv_sec;
> > +    status.tstamp.tv_nsec = tu->tstamp.tv_nsec;
> >      status.resolution = snd_timer_resolution(tu->timeri);
> >      status.lost = tu->timeri->lost;
> >      status.overrun = tu->overrun;
>
> With the change to the structure definition, this will now only handle
> the new structure size on patched kernels, but not work with old
> user space on native 32-bit kernels any more.
>
> Your patch 2 fixes the case of handling both old compat 32-bit user space
> on 64-bit kernels as well as new compat 32-bit user space with 64-bit
> time_t, but I think you are missing the case of handling old 32-bit
> user space.
>
> Note that we cannot use compat_ioctl() for native 32-bit kernels, so
> snd_timer_user_ioctl will now have to be changed to handle both cases.
Oh, I miss it, I will try to add it in my next version.
>
> > @@ -1843,9 +1854,12 @@ static ssize_t snd_timer_user_read(struct file *file, char __user *buffer,
> >      struct snd_timer_user *tu;
> >      long result = 0, unit;
> >      int err = 0;
> > +    struct __kernel_snd_timer_tread kttr;
> > +    struct snd_timer_tread *ttrp;
> >
> >      tu = file->private_data;
> > -    unit = tu->tread ? sizeof(struct snd_timer_tread) : sizeof(struct snd_timer_read);
> > +    unit = tu->tread ? sizeof(struct __kernel_snd_timer_tread) :
> > +        sizeof(struct snd_timer_read);
> >      spin_lock_irq(&tu->qlock);
> >      while ((long)count - result >= unit) {
> >          while (!tu->qused) {
>
> Now this is the part that gets really tricky: Instead of two cases
> (read and tread), we now have to handle three cases. Any user space
> that is compiled with 64-bit time_t needs to get the new structure,
> while old user space needs to get the old structure.
>
> It looks like we already get this wrong for existing compat user
> space: running a 32-bit program on a 64-bit kernel will currently
> get the 64-bit version of struct snd_timer_tread and misinterpret
> that. We can probably fix both issues at the same time after
> introducing turning the tread flag into a three-way enum (or something
> along that lines).
It seems that the current tread flag select the read or tread. How about
choose the following you mentioned to deal with it?
if (tu->tread)
    if (BITS_PER_TIME_T == BITS_PER_LONG)
        unit = sizeof(struct snd_timer_tread);
    else
        unit = sizeof(struct snd_timer_tread64);
else
    unit = sizeof(struct snd_timer_read);

>
> I would recommend separating the tread changes from the user_status
> changes, as both of them are getting more complex now.
Ok.
>
>     Arnd

[1] http://git.kernel.org/cgit/linux/kernel/git/arnd/playground.git/commit/?h=y2038-syscalls&id=9005d4f4a44fc56bd0a1fe7c08e8e3f13eb75de7
```

2.  Mark
> I don't think that's going to fly, we can't break all existing ALSA
> userspace and not have people get angry.

10:44 2015-07-23
----------------
qemu, aarch64
-------------
1.  doc
    https://en.opensuse.org/openSUSE:AArch64#Foundation_V8_emulator
    https://www.suse.com/documentation/sles11/book_kvm/data/cha_qemu_running_networking.html

2.  qemu command line
    qemu-system-aarch64 -m 2048 -cpu cortex-a57 -smp 2 -M virt --kernel /home/bamvor/works/source/kernel/linux_kselftest_arm_aarch64/arch/arm64/boot/Image --append "console=ttyAMA0 root=/dev/vda2 rw" --serial stdio -device virtio-net-device,vlan=0,id=net0,mac=52:54:00:09:a4:37 -net user,vlan=0,name=hostnet0,hostfwd=tcp::2222-:22 -drive if=none,file=openSUSE-Tumbleweed-ARM-JeOS-efi.aarch64-1.12.1-Build296.1.raw,id=hd0 -device virtio-blk-device,drive=hd0

3.  Add local repo(take nfs and plaindir as example).
    1.  Ensure mount.nfs is is installed.
        1.  Otherwise zypper will say
            ```
            #zypper ar -c -f -t plaindir nfs://10.0.2.2/home/bamvor/works/software/opensuse/repo/ports/aarch64/tumbleweed/repo/oss openSU SE-Tumbleweed-repo-oss_local
            Adding repository 'openSUSE-Tumbleweed-repo-oss_local' ----------------------------------------------------------------------------[\]
            Failed to mount 10.0.2.2:/home/bamvor/works/software/opensuse/repo/ports/aarch64/tumbleweed/repo/oss on /var/tmp/AP_0x4OyaTa: Invalid filesystem on media (       dmesg | tail or so.)
            ```
        2.  Or, mount will say:
            ```
            # mount -t nfs 10.0.2.2:/home/bamvor/works/software/opensuse/repo/ports/aarch64/tumbleweed/repo/oss /mnt/
            mount: wrong fs type, bad option, bad superblock on 10.0.2.2:/home/bamvor/works/software/opensuse/repo/ports/aarch64/tumbleweed/repo/oss,
                   missing codepage or helper program, or other error
                   (for several filesystems (e.g. nfs, cifs) you might
                   need a /sbin/mount.<type> helper program)

                   In some cases useful info is found in syslog - try
                   dmesg | tail or so.
           ```
    2.  install mount.nfs
        ```
        linux:~ # mount.nfs
        -bash: mount.nfs: command not found
        linux:~ # cnf mount.nfs
        The program 'mount.nfs' can be found in the following package:
          * nfs-client [ path: /sbin/mount.nfs, repository: zypp (openSUSE-Factory-repo-oss) ]

        Try installing with:
            zypper install nfs-client

        linux:~ # zypper in nfs-client
        ```

12:35 2015-07-23
----------------
kselftest, aarch64
-----------------
    item        |   compile(x86)    |   compile(arm)    |  compile(arm64)   |     test(x86)     |     test(arm)     |    test(arm64)    |
----------------|-------------------|-------------------|-------------------|-------------------|-------------------|-------------------|
breakpoints     |   PASS            |                   |   ONLY FOR X86    |   PASS            |                   |   ONLY FOR X86    |
cpu-hotplug     |                   |                   |                   |   PASS            |                   |   PASS            |
efivarfs        |                   |                   |                   |   PASS            |                   |   SKIP            |
exec            |                   |                   |                   |   FAIL            |                   |   FAIL            |
firmware        |                   |                   |                   |   FAIL            |                   |   FAIL            |
ftrace          |                   |                   |                   |   PASS            |                   |                   |
futex           |                   |                   |                   |   PASS            |                   |   PASS            |
kcmp            |   FAIL            |                   |   PASS            |   FAIL            |                   |   FAIL  PASS      |
memfd           |   FAIL            |                   |   FAIL            |   FAIL            |                   |   FAIL            |
memory-hotplug  |                   |                   |                   |   PASS            |                   |   SKIP            |
mount           |                   |                   |                   |   SKIP            |                   |   SKIP            |
mqueue          |   FAIL            |                   |   FAIL            |
net             |                   |                   |                   |   FAIL            |                   |   FAIL            |
powerpc         |                   |                   |                   |                   |                   |                   |
ptrace          |                   |                   |                   |   PASS            |                   |   PASS            |
seccomp         |   PASS            |                   |   FAIL            |   FAIL            |                   |                   |
size            |   FAIL            |                   |   FAIL            |
sysctl          |                   |                   |                   |   FAIL            |                   |   FAIL            |
timers          |                   |                   |                   |   PASS            |                   |   FAIL            |
user            |                   |                   |                   |   FAIL            |                   |   FAIL            |
vm              |                   |                   |                   |   FAIL            |                   |   FAIL            |
x86             |   WARNING         |

1.  todo
    1.  if the case is fail in x86_64, check why it is fail.
        1.  "x86"
            need install glibc-32bit and glibc-devel-32bit

1.  breakpoints:
    Not an x86 target, can't build breakpoints selftests

1.  breakpoints
1.  cpu-hotplug
1.  efivarfs
    1.  It seems that it is skpped because my qemu do not use the efi boot.
1.  exec
    1.  <http://lwn.net/Articles/600344/>
        > The primary aim of adding an execveat syscall is to allow an
        > implementation of fexecve(3) that does not rely on the /proc
        > filesystem.  The current glibc version of fexecve(3) is implemented
        > via /proc, which causes problems in sandboxed or otherwise restricted
        > environments.
    2.  It fails when direct build from kernel top level source tree.
    3.  Test failed in when run in the install director because the symbol link
        is installed as regular file.

1.  firmware
1.  ftrace
1.  futex
1.  kcmp
1.  memfd
1.  memory-hotplug
1.  mount
    1.  "/proc/self/uid_map"
1.  mqueue
1.  net
1.  powerpc
1.  ptrace
1.  seccomp
1.  size
1.  sysctl
1.  timers
1.  user
1.  vm
1.  x86
    1.  make install fail on arm. TODO: fix this issue.

11:24 2015-07-28
----------------
kernel, kselftest
-----------------
1.  current status
    I work on the kselftest from last week. And I got some failures on arm64 as we expected. I plan to dig into this failures in this week.

    1.  run kselftest on x86(openSUSE 13.2) and arm64(openSUSE Tumbleweed). Got some failures on x86 and arm64.
        I guess some of the failures on x86 is because the lower kernel vesion and missing pacakges. Will try to re-build/run these cases when work on the same case on the aarch64.

    2.  Installation is failed on arm64 because install x86 testcase failed.
        The "x86" testcase should probably add some check like the Makefile in powerpc testcase.
        Do we need to add the arm/arm64 testcase in kselftest?

    3.  breakpoints:
        It could not run on arm64.
        Acctually, it is only support x86, because it use INT 1(for single-stepping) and INT 3(setting breakpoints).

    4.  efivars:
        I could not test efi test on arm64 because qemu-system-aarch64 crashed when efi is enabled.
        I will deal with it later. Maybe test it on hardware is easier?

    5.  exec:
        Test successful when run it from the build directory.
        Test fail when run it from the install directory.
        Run failed if running it from top level Makefile.
        I guess maybe there are some minor issues(build?) in this case.

12:18 2015-07-28
----------------
linaro, work reprot, weekly report
----------------------------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-07-20 to 2015-07-26

=== Highlights ===
1.  kselftest(it is as same as the comment in https://projects.linaro.org/browse/KWG-23)

2.  reply to arnd and mark about y2038 patches for sound subsystem.

=== Plans ==
1.  kselftest:
    1.  Fix the issues I found this week.

2.  Write new vesion of alsa y2038 patches.

22:49 2015-07-31
----------------
1.  email
Hi, MarK
> Hi Bamvor,
>
> I was just speaking to Tyler and Kevin about kselftest in a meeting earlier today and Tyler was mentioning that there's quite a few ARM issues with kselftest that have been fixed in the latest -next code so it's probably good to make sure you're working on -next for your investigations - it seems it's quite a fast moving area.
Thanks for you help. I will work on linux-next in future. It might be some duplicated work. I will try to avoid it in future.
>
> Can you please coordinate with them on your kselftest work, Tyler has quite a few ideas for improvements which would really help with the integration into kernelci.org.
Sure.
And I just have a nice talk with Tylor. According to Tyler's suggestion, I will work on enable cross-compile for kselftest by passing the "--sysroot" to cross-compler. Tylor gave me the rootfs[1] and libraries[2] for cross-compiling kselftest.

Is there any others suggestion for me?

Thanks in advance.

>
> Thanks,
> Mark

[1] http://storage.kernelci.org/images/selftests/arm/rootfs.cpio.gz
[2] http://images.armcloud.us/misc/tyler-kselftest/armel/kselftest-cross-deps-armhf.tar.gz

2.  Tylar
    The needed libraries are: libpopt-dev and libcap-dev. the mqueue test uses libpopt-dev
this root file system contains the libs for ARM - http://storage.kernelci.org/images/selftests/arm/rootfs.cpio.gz
was hoping to be able to use this with sysroot
here are the cross deps - http://images.armcloud.us/misc/tyler-kselftest/armel/kselftest-cross-deps-armhf.tar.gz
take some time and review the status. we can chat more next week
23:57 <bamvor> Thanks. I will try to work on the "--sysroot" in my next move.
23:58 <tyler-baker> ok great, thanks for the help
23:58 <bamvor> Last question. Is there something like TODO list for kselftest?
23:58 <tyler-baker> Not at the moment, but I can put one together for next week

3.  Tylar's command
make distclean
make multi_v7_defconfig
make zImage dtbs -j12
export INSTALL_HDR_PATH=./usr/include
make headers_install
#wget http://storage.kernelci.org/images/selftests/arm/kselftest.tar.gz
#tar -C . -xaf kselftest.tar.gz (this unpacks the shared libraries to the header install location)
make -C tools/testing/selftest
make -C tools/testing/selftest install

20:37 2015-08-02
----------------
Hi, Shuah

Sorry for the empty email.

This is Bamvor from linaro kernel working group. We want to improve arm/arm64
support for kselftest. Maybe I could discuss with you before I really dig into
it.

The first thing we want to do it improve the cross-compile support. Although
kselftest support cross compiler, the build may fail because of lacking
libpopt-dev, libcap-dev. We propose add something like
"SYSROOT=/path/to/your/root" as a parameter for make. User could put the rootfs
which include the library above to cross compiling.

The second thing for us is that fix the bugs for arm/arm64. I found that there
are four branches in your git.kernel.org: devel fixes master next. Which one
should I used for testing and devopment?

Besides, which mailing list is suitable for discussion? It seems that the wiki
is a little bit out-of-date. And there is no kselftest relative discussion
around ksubmit mailing list and kernel api mailing list.

regards

bamvor

15:36 2015-08-06
----------------
kselftest
---------
1.

Hi, Tyler

About add "--sysroot" to the kselftest.
The rootfs you gave me[1] lack the sufficient header(e.g. stdio.h) for building
kselftest when I set "--sysroot /path/to/Tyler/rootfs". Of courses, we
could add the missing headers to these rootfs. I just not sure if it is
necessary.

Compare with add sysroot to kselftest, we could also add something like
CFLAGS_EXTRA for passing the additional flags:

diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
index ee412ba..1acfd02 100644
--- a/tools/testing/selftests/lib.mk
+++ b/tools/testing/selftests/lib.mk
@@ -2,6 +2,8 @@
 # Makefile can operate with or without the kbuild infrastructure.
 CC := $(CROSS_COMPILE)gcc

+CFLAGS += $(CFLAGS_EXTRA)
+
 define RUN_TESTS
        @for TEST in $(TEST_PROGS); do \
                (./$$TEST && echo "selftests: $$TEST [PASS]") || echo "selftests: $$TEST [FAIL]"; \


Then, we could build kselftest with the following comand:
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C tools/testing/selftests/ CFLAGS_EXTRA="-I /path/to/kselftest-cross-deps-armhf -L /path/to/kselftest-cross-deps-armhf"

What do you think about it?

BTW, where could I find the kselftest test result in LAVA or the list of cases
of kselftest failure?

regards

bamvor

[1] http://storage.kernelci.org/images/selftests/arm/rootfs.cpio.gz
[2] http://images.armcloud.us/misc/tyler-kselftest/armel/kselftest-cross-deps-armhf.tar.gz

2.
diff --git a/tools/testing/selftests/mqueue/Makefile b/tools/testing/selftests/mqueue/Makefile
index 0e3b41e..83f26c8 100644
--- a/tools/testing/selftests/mqueue/Makefile
+++ b/tools/testing/selftests/mqueue/Makefile
@@ -1,4 +1,5 @@
 CFLAGS = -O2
+CFLAGS += $(CFLAGS_EXTRA)

 all:
        $(CC) $(CFLAGS) mq_open_tests.c -o mq_open_tests -lrt

09:41 2015-08-07
----------------
kselftest
---------
1.  compare the compiling result for arm and arm64.
2.  found out why "exec" failed in install directory. ref"12:35 2015-07-23"
    1.  try to learn from libvirt about how to install symbol link.

16:11 2015-08-11
---------------
kselftest
---------
1.  tools/testing/selftests/jump_label is deleted by 2bf9e0ab.

14:39 2015-08-12
----------------
software skill, SCM, git, cherry-pick
-------------------------------------
apply the top 6 patches from bjzhang_github/kselftest to current branch:
`git cherry-pick -6 bjzhang_github/kselftest`

15:23 2015-08-12
----------------
kselftest
---------
1.  cover letter
Improvement kselftest support for arm and arm64

This is my first attempt to improve the kselftest for arm
architecture. Eventually, we hope we could build(in an cross
compile environment) and run all the kselftest cases
automatically.

According to your suggections, all my work is based on the lastest
linux-next tree(c1a0c66 Add linux-next specific files for 20150812)
right now.

In this series, I try to make all the testcases compile pass
except kdbus(i do not know whether it support arm or not, will deal
with it later).

There are different reasons that build or install fail on our arm or
arm64 environment.

The first reason is the test cases may fail in cross compiling due
to lack of the headers and libraries. I add the CFLAGS_EXTRA to fix
this. Reference patch 2 for details.

The second reason is install rules do not handle the special file.
I overwrite the INSTALL_RULES in exec test case to fix this.
Reference patch 3 for details.

The third reason is those cases do not support arm architecture.
E.g. userfaultfd, x86, seccomp. I do the same thing in
tools/testing/selftests/powerpc/Makefile, and move them to the
lib.mk. Reference patch 4, 5, 6, 7 for details.

In my next step, I will figure out how to build kdbus testcases.
When all the testcases build pass, I will check the test result.

In my previous testing, lots of testcass is failed. Due to the
fact what I test it on 4.2-rcx instead linux-next. I will retest
all the test cases.

Here is my test result on 4.2-rcX.

firmware         FAIL
kcmp             FAIL
memfd            FAIL
memory-hotplug   SKIP
mount            SKIP
net              FAIL
sysctl           FAIL
timers           FAIL
user             FAIL
vm               FAIL

It would be great if there are the test result from LAVA already.

2.  send email
"`git send-email --no-chain-reply-to --annotate --to broonie@linaro.org --to khilman@linaro.org --to tyler.baker@linaro.org --cc bamvor.zhangjian@linaro.org *.patch`"

3.  kdbus: -devel
    mqueue: popt-devel

4.  size compile failed on aarch64 on opensuse.
    1. -lc not found
        ```
        > gcc -static -ffreestanding -nostartfiles -s get_size.c -o get_size
        /usr/lib64/gcc/aarch64-suse-linux/5/../../../../aarch64-suse-linux/bin/ld: cannot find -lc
        collect2: error: ld returned 1 exit status
    ```
    2.  create the soft link from libc_noshared.a to libc.a
        ```
        > gcc -static -ffreestanding -nostartfiles -s get_size.c -o get_size
        /tmp/ccaUd19E.o: In function `print':
        get_size.c:(.text+0x10): undefined reference to `strlen'
        get_size.c:(.text+0x20): undefined reference to `write'
        /tmp/ccaUd19E.o: In function `_start':
        get_size.c:(.text+0x188): undefined reference to `sysinfo'
        get_size.c:(.text+0x1b8): undefined reference to `_exit'
        get_size.c:(.text+0x264): undefined reference to `_exit'
        collect2: error: ld returned 1 exit status
        ```
    3.  it build successful on cross-compile with gcc-linaro
        gcc version 5.9.3 20141031 (prerelease) (Linaro GCC 2014.11)

    4.  the options difference between cross compiler(4.9 success) and native compiler(5.1 fail)
        ```
        diff -urN success pass
        --- success     2015-08-13 15:46:24.145150405 +0800
        +++ pass        2015-08-13 18:19:08.480025385 +0800
        @@ -1,11 +1,12 @@
        -/usr/lib64/gcc/aarch64-suse-linux/5/collect2
        +/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/4.9.3/collect2
         -plugin
        -/usr/lib64/gcc/aarch64-suse-linux/5/liblto_plugin.so
        --plugin-opt=/usr/lib64/gcc/aarch64-suse-linux/5/lto-wrapper
        --plugin-opt=-fresolution=/tmp/ccYU3agp.res
        +/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/4.9.3/liblto_plugin.so
        +-plugin-opt=/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libexec/gcc/aarch64-linux-gnu/4.9.3/lto-wrapper
        +-plugin-opt=-fresolution=/tmp/ccOfTGms.res
         -plugin-opt=-pass-through=-lgcc
         -plugin-opt=-pass-through=-lgcc_eh
         -plugin-opt=-pass-through=-lc
        +--sysroot=/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc
         --build-id
         -Bstatic
         -dynamic-linker
        @@ -13,16 +14,20 @@
         -X
         -EL
         -maarch64linux
        +--fix-cortex-a53-835769
         -o
         get_size
         -s
        --L/usr/lib64/gcc/aarch64-suse-linux/5
        --L/usr/lib64/gcc/aarch64-suse-linux/5/../../../../lib64
        --L/lib/../lib64
        --L/usr/lib/../lib64
        --L/usr/lib64/gcc/aarch64-suse-linux/5/../../../../aarch64-suse-linux/lib
        --L/usr/lib64/gcc/aarch64-suse-linux/5/../../..
        -/tmp/ccqmrEUN.o
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/lib/../lib64
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/lib/../lib64
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/usr/lib/../lib64
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/4.9.3/../../../../aarch64-linux-gnu/lib
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/lib
        +-L/path/to/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin/../libc/usr/lib
        +/tmp/cceoPRQ6.o
         --start-group
         -lgcc
         -lgcc_eh
        ```

5.  cover letter
Improvement kselftest support for arm and arm64

This is my second version for improving the kselftest for arm
architecture. Eventually, we hope we could build(in an cross
compile environment) and run all the kselftest cases
automatically(successful of courses).

According to your suggections, all my work is based on the lastest
linux-next tree("c1a0c66 Add linux-next specific files for 20150812").

In this series, I try to make all the testcases compiling and
installation successful.

There are different reasons that build or install fail on our arm or
arm64 architecture.

Patch 2 add CFLAGS_EXTRA to fix the cross comiling failure.

Patch 3 fix the running the installation issue for exec testcase.

Patch 4 check if there are files need to be installed. This is
useful when such testcase is not built for specific architecture.
E.g. x86 testcases for arm/arm64.

Patch 5 and 6 disable seccomp for arm64 and only enable userfaultfd
for x86 and powerpc.

In my previous testing, lots of testcass is failed. Due to the
fact what I test it on 4.2-rcx instead linux-next. I will retest
all the test cases. In my next step, I will fix them.

It would be great if I could get our lastest test result(from LAVA?).

6.  cover letter(send it to LKML):
Improvement kselftest support for arm and arm64

This is my first attempt for improving the kselftest for arm/arm64
architecture. Eventually, we hope we could build(in an cross compile
environment) and run all the kselftest cases automatically(successful
of courses).

I realize that there are lots of improvement for kselftest after the
lastest pull request for kselftest. So, All my work is based on the
lastest linux-next tree ("30b42f4 Add linux-next specific files for
20150813").

In this series, I try to make all the testcases compiling and
installation successful.

Patch 1 rename jumplabel target to static_keys in the Makefile.

Patch 2 add CFLAGS_EXTRA to fix the cross comiling failure.

Patch 3 fix the running the installation issue for exec testcase.

Patch 4 check if there are files need to be installed. This is
useful when such testcase is not built for specific architecture.
E.g. x86 testcases for arm/arm64.

Patch 5, 6 and 7 check the architecture before build and install.

7.  0815: Mark said that I should send to broonie@kernel.org:
    ```
    Please when posting patches can you send them to my upstream address broonie@kernel.org - it is a lot easier for me to work with patches there and it avoids confusing other people working upstream.
    ```
    `git send-email --no-chain-reply-to --annotate --to linux-kernel@vger.kernel.org --cc broonie@kernel.org --cc khilman@linaro.org --cc tyler.baker@linaro.org --cc bamvor.zhangjian@linaro.org --cc shuahkh@osg.samsung.com *.patch`
    broonie@linaro.org
--

08:56 2015-08-13
----------------
GTD
---
1.  today
    1.  8:57-9:18 rebase buildroot patch.
    2.  9:25-09:31 update linaro card. <https://projects.linaro.org/browse/KWG-23>
    3.  9:31-10:16 13:53-17:30 kselftest, fix compile issue for kdbus. send v2 internally.
    4.  10:16-11:30 Preparing the environment and setup the network.
    5.  AAR: need continue to focus on kselftest. This is maybe my last chance to join the open source community.
        I cann't fail everytime!

09:45 2015-08-14
----------------
GTD
---
1.  today
    1.  9:45-10:50 11:25-12:40 14:20-14:47 kselftest exec.
    2.  10:50-11:25 personal call.
    3.  14:47-16:20 huawei internal meeting.

2.  TODO
    2.  vim markdown

15:42 2015-08-14
----------------
kselftest, testcases
---------
1.  firmware
    1.  need enable "`CONFIG_TEST_FIRMWARE`" and put `test_firmware.ko` into filesystem.
    2.  PASS.

2.  ftrace
    1.  need enable COFNIG_FTRACE and all the sub config except CONFIG_FTRACE_STARTUP_TEST(This config will not affect the test result, but it takes long time to test it..
    2.  ftrace: 10 PASS, 5 UNSUPPORTED(kprobe relative cases).

3.  futex: PASS.

4.  kcmp: PASS.

5.  kdbus
    1.  need enable CONFIG_KDBUS.

    2.  fail
        ```
        Assertion 'ret == 0' failed in kdbus_test_activator_quota(), test-message.c:435
        Assertion 'ret == 0' failed in kdbus_test_message_quota(), test-message.c:619
        Testing message quotas are enforced (message-quota) .................... ERROR
        ```

    3.  skip
        ```
        Testing retrieving connection information (connection-info) ............ SKIPPED
        Testing unprivileged bus access (policy-priv) .......................... SKIPPED
        Testing policy in user namespaces (policy-ns) .......................... SKIPPED
        Testing metadata in different namespaces (metadata-ns) ................. SKIPPED
        Testing activator connections (activator) .............................. SKIPPED
        ```

6.  memfd
    1.  memfd
        > (./memfd_test && echo "selftests: memfd_test [PASS]") || echo "selftests: memfd_test [FAIL]"
        memfd: CREATE
        memfd: BASIC
        memfd: SEAL-WRITE
        memfd: SEAL-SHRINK
        memfd: SEAL-GROW
        memfd: SEAL-RESIZE
        memfd: SHARE-DUP
        memfd: SHARE-MMAP
        memfd: SHARE-OPEN
        memfd: SHARE-FORK
        clone() failed: Invalid argument
        selftests: memfd_test [FAIL]

    2.  fuse: fuse-devel

22:44 2015-08-15
----------------
howto, send patches
-------------------
1.  check prefix, version; to and cc in patches.
2.  ensure the proper email address
    For non-linaro internal email: Mark: broonie@kernel.org
    Same as arnd?

18:18 2015-08-19
-
GTD
-
1.  today
    1.  kselftest kdbus.

10:13 2015-08-24
-
GTD
-
1.  today
    1.  10:13-10:34 weekly report.

10:13 2015-08-24
----------------
linaro, work reprot, weekly report
----------------------------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-08-10 to 2015-08-23

=== Highlights ===
1.  kselftest
    1.  add some improvement for kselftest in order to build and test kselftest automatically.
        And send v1 to LKML after internal review. No one response yet(because of Linux Plumbers Conference?).
    2.  check the failure of kdbus and memfd. Some of the failure due to the failure of clone syscall.

=== Plans ==
1.  kselftest:
    1.  try to write the kselftest for seccomp for arm64 in reference to the patch for s390[1]
    2.  send v2 with more improvement for kselftest on arm64.

[1]  http://comments.gmane.org/gmane.linux.kernel/2024322

14:45 2015-09-02
-
GTD
-
1.  today
1.  kselftest patch v2.

15:57 2015-09-02
010 67294071

15:42 2015-09-03
-
GTD
-
1.  today
1.  kselftest patch v2. see"15:42 2015-09-03"
2.  next
1.  evaluate the task for kselftest. when could I finish this task?

15:42 2015-09-03
kselftest
1.  exec
1.  as Michael Ellerman said, the subdir I fixed is broken after 84cbd9e4c457.
    try the rsync later, hope I could fix all the bugs.

2.  if userfaultfd compile failed, it will not install the entire project.

3.  TODO send v2 tomorrow.

16:41 2015-09-03
mmc, usb.

15:26 2015-09-06
-
GTD
-
1.  today
1.  16:41- kselftest v2.

16:19 2015-09-07
-
kselftest
-
1.  cover letter
kselftest improvement and cleanup

This is my second attempt for improving the kselftest for arm/arm64
architecture. Eventually, we hope we could build(in an cross compile
environment) and run all the kselftest cases automatically(successful
of courses). The first version is here[1].

In this series, I try to make all the testcases compiling and
installation successful.

c 9fae100 selftests: breakpoints: fix installing error on the architecture except x86
c a7d0f07 selftests: check before install
a 7824b26 selftests: rename jump label to static_keys
a f93be76 selftests: only compile userfaultfd for x86 and powperpc
8ec8722 selftests: mqueue: allow extra cflags
d5babcb selftests: mqueue: simpification the Makefile
e2fe790 selftests: change install command to rsync
2becd5b selftests: exec: simpification the Makefile

"c" means committed by Shuah Khan <shuahkh@osg.samsung.com>
"a" means acked by Shuah Khan <shuahkh@osg.samsung.com>

[1] http://www.spinics.net/lists/kernel/msg2056987.html

2.  git send email
`git send-email --no-chain-reply-to --annotate --to linux-kernel@vger.kernel.org --cc broonie@kernel.org --cc khilman@linaro.org --cc tyler.baker@linaro.org --cc bamvor.zhangjian@linaro.org --cc shuahkh@osg.samsung.com --cc mpe@ellerman.id.au *.patch`

3.  the patch for userfaultfd is replaced by "Michael Ellerman"

08:58 2015-09-09
-
GTD
-
1.  today
    1.  kselftest: read the mail and patch sent by Andrea Arcangeli.
    2.  9:27 seccomp: send email to maintainer.
    3.  14:32 write v3 patch.

12:05 2015-09-09
-
colleague, linaro, kwg
-
John Stultz, android, ion
<http://lwn.net/Articles/656324/>

12:13 2015-09-09
-
[what does tipbot mean in LKML?](http://stackoverflow.com/questions/15352669/what-does-tipbot-mean-in-lkml)
tip-bot is an automated script that notifies the LKML(linux kernel mailing list) whenever a certain code or patch has made its way into few of the branches maintained by Peter Anvin, Thomas Gleixner, and Ingo Molnar. I think the tip refers to the tip trees.

14:37 2015-09-09
1.  Capitalize the Fixes?
2.  Acked-by: Viresh Kumar <viresh.kumar@linaro.org>

14:56 2015-09-09
1.  cover letter
kselftest improvement and cleanup

This is my third attempt for improving the kselftest for arm/arm64
architecture. Eventually, we hope we could build(in an cross compile
environment) and run all the kselftest cases automatically(successful
of courses). The first and second version is here[1][2].

In this series, I try to make all the testcases compiling and
installation successful.

Changes since v2:
1.  Remove the patch "selftests: only compile userfaultfd for x86 and
powperpc". Michael sent anther better patch.
2.  Improve the commits and patches according to Michael's suggestion.

c 9fae100 selftests: breakpoints: fix installing error on the architecture except x86
c a7d0f07 selftests: check before install
a 1189f67 selftests: rename jump label to static_keys
a 4ee06bb selftests: mqueue: allow extra cflags
  9767a8e selftests: mqueue: Simplify the Makefile
  980ac26 selftests: change install command to rsync
  82775ac selftests: exec: Revert to default emit rule

"c" means committed by Shuah Khan <shuahkh@osg.samsung.com>
"a" means acked by Shuah Khan <shuahkh@osg.samsung.com> or Michael Ellermani <mpe@ellerman.id.au>

09:46 2015-09-10
-
kselftest, seccomp, arm, arm64, restartable syscall
-
1.  "Kees Cook" reply to "Arnd Bergmann"
On Wed, Sep 9, 2015 at 2:20 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday 09 September 2015 13:52:39 Kees Cook wrote:
>> On Wed, Sep 9, 2015 at 1:08 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> On Wednesday 09 September 2015 12:30:27 Kees Cook wrote:
>
>>> If this is intentional, it at least needs a comment to explain the
>>> situation, and be extended to all other architectures that do not have
>>> a poll() system call.
>>>
>>> The arm32 version of sys_poll should be available as 168 in both native
>>> and compat mode.
>>
>> Does ppoll still get interrupted like poll to require a restart_syscall call?
>
> Yes, the only difference between the two is the optional signal mask
> argument in ppoll.

Okay, good. I'll respin the patch to use ppoll (which was Bamvor's
original suggestion to me, IIRC).

>> Regardless, the primary problem is this (emphasis added):
>>
>>>> +        * - native ARM does _not_ expose true syscall.
>>>> +        * - compat ARM on ARM64 _does_ expose true syscall.
>>
>> When you ptrace or seccomp an arm32 binary under and arm32 kernel,
>> restart_syscall is invisible. When you ptrace or seccomp an arm32
>> binary under and arm64 kernel, suddenly it's visible. This means, for
>> example, seccomp filters will break under an arm64 kernel.
>
> Ok, I see.
>
>> (And apologies if I'm not remembering pieces of this correctly, I
>> don't have access to arm64 hardware at the moment, which is why I'm
>> reaching out for some help on this... I'm trying to close out this old
>> thread: https://lkml.org/lkml/2015/1/20/778 )
>
> FWIW, it should not be too hard to get an image that runs in
> qemu-system-arm64.

Yeah, that's my next project on this front.

> I suppose the same problem exists on all restartable system calls
> (e.g. nanosleep, select, recvmsg, clock_nanosleep, ...)?

As far as I know, yes. I just happened to set up the testing around
poll as it was easiest to trigger for me.

> I also believe there are various architectures that cannot see the
> original system call number for a restarted syscall, in particular
> when the syscall number argument is in the same register as the
> return code of the syscall and gets overwritten on the way out of
> the kernel. Is this the problem you are seeing? If so, we should
> find a solution that works on all such architectures.

I don't think there's any one way things operate, unfortunately. I
need to map out the behaviors, since sometimes ptrace sees things
differently from seccomp (which leads to no end of confusion on my
part). I will try to generate a comparison across several
architectures.

-Kees

-- 
Kees Cook
Chrome OS Security

2.  kselftest status
    1.  except seccomp which in discussion, all the testcases is compiled pass.
    2.  Will check all the testcases failure in my next step.

11:38 2015-09-17
---------------
kselftest, testcases
--------------------
1.  memory hotplug
    1.  do not support by arm and arm64.

2.  mount
    1.  enable /proc/self/uid_map
        user namespace?

    2.  enable CONFIG_DEVPTS_MULTIPLE_INSTANCES
        TODO

3.  mqueue
    1.  PASS: mq_open_tests, mq_perf_tests

4.  net
    1.  run_afpackettests
        1.  got the following failure.
            test: datapath 0x1000
            info: count=0,0, expect=0,0
            info: count=0,20, expect=15,5
            ERROR: incorrect queue lengths

            1.  after enable user namespace, BPF_SYSCALL and TEST_BPF and reboot. it is ok.
                but after reboot, it fail again. maybe it fail because of qemu?
                TODO

        2.  psock_fanout
            CONFIG_BPF_SYSCALL: enable bpf syscall

    2.  enable TEST_BPF for test_bpf.


5.  rcutorture is not tested. TODO: do we need test it?

6.  size
    1.  compile failed in arm64 native.
        ```
        gcc -static -ffreestanding -nostartfiles -s get_size.c -o get_size
        /usr/lib64/gcc/aarch64-suse-linux/5/../../../../aarch64-suse-linux/bin/ld: cannot find -lc
        collect2: error: ld returned 1 exit status
        Makefile:4: recipe for target 'get_size' failed
        make: *** [get_size] Error 1
        ```
    2.  test pass.

7.  staic_keys:
    1.  enable TEST_STATIC_KEYS

8.  sysctl
    1.  got the same error on arm64 and x86
    ```
    # ./run_numerictests
    == Testing sysctl behavior against /proc/sys/vm/swappiness ==
    Writing middle of sysctl after synchronized seek ... FAIL
    Writing beyond end of sysctl ... FAIL
    # ./run_stringtests
    == Testing sysctl behavior against /proc/sys/kernel/domainname ==
    Writing middle of sysctl after synchronized seek ... FAIL
    Writing beyond end of sysctl ... FAIL
    Writing sysctl with multiple long writes ... FAIL
    Writing entire sysctl in short writes ... FAIL
    Checking sysctl keeps original string on overflow append ... FAIL
    ```

    2.  (17:14 2015-10-15)
        It is a fix for procfs: when kernel.sysctl_writes_strict = 1, it will append instead of trucate. ref"f4aacea2" and [discussion](https://lkml.org/lkml/2015/6/17/124)

    "17:14 2015-10-15"end

9.  timers
    1.  FAIL: rtctest

10. user
    1.  enable TEST_USER_COPY

17:26 2015-10-11
1.  这是我第一次参加linaro connect, 认识相关同事, 看了demo friday.
    1.  和下列同事有面对面的交流.
        1.  kwg
            1.  Takahiro Akashi(kdump)
                DONE: he will discuss with jeff about the plan of upstream for kdump and kexec.

2.  daivd long kprobe
      the handler of brk instruction changed a little. david will change his patches a little.
     it may be useful for my breakpoint of kprobe work.

    I suggest that david could use the 4.2 rcx for hikey board.

3.  linus
    he suggest gpio test.

4.  mark
   mark ack our(me and linus) thought, i will discuss with mark later after i think carefully.

5.  Mathieu Poirier

core
Serge Broslavsky
    Samsung leave and join.

Alex Bennée
    qemu tcg.

pmwg
lina: cpuidle
todo suspend to idle?

leg
venkatesh jooth vivekanandan: was working in lng. focus on openstack for arm. the new arm64 server chip of broadcom is coming.
guohanjun: 有的，而且应该支持多P互联，他们有人问我NUMA进展.

lmg
Sumit Semwal: android kernel leader(5 persons). maintainer of dma buffer sharing framework.

Amit Pundir: lsk-android



geoff
he will send the new versions with Takahiro together. with an update which enable cache for kdump.

Stefano Stabellini:
i mentioned i contribute to xen two years ago. glad to know that he still remember me.

Paul Liu

Viswanath Puttagunta: show the case for wayland.

阿里
一斐: todo 最近在做什么？

face to face hello
1.  Samuel Li
    linaro, vp, great China. responsible for bd(business development).

Yongqin Liu

Jorge Ramirez-Ortiz

18:10 2015-10-13
----------------
clone
1.  there is copy_thread_tls in x86. it is not exist in another architecture.
```
> grep copy_thread_tls * -R -I
arch/x86/kernel/process_32.c:int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
arch/x86/kernel/process_64.c:int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
arch/Kconfig:     Architecture provides copy_thread_tls to accept tls argument via
include/linux/sched.h:extern int copy_thread_tls(unsigned long, unsigned long, unsigned long,
include/linux/sched.h:/* Architectures that haven't opted into copy_thread_tls get the tls argument
include/linux/sched.h:static inline int copy_thread_tls(
kernel/fork.c:  retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
```

2.  patch
```c
diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 0b9eafb..6859af5 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -18,7 +18,7 @@
 #include <unistd.h>
 
 #define MFD_DEF_SIZE 8192
-#define STACK_SIZE 65535
+#define STACK_SIZE (65535&(~15))
 
 static int sys_memfd_create(const char *name,
            unsigned int flags)
```

3.  send email(cancelled)
RFC: selftest: memfd: fix alignment issue on aarch64
Due to 16-byte aligned stack mandatory on AArch64, copy_thread() in arch/arm64/kernel/process.c will failed.
Except arm64, parisc will do the word algn in copy_thread instead of checking and sparc will do the 16bytes algn.

4.  reply to chunyan
This works for me. Meanwhile, I check all the implementation of
copy_thread in all architectures. There is no aliment check except
aarch64. Parisc and sparc will do the 4bytes and 16bytes alignment
instead of checking respectively.

And such alignment is introduced by Commit e0fd18ce1169 ("arm64:
get rid of fork/vfork/clone wrappers"). So, it seems that we should
fix in memfd_test.c?

not used
dh.herrmann@gmail.com
Catalin Marinas <catalin.marinas@arm.com>
Will Deacon <will.deacon@arm.com>

cc'd the author of memfd_test.c and aarch64 maintainer.


19:17 2015-10-14
----------------
arm32 meeting
For connect:
This is the first time I join connect. The primary things in my mind is chatting, especially with the kernel developers.
Linus suggest me to work on the gpio test stuff. Mark create a card for it(https://projects.linaro.org/browse/KWG-148).
I take a vacation after conenct until this Monday.
In recent two days, I evalute the gpio test stuff. And try to fix a bug for aarch64 in memfd test of kselftest.
In memfd_test.c, due to 16-byte aligned stack mandatory on AArch64, copy_thread() in arch/arm64/kernel/process.c will failed.
Except arm64, parisc will do the word algn in copy_thread instead of checking and sparc will do the 16bytes algn.
There are two method for solving this issue: a, align to 16bytes in clone in memfd_test.c; b. change the stack check to force alignment in aarch64. I feel I should modify the code in memfd_test.c

20:50 2015-10-14
----------------
Summary for linaro connect sfo15

12:00 2015-10-16
----------------
kselftest
CONFIG_DEVPTS_MULTIPLE_INSTANCES
CONFIG_TEST_STATIC_KEYS
CONFIG_TEST_USER_COPY
CONFIG_KDBUS
CONFIG_TEST_FIRMWARE
CONFIG_FTRACE
CONFIG_GENERIC_TRACER
CONFIG_TRACING_SUPPORT
CONFIG_FUNCTION_TRACER
CONFIG_FUNCTION_GRAPH_TRACER
CONFIG_IRQSOFF_TRACER
CONFIG_PREEMPT_TRACER
CONFIG_SCHED_TRACER
CONFIG_FTRACE_SYSCALLS
CONFIG_TRACER_SNAPSHOT
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP
CONFIG_BRANCH_PROFILE_NONE
CONFIG_STACK_TRACER
CONFIG_BLK_DEV_IO_TRACE
CONFIG_DYNAMIC_FTRACE
CONFIG_FUNCTION_PROFILER
CONFIG_FTRACE_MCOUNT_RECORD
CONFIG_TRACEPOINT_BENCHMARK
CONFIG_RING_BUFFER_STARTUP_TEST
CONFIG_TRACE_ENUM_MAP_FILE
CONFIG_USER_NS
CONFIG_BPF_SYSCALL
CONFIG_TEST_BPF

15:20 2015-10-16
----------------
1.  efivarfs
2.  exec
    1.  cross-compile: fail.
    2.  native build: succeessful: missing Makefile in installation path. successful if manaually add.
3.  kdbus
    1.  I suppose the module issue.

16:00 2015-10-18
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-10-12 to 2015-10-16
= Bamvor Jian Zhang=

3 days leave this week.

=== Highlights ===
* GPIO kselftest/[new KWG-148]
    - Get this task from Linus during sfo15.
    - Understanding this task and read the patch from Kamlakant Patel.

17:14 2015-10-19
----------------
0.  take tegra as example.
1.  should i do it base on gpiolib?
    yes
2.  which interface should I implemented for gpio_chip?
    set, get, direction_out, direction_in; it seems that I should add request and free.
3.  there is debugfs in drivers/gpio/gpiolib.c, So, why we need a dedicated /sys/kernel/debug/mock-up-gpio-state?

4.  My plan
    1.  write gpio-mock with set, get, direction_out, direction_in, request and free.
        use gpiolib_seq_ops for our debugfs work.
    2.  use dbg_show in other gpio, such as tegra...

19:00 2015-10-21
----------------
// enable all the messages in file svcsock.c
nullarbor:~ # echo -n 'file svcsock.c +p' > <debugfs>/dynamic_debug/control
See Documentation/dynamic-debug-howto.txt for additional information.

10:24 2015-10-26
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-10-19 to 2015-10-23
= Bamvor Jian Zhang=

=== Highlights ===
* GPIO kselftest/[KWG-148]
    - Discuss with Linus and arnd about this task. I may do the following items:
      basic gpio mockup driver, kselftest test script, support pinctrl, emulate
      interrupt by eventfd(not sure if it works in debugfs).
    - Rebase and update the patch from Kamlakant Patel.
      Currently, it support change direction and out value.
    - Writing kselftest script.
    - Found the new gpio interface(char device) from linus. Maybe my gpio
      kselftest could try to support it after Linus send out the set/get API.

* kselftest improvements/[KWG-23]
    - Found out why my sysctl testcase is failed on both x86 and arm. It is
      because write behave depend on the kernel.sysctl_writes_strict after
      Commit 24fe831c17ab ("tools/testing/selftests/sysctl: validate
      sysctl_writes_strict")

=== Plans ===
* GPIO: write kselftest script and pinctrl.
* kselftest: revisit all the test result on the lastest kernel.
* Try to boot the lastest kernel on my 96boards.

15:07 2015-10-29
----------------
0.  TODO
    1.  there is no relationship between generic gpio_chip and mockup gpio_stat.
    2.  add multi gpio_chip to test overlap:
    ```
        GPIO integer space overlap, cannot add chip\n");
    ```
    3.  probe failed, but driver already insert. is it normal?
        1.  improve gpiochip_add_to_list: add better overlap check; add base conflict check to avoid the failure of gpiochip_sysfs_register.

1.  there are pros and cons if we do not support device tree.
pros: do not need to mix with the real hardware dts.
cons: could not test the dt_gpio_count, of_find_gpio which rely on device tree. And other function such like gpiod_get_index which rely on the correctness dts.

2.  should I set nrgpio and base as module parameter?
    add multiple gpio chip support?


