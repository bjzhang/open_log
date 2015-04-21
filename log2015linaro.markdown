
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

