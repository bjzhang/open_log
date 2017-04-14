
21:40 2017-03-21
----------------
activity

git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2017-03-06 to 2017-03-21

*  06, March to 10, March: Join linaro connect in budapest. Learn/discuss the follow things:
    *   Discuss coresight with Mathieu and Mike Leach.
    *   Discuss with tcwg, arm and Cavium about how to enable v8.1, v8.2 in filesytem respectively.
        At the beginning, it is make sense that make use of ifunc to hook the lse instruction in glibc library. It turns out that ifunc is too heavy to do this job. It seems there is no better way to do it.
    *   Chat with Alex graf and Andrew Farber from suse about open build service and 96 board enablement.

*   TEE
    Help debug the memory access issue between non-secure and secure world. Eventually, we found that it is because the ns bit in page table.

*   Coresight
    Read the coresight driver, especially the tmc part.

*   Kselftest
    try to fix the regression introduced by my patch. The reasone is build one testcase of x86 will bypass the top level Makefile of kselftests.

17:22 2017-03-22
----------------
arm32, meeting
--------------
1.  arnd: build kernel with distcc in arm machine farm.

last thing from me, I've done some more analysis on the requirements of my build machine, trying to come up with a theoretical analysis of what kind of cheap ARM devboards I could use to get similar performance with lower power
My current estimate is that I'd need only 24 quad-core cortex-a53 boards with 1GB RAM each, but there are lots of downsides to doing that
<bamvor> Bamvor Jian Zhang do you mean the socionext 24core A53 board? 
A<arnd> bamvor: no, I would need four of those boards, with 16GB RAM each for the CPU performance, but if I did that, I'd probably run into network bandwidth limits
and memory bandwidth
an interesting find is that 80% of the build time can be parallelized for the kernel with distcc, which is better than I thought

2.  binoy: dm-crypt performance test. It downgrade except sequential writes with "bonnie". The reason of downgraion is because the lack of dm crypt hw in arm(410c).

3.  baolin:
    1.  extcon
    2.  vbus notification.
USB GPIO Extcon device: This is a virtual device used to generate USB cable states from the USB ID pin
connected to a GPIO pin.

09:20 2017-04-04
----------------
activity

git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2017-03-22 to 2017-04-04

=== Highlights ===
*   Coresight
    Discuss with Mathieu and Mike Leach.

*   Kselftest
    Send two patches to fix the regression introduced by my patch.
    Review the patch from Fathi Boundra.

*   1:1 with Mark Brown

*   Huawei internal work

*   op-tee
    Discuss with jerome.forissier@linaro.org about op-tee. The op-tee driver will be merged in 4.12. I am thinking if I could help on improving the op-tee driver.

=== Plans ===
*   Kselftest
    Test all the testcases in kselftest in x86 and arm64. Fathi may work on this. Confirm before work on it.

*   KWG-192
    Discuss with Arnd and Mark about this work. Whether it is worth to place the contiguous hint in exeve.

=== Travel/Out ===
    2, April to 4, April for Qingming Festival(also known as Tomb-Sweeping Day)

10:49 2017-04-14
----------------
KWG-225
-------
Mark to me:
It's about using signatures to verify that the firmware we're loading is authorized at all - basically a firmware counterpoint to signed modules for systems that want this either for security reasons or just to make sure we're using a single system image for regulatory reasons. Currently we just don't do any verification at all.
