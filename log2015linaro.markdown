
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
    print common ```
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

7.  static_keys:
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
    1.  DONE: there is no relationship between generic gpio_chip and mockup gpio_stat.
    2.  DONE: add multi gpio_chip to test overlap:
    ```
        GPIO integer space overlap, cannot add chip\n");
    ```
    3.  DONE: probe failed, but driver already insert. is it normal?
        1.  improve gpiochip_add_to_list: add better overlap check; add base conflict check to avoid the failure of gpiochip_sysfs_register.
    4.  DONE: write proper label for gpio-mockup gpiochip.
    5.  DONE: test base == -1;

1.  there are pros and cons if we do not support device tree.
pros: do not need to mix with the real hardware dts.
cons: could not test the dt_gpio_count, of_find_gpio which rely on device tree. And other function such like gpiod_get_index which rely on the correctness dts.

2.  YES: DONE: should I set nrgpio and base as module parameter?
    add multiple gpio chip support?

3.  I am wrong, we need to check it: there is no need to check `_chip->base==chip->base` when we look for where should insert gpiochip if we do not allow nrgpio == 0.

4.
```
    #FAIL in original code
    gpio_test_fail "0,32,30,5"
    #FAIL in original code
    gpio_test_fail "0,32,1,5"
    #FAIL in original code
    gpio_test_fail "10,32,9,5"
    #FAIL in original code
    gpio_test_fail "10,32,30,5"
    #FAIL in original code
    gpio_test_fail "0,32,40,16,39,5"
    #successful in original code
    gpio_test_fail "0,32,40,16,30,5"
    #FAIL in original code
    gpio_test_fail "0,32,40,16,30,11"
    #successful in original code
    gpio_test_fail "0,32,40,16,20,1"
```

5.  TODO before sending out:
    1.  DONE: check the testcase and patch for overlapping.
    2.  DONE: review all the commit message. TODO for gpio.sh and range overlap.
    3.  DONE: add the error message for overlap of base.
    4.  DONE: format check

6.  cover letter
RFC: Add gpio test framework

These series of patches try to add support for testing of gpio
subsystem based on the proposal from Linus Walleij.

The basic idea is implement a virtual gpio device(gpio-mockup) base
on gpiolib. Tester could test the gpiolib by manipulating gpio-mockup
device through sysfs and check the result from debugfs. Both sysfs
and debugfs are provided by gpiolib. Reference the following figure:

   sysfs  debugfs
     |       |
  gpiolib---/
     |
 gpio-mockup

Find three issue with these with gpio test script. Further discussion
may needed for these issues.

I split the original patch(from Kamlakant with little update) and
enhancement patch(support multiple gpiochip). Hope it is easy to
review it. But I not sure if I should merge when I send to the ML.

I add the entry in MAINTAINER files due to the warning came from
./scripts/checkpatch.pl. But I am not sure if I should add the
M or R While I notice that there is a discussion about "Start using
the 'reviewer' (R) tag"[1].

Futher work and discussion:
1.  Test other code path(if exists).
2   Add pinctrl and interrupt support(Linus suggest trying the
    eventfd) in next steps.
3.  I feel that we could rework the debugfs in other gpiolib based
    drivers to the code in gpiolib.c with generic gpiolib_dbg_show or
    chip->dbg_show.
4.  Currently, gpio-mockup does not support the device tree. There are
    pros and cons if we do not support device tree:
    Pros: do not need to mix with the real hardware dts.
    Cons: could not test the dt_gpio_count, of_find_gpio which rely on
    device tree. And other function such like gpiod_get_index which
    rely on the correctness of the above functions.

    If we want to test the above functions, we could provide a
    dedicated device tree for gpio-mockup device which could be
    included by other device tree. And we could use device tree
    overlay to provide multiple device tree testcases.
5.  Given that this gpio test framework is based on sysfs and debugfs.
    I feel that it could be a generic gpio test script other then a
    dedicated script for gpio-mockup driver. Although, my script only
    support gpio-mockup driver at this monment.

My patch rebased on linux-gpio/devel, could get from
https://github.com/bjzhang/linux/tree/gpio-mockup-RFC-only-for-Linus

[1] http://www.spinics.net/lists/arm-kernel/msg456194.html

7.  send
`git send-email --no-chain-reply-to --annotate --to linus.walleij@linaro.org --cc broonie@linaro.org *.patch`

21:53 2015-11-03
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-10-26 to 2015-11-03
= Bamvor Jian Zhang=

=== Highlights ===
* GPIO kselftest/[KWG-148]
    - Add multiple gpiochip support in my gpio-mockup driver.
    - Add a test script in kselftest for testing multiple gpiochip and overlap.
    - Found three issues with my test script.
    - Send all my 7 patches to Linus and Mark privately yestoday.

* Play with my hikey board
    - reflash the bootloader and debian.
    -  The serial do not work with serial board for 96boards. Both Uart0 and Uart1
       do not work. Will try from J16 directly.

* 1:1 with Mark

=== Plans ===
* Discuss with Linus with my gpio patches.
* y2038: ppdev: write a updated version of ppdev patches for converting it to
  y2038 safe.
* Continue trying the seiral of hikey.

14:56 2015-11-04
----------------
y2038, ppdev
------------
1.  requirement.
    1.  Do not break old applications which include arm32 application on arm32 kernel; compat and aarch64 applications on arm64 kernel.
    2.  New compiled code based on `time64_t` which include arm32 and compat.
    3.  Do not consider ilp32 at this monment?

2.  current status
    1.  Do not support compat.
    2.  There is no need to convert timeval to 64bit.

3.  Analysis in details.
notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit kernel. compat means 32bit app running on 64bit kernel. 64 means 64bit app running on 64bit kernel.

summary            |u:arch |u:tv_sec |k:arch |k:tv_set |is_timeval_same |how_to_check_it_in_kernel
-------------------|-------|---------|-------|---------|----------------|--------------------------------------------------------------------
32_y2038_unsafe    |32     |32       |32     |32       |yes             |!IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 4
compat_y2038_unsafe|32     |32       |64     |64       |no              |IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && is_compat_task()
64_y2038_safe      |64     |64       |64     |64       |yes             |IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && !is_compat_task()

    1.  1.3.4 are the original one, we need keep the compatability. 2 is new one we need to support.
    2.  I suppose that there is no need to update time_t of timeval to time64_t(aka timeval64) in 32bit kernel. Because timeval is timeout, usually a little bit offset of realtime and is desprecated.

TODO!!!
summary            |u:arch |u:tv_sec |k:arch |k:tv_sec |is_timeval_same |how_to_check_it_in_kernel
-------------------|-------|---------|-------|---------|----------------|--------------------------------------------------------------------
32_y2038_unsafe    |32     |32       |32     |32       |yes             |!IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 4
32_y2038_safe      |32     |64       |32     |64       |yes             |!IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8
compat_y2038_unsafe|32     |32       |64     |64       |no              |IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && is_compat_task() && !COMPAT_USE_64BIT_TIME
compat_y2038_safe  |32     |64       |64     |64       |yes             |IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && is_compat_task() && COMPAT_USE_64BIT_TIME
64_y2038_safe      |64     |64       |64     |64       |yes             |IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && !is_compat_task()

    1.  1.3.5 are the original one, we need keep the compatability. 2,4 is new one we need to support.
    2.  I suppose user will update time_t in timval to time64_t. And kernel will use timespec64 instead timeval.


    Is_timeval_same: if timeval in userspace and kernel is same.

4.  TODO
    Which should I use for check compat? is_compat_task or "#ifdef CONFIG_COMPAT"?
    DONE(The original 4 is deleted): I could not check time_t is 64 or 32 in userspace from kernel. So, I could not distinguish item 3(not y2038 safe) and 4(y2038 safe). IIUC, what we want is migrate from 3 to 4. So, maybe there is another config(CONFIG_COMPAT_TIME?) to check it?
    DONE: Should I need to find a way to avoid use CONFIG_COMPAT_TIME? Avoid to use it by check COMPAT_USE_64BIT_TIME.
    need to consider big endian later.
    DONE(NO, ref note 3): Should I define `__kernel_timeval`/`timeval64` or just use the `timeval`. The latter may work but the former one is more clear.
    Do the same for: drivers/char/lp.c

5.  Add get_timeval and put_timeval to abstract the difference time_t between kernel and userspace, between y2038 safe and not.
    TODO:

6.  The old reply from maintainer.
    1.  <https://lists.linaro.org/pipermail/y2038/2015-June/000553.html>
    ```
        The problem for y2038 safety in this driver is not that the 32-bit time_t
        is insufficient because the tv_sec member here is only used to pass
        a timeout value that is at most a few seconds rather than an absolute
        time.

        Instead, we need to modify the driver so it can work with new user space
        that has set time_t to 64-bit and passes an updated structure layout.
    ```

    2.  Whether I should define timeval or array in uapi? There are different reply here. Maybe I misunderstanding the reply?
        <https://lists.linaro.org/pipermail/y2038/2015-June/000548.html>
        <https://lists.linaro.org/pipermail/y2038/2015-June/000553.html>

    3.  <https://lists.linaro.org/pipermail/y2038/2015-July/000575.html>
    ```
        I would also keep this function local to the ppdev driver, in order
        to not proliferate this to generic kernel code, but that is something
        we can debate, based on what other drivers need. For core kernel
        code, we should not need a get_timeval64 function because all system
        calls that pass a timeval structure are obsolete and we don't need
        to provide 64-bit time_t variants of them.
    ```

    4.  CLOSE: <https://lists.linaro.org/pipermail/y2038/2015-July/000584.html>
    ```
        > > Actually I think we can completely skip this test here: Unlike
        > > timespec, timeval is defined in a way that always lets user space
        > > use a 64-bit type for the microsecond portion (suseconds_t tv_usec).
        >
        > I do not familar with this type. I grep the suseconds_t in glibc, it
        > seems that suseconds_t(__SUSECONDS_T_TYPE) is defined as
        > __SYSCALL_SLONG_TYPE which is __SLONGWORD_TYPE(32bit on 32bit
        > architecture).

        Correct, but POSIX allows it to be redefined along with time_t, so
        timeval can be a pair of 64-bit values. In contrast, timespec is
        required by POSIX (and C11) to be a time_t and a 'long', which is
        why we need a hack to check the size of the second word of the
        timespec structure.
    ```

    5.  <https://lists.linaro.org/pipermail/y2038/2015-July/000572.html>
    ```
        In case of this driver, nobody would ever want to change their user
        space to use a 64-bit __kernel_timeval instead of timeval and explicitly
        call PPGETTIME64 instead of PPGETTIME, because we are only dealing with
        an interval here, and a 32-bit second value is sufficient to represent
        that. Instead, the purpose of your patch is to make the kernel cope with
        user space that happens to use a 64-bit time_t based definition of
        'struct timeval' and passes that to the ioctl.
    ```

7.  Difference between timespec and timeval.
    1.  There is no need to force userspace to migrate timeval to timeval64 because even if 32bit time is enough for timeval which is offset of the realtime(?).
        <https://lists.linaro.org/pipermail/y2038/2015-June/000553.html>

8.  send email to arnd
Hi, Arnd

I am thinking the ppdev work recently. There are something I want to discuss
with you. I am not sure if I understand my task correctly. Here, I hope I
could align with you.

My task is support ppdev driver in a y2038 safe way and keep the old binary
(y2038 unsafe) running with the kernel which do not enble y2038 support.
If I undertand correctly, when we talk about y2038 safe in user space, the
time_t is always 64bit no matter we use it standalone or embeded it to other
structure(e.g. timespec, timeval and so on)?

And, secondly, will the 32bit kernel use time64_t allover the kernel when we
say it is y2038 safe?(or on the contrast 32bit kernel do not update time_t
in timeval to time64_t?)

If then are both yes. I feel that there are the 5 cases I need to support:

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit kernel.
        compat means 32bit app running on 64bit kernel. 64 means 64bit app
        running on 64bit kernel.
    2.  1.3.5 are the original one, we need keep the compatability. 2,4 is
        new one we need to support.

You are mentioned that timeval is depercated. And I found that pingbo convert
timeval to timespec64 in his patch.
Should I follow this rule too?

Thanks in advance.

Best regards

Bamvor

9.  compile test: arm32, arm64, COMPAT_USE_64BIT_TIME=0,1

10.
Hi,

These patches try to convert user space parport driver to y2038 safe to avoid
overflow in 32bit time in year 2038.

An y2038 safe application/kernel use 64bit time_t(aka time64_t) instead of 32bit
time_t. There are the 5 cases need to support:

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit kernel.
        compat means 32bit app running on 64bit kernel. 64 means 64bit app
        running on 64bit kernel.
    2.  1.3.5 are the original one, we need keep the compatability. 2,4 is
        new one we need to support.

But it is not mean that we need to convert all the time relative struct
to 64bit. Because some time relative struct(e.g. timeval in ppdev.c) is mainly
the offset of the real time.

The main issue in ppdev.c is PPSETTIME/PPGETTIME which transfer timeval between
user space and kernel. Considering, timeval is deprecated and it is different
in 32bit and 64bit kernel. I could not rely on it to represent the correct
time.

My approach here is replace original timeval to s64[2] in ioctl definition and
then hanle the case of y2038 safe and unsafe in different types of array in
kernel.

I split to three patches to illustrate what I am doing.

The first patch add some helper for 32bit kernel to use some of compat. This
patch is useless after arnd's y2038 patch(which define the same things in
compat_time.h) is accepted.

The second patch convert parport driver to y2038 safe on 32bit kernel(case 2
in above table) and the third patch do the similar work for compat on 64bit
kernel(case 4 in above table).

10. send to y2038 mailing list
Hi,

Here is the third version for converting parport device(ppdev) to y2038 safe.
The first two version could found at [1],[2].

An y2038 safe application/kernel use 64bit time_t(aka time64_t) instead of 32bit
time_t. There are the 5 cases need to support:

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit kernel.
        compat means 32bit app running on 64bit kernel. 64 means 64bit app
        running on 64bit kernel.
    2.  1.3.5 are the original one, we need keep the compatability. 2,4 is
        new one we need to support.

There are different ways to do this. Convert to 64bit time and/or define
COMPAT_USE_64BIT_TIME 0 or 1 to indicate y2038 safe or unsafe.

But it is not mean that we need to convert all the time relative struct
to 64bit. Because some time relative struct(e.g. timeval in ppdev.c) is mainly
the offset of the real time.

The main issue in ppdev.c is PPSETTIME/PPGETTIME which transfer timeval between
user space and kernel. My approach here is handle them as different ioctl
command.

Build successful on arm64 and arm.

[1] https://lists.linaro.org/pipermail/y2038/2015-June/000522.html
[2] https://lists.linaro.org/pipermail/y2038/2015-June/000567.html

11. git send.email
```
git send-email --no-chain-reply-to --annotate --to y2038@lists.linaro.org --cc arnd@arndb.de --cc john.stultz@linaro.org --cc broonie@kernel.org *.patch
```

12. 20151115: send v4 to y2038
Hi,

Here is the fourth version for converting parport device(ppdev) to
y2038 safe. The first three could found at [1], [2], [3].

An y2038 safe application/kernel use 64bit time_t(aka time64_t) 
instead of 32bit time_t. There are the 5 cases need to support:

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit
        kernel. Compat means 32bit app running on 64bit kernel. 64
        means 64bit app running on 64bit kernel.
    2.  1.3.5 are the original one, we need keep the compatability.
        2,4 is new one we need to support.

There are different ways to do this. Convert to 64bit time and/or
define COMPAT_USE_64BIT_TIME 0 or 1 to indicate y2038 safe or unsafe.

But it is not mean that we need to convert all the time relative
struct to 64bit. Because some time relative struct(e.g. timeval in
ppdev.c) is mainly the offset of the real time.

The main issue in ppdev.c is PPSETTIME/PPGETTIME which transfer
timeval between user space and kernel. My approach here is handle them
as different ioctl command.

Build successful on arm64 and arm.

Changes since V3:
1.  create pp_set_timeout, pp_get_timeout to reduce the duplicated
    code in my patch according to the suggestion of arnd.
    I use div_u64_rem instead of jiffies_to_timespec64 because
    it could save a divide operaion.

[1] https://lists.linaro.org/pipermail/y2038/2015-June/000522.html
[2] https://lists.linaro.org/pipermail/y2038/2015-June/000567.html
[3] https://lists.linaro.org/pipermail/y2038/2015-November/001093.html

11:04 2015-11-06
----------------
sihao:

感谢帮忙. 请问下这是用哪个版本的内核测试的? 压缩包里面的README里面有需要打开的内核选项, 不好上次忘了说:p
1.  memfd用例失败的需要合入这个补丁.
    <https://lkml.org/lkml/2015/10/1/172>

2.  其余用例有没有可能帮忙分析下是成功还是失败? 可以通过看log和测试用例的返回值($?)判断.

谢谢

01:04 2015-11-10
[ACTIVITY] (Bamvor Jian Zhang) 2015-11-04 to 2015-11-10
= Bamvor Jian Zhang=

=== Highlights ===
* Y2038: ppdev
    - Work on the new version of this work.
    - Send to arnd privately on 10, Dec.
    - Found that there are same issue in driver/char/lp.c.

* GPIO kselftest/[KWG-148]
    - Discuss with Mark with my patches.
    - Update card. Not sure if I use jira correctly, please
      correct me, thanks.

* Play with my hikey board
    - Try the board from lemaker.
    - The serial do not work with serial board for both hikey early
      access board and hikey from lemaker.

* kselftest improvement/[KWG-23]
    - Get some updates from Tyler and Kevin from KS. I will work on
      provide something like kconfig things for kselftest.

=== Plans ===
* y2038
  Send new version of patches of ppdev.

* kselftest:
  Work on provide something like kconfig things for kselftest.
  The first step would provide kconfig fragments in each testcase
  so that merge_configs.sh could make use of them.

* GPIO kselftest:
  Learn how pinctrl work with gpio and try to add pinctrl support
  in my mockup driver.

14:56 2015-11-04
----------------
y2038, ppdev
------------
1.  requirement.
    1.  Do not break old applications which include arm32 application on arm32 kernel; compat and aarch64 applications on arm64 kernel.
    2.  New compiled code based on `time64_t` which include arm32 and compat.
    3.  Do not consider ilp32 at this monment?

2.  current status
    1.  Do not support compat.
    2.  There is no need to convert timeval to 64bit.

3.  Analysis in details.
        u:arch  u:time_t    k:arch  k:time_t    is_timeval_same     how_to_check_it_in_kernel
    1.  32      32          32      32          yes                 !IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 4
    2.  32      32          32      64          no                  !IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8
    3.  32      32          64      64          no                  IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && is_compat_task()
    4.  32      64          64      64          yes                 IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && is_compat_task()
    5.  64      64          64      64          yes                 IS_ENABLED(CONFIG_64BIT) && sizeof(time_t) == 8 && !is_compat_task()

    Is_timeval_same: if timeval in userspace and kernel is same.
    which should I use for check compat? is_compat_task or "#ifdef CONFIG_COMPAT"?
    I could not check time_t is 64 or 32 in userspace from kernel. I could not distinguish item 3(not y2038 safe) and 4(y2038 safe). IIUC, what we want is migrate from 3 to 4. So, maybe there is another config(CONFIG_COMPAT_TIME?) to check it?
    Should I need to find a way to avoid use CONFIG_COMPAT_TIME?
    What does the mean of COMPAT_USE_64BIT_TIME?

4.  need to consider big endian later.

14:29 2015-11-11
----------------
1:1 with mark(not used)
1.  I am in company. I could send patch with linaro.org email.
1.  Sorry I do not notice that it is during merge windows. I do not want to push Linus.

14:35 2015-11-11
----------------
kselftest, testcases, table
---------------------------
                built   x86     arm     arm64   CONFIG                                  module              other
breakpoints     S               N/A     N/A     NONE
capabilities    Y                       PASS
cpu-hotplug     Y                       PASS    CONFIG_NOTIFIER_ERROR_INJECTION=y                           run_hotplug for all cpu hotplug test
                                                CONFIG_CPU_NOTIFIER_ERROR_INJECT=m
efivarfs        Y
exec            Y                               NONE
firmware        Y                       PASS    CONFIG_TEST_FIRMWARE                    test_firmware.ko
ftrace          Y                       PASS,S  CONFIG_FTRACE
                                                #CONFIG_FTRACE_STARTUP_TEST is not set
futex           Y                       PASS    NONE
ipc             Y                       PASS    CONFIG_EXPERT=y
                                                CONFIG_CHECKPOINT_RESTORE=y                                 opensuse13.2 open it
kcmp            Y                       PASS
kdbus           N                       PASS,S  CONFIG_KDBUS
membarrier      Y                       PASS
memfd           Y       PASS            PASS
memory-hotplug  Y               SKIP    SKIP    CONFIG_MEMORY_HOTPLUG=y
                                                CONFIG_MEMORY_HOTPLUG_SPARSE=y
                                                CONFIG_NOTIFIER_ERROR_INJECTION=y
                                                CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
mount           Y                               CONFIG_USER_NS
                                                CONFIG_DEVPTS_MULTIPLE_INSTANCES(?)
mqueue          Y                       PASS
net             Y                       PASS    CONFIG_USER_NS
                                                CONFIG_BPF_SYSCALL
                                                CONFIG_TEST_BPF
powerpc         S       SKIP    SKIP    SKIP
pstore          Y                       It seems that pstore need dedicated hareware to test it.
                                                CONFIG_MISC_FILESYSTEMS=y
                                                CONFIG_PSTORE=y
                                                CONFIG_PSTORE_PMSG=y
                                                CONFIG_PSTORE_CONSOLE=y
ptrace          Y       PASS            PASS
rcutorture      N                       It seems that this testcase is not supported by kselftest framework.
seccomp         Y                       PASS    CONFIG_SECCOMP
                                                CONFIG_SECCOMP_FILTER(should be enabled after CONFIG_SECCOMP is enabled).
size            Y                       PASS    NONE
static_keys     Y                       PASS    TEST_STATIC_KEYS
sysctl          Y                       PASS    NONE
timers          Y       PASS                    NONE
user            Y                               TEST_USER_COPY
vm              S                       PASS,F  CONFIG_USERFAULTFD=y                                        compile need support the lastest unistd.h or `__NR_mlock2` is not defined.
                                        FAIL    on-fault-limit: mlockall: cannot allocate memory.
x86             S
zram            Y                       PASS    CONFIG_ZSMALLOC=y
                                                CONFIG_ZRAM=m

temp summary for the testcase I do not try:
efivarfs        Y
rcutorture

19:20 2015-11-11
----------------
kselftest, seccomp
------------------
1.
fix for commit fd88d16c58c2 ("selftests/seccomp: Be more precise with syscall arguments.")

Signed-off-by: Robert Sesek <rsesek@google.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>

git send-email --no-chain-reply-to --annotate --to linux-api@vger.kernel.org --cc rsesek@google.com --cc keescook@chromium.org --cc shuahkh@osg.samsung.com 0001-selftests-seccomp-Get-page-size-from-sysconf.patch

2.  add assert
the assert in test harmness.h could not print the negative value correctly(I intended to set page_size as "-1" to test it):
seccomp_bpf.c:497:global.KILL_one_arg_six:Expected 0 (0) < page_size (18446744073709551615)
global.KILL_one_arg_six: Test terminated by assertion

16:32 2015-11-13
----------------
kselftest, gpio
---------------
Hi, sihao

1. 打上我这两个补丁,
2. 内核打开CONFIG_GPIO_MOCKUP=m
3. 把编译出的模块包括gpio-mock.ko复制到/lib/modules/`uname -r`下对应目录.
4. toots/testing/selftest/gpio/gpio.sh复制到板子执行.
5. 如果成功, 最后会打印PASS.

谢谢

22:04 2015-11-13
----------------
kselftest, config
-----------------
1.  send to kevin, tyler and mark

These series patches try to start the work mentioned by the kevin:

"Yes, we discussed 2 things at ksummit.

1) keep test-specific kconfig fragments inside each selftest so that
an exteranl tool could use merge_configs.sh to build up a kernel that
can test the specific feature.

2) In the main menu, have an additional option/flag for each feature
that should be enabled when ksefltests are wanted.  Similar to the
CONFIG_COMPILE_TEST flag.

I hope to start a discussion on LKML soon on this subject, but for now I
suggest you follow option (1) so at least we have a good idea of which
tests require which kconfig options."

The first patch do the option 1. other patches do minor fixs for
kselftest in order to actually do these tests.

2.  send it out
`git send-email --no-chain-reply-to --annotate --to khilman@linaro.org --cc tyler.baker@linaro.org --cc broonie@kernel.org *.patch`

3.  send to upstream
Michael Ellerman <mpe@ellerman.id.au>
Darren Hart <dvhart@infradead.org>

`git send-email --no-chain-reply-to --annotate --to linux-api@vger.kernel.org --cc shuahkh@osg.samsung.com --cc khilman@linaro.org --cc tyler.baker@linaro.org --cc broonie@kernel.org --cc mpe@ellerman.id.au --cc dvhart@infradead.org  0001-selftests-create-test-specific-kconfig-fragments.patch`

4.  send minor fix to upstream
Enable two testcases in kselftest

Capabilities and ipc exist in selftest but is not enabled in the top
level Makefile. I do not know whether it is intended to.

It seems that both of them are tiny tests. These patches try to enable
them and make them build successful in cross compiling environment.

14:39 2015-11-14
----------------
kselftest, gpio, mockup
-----------------------
1.  cover letter for gpio fix
Fix bugs in the insertion of gpiochip.

These patches try to fix following bugs which is found by my gpio
mockup driver and testscript[1](will send them later):
1.  Could not check the overlap if the new gpiochip is the secondly
    gpiochip.
2.  Could not check the overlap if the new gpiochip is overlap
    with the left of gpiochip.
3.  Allow overlap of base of different gpiochip.
4.  Allow to insert an empty gpiochip

The first patch fix the first three by rewriting the logic in the
gpiochip_add_to_list.

The second patch fix the fourth bug in gpiochip_add. I do not
found the checker in gpiolib.c. Hope it is not a redundant logic.

[1] https://github.com/bjzhang/linux/tree/gpio-fix-and-mockup-driver

2.  cover letter for gpio mockup driver
RFD: Add gpio test framework

These series of patches try to add support for testing of gpio
subsystem based on the proposal from Linus Walleij.

The basic idea is implement a virtual gpio device(gpio-mockup) base
on gpiolib. Tester could test the gpiolib by manipulating gpio-mockup
device through sysfs and check the result from debugfs. Both sysfs
and debugfs are provided by gpiolib. Reference the following figure:

   sysfs  debugfs
     |       |
  gpiolib---/
     |
 gpio-mockup

Find two issues with my patch series[1]

Futher work and discussion:
1.  Test other code path(if exists).

2   Add pinctrl and interrupt support(Linus suggest trying the
    eventfd) in next steps.

3.  I feel that we could rework the debugfs in other gpiolib based
    drivers to the code in gpiolib.c with generic gpiolib_dbg_show or
    chip->dbg_show.

4.  Currently, gpio-mockup does not support the device tree. There are
    pros and cons if we do not support device tree:
    Pros: do not need to mix with the real hardware dts.
    Cons: could not test the dt_gpio_count, of_find_gpio which rely on
    device tree. And other function such like gpiod_get_index which
    rely on the correctness of the above functions.

    If we want to test the above functions, we could provide a
    dedicated device tree for gpio-mockup device which could be
    included by other device tree. And we could use device tree
    overlay to provide multiple device tree testcases.

5.  Given that this gpio test framework is based on sysfs and debugfs.
    I feel that it could be a generic gpio test script other then a
    dedicated script for gpio-mockup driver. Although, my script only
    support gpio-mockup driver at this monment.

[1] http://article.gmane.org/gmane.linux.kernel.gpio/11878

3.  send to upstream
`git send-email --no-chain-reply-to --annotate --to linux-gpio@vger.kernel.org --cc linus.walleij@linaro.org --cc broonie@kernel.org *.patch`

4.  send v2 fix to upstream
Fix bugs in the insertion of gpiochip.

The first version of these patches could be found [1].

These patches try to fix following bugs which is found by my gpio
mockup driver and testscript[1](will send them later):
1.  Could not check the overlap if the new gpiochip is the secondly
    gpiochip.
2.  Could not check the overlap if the new gpiochip is overlap
    with the left of gpiochip.
3.  Allow overlap of base of different gpiochip.
4.  Allow to insert an empty gpiochip

The first patch fix the first three by rewriting the logic in the
gpiochip_add_to_list.

The second patch fix the fourth bug in gpiochip_add. I do not
found the checker in gpiolib.c. Hope it is not a redundant logic.

Changes since v1
1.  Update comment and print according to suggestion given by Linus.
2.  Delete the dedicated checking for base overlap. The other logic
    in the patch 1/2 already cover it.

[1] http://www.spinics.net/lists/linux-gpio/msg09594.html
[2] https://github.com/bjzhang/linux/tree/gpio-fix-and-mockup-driver

11:10 2015-11-16
----------------
kselftest
---------
Hi, 思浩

我重新看了下你11月14日 9:44发给我的log:
1.  由于没打开内核选项或没安装相应的内核模块会导致下列测试失败: firmwire, net, static_keys, user, vm, zram.
    以上用例需要打开相应内核选项并安装ko重新测试.
2.  kcmp, memory-barrier我这里在qemu上测试是通过的, 麻烦你在hikey上再测试下.
3.  capabilities, ipc之前的log里面没有, 麻烦你再测试一下.
4.  memfd是最近才合入的,咱们的mainline rebase里面可能还没有. 这个先不用管.

我这里有个表格, 梳理了我在qemu的测试结果, 供你参考.

11:40 2015-11-17
----------------
kselftest, minor fix
--------------------
1.  compile test need to be done
    1.  build all the testcases:
        make -C tools/testing/selftest

    2.  build individual testcases
        make -C tools/testing/selftest TARGETS=capabilities
        make kselftest TARGETS=capabilities

2. cover letter for v2.
Clean up and enable two testcases in kselftest

These patches try to enable two testcases (capabilities and ipc) and
make them build successful in cross compiling environment.

Clean up the Makefile of capabilities according to the usage in
kselftest.

Changes since v1
1.  Update Makefile of capabilities according to Michael's suggestion.
    reference commit message for details.

3.  send
`git send-email --no-chain-reply-to --annotate --to linux-api@vger.kernel.org --cc shuahkh@osg.samsung.com --cc khilman@linaro.org --cc tyler.baker@linaro.org --cc broonie@kernel.org --cc mpe@ellerman.id.au 000*.patch`

15:43 2015-11-17
----------------
kselftest, config, v2
---------------------
1.  Michael
```
> > Before you do, do you want to try adding a top-level target that does the
> > merge, something like:
> > 
> >  $ make kselftest-mergeconfig
> > 
> > 
> > Or some other better name.

> Ok, Do you mean merge all the test config?

Yeah sorry that wasn't very clear. I meant that it would essentialy do your
logic to merge all the config fragments:

./scripts/kconfig/merge_config.sh .config tools/testing/selftests/*/config

You'll probably need to be more careful with $(srctree) vs $(objtree) etc. Have
a look at the merge_into_defconfig rule in arch/powerpc/Makefile for an
example.
```
2.  cover letter
Create specific kconfig for kselftest

There is a discussion about improving the usability of kselftest by
creating test-specific kconfig in recent kernel Summit. Furthormore,
there are different approaches to do it:

1) keep test-specific kconfig fragments inside each selftest so that
merge_configs.sh could build up a kernel that can test the specific
or all feature(s).

2) In the main menu, have an additional option/flag for each feature
that should be enabled when ksefltests are wanted.  Similar to the
CONFIG_COMPILE_TEST flag.

Patch 1/2: do option 1. Hope it is a good start for discussion.

Patch 2/2: add config option(kselftest-mergeconfig) in make file as a
helper to merge all the test config dependecies to .config.

Changes since v1:
1.  Add kselftest-mergeconfig in scripts/kconfig/Makefile according
    to the suggestion from Michael.

3.  send
`git send-email --no-chain-reply-to --annotate --to linux-api@vger.kernel.org --cc linux-kernel@vger.kernel.org --cc shuahkh@osg.samsung.com --cc khilman@linaro.org --cc tyler.baker@linaro.org --cc broonie@kernel.org --cc mpe@ellerman.id.au --cc dvhart@infradead.org  000*`

16:41 2015-11-17
----------------
Kbuild, doc
1.  $(kecho)

22:50 2015-11-17
----------------
[ACTIVITY] (Bamvor Jian Zhang) 2015-11-11 to 2015-11-17
= Bamvor Jian Zhang=

=== Highlights ===

* Y2038: ppdev
    - Send out two version of patches this week.
    - Removing the duplicated code according to the review.

* GPIO kselftest/[KWG-148]
    - Send GPIO mockup driver and gpio bug fix seperately.
    - Re-write the comment of gpio bug fix and send v2 patches. Got ack today.
    - Fix a comment in gpiolib. Got ack today.
    - Update some test cases for gpio of kselftest.
    - No update for gpio mockup driver(It is in my plan but not get chance to do it)

* kselftest improvement/[KWG-23]
    - Send three minor fix for kselftest: enable ipc and capabilities in the top level Makefile of kselftest.
    - Send patch "Create specific kconfig for kselftest" to linux-api and LKML. Add a new make target(kselftest-mergeconfig) for merging all the kernel config dependencies to .config. [2]

* Play with my hikey board
    - Try the THP on my board. It seems that there is different alignment strategy for different version of glibc.

=== Plans ===

* GPIO kselftest:
    Learn how pinctrl work with gpio and try to add pinctrl support
    in my mockup driver.

* kselftest:
    Follow up the response from upstream for my patches.

* Y2038
    Convert driver/char/lp.c to y2038 safe(it seems that no one work on it).

[1] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1021974.html

16:14 2015-11-18
----------------
kernel; glibc, arm64, ilp32
---------------------------
1.  reply to wookey "Re: [Dev] Multilib/AArch32 support on AArch64 Linux?".
Hi, Wookey

Not sure if I lost some discussion. I am very interested in ilp32.
And rfc2-v6 patches sent out today. Is there any plan to test in
linaro? And how do I know the version of patches we supported?

19:35 2015-11-18
----------------
<arnd> bamvor: when you start working on lp.c, have a look at fs/compat_ioctl.c, I think you can then remove the compat handling there once you are done with the new code

09:46 2015-11-19
----------------
test framework, kernel
----------------------
1.  gpio mockup driver: Bamvor Jian Zhang

2.  userio
    <https://lwn.net/Articles/663755/>
    ```
    This module is intended to try to make the lives of input driver developers
    easier by allowing them to test various serio devices (mainly the various
    touchpads found on laptops) without having to have the physical device in front
    of them. userio accomplishes this by allowing any privileged userspace program
    to directly interact with the kernel's serio driver and control a virtual serio
    port from there.
    ```

09:54 2015-11-19
----------------
kselftest, KBUILD_OUTPUT fix
----------------------------
1.  From kevin
    ```
    Hi Bamvor,

    If you have any more time for kselftest fixes, could you investigate
    fixing the selftest build when "make O=<dir>" is used?

    There seem to be several issues where this doesn't work properly, also
    related to the dependency of some of the tests on the 'make
    headers_install' which will put the headers into KBUILD_OUTPUT, but
    not where the kselftest make expects them.

    I think it's related, but there seem to be spots wher the selftest
    makefiles should be using $(MAKE) instead of make to inherit things
    from the parent.

    Kevin
    ```

10:37 2015-11-20
----------------
hikey, uefi
-----------
1.  could not boot after I follow the instruction in <https://github.com/96boards/documentation/wiki/HiKeyUEFI>.
debug EMMC boot: print init OK
debug EMMC boot: send RST_N .
debug EMMC boot: start eMMC boot......

I flash them twice but still failed. And I check the size of these images, found that fip is smaller that it should be.

2.  after flash the right fip:

debug EMMC boot: print init OK
debug EMMC boot: send RST_N .
debug EMMC boot: start eMMC boot......
��`�`. �� INF TEE-CORE:init_primary_helper:322: Initializing (2cdaaac #2 Thu Nov 19 07:52:57 UTC 2015 aarch64)
INF TEE-CORE:init_teecore:77: teecore inits done

3.  I found the boot-fat.uefi.img is different. Try it again:

20:29 2015-11-20
----------------
hikey
----
1.  enable earlycon on 3.18 on hikey
```
    earlycon=pl011,0xf8015000 console=ttyAMA3,115200n8 root=/dev/disk/by-partlabel/system rootwait rw
```

2.  log
    ```
     64 start hifi ok
    [    0.000000] Initializing cgroup subsys cpuset
    [    0.000000] Initializing cgroup subsys cpu
    [    0.000000] Initializing cgroup subsys cpuacct
    [    1.000000] Linux version 3.18.0+ (bamvor@linux-j170.site) (gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11) ) #2 SMP PREEMPT Thu Nov 19 14:50:51 CST 2015
    [    0.000000] CPU: AArch64 Processor [410fd033] revision 3
    [    0.000000] Detected VIPT I-cache on CPU0
    [    0.000000] Ignoring memory range 0x0 - 0x7400000
    [    0.000000] Early serial console at I/O port 0x0 (options '')
    [    0.000000] bootconsole [uart0] enabled
    [    0.000000] Memory limited to 908MB
    [    0.000000] Kernel panic - not syncing: BUG!
    [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.18.0+ #2
    [    0.000000] Call trace:
    [    0.000000] [<ffffffc000088504>] dump_backtrace+0x0/0x124
    [    0.000000] [<ffffffc000088638>] show_stack+0x10/0x1c
    [    0.000000] [<ffffffc0008025ac>] dump_stack+0x74/0xb8
    [    0.000000] [<ffffffc000800c44>] panic+0xe0/0x220
    [    0.000000] [<ffffffc000b26750>] __create_mapping+0x22c/0x2cc
    [    0.000000] [<ffffffc000b26940>] paging_init+0xfc/0x1b8
    [    0.000000] [<ffffffc000b236ec>] setup_arch+0x2b0/0x5bc
    [    0.000000] [<ffffffc000b2065c>] start_kernel+0x94/0x3b0
    [    0.000000] ---[ end Kernel panic - not syncing: BUG!
    ```

3.  
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.18.0+ (bamvor@linux-j170.site) (gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11) ) #24 SMP PREEMPT Tue Nov 24 17:04:32 CST 2015
[    0.000000] CPU: AArch64 Processor [410fd033] revision 3
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] Ignoring memory range 0x0 - 0x7400000
[    0.000000] Early serial console at I/O port 0x0 (options '')
[    0.000000] bootconsole [uart0] enabled
[    0.000000] Memory limited to 908MB
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] cma: Reserved 128 MiB at 0x0000000038000000
[    0.000000] create_mapping: start<phys: 7400000; virt: ffffffc000000000>, size: <f000>
[    0.000000] BUG: failure at arch/arm64/mm/mmu.c:149/alloc_init_pte()!
[    0.000000] Kernel panic - not syncing: BUG!
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.18.0+ #24
[    0.000000] Call trace:
[    0.000000] [<ffffffc000088504>] dump_backtrace+0x0/0x124
[    0.000000] [<ffffffc000088638>] show_stack+0x10/0x1c
[    0.000000] [<ffffffc0008025ac>] dump_stack+0x74/0xb8
[    0.000000] [<ffffffc000800c44>] panic+0xe0/0x220
[    0.000000] [<ffffffc000b26750>] __create_mapping+0x22c/0x2cc
[    0.000000] [<ffffffc000b26960>] paging_init+0x11c/0x1d8
[    0.000000] [<ffffffc000b236ec>] setup_arch+0x2b0/0x5bc
[    0.000000] [<ffffffc000b2065c>] start_kernel+0x94/0x3b0
[    0.000000] ---[ end Kernel panic - not syncing: BUG!

4.  

    ```
    diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
    index f4f8b50..8a96ed6 100644
    --- a/arch/arm64/mm/mmu.c
    +++ b/arch/arm64/mm/mmu.c
    @@ -269,6 +269,7 @@ static void __init __create_mapping(pgd_t *pgd, phys_addr_t phys,
     static void __init create_mapping(phys_addr_t phys, unsigned long virt,
                      phys_addr_t size)
     {
    +	pr_info("create_mapping: start<phys: %llx; virt: %llx>, size: <%llx>\n", phys, virt, size);
        if (virt < VMALLOC_START) {
            pr_warn("BUG: not creating mapping for %pa at 0x%016lx - outside kernel range\n",
                &phys, virt);
    diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
    index d134710..12898b2 100644
    --- a/drivers/of/fdt.c
    +++ b/drivers/of/fdt.c
    @@ -927,7 +927,7 @@ int __init early_init_dt_scan_chosen(unsigned long node, const char *uname,

     void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
     {
    -	const u64 phys_offset = __pa(PAGE_OFFSET);
    +	const u64 phys_offset = 0x7500000;

        if (!PAGE_ALIGNED(base)) {
            size -= PAGE_SIZE - (base & ~PAGE_MASK);
    ```

    ```
    [    0.000000] Initializing cgroup subsys cpuset
    [    0.000000] Initializing cgroup subsys cpu
    [    0.000000] Initializing cgroup subsys cpuacct
    [    0.000000] Linux version 3.18.0+ (bamvor@linux-j170.site) (gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11) ) #25 SMP PREEMPT Tue Nov 24 17:06:46 CST 2015
    [    0.000000] CPU: AArch64 Processor [410fd033] revision 3
    [    0.000000] Detected VIPT I-cache on CPU0
    [    0.000000] Ignoring memory range 0x0 - 0x7500000
    [    0.000000] Early serial console at I/O port 0x0 (options '')
    [    0.000000] bootconsole [uart0] enabled
    [    0.000000] Memory limited to 908MB
    [    0.000000] efi: Getting EFI parameters from FDT:
    [    0.000000] efi: UEFI not found.
    [    0.000000] cma: Reserved 128 MiB at 0x0000000038000000
    [    0.000000] create_mapping: start<phys: 7600000; virt: ffffffc000200000>, size: <38a00000>
    [    0.000000] On node 0 totalpages: 232192
    [    0.000000]   DMA zone: 3175 pages used for memmap
    [    0.000000]   DMA zone: 0 pages reserved
    [    0.000000]   DMA zone: 232192 pages, LIFO batch:31
    [    0.000000] psci: probing for conduit method from DT.
    ```

14:21 2015-11-23
----------------
linaro, gpio
1.  TODO
    1.  Q: Do I really need create my specific pinctrl, or I could make use of pinctrl-single.c?
        A: There is no device emulation in pinctrl-single.

1.  TODO:
    1.  where handle `pinctrl_gpio_range->pins` not NULL?
    1.  need test lock in gpio and pinctrl.
    1.  do we need to improve `pinctrl_check_ops`?
        1.  print more accuracy error.
        2.  check more ops?
    1.  cleanup for specific driver
        1.  the following function is duplicated with parent functions.
            ```
                static const struct pinconf_ops tegra_pinconf_ops = {
                    .pin_config_get = tegra_pinconf_get,
                    .pin_config_set = tegra_pinconf_set,
            ```
        2.  It seems that sunxi pinctrl driver do not support request gpio?
            TODO: learn how to use gpio in sunxi. If I could not use it, discuss with maintainer and submit a patch.
    1.  `pinmux_ops.gpio_set_direction` is useful when gpio set direction is handled by pinctrl subsystem.
        It seems that it is a hardware specfic function. Where it should implement depend on the module(gpio or pinctrl) which control gpio direction.

2.  `pinctrl_ready_for_gpio_range`
    do it mean we want?
    ```
        if (range->base + range->npins - 1 < chip->base ||
            range->base > chip->base + chip->ngpio - 1)
            continue;
    ```
    ```
    range->base + range->npins - 1 >= chip->base &&
    range->base <= chip->base + chip->ngpio -1
    ```
    if so, the logic seems incorrrect.


3.  "Documentation/pinctrl.txt"
    ```
    Calling pinctrl_add_gpio_range from pinctrl driver is DEPRECATED. Please see
    section 2.1 of Documentation/devicetree/bindings/gpio/gpio.txt on how to bind
    pinctrl and gpio drivers.
    ```

19:44 2015-11-23
----------------
gpio, learn
-----------
1.  `pinctrl_request_gpio`: switch the whole function to gpio mode. It is the same as just switch a pin to gpio, because after switching, user could not use that function anymore.
    E.g. request a gpio in sd(4 gpio), sd function is disable after request successful.

15:19 2015-11-24
----------------
kselftest, testcases, table, simple
-----------------------------------
                built   arm64
breakpoints     S       N/A
capabilities    Y       PASS
cpu-hotplug     Y       PASS
efivarfs        Y
exec            Y
firmware        Y       PASS
ftrace          Y       PASS,S
futex           Y       PASS
ipc             Y       PASS
kcmp            Y       PASS
membarrier      Y       PASS
memfd           Y       PASS
memory-hotplug  Y       SKIP
mount           Y
mqueue          Y       PASS
net             Y       PASS
powerpc         S       SKIP
pstore          Y
ptrace          Y       PASS
rcutorture      N
seccomp         Y       PASS
size            Y       PASS
static_keys     Y       PASS
sysctl          Y       PASS
timers          Y       PASS
user            Y       PASS
vm              S       PASS, F
x86             S
zram            Y       PASS

notes: Y: built, N: built fail, S: skip for some reason.
       PASS,S: pass with some test cases skip.
       PASS,F: pass with few test case failure.

16:17 2015-11-24
----------------
1. Step for reproduce

11:19 2015-11-25
----------------
1.  [ACTIVITY] (Bamvor Jian Zhang) 2015-11-18 to 2015-11-24
= Bamvor Jian Zhang=

=== Highlights ===
* GPIO kselftest/[KWG-148]
    - Write basic pinctrl-mockup driver which will interact with gpio-mockup driver.
    - When I wrote the code, I feel that pinctrl-single.c match the functionality I want, But it could not save the reg status in memory without acctually write(mockup driver need this). May I could make use of regmap?
    - There will be lots configuration things in gpio and pinctrl mockup drivers. It would be useful if I could use devicetree during module insertion(I do not want to impact the real system). Need think about it later.

* kselftest improvement/[KWG-23]
    - Five patches ack by Shuah will be included in 4.5 rc1.
    - "Create specific kconfig for kselftest"[1]
    - "Clean up and enable two testcases in kselftest"

* Play with my hikey board
    - Run kselftest on 3.18 with the patches "Create specific kconfig for kselftest".
    - kernel hangs with above config while It could boot on qemu. With the default defconfig it boot successful on hikey and qemu.

* arm32 team meeting.

=== Plans ===
* GPIO kselftest:
    Continue working support pinctrl mockup driver.

* Y2038
    Convert driver/char/lp.c to y2038 safe.

[1] http://www.spinics.net/lists/linux-api/msg15593.html

2.  pending
    1.  ppdev patch review.

3.  Send to Mark
    Hi, if you have time, I hope I could discuss with you about map gpio mockup driver works. I hope I could make use of regmap, but I am not sure about it.


17:06 2015-11-25
----------------
1.
My internet vendor is "Beijing gehua CATV network" who need to buy the international bandwidth from other vendor(e.g. China telcom). The result is as follows:
sever                       25, Nov                 26, Nov         27, Nov         30, Nov
git-ap.linaro.org           1.99 MiB/s              1.90 MiB/s      2.00 MiB/s      2.20 MiB/s
git-ap-aryaka.linaro.org    Connection timed out    1.12 MiB/s      1.12 MiB/s      1.12 MiB/s
git-us.linaro.org           273.00 KiB/s            173.00 KiB/s    179.00 KiB/s    231.00 KiB/s
git-us-aryaka.linaro.org    1.07 MiB/s              1.04 MiB/s      1.11 MiB/s      1.11 MiB/s

```
:'<,'>s/^git.clone..v.ssh...git@\(git.*\.org\).*\.git\nReceiving.objects..100...[0-9]*\/[0-9]*.,.[0-9.]*\ MiB\ |\ \([0-9]*\.[0-9]*\ [KM]iB\/s\),.done.$/\1 \2/gc
```

2.  reply to Philip Colmer
Hi, Philip

I definitely want to help on this. But I do not understand why I am the worst. I found that there are lots of people slower than me.
Take git-us-aryaka.linaro.org example, fengwei.yin, hanjun guo, jun nie, junlin.quan are slower then me.

Regards

Bamvor

12:56 2015-11-26
----------------
mockup, gpio, pinctrl
---------------------
1.  discuss with Mark:
    ```
    > A MMIO regmap backed by dynamically allocated memory should do the job there.
    Do you mean add MMIO regmap support in pinctrl-single?
    I could allocate the buf and call
    regmap_init_mmio(dev, buf, &buf_regmap_config) in pinctrl-single and
    replace all the read/write to regmap_read/write or their variants.
    But I found that some of read/write is not protected by lock. Which
    regmap function should I used in this case?

    Assume that I have already convert pinctrl-single to regmap way, I need dt
    test pinctrl sub system as well as gpio sub system. I feel that I should
    pass them to kernel in runtime instead of boot time. But how?
    ```

2. no lock read in pinctrl-single
pcs_request_gpio
pcs_pinconf_get
pcs_add_pin

3.  Discuss with Linus
    ```
    > I'm sorry for not having had time to look at the patches yet, as I've been
    > deeply focused on other stuff.
    Understand. My confusion is not about the patches I already sent. I have no
    idea how to test the pinctrl part with minimum duplicated code. After I
    could test the pinctrl subsystem, I could test the interaction between
    gpio and pinctrl. Am I in the right direction?
    >
    > Spontaneously I don't think the testing mock drivers should have device
    > tree bindings (as they are Linux-specific) at all. DT is hardware
    > descriptions.
    Device tree could help test the corner test in pinctrl as well as
    interacting with my gpio mockup driver. If I only want to test gpio mockup
    driver seperatedly, I do not need the device tree.
    ```

16:36 2015-11-26
----------------
arm64, kernel, ftrace
---------------------
Ftrace问题可以打上这个补丁试下:
"[PATCH] arm64: kernel: pause/unpause function graph tracer in cpu_suspend()"
original discussion: "arm64 function_graph tracer panic with CONFIG_DYNAMIC_FTRACE"

18:23 2015-11-26
----------------
kernel, gpio, pinctrl, mockup
-----------------------------
Hi, Mark, Linus

I arm confused about my gpio mockup driver. Maybe I need to re-focus about what
I need to do.

What I should do is creae a mockup driver to testing more functionality in gpio
sub system.

There is already a basic gpio mockup driver which support multiple gpiochip
(during review). Other function should support:
1.  support request/free of a gpio. which could do in the different ways:
    1.  Write a dedicated gpio request and free function for testing.
    2.  Write a simple pinctrl mockup driver to testing the generic api
        pinctrl_request_gpio/pinctrl_free_gpio. Such pinctrl mockup driver
        need to support different parameter(through module parameter) for
        testing the corner case.
        E.g. A. gpio range is same as pinctrl range.
             B. gpio range is different from pinctrl range.
             C. gpio pins is discrete.
    3.  Reuse the existing pinctrl drivers. E.g. re-use the pinctrl-single
        in order to test all the pinctrl sub system.
        pinctrl-single need to work with device tree. I would like to use
        device tree overlay to provide different test cases. But I am not if
        a mockup driver should use the device tree. User may not like insert
        the test purpose device tree with the hardware specific dt.

2.  Support interrupt. Linus suggest me try the eventfd. I do not investigate
    it right now.

Regards

Bamvor

11:36 2015-11-27
----------------
kernel, gpio, mockup; devicetree, overlay, unittest
---------------------------------------------------
1.  reply to Mark:
    ```
    > I'd expect it should be possible to just use the chardev interface that Linus has been working on here - if it can satisfy all the "real" userspace GPIO/pinctrl users it should also be doing most if not all of what a test driver would need. That'd also provide something for the people who need a better interface than sysfs currently provides.
    Understand. I just read the patches(v1). According to the 3/6 and 5/6, it only
    support read gpiochip info:
        ```
        #define GPIO_GET_CHIPINFO_IOCTL _IOR('o', 0x01, struct gpiochip_info)
        ```
    Do you mean I should read gpiochip information from chardev interface when it exists?

    > We've discussed overlays before - some other test code is doing that, it might work here and only require minimal updates to the existing bindings rather than a completely new binding.
    Yeap. Glad to know this. Do you mean something like
    drivers/of/unittest-data/test*.dts(i)? I will learn it later.
    > There is also the possibility of implementing platform data but like you've said elsewhere that's quite invasive for the current code since it unfortunately only supports DT systems.
    Yeap.
    ```

15:21 2015-11-27
----------------
1.  Kevin
    ```
    Hi Bamvor,

    If you have any more time for kselftest fixes, could you investigate
    fixing the selftest build when "make O=<dir>" is used?

    There seem to be several issues where this doesn't work properly, also
    related to the dependency of some of the tests on the 'make
    headers_install' which will put the headers into KBUILD_OUTPUT, but
    not where the kselftest make expects them.

    I think it's related, but there seem to be spots wher the selftest
    makefiles should be using $(MAKE) instead of make to inherit things
    from the parent.

    Kevin
    ```
2.  KBUILD_OUTPUT is not work for perf. But O=dir works.
3.  perf_clean do not work. Do I need to fix it?
    ```
    bamvor@linux-j170:~/works/source/kernel/linux> log.sh make -C tools/ perf_clean  O=`pwd`/../build
    make: Entering directory '/home/bamvor/works_ssd/source/kernel/linux/tools'
      DESCEND  perf
    make[1]: Entering directory '/home/bamvor/works_ssd/source/kernel/linux/tools/perf'
      CLEAN    libtraceevent
      CLEAN    libapi
      CLEAN    libbpf
      CLEAN    config
    /bin/sh: line 0: cd: /home/bamvor/works_ssd/source/kernel/build/perf/perf/: No such file or directory
    ../../scripts/Makefile.include:16: *** output directory "/home/bamvor/works_ssd/source/kernel/build/perf/perf/" does not exist.  Stop.
    Makefile.perf:430: recipe for target '/home/bamvor/works_ssd/source/kernel/build/perf//../lib/api/libapi.a-clean' failed
    make[2]: *** [/home/bamvor/works_ssd/source/kernel/build/perf//../lib/api/libapi.a-clean] Error 2
    make[2]: *** Waiting for unfinished jobs....
    /bin/sh: line 0: cd: /home/bamvor/works_ssd/source/kernel/build/perf/perf/: No such file or directory
    /bin/sh: line 0: cd: /home/bamvor/works_ssd/source/kernel/build/perf/perf/: No such file or directory
    ../../scripts/Makefile.include:16: *** output directory "/home/bamvor/works_ssd/source/kernel/build/perf/perf/" does not exist.  Stop.
    ../../scripts/Makefile.include:16: *** output directory "/home/bamvor/works_ssd/source/kernel/build/perf/perf/" does not exist.  Stop.
    Makefile.perf:437: recipe for target '/home/bamvor/works_ssd/source/kernel/build/perf/libbpf.a-clean' failed
    make[2]: *** [/home/bamvor/works_ssd/source/kernel/build/perf/libbpf.a-clean] Error 2
    Makefile.perf:420: recipe for target '/home/bamvor/works_ssd/source/kernel/build/perf/libtraceevent.a-clean' failed
    make[2]: *** [/home/bamvor/works_ssd/source/kernel/build/perf/libtraceevent.a-clean] Error 2
    Makefile:75: recipe for target 'clean' failed
    make[1]: *** [clean] Error 2
    make[1]: Leaving directory '/home/bamvor/works_ssd/source/kernel/linux/tools/perf'
    Makefile:132: recipe for target 'perf_clean' failed
    make: *** [perf_clean] Error 2
    make: Leaving directory '/home/bamvor/works_ssd/source/kernel/linux/tools'
    ```

19:18 2015-12-02
----------------
linaro, arm32 meeting
---------------------
1.  y2038 work: convert printer code to y2038 safe. Will send it out after I come back home.
2.  I eventually found the arnd review which tagged by junk(I do not know why). I will send the new version to list later.
3.  gpio mockup driver: discuss with Linus and Mark about my work. Not acctually coding this week.
4.  It takes sometime for me to try to do kselftest on my hikey board.

20:26 2015-12-02
----------------
y2038, kernel, printer, lp.c
----------------------------
1.  v1, cover letter
    char/lp: convert to y2038 safe

    The y2038 issue of printer exist in the time_t of timeval in ioctl
    LPSETTIME. This patch try to convert it to y2038 safe by the
    following steps:
    1.  Remove timeval from lp_set_timeout in order to support 32bit and
        64bit time_t in the same function without the new definition
        of timeval64 or something else.
    2.  Handle both 32bit and 64bit time in the same LPSETTIMEOUT switch
        case in order to support y2038 safe and non-safe cases.
    3.  Merge compat of LPSETTIMEOUT into non-comapt one.

2.  Arnd reply to me
> Given that long is 64bit in 64bit architecture, shall I keep tv_sec as s64
> and cast HZ to s64 as well?
> +       to_jiffies += tv_sec * (s64)HZ;

I would just leave tv_sec as 'long' then.

You don't need a cast for HZ at all.

Neither of them is important, since it only matters if the timeout is
more than 50 days, and that is not a setting we need to worry about.

--------------
Notes: 强制类型转换是同宽度有符号转为无符号, 小宽度转为大宽度.


20:52 2015-12-04
----------------
Test command: git clone -v ssh://git@git-ap.linaro.org/boot/u-boot-linaro-stable.git
Test command: git clone -v ssh://git@git-ap-aryaka.linaro.org/boot/u-boot-linaro-stable.git
Total size: 53.03MiB

                04, Dec
git-ap-aryaka   1.12 MiB/s
git-ap          61.00 KiB/s

21:04 2015-12-04
----------------
1.
Here is the fifth version for converting parport device(ppdev) to
y2038 safe. The first four could found at [1], [2], [3], [4].

An y2038 safe application/kernel use 64bit time_t(aka time64_t)
instead of 32bit time_t. There are the 5 cases need to support:

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

notes:
    1.  xxx_y2038_safe/unsafe. 32 means app running on the 32bit
        kernel. Compat means 32bit app running on 64bit kernel. 64
        means 64bit app running on 64bit kernel.
    2.  1.3.5 are the original one, we need keep the compatability.
        2,4 is new one we need to support.

There are different ways to do this. Convert to 64bit time and/or
define COMPAT_USE_64BIT_TIME 0 or 1 to indicate y2038 safe or unsafe.

But it is not mean that we need to convert all the time relative
struct to 64bit. Because some time relative struct(e.g. timeval in
ppdev.c) is mainly the offset of the real time.

The main issue in ppdev.c is PPSETTIME/PPGETTIME which transfer
timeval between user space and kernel. My approach here is handle them
as different ioctl command.

Build successful on arm64 and arm.

Change since v4:
1.  change type of tv_sec and tv_usec to s64 in pp_set_timeout.
    Use s64 could avoid s64 cast to s32 in arm 32bit.

Changes since V3:
1.  create pp_set_timeout, pp_get_timeout to reduce the duplicated
    code in my patch according to the suggestion of arnd.
    I use div_u64_rem instead of jiffies_to_timespec64 because
    it could save a divide operaion.

[1] https://lists.linaro.org/pipermail/y2038/2015-June/000522.html
[2] https://lists.linaro.org/pipermail/y2038/2015-June/000567.html
[3] https://lists.linaro.org/pipermail/y2038/2015-November/001093.html
[4] https://lists.linaro.org/pipermail/y2038/2015-November/001132.html

2.
`git send-email --no-chain-reply-to --annotate --to y2038@lists.linaro.org --cc arnd@arndb.de --cc broonie@kernel.org *.patch`

3.
Here is the sixth version for converting parport device(ppdev) to
y2038 safe. The first four could found at [1][2][3][4][5].

An y2038 safe application/kernel use 64bit time_t(aka time64_t)
instead of 32bit time_t. Given that some time relative struct(e.g.
timeval in ppdev.c) is mainly the offset of the real time, the old
32bit time_t in such application is safe. We need to handle the
32bit time_t and 64bit time_t application at the same time.

My approach here is handle them as different ioctl command for
different size of timeval.

Build successful on arm64 and arm.

Changes since v5:
1.  Replace PP[GS]ETTIME_safe/unsafe with PP[GS]ETTIME32/64.
2.  Rewirte PPSETTIME ioctl with jiffies_to_timespec64 in order to
    replace user fake HZ(TICK_USEC) to kernel HZ(TICK_NSEC).
3.  define tv_sec as long and tv_usec as int in pp_set_timeout. It
    should be enough for the timeout.

Change since v4:
1.  change type of tv_sec and tv_usec to s64 in pp_set_timeout.
    Use s64 could avoid s64 cast to s32 in arm 32bit.

Changes since V3:
1.  create pp_set_timeout, pp_get_timeout to reduce the duplicated
    code in my patch according to the suggestion of arnd.
    I use div_u64_rem instead of jiffies_to_timespec64 because
    it could save a divide operaion.

[1] https://lists.linaro.org/pipermail/y2038/2015-June/000522.html
[2] https://lists.linaro.org/pipermail/y2038/2015-June/000567.html
[3] https://lists.linaro.org/pipermail/y2038/2015-November/001093.html
[4] https://lists.linaro.org/pipermail/y2038/2015-November/001132.html
[5] https://lists.linaro.org/pipermail/y2038/2015-December/001201.html

4.  sent to LKML
    1.  Do not add reviewed-by arnd. Arnd will add it in LKML.
    2.  Do list all the revision(too much revision).
    3.
These series of patches try to convert parport device(ppdev) to
y2038 safe, and support y2038 safe and unsafe application at the
same time. There were some discussions in y2038 mailing list[1].

An y2038 safe application/kernel use 64bit time_t(aka time64_t)
to avoid 32-bit time types broken in the year 2038. Given that
some time relative struct(e.g. timeval in ppdev.c) is mainly the
offset of the real time, the old 32bit time_t in such application
is safe. We need to handle the 32bit time_t and 64bit time_t
application at the same time. My approach here is handle them as
different ioctl command for different size of timeval.

Build successful on arm64 and arm.

[1] https://lists.linaro.org/pipermail/y2038/

5.  Send to LKML
Arnd Bergmann <arnd@arndb.de> (supporter:CHAR and MISC DRIVERS)
Greg Kroah-Hartman <gregkh@linuxfoundation.org> (supporter:CHAR and MISC DRIVERS)
Sudip Mukherjee <sudipm.mukherjee@gmail.com> (maintainer:PARALLEL PORT SUBSYSTEM)
linux-kernel@vger.kernel.org (open list)

`git send-email --no-chain-reply-to --annotate --to linux-kernel@vger.kernel.org --cc y2038@lists.linaro.org --cc gregkh@linuxfoundation.org -cc arnd@arndb.de --cc sudipm.mukherjee@gmail.com --cc broonie@kernel.org *.patch`

23:17 2015-12-04
----------------
Question about upstream of ILP32
Hi, Mark, Arnd

1.  v3 vs v6?
2.  when upstream or when abi is stable?

09:54 2015-12-05
----------------

summary            |u:arch |u:tv_sec |k:arch |k:tv_sec
-------------------|-------|---------|-------|--------
32_y2038_unsafe    |32     |32       |32     |32
32_y2038_safe      |32     |64       |32     |64
compat_y2038_unsafe|32     |32       |64     |64
compat_y2038_safe  |32     |64       |64     |64
64_y2038_safe      |64     |64       |64     |64

21:41 2015-12-07
----------------
1.  [ACTIVITY] (Bamvor Jian Zhang) 2015-11-25 to 2015-12-03
= Bamvor Jian Zhang=

=== Highlights ===
* kselftest improvement/[KWG-23]
    - Try to fix the KBUILD_OUTPUT issue for kselftest. It seems that I should write a make file like tools/perf/Makefile.perf to do it?

* Y2038
    - Send new version of parport device and printer and get useful feedback from maintainers.

* arm32 team meeting.

=== Plans ===
* GPIO kselftest:
    Continue working support pinctrl mockup driver.

* Y2038
    Convert driver/char/lp.c to y2038 safe.

22:07 2015-12-07
1.
Hi all

I'm pleased to say that the testing of the Aryaka network went very well next week. The average speed that people got from the downloads were better than if I tested it from Cambridge!

For comparison, we now need to check going through Aryaka's Hong Kong POP instead of China.

Please repeat the exact steps as before - four git downloads and four speeds.

Please test daily if possible and email me the results.

Many thanks.

Philip

2.
My internet vendor is "Beijing gehua CATV network" who need to buy the international bandwidth from other vendor(e.g. China telcom). The result is as follows:
sever                       07, Dec
git-ap.linaro.org           86.00 KiB/s
git-ap-aryaka.linaro.org    641.00 KiB/s
git-us.linaro.org           37.00 KiB/s
git-us-aryaka.linaro.org    606 KiB/s

17:17 2015-12-10
1.  Introduction for hikey and 96boards.
    1.  take picture(from 96boards.org) for hikey and dragon 410c.
        e.g. https://www.96boards.org/products/ce/hikey/start/

1.  Introduction for hikey: hikey feature list.
    reference: <http://www.cnx-software.com/2015/02/09/hikey-board-64-bit-arm-development-board/>

1.  Hikey resource list
    1.  add table for the follow links
    hikey https://github.com/96boards/documentation/wiki/HiKey
    uefi: https://github.com/96boards/documentation/wiki/HiKeyUEFI
    kernel source: https://github.com/96boards/linux/tree/hikey-mainline-rebase

1.  upstream status: already upstream
    1.  bootloader: uefi
    2.  kernel:
        1.  basic dts of hi6330, clk, psci, uart
        2.  power management: cpufreq, cpuidle, mailbox
        3.  other: spi, emmu(exclude hi speed).

1.  upstream status: already ack by maintainer
    gpio、pinctrl, i2c, tsensor, reset

1.  upstream status: in process:
    1.  power management: pmic, mtcmos, regulator
    2.  display
        1.  DRM
        2.  hdmi audio
        3.  HDMI adv7533: by 96boards community.
    3.  usb host, otg.
    4.  smmu/ion.
    5.  coresight.

1.  introduction arduino
    referecen arduino.cc

1.  hikey sensor kit(will send picture to you later).

1.  How to use relay from hikey.(will send picture to you later).

14:29 2015-12-14
----------------
sever                       1           2           3
git-ap.linaro.org           1.19 MiB/s  2.49 MiB/s  1008 KiB/s
git-ap-aryaka.linaro.org    958 KiB/s   946 KiB/s   945 KiB/s
git-us.linaro.org           357 KiB/s   292 KiB/s   1.33 MiB/s
git-us-aryaka.linaro.org    623 KiB/s   907 KiB/s   878 KiB/s

15:30 2015-12-16
----------------
kernel, device, driver, bind, unbind
------------------------------------
Manual driver binding and unbinding
<https://lwn.net/Articles/143397/>
echo -n "1-1:1.0" > /sys/bus/usb/drivers/ub/unbind

18:37 2015-12-17


 userspace |  kernel  | `__BITS_PER_SIZE_T` | `__BITS_PER_LONG`
-----------|----------|---------------------|------------------
    32     |    32    |         32          |       32
    32     |    32    |         64          |       32
    32     |    64    |         32          |       32
    32     |    64    |         64          |       32
    64     |    64    |         64          |       64
           |          |                     |

           |          |                     |

16:37 2015-12-21
----------------
Hi, I have a fews questions about THP(Transparent Huge Page). Hope it is not off-topic.
I found that arm64 consume more than 100-200MBytes memory than x86_64 when THP set to always.
And this could be 'fixed' by the alignment the memory allocation code from arm64 to x86_64, the patches is here:
1.  revert part of commit 41b8189 ("Handle ARENA_TEST correctly")
diff --git a/malloc/arena.c b/malloc/arena.c
index 26e9dfd..9738629 100644
--- a/malloc/arena.c
+++ b/malloc/arena.c
@@ -884,7 +884,7 @@ arena_get2 (mstate a_tsd, size_t size, mstate avoid_arena)
          narenas_limit is 0.  There is no possibility for narenas to
          be too big for the test to always fail since there is not
          enough address space to create that many arenas.  */
-      if (__glibc_unlikely (n <= narenas_limit - 1))
+      if (__glibc_unlikely (n < narenas_limit))
         {
           if (catomic_compare_and_exchange_bool_acq (&narenas, n + 1, n))
             goto repeat;


2.  Define the MULTI_PAGE_ALIASING
diff --git a/sysdeps/aarch64/stack-aliasing.h b/sysdeps/aarch64/stack-aliasing.h
new file mode 100644
index 0000000..ced9f69
--- /dev/null
+++ b/sysdeps/aarch64/stack-aliasing.h
@@ -0,0 +1,7 @@
+/* Follow the definition from x86 in order to reduce the number of
+   THP when create a new thread. */
+/* What is useful is to avoid the 64k aliasing problem which reliably
+   happens if all stacks use sizes which are a multiple of 64k.  Tell
+   the stack allocator to disturb this by allocation one more page if
+   necessary.  */
+#define MULTI_PAGE_ALIASING     65536

3.  There were some discuss in glibc mailiing list, but I do not get the point.
[[RFC] malloc: a question about arena_get2()](https://sourceware.org/ml/libc-alpha/2015-12/msg00029.html)
[hi, I have a question about "MULTI_PAGE_ALIASING" in allocate_stack()](https://sourceware.org/ml/libc-alpha/2015-12/msg00444.html)

I am very appreciated if I could not get some suggestions.

17:37 2015-12-21
----------------
1.  [ACTIVITY] (Bamvor Jian Zhang) 2015-12-14 to 2015-12-18
= Bamvor Jian Zhang=

=== Highlights ===
* Y2038
    - Send new version of parport device to LKML.

* 1:1 with Mark.

* Hikey
    - Try to do the automating flash kernel and OTG unplugging according to the method 2 from kevin[1]. The basic function works.

=== Plans ===
* Y2038
    Convert driver/char/lp.c to y2038 safe.

[1] https://docs.google.com/document/d/1tCbC7gCRAIvmqXkePqMK-fLL0jfE3EPk3zW_u9x4YZw/

11:53 2015-12-24
----------------
y2038, printer, lp
------------------
1.  reply to arnd
    Hi, arnd

    I am trying to follow your suggestion. But I do not understand why
    `__BITS_PER_SIZE_T` is relative to sizeof(time_t). And I also tried to use
    `__BITS_PER_TIME_T` according to the following table.

    ```
    /*
     *  userspace |  kernel  | `__BITS_PER_TIME_T` | `__BITS_PER_LONG` | `__BITS_PER_TIME_T` <= `__BITS_PER_LONG`
     * -----------|----------|---------------------|-------------------|------------------------------------------
     *     32     |    32    |         32          |       32          |                    true
     *     32     |    32    |         64          |       32          |                    false
     *     32     |    64    |         32          |       32          |                    true
     *     32     |    64    |         64          |       32          |                    false
     *     64     |    64    |         64          |       64          |                    true
     */
    #if __BITS_PER_TIME_T <= __BITS_PER_LONG
    #define LPSETTIMEOUT 0x060f /* set parport timeout */
    #else
    #define LPSETTIMEOUT _IOW(0x06, 0x0f, struct timeval)
    #endif
    ```
    As you know, there is no `__BITS_PER_TIME_T` as well. Finally, I thought I could
    make use of `__USE_TIME_BITS64` which mentioned in
    <https://sourceware.org/glibc/wiki/Y2038ProofnessDesign>

    How about something like this?
    ```
    #if defined(__USE_TIME_BITS64) && __BITS_PER_LONG == 32
    #define LPSETTIMEOUT _IOW(0x06, 0x0f, struct timeval)
    #else
    #define LPSETTIMEOUT 0x060f /* set parport timeout */
    #endif
    ```

2.  reply to arnd
> Yes, this is what I meant. Unfortunately, we have not agreed on
> what we are going to call that macro, but this is roughly how it
> should work.
Got you, could I use __USE_TIME_BITS64 in my patch right now?
Or should I need to wait for this agreement?

> However, the definition you have here is only correct
> for user space, not for the kernel itself, which needs a slightly
> different definition when __KERNEL__ is defined and 'struct timeval'
> has been removed from the kernel.
Yeap, I am thinking it is header for uapi. I will define LPSETTIMEOUT64 in
driver/char/lp.c:
#define LPSETTIMEOUT64	_IOW(0x06, 0x0f, s64[2])

Is it make sense?

Regards

Bamvor

17:50 2015-12-24
----------------
kernel, kselftest, mergeconfig
------------------------------
1.  reply to Michael
    Hi, Michael

    Do you mean "tools/testing/selftest/Makefile"? I try to do it but I could not
    get the objtree and srctree if it is called directly(objtree and srctree is
    defined in toplevel Makefile)
    > make -C tools/testing/selftests kselftest-mergeconfig
    make: Entering directory '/home/bamvor/works/source/kernel/linux/tools/testing/selftests'
    Makefile:112: *** No .config exists, config your kernel first!.  Stop.
    make: Leaving directory '/home/bamvor/works/source/kernel/linux/tools/testing/selftests'

    Suggestions?

    Regards

    Bamvor

14:40 2015-12-25
----------------
kernel, kselftest, KBUILD_OUTPUT

Hi,

I am trying to support KBUILD_OUTPUT(O=xxx) for kselftest. And I found that


