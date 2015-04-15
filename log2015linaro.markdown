
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

