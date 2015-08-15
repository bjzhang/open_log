
<https://wiki.archlinux.org/index.php/Solid_State_Drives>
<https://wiki.debian.org/SSDOptimization>

1.  rotational is zero means it is a ssd, reference: <http://stackoverflow.com/questions/20372544/what-is-the-significance-of-queue-rotational-in-linux>, <http://lwn.net/Articles/408428/>
    ```
    > grep . /sys/block/sd?/queue/rotational
    /sys/block/sda/queue/rotational:1
    /sys/block/sdb/queue/rotational:0
    ```

1.  Whether support trim or not
    ```
    > sudo hdparm -I /dev/sdb | grep TRIM
               *    Data Set Management TRIM supported (limit 8 blocks)
               *    Deterministic read ZEROs after TRIM
    ```

1.  btrfs mount options

    1.  http://unix.stackexchange.com/questions/37980/partition-mounted-noexec-even-though-not-specified-in-etc-fstab
        ```
        I believe that, as a security feature, anything with user in the fstab is automatically mounted noexec unless exec is explicitly given in the fstab.
        ```
    2.  mount options with user:
        > mount|grep ssd
        /dev/sdb2 on /home/bamvor/works_ssd type btrfs (rw,nosuid,nodev,noexec,relatime,ssd,discard,space_cache,user)
    3.  mount options without user:
        > mount|grep ssd
        /dev/sdb2 on /home/bamvor/works_ssd type btrfs (rw,noatime,ssd,discard,space_cache)

1.  IO scheduler
    1.  onetime
        echo noop > /sys/block/sdX/queue/scheduler

    2.  udev
        /etc/udev/rules.d/60-schedulers.rules
        # set deadline scheduler for non-rotating disks
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

1.  test result
    1.  build kernel on ssd
        2:12 2:00 2:03 avg 2:05
    2.  build kernel on hdd
        2:42 2:14 2:25 avg 2:27

    3.  test command
        ```
        > cat build_v8.sh
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean &&
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig &&
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image dtbs -j8 &&\
        export INSTALL_HDR_PATH=./usr/include &&\
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C tools/testing/selftests
        make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C tools/testing/selftests install
        ```

