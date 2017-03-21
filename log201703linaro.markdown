
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

