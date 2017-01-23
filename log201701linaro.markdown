
11:49 2017-01-03
----------------
GTD
---
1.  today
    1.  There is discussion about ILP32 merged. Process and send out the performance report.
        1.  Test huawei benchmark.
            14:49-
        2.  Test specint and lmbench.
        3.  Process the existing benchmark.
    2.  do_wp_page.

15:03 2017-01-04
----------------
GTD
---
1.  today
    1.  There is discussion about ILP32 merged. Process and send out the performance report.
        1.  Test huawei benchmark. Test specint and lmbench.
            It takes 24 hours to test benchmark project. I do not why it takes so much time. Check the result later.
        2.  Check the result of specint and lmbench in hikey.
            15:08-15:12 evaluate the time.
            specint: est. 5min.
                16:12-
            lmbench: est. 10min.
                15:12-15:40 Get first stage result in lmbench.
                16:00-16:12 The result is too bad. Check specint.
    1.  What is the difference between lmbench3 and lmbench-3-a9?

16:05 2017-01-04
----------------
1.  ILP32_disable_aarch32
    The result is too bad. Check specint.
    1.  Processor, Processes - times in microseconds - smaller is better
        stat: 5.14%
        fork-proc: -5.54%
    2.  Should not be difference:
        1.  Basic integer operations - times in nanoseconds - smaller is better
        2.  Basic uint64 operations - times in nanoseconds - smaller is better
    3.  Context switching - times in microseconds - smaller is better
        -------------------------------------------------------------------------
        Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                                 ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
        --------- ------------- ------ ------ ------ ------ ------ ------- -------
        localhost Linux 4.9.0-1 11.6 27.8500   24.0260 30.9   10.2 22.49200    31.0
        localhost Linux 4.9.0-1 11.0360 6.4200   24.0 22.9880   21.3 28.08800    40.1
        localhost Linux 4.9.0-1 5.11% 333.80%   0.11% 34.42%   -52.11% -19.92%    -22.69%

    4.  *Local* Communication latencies in microseconds - smaller is better
        ---------------------------------------------------------------------
        Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                                ctxsw       UNIX         UDP         TCP conn
        --------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
        localhost Linux 4.9.0-1 11.6  21.9 26.3  45.0        48.6        113.
        localhost Linux 4.9.0-1 11.036  33.4 26.7  34.5        52.0        111.
        localhost Linux 4.9.0-1 5.11%  -34.43% -1.50%  30.43%        -6.54%        1.80%

    5.  File & VM system latencies in microseconds - smaller is better
        -------------------------------------
        Host                 OS File   Prot
                                Delete Fault
        --------- ------------- - ------ ----
        localhost Linux 4.9.0-1 26.6   0.299
        localhost Linux 4.9.0-1 25.8   0.256
        localhost Linux 4.9.0-1 3.10%  16.80%

    6.  *Local* Communication bandwidths in MB/s - bigger is better
        ----------------------------------   -------
        Host                OS  AF    TCP     File
                                UNIX         reread
        --------- ------------- ---- ----    ------
        localhost Linux 4.9.0-1 1700  202.9    970.6
        localhost Linux 4.9.0-1 1594  21.4     940.7
        localhost Linux 4.9.0-1 6.65% 848.13%  3.18%

10:56 2017-01-05
----------------
GTD
---
1.  today
    0.  Misc:
        14:22 wakeup
        15:18 Plan to start to work
    1.  run lmbench on hikey emmc.
        10:59-11:08 replace kernel. est 10min. I forget there is not compile script in my home. And I plan to update to the latest kernel when I plan to do it.
                    boot fail(probably because of missing ethernet module). I could not use hikey today.
                    I feel that I need to improve the experiment at home: serial console and remote power up.
        DELAY, resume when I could use hikey tomorrow: try ssh.py without kernel compile.
    2.  do_wp_page.
        11:23-11:56 This part is too complex than I could imagine.

2.  TODO
    1.  考虑写glibc release notes.

08:38 2017-01-05
----------------
pm2.5过滤器
-----------
0.  后续计划: 放在枕头下面的闹钟, nfc用于收款游戏或其它场景。
1.  依次考虑96board, vocore等linux方案, 实在不行才考虑arduino等单片机.
    现在是手头没有能用的hikey，另外hikey功耗太大。目前考虑vocore.
    1.  尽量利用现有开发板，淘宝上买12v电池和电池盒，买来试试(通过led看长时间放电的性能)，如果可以用hikey。
    2.  如果用hikey，需要1.8到3.3v双向电平转换，这个需要焊接（可以考虑让卖家焊接好接插件）。已经选好的电烙铁（ts100）和焊锡（小桶），助焊剂，需要购买时购买。
    3.  另外需要买一个1.8到3.3v双向电平转换， 用于cubietruck上链接96boards的串口。
    4.  hikey还是得修好，主要用于原型实验的。

10:29 2017-01-06
----------------
GTD
---
1.  today
    0.  10:38-11:00 log env setup.
        11:00-11:10 vim edit history.
        14:14: start to work.
        15:43-17:05 no track. 10' about internal discuss for ILP32.
    1.  ILP32 performance test. ref"03:30 2017-01-06"
    2.  do_wp_page.
        15:34-15:43
    3.  pm2.5 monitor.
    2.  buy serial: 1.8v x2, 3.6v x2.
    4.  1:1 with Mark.

10:30 2017-01-06
----------------
arm64, ILP32, performance regresssion
-------------------------------------
1.  run lmbench on hikey emmc.
    0105 10:59-11:08 replace kernel. est 10min. I forget there is not compile script in my home. And I plan to update to the latest kernel when I plan to do it.
                boot fail(probably because of missing ethernet module). I could not use hikey today.
                I feel that I need to improve the experiment at home: serial console and remote power up.
    DELAY, resume when I could use hikey tomorrow: try ssh.py without kernel compile.
2.  test ILP32 enable: use merge config to select ILP32.
    1.  20' write gen_config.sh
    2.  rebase, compile kernel, deploy and run.
        14:18-15:10 est. 25'. actual 37' exceed 12' I hope I could save 30' when I use all the script.
               7' for rebase(auto without error) and compile kernel.
               15' personal
               10' copy kernel and modules
3.  check result in d03 and hikey.
    1.  hikey
        17:06-
3.  test ILP32 disable: use rpmspec file.
3.  Test lmbench aarch32 on d03 after current test finish(probably tomorrow).

11:19 2017-01-06
----------------
software skill, vim, edit history
----------------------------------
1.  vim does not open at the last location when I reopen it. After google it, I found that I need uncomment the following line in "/etc/vim/vimrc":
```
" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
```

17:25 2017-01-06
----------------
The test result:
['ILP32_enable_aarch32/CINT2006.014.ref.txt']
The test base:
['ILP32_unmerged_aarch32/CINT2006.022.ref.txt']
Original numbers:
{'462.libquantum': 8.07, '400.perlbench': 4.35, '401.bzip2': 2.61, '429.mcf': 2.64, '464.h264ref': 7.14, '473.astar': 2.98, '458.sjeng': 4.15, '403.gcc': 3.85, '456.hmmer': 3.0, '483.xalancbmk': 4.22, '445.gobmk': 4.7}
{'462.libquantum': 8.13, '400.perlbench': 4.32, '401.bzip2': 2.63, '429.mcf': 2.46, '464.h264ref': 7.11, '473.astar': 2.95, '458.sjeng': 4.29, '403.gcc': 3.84, '456.hmmer': 3.01, '483.xalancbmk': 4.23, '445.gobmk': 4.71}

Diff:
['ILP32_enable_aarch32/CINT2006.014.ref.txt']
   400.perlbench:  0.69%
       401.bzip2: -0.76%
         403.gcc:  0.26%
         429.mcf:  7.32%
       445.gobmk: -0.21%
       456.hmmer: -0.33%
       458.sjeng: -3.26%
  462.libquantum: -0.74%
     464.h264ref:  0.42%
       473.astar:  1.02%
   483.xalancbmk: -0.24%
The test result:
['ILP32_disable_aarch32/CINT2006.016.ref.txt']
The test base:
['ILP32_unmerged_aarch32/CINT2006.022.ref.txt']
Original numbers:
{'462.libquantum': 8.07, '400.perlbench': 4.35, '401.bzip2': 2.63, '429.mcf': 2.58, '464.h264ref': 7.15, '473.astar': 2.96, '458.sjeng': 4.3, '403.gcc': 3.86, '456.hmmer': 2.96, '483.xalancbmk': 4.14, '445.gobmk': 4.7}
{'462.libquantum': 8.13, '400.perlbench': 4.32, '401.bzip2': 2.63, '429.mcf': 2.46, '464.h264ref': 7.11, '473.astar': 2.95, '458.sjeng': 4.29, '403.gcc': 3.84, '456.hmmer': 3.01, '483.xalancbmk': 4.23, '445.gobmk': 4.71}

Diff:
['ILP32_disable_aarch32/CINT2006.016.ref.txt']
   400.perlbench:  0.69%
       401.bzip2: 0.00%
         403.gcc:  0.52%
         429.mcf:  4.88%
       445.gobmk: -0.21%
       456.hmmer: -1.66%
       458.sjeng:  0.23%
  462.libquantum: -0.74%
     464.h264ref:  0.56%
       473.astar:  0.34%
   483.xalancbmk: -2.13%
The test result:
['ILP32_enable_aarch64/']
The test base:
['ILP32_unmerged_aarch64']
Original numbers:
{'462.libquantum': 10.9, '400.perlbench': 4.31, '401.bzip2': 2.63, '429.mcf': 2.01, '464.h264ref': 7.33, '473.astar': 2.76, '458.sjeng': 4.62, '403.gcc': 4.0, '456.hmmer': 4.05, '483.xalancbmk': 3.86, '445.gobmk': 4.8}
{'462.libquantum': 11.2, '400.perlbench': 4.32, '401.bzip2': 2.64, '429.mcf': 2.08, '464.h264ref': 7.06, '473.astar': 2.74, '458.sjeng': 4.53, '403.gcc': 4.01, '456.hmmer': 4.04, '483.xalancbmk': 3.77, '445.gobmk': 4.74}

Diff:
['ILP32_enable_aarch64/']
   400.perlbench: -0.23%
       401.bzip2: -0.38%
         403.gcc: -0.25%
         429.mcf: -3.37%
       445.gobmk:  1.27%
       456.hmmer:  0.25%
       458.sjeng:  1.99%
  462.libquantum: -2.68%
     464.h264ref:  3.82%
       473.astar:  0.73%
   483.xalancbmk:  2.39%
The test result:
['ILP32_disable_aarch64']
The test base:
['ILP32_unmerged_aarch64']
Original numbers:
{'462.libquantum': 11.0, '400.perlbench': 4.2, '401.bzip2': 2.61, '429.mcf': 2.07, '464.h264ref': 7.25, '473.astar': 2.76, '458.sjeng': 4.53, '403.gcc': 4.01, '456.hmmer': 4.05, '483.xalancbmk': 3.77, '445.gobmk': 4.78}
{'462.libquantum': 11.2, '400.perlbench': 4.32, '401.bzip2': 2.64, '429.mcf': 2.08, '464.h264ref': 7.06, '473.astar': 2.74, '458.sjeng': 4.53, '403.gcc': 4.01, '456.hmmer': 4.04, '483.xalancbmk': 3.77, '445.gobmk': 4.74}

Diff:
['ILP32_disable_aarch64']
   400.perlbench: -2.78%
       401.bzip2: -1.14%
         403.gcc: 0.00%
         429.mcf: -0.48%
       445.gobmk:  0.84%
       456.hmmer:  0.25%
       458.sjeng: 0.00%
  462.libquantum: -1.79%
     464.h264ref:  2.69%
       473.astar:  0.73%
   483.xalancbmk: 0.00%

10:36 2017-01-09
----------------
v8.1 must support crc intruction.
看arm架构手册，我又想自己写操作系统了。不自己动手总是理解不了。
网上找到一个singpolyma-kernel例子，是基于arm的，我觉得可以我可以参考这个写一个arm64 hikey的操作系统。
<https://singpolyma.net/category/singpolyma-kernel/>

12:04 2017-01-10
----------------
GTD
1.  today
    1.  linaro activity. est 20'
        14:51-14:52 cancel.
    2.  reply to Alex Bennee.
        14:52-14:59
    2.  reply to Arnd in my last activity. est 20'
        14:59-15:25 finish draft. It takes more 5 minutes because I need to re-check the result and calculate the Coefficient of Variation.
        15:25-15:35 Send out. I forget why I need 10 minutes more.
    3.  Discuss with my boss in huawei.
    3.  do_wp_page: it seems that I have no time to do it.

14:48 2017-01-10
----------------
自己想了想，每周中午两个中午用来做自己的事情，初步想法是1天画画。其余四天做技术，技术方便需要考虑实际动手和架构学习的需求，目前动手类想做pm2.5传感器，nfc和语音助手。架构类学习是自己动手写操作系统。每个月各自用一般的时间。

10:25 2017-01-11
----------------
GTD
1.  today
    1.  linux mm summit proposal.
    2.  linaro proposal
    3.  apply for linaro connect(for my visa).


18:59 2017-01-11
----------------
kwg, meeting
------------
1.  Brief from arnd:
```
right, so there is probably hope. I think in order to present this at lsf/mm, you either should have prototype code that shows a clear overall performance win of at least 2 or 3 percent compared to 4k pages, or have a theory of what is going on with hmmer that predicts a positive outcome
actually we probably need an improvement comparing 4k+transhuge against 4k+pagehint+transhuge
from the data so far, it's not clear how much we can expect there, I was hoping for a more consistent picture in the results
I guess if showing that the hmmer benchmark falls into a class of tests that would be worse with the page hint than without it, that would kill the work, while showing that it would be better than 64k pages would make it interesting a gain as we could try again to convince Red Hat to move away from 64k pages
bamvor: either by understanding what is going with with hmmer and 64k pages,or by getting your patches to run correctly under the benchmark
in any case, if you want to submit this for lsf/mm, feel free to send me your abstract and I'll have a look before you send it in
```

2.  I need a stable result. Which I could run on hikey after ILP32 result?. Repair the hikey!!!!

3.  Full conversation:
```
[2017-01-11 17:38:13] <arnd> bamvor: anything  to report from your side?
[2017-01-11 17:39:16] <bamvor> most of thing we already discuss in my activity.
[2017-01-11 17:39:49] <bamvor> And I am in a train of armv8 in huawei in this week. So no much progress this week.
[2017-01-11 17:41:00] <arnd> ok
[2017-01-11 17:41:14] <bamvor> I plan to write the proposal/atttend for linux mm summit. I want to discuss the design of cont page hint and the performance improvement. Is it make sense to you?
[2017-01-11 17:41:51] <arnd> I wonder how much sense it still makes after your findings with the benchmarks
[2017-01-11 17:42:09] <bamvor> This is what I want to know from you.
[2017-01-11 17:42:12] <arnd> I was expecting a clear win for 64k pages on specint when you don't run into low memory
[2017-01-11 17:42:46] <arnd> but what you found was a much more mixed picture, with a significant degradation in some cases
[2017-01-11 17:43:02] <bamvor> do you mean compare with 4k with transhuge or 4k without transhuge.
[2017-01-11 17:43:21] <arnd> I mean comparing 4k pages with 64k pages
[2017-01-11 17:44:38] <bamvor> I suppose 4k with cont page hint could be better because we only allocate cont 64k page when it needed(by request the same 64k region twice as you said).
[2017-01-11 17:44:44] <arnd> the question is whether the 64k page hint on 4k pages will be able to perform better than plain 4k pages in the same test
[2017-01-11 17:45:24] <bamvor> yes. i do not know right now. do you think worth to investigate? it is hard to say without the code.
[2017-01-11 17:47:12] <arnd> right, so there is probably hope. I think in order to present this at lsf/mm, you either should have prototype code that shows a clear overall performance win of at least 2 or 3 percent compared to 4k pages, or have a theory of what is going on with hmmer that predicts a positive outcome
[2017-01-11 17:48:07] <arnd> actually we probably need an improvement comparing 4k+transhuge against 4k+pagehint+transhuge
[2017-01-11 17:49:07] <arnd> from the data so far, it's not clear how much we can expect there, I was hoping for a more consistent picture in the results
[2017-01-11 17:49:18] <bamvor> I do not know if I could finish the code before lsf/mm. But I think it is worth to try.
[2017-01-11 17:49:52] <bamvor> yes, I hoped so.
[2017-01-11 17:50:34] <arnd> e.g. the bzip2 benchmark is actually quite promising as it shows very little gains from transhuge, but noticeable gains from 64k
[2017-01-11 17:53:22] <arnd> looking at the numbers again, I would estimate that we can get at best a 1-2% improvement in specint
[2017-01-11 17:53:34] <bamvor> why?
[2017-01-11 17:54:27] <bamvor> does 1-2% enough for continuing this work?
[2017-01-11 17:54:50] <arnd> that's a very good question. I was initially hoping for much more, but it's still significant
[2017-01-11 17:56:07] <bamvor> I would like to continue doing till we prove that it is impossible.
[2017-01-11 17:56:11] <arnd> I guess if you put that estimate in your proposal for lsf/mm, the program committee can decide if they think it's worth discussing it there
[2017-01-11 17:57:13] <bamvor> Ok. i will write the proposal and send to you before I apply.
[2017-01-11 17:57:13] <arnd> it's also possible that other CPU cores gain more from this
[2017-01-11 17:57:28] <bamvor> do you mean other cpu arch?
[2017-01-11 17:58:00] <bamvor> or other arm SOC?
[2017-01-11 17:58:11] <arnd> If you tested this on Cortex-A57/A72/A73 or similar, they probably have a large enough TLB cache that the gains are smaller than on a Cortex-A35 or A53
[2017-01-11 17:59:29] <bamvor> oh, understand.
[2017-01-11 18:01:21] <arnd> http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.subset.cortexa.a72/index.html and http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0500g/Chddabii.html have some numbers for the TLB
[2017-01-11 18:03:50] <arnd> I guess if showing that the hmmer benchmark falls into a class of tests that would be worse with the page hint than without it, that would kill the work, while showing that it would be better than 64k pages would make it interesting a gain as we could try again to convince Red Hat to move away from 64k pages
[2017-01-11 18:05:18] <arnd> bamvor: either by understanding what is going with with hmmer and 64k pages,or by getting your patches to run correctly under the benchmark
[2017-01-11 18:05:55] <arnd> in any case, if you want to submit this for lsf/mm, feel free to send me your abstract and I'll have a look before you send it in
[2017-01-11 18:06:40] <bamvor> ok. understand. The deadline of lsf/mm is 15, Jan. I think we could discuss the proposal then continue to work.
```

19:01 2017-01-11
----------------
1.  [LSF/MM TOPIC][LSF/MM ATTEND] Implement contiguous page hint for anonymous page in user space
    Contiguous page hint is a feature in arm/arm64 which could decrease the tlb miss and improve the performance. Currently, it is only used in hugetlb which limited the senario. This proposal want to discuss the possibiliy and design for implementing contiguous page hint in annoymous page in user space. There are already some off-list discussion on two aspects: how much performance gain we could get; how to implement it in a simple way.

    Hope could discuss the following items in lsf:
    1.  Dicuss the my current idea and/or prototype(I am actively working on the prototype, hope could get a work prototype with performance result before lsf).
        Allocate 64k(with GFP_NOWAIT to avoid evict any other pages) during pte fault, where we have already handled the possible transparent hugepage. Immediatelly split it up into 4k pages and only add one page at this time. Once the fault happens again in the same contiguous area, add all the remaining 15 pages and set the contiguous page hint. We will track the 64k pages in mm_struct.
        We will split the 64k page in mprotect, mremap, munmap, LRU handling and any other point similar to trans-huge.

    2.  Analysis the reason of performance result of specint in mix with 4k/64k page size, transhuge and hugetlb.
        2.1 The following teest result is compare with 4k page with transhuge with or without hugetlb through libhugetlbfs and hugectl. We could see that only xalancbmk downgrade in both 64k and 2048k hugetlb. This is very interesting thing I will investigate and explain it in lsf. On the other hand, sjeng, omnetpp also downgrade in hugetlb 64k case, I think it is because in hugetlb we allocate the hugetlb before transhuge, while in cont page hint, we will allocate the 64k page after the check of transhuge. Therefore we could avoid these downgrade.
        Arnd: I plan to test the tlb miss tomorrow for the downgrade case, if the tlb miss of hugetlb 64k is higher than 4k with transhuge for sjeng and omnetpp. I think it could prove my guess. And I do not know why the result is a little bit difference than before. These number get from 3 times test which should be reliable than before. I plan to do specint test on my hikey but I do not start it yet.

                      64k hugetlb 2048k hugetlb
           401.bzip2:       2.33%         3.18%
             403.gcc:       0.13%         0.64%
             429.mcf:      -0.22%         0.77%
           445.gobmk:       0.00%         0.88%
           456.hmmer:       5.96%         5.30%
           458.sjeng:      -1.87%         0.00%
      462.libquantum:       3.73%         4.35%
         471.omnetpp:      -2.66%         0.89%
           473.astar:       2.19%         4.37%
       483.xalancbmk:      -4.10%        -2.46%

       2.2  In our another test, we found that there are some downgrade of 64k compare with 4k with or without transhuge. I think it show that there is some shortage of 64k page size, and we need to find a better way to improve the overall performance instead of increasing the base page size.
       Arnd: I am re-testing the result tonight with 3 times test, will paste the result tomorrow.

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

    3.  Discuss the potential solution for mobile world. Android is usually base on 4k page and disable transhuge and hugetlb to save high order memories and total memories. Our idea of contiguous page hint could be a better belance for mobile or other limited memory senario.

2.  Reply to Arnd
> On Thu, Jan 12, 2017 at 12:58 PM, Bamvor Zhang Jian
> <bamvor.zhangjian@linaro.org> wrote:
> > Contiguous page hint is a feature in arm/arm64 which could decrease
> > the tlb miss and improve the performance.
>
> This needs slightly more background as few people will be aware of the
> way ARM64 page tables work. Maybe
>
> ... and improve the performance by sharing a single TLB entry across 16
> 4k pages whenever the pages are also physically contiguous.
Ok
>
> > Currently, it is only used
> > in hugetlb which limited the senario. This proposal want to discuss
> > the possibiliy and design for implementing contiguous page hint in
> > annoymous page in user space. There are already some off-list
> > discussion on two aspects: how much performance gain we could get; how
> > to implement it in a simple way.
> >
> > Hope could discuss the following items in lsf:
>
> LFS/MM
>
> > 1.  Dicuss the my current idea and/or prototype(I am actively working
> > on the prototype, hope could get a work prototype with performance
> > result before lsf).
> >     Allocate 64k(with GFP_NOWAIT to avoid evict any other pages)
> > during pte fault, where we have already handled the possible
> > transparent hugepage. Immediatelly split it up into 4k pages and only
> > add one page at this time. Once the fault happens again in the same
> > contiguous area, add all the remaining 15 pages and set the contiguous
> > page hint. We will track the 64k pages in mm_struct.
> >     We will split the 64k page in mprotect, mremap, munmap, LRU
> > handling and any other point similar to trans-huge.
> write "transparent hugepages", not everyone abbreviates it the same way
Ok.
>
> > 2.  Analysis the reason of performance result of specint in mix with
> > 4k/64k page size, transhuge and hugetlb.
> >     2.1 The following teest result is compare with 4k page with
>
> test
>
> > transhuge with or without hugetlb through libhugetlbfs and hugectl. We
> > could see that only xalancbmk downgrade in both 64k and 2048k hugetlb.
> > This is very interesting thing I will investigate and explain it in
> > lsf. On the other hand, sjeng, omnetpp also downgrade in hugetlb 64k
> > case, I think it is because in hugetlb we allocate the hugetlb before
> > transhuge, while in cont page hint, we will allocate the 64k page
> > after the check of transhuge. Therefore we could avoid these
> > downgrade.
> >     Arnd: I plan to test the tlb miss tomorrow for the downgrade case,
> > if the tlb miss of hugetlb 64k is higher than 4k with transhuge for
> > sjeng and omnetpp. I think it could prove my guess.
>
> ok, very good.
>
> > And I do not know
> > why the result is a little bit difference than before. These number
> > get from 3 times test which should be reliable than before. I plan to
> > do specint test on my hikey but I do not start it yet.
>
> Also good to have a cortex-a53 in the mix.
Ok, I will try to test on hikey. Hope could get the result in time.
>
> >                   64k hugetlb 2048k hugetlb
> >        401.bzip2:       2.33%         3.18%
> >          403.gcc:       0.13%         0.64%
> >          429.mcf:      -0.22%         0.77%
> >        445.gobmk:       0.00%         0.88%
> >        456.hmmer:       5.96%         5.30%
> >        458.sjeng:      -1.87%         0.00%
> >   462.libquantum:       3.73%         4.35%
> >      471.omnetpp:      -2.66%         0.89%
> >        473.astar:       2.19%         4.37%
> >    483.xalancbmk:      -4.10%        -2.46%
> >
> >    2.2  In our another test, we found that there are some downgrade of
> > 64k compare with 4k with or without transhuge. I think it show that
> > there is some shortage of 64k page size, and we need to find a better
> > way to improve the overall performance instead of increasing the base
> > page size.
> >    Arnd: I am re-testing the result tonight with 3 times test, will
> > paste the result tomorrow.
>
> I'd reword this, given that the people in the program committee will
> very likely all be aware that using 64k pages is a bad idea. Maybe
> write something like:
>
> As several distributions are already using 64k base pages, moving them
> to 4k pages with the continuous page hint should drastically improve
> performance in cases that are currently limited on the amount of memory,
> but ideally also keep the better performance in benchmarks that are
> limited by TLB misses.
>
> On the same note, I wonder if the overhead you see for 64k pages
> in hmmer is a result of wp_page_copy()/clear_page()/copy_user_highpage()
> having to copy or zero-fill more data on a page fault. This is
> probably easy to see using 'perf'.
Do you mean check them perf top/report/script? I do not find the
trace point of these functions.

Regards

Bamvor
>
>     Arnd

10:21 2017-01-12
----------------
GTD
---
1.  today
    0.  misc
        18:00-18:50 lunch and rest
    1.  find a better way to sync with trello to avoid block by the great wall.
        I could use icalsync2 which support create account on android and continuously import calender from trello.
        20'(-10:15)
    2.  linux mm summit proposal.
        10:29-11:03 It is hard for me.
        11:19-11:52 15:12-15:25
        15:25-16:29 calculate the result.
        -18:00 try to write the proposal, not big progress.
        19:00-
    3.  huawei opensource discussion.
        11:04-11:19 15:05-15:11
    4.  dairy.
        14:20-14:45
    5.  update the repo in github.
        16:29-16:40 I think it takes too much time to update the repo. The main issues are the diversity of repo.
    2.  Test base memory copy in hugetlb(with cont page hint). monitor the tlb miss through perf.
    2.  linaro proposal
    2.  reply to guodongxu and zhuangluan su.
    3.  apply for linaro connect(for my visa).

16:38 2017-01-12
----------------
1.  64k(with all the testresult in 4k with transhuge and 64k)
       testcases: increase cv(base) cv(result) CV: Coefficient of Variation
       401.bzip2:   2.30%   0.13%    0.22%
         403.gcc:   0.34%   0.12%    0.37%
         429.mcf:   0.62%   0.57%    1.26%
       445.gobmk:   0.29%   0.41%    0.00%
       456.hmmer:   7.20%   0.00%    2.24%
       458.sjeng:  -1.87%   0.00%    0.00%
  462.libquantum:   4.47%   3.17%    2.11%
     471.omnetpp:  -1.74%   0.57%    0.39%
       473.astar:   1.15%   0.27%    0.10%
   483.xalancbmk:  -3.31%   1.07%    0.78%

2.  64k(only the testresult in yesterday).
       401.bzip2:   2.33%   0.00%    0.00%
         403.gcc:   0.13%   0.00%    0.00%
         429.mcf:  -0.22%   0.00%    0.00%
       445.gobmk:   0.00%   0.00%    0.00%
       456.hmmer:   5.96%   0.00%    0.00%
       458.sjeng:  -1.87%   0.00%    0.00%
  462.libquantum:   3.73%   0.00%    0.00%
     471.omnetpp:  -2.66%   0.00%    0.00%
       473.astar:   2.19%   0.00%    0.00%
   483.xalancbmk:  -4.10%   0.00%    0.00%

3.  2048k(only the testresult in yesterday).
       401.bzip2:   3.18%   0.00%    0.00%
         403.gcc:   0.64%   0.00%    0.00%
         429.mcf:   0.77%   0.00%    0.00%
       445.gobmk:   0.88%   0.00%    0.00%
       456.hmmer:   5.30%   0.00%    0.00%
       458.sjeng:   0.00%   0.00%    0.00%
  462.libquantum:   4.35%   0.00%    0.00%
     471.omnetpp:   0.89%   0.00%    0.00%
       473.astar:   4.37%   0.00%    0.00%
   483.xalancbmk:  -2.46%   0.00%    0.00%

In hugetlb 2048k, xalancbmk is only decreasing one. In hugetlb 64k, there are three testcases downgrade 458.sjeng, 471.omnetp, 483.xalancbmk.
I am thinking the unsplitable hugetlb hurt the flexbility. I plan to test the tlb miss in hmmer and xalancbmk to prove it.

4.  (15:58 2017-01-13)Test on hikey
    1.  400.perlbench 403.gcc test run fail. I do not know the reason.

5.  Key case I need to know
    401.bzip2
    456.hmmer
    462.libquantum
    483.xalancbmk
    471.omnetpp

6.  pmu on d03 and hikey could not use right now. I boot fail after apply the pmu of acpi from arm.

15:52 2017-01-13
----------------
GTD
---
1.  today
    1.  who should I cc when I send to linux/mm?

09:43 2017-01-14
----------------
GTD
---
1.  today
    1.  set one boot option for grub.
        9:50-10:20 not works. continue trying when doing "3".
        10' 11:17-11:20 learn how to use grub2 tools. see"11:20 2017-01-14"
        FAIL: I suspect there is a bug in my grub suite.
    2.  TODO count the reboot time
        reboot 10:10-10:14 10:23-10:27:41 10:44:23-10:48:54 11:16:01-11:20:33 about 4:30, I could set the timeout as 9minutes.
    3.  try pmu patch one by one
        10:20-11:53 interleave with other work. I do not why it not work yesterday.
        1: pass
        2: pass
        d055481: pass
        4b1420d: pass
        74991b6: pass
        84f6528: pass
        d5921fa: pass
    4.  specint analysis. see"12:09 2017-01-16"
    5.  send out the proposal of lsf/mm
        1.  update the doc according to arnd.
        2.  update the test result of hikey and perf pmu of d03.
            1.  11:24-11:40 check result of hikey. Hikey hung all the night in bzip after perlbench fail.  comment perlbench and run bzip and other case again.
                timer: 16:02 libquan 16:32 h264 18:34 astar
        3.  cc:
            > And who should I cc in the list? you two, mel gorman, Laura Abbott,
            > Marc Zyngier, Christoffer Dall?
            Sounds ok. I'd also suggest including Catalin Marinas and Will Deacon.

11:20 2017-01-14
----------------
software skill, grub2, grub configuration editor
------------------------------------------------
1.  set variable through grub2-edit-env
    `grub2-editenv /boot/EFI/grub2/grubenv set saved_entry=z00293696-ilp32-test`
2.  set saved_entry through grub2-set-default
    `grub2-set-default --boot-directory=/boot/EFI z00293696-4.1-test`
3.  set next_entry through grub2-reboot
    `grub2-reboot --boot-directory=/boot/EFI z00293696-ilp32-test1
4.  if prompt "error: environment block too small.", create the new one
    ```
    # grub2-set-default --boot-directory=/boot/EFI z00293696-ilp32-test`
    /usr/bin/grub2-editenv: error: environment block too small.
    # grub2-editenv  /boot/EFI/grub2/grubenv create
    ```

12:09 2017-01-14
----------------
KWG-192, cont page hint, specint analysis
-----------------------------------------
1.  try armv8 pmu tlb miss.
    1.  try with malloc.
        12:09-12:53 tlb miss increase after I use hugetlb, why?
    2.  try specint testcases: sjeng, omnetpp, xalancbmk.
        12:53-13:50 write the conf file for test hmmer and sjeng.
        16:02-16:32 check the result, test other significant test case.
        TODO I should force test with huge64k binary even if I test the normal patch in order to avoid compile stage in test. It could also avoid the alignment difference across pure 4k with transhuge, huge64k and huge2048k.
        Should I mention that I relink the application in order to test hugepage?
    3.  internal discussion for pmu of acpi patches. Add tested by.
        15'
2.  64k hmmer
    > On the same note, I wonder if the overhead you see for 64k pages
    > in hmmer is a result of wp_page_copy()/clear_page()/copy_user_highpage()
    > having to copy or zero-fill more data on a page fault. This is
    > probably easy to see using 'perf'.

3.  (10:15 2017-01-16) Aleast finish one today.
    1.  Analysis the relationship between performance and perf stat for 4k transhuge with/without huge64k
        17:46-18:23
        18:54-19:44 Discuss with my colleague. For sjeng, he suggest add l1 access to think why l2 data access increasing when the behavior of test is not changed. He also suggest add :u after the event to only track the userspace.
        0119 14:48-15:58 check the result.
                         My colleague suggest to run perf report/top get the hot spot.
             15:38-15:46 plot?
             -16:34      update the format for gnuplot. It takes too much time to do this right long.
             16:34-17:13 -17:24 Already overtime. finish it.
    2.  Analysis 64k hmmer with perf.
        1.  17:45 I overwrite the perf.data. Start re-testing.
            TODO

22:54 2017-01-14
----------------
1   I think the base is not suitable to compare the result(4.10-rc2). because there are differnce kernel.
bamvor@instance-uu77xy2w:~/works/source/test_results$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase ILP32_performance_regression/hikey_4.9_sd_hungtask_20161224/ILP32_unmerged_aarch64/ --testresult cont_page_hint/20170114_huge64k/
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
       401.bzip2:   0.00%   0.00%    0.00%
       445.gobmk:   0.21%   0.00%    0.00%
       456.hmmer:   1.24%   0.00%    0.00%
       458.sjeng:   5.30%   0.00%    0.00%
  462.libquantum:  -8.93%   0.00%    0.00%
     464.h264ref:   2.83%   0.00%    0.00%
       473.astar:   1.46%   0.00%    0.00%
   483.xalancbmk:  -1.59%   0.00%    0.00%

2.  Continue testing.

16:17 2017-01-15
----------------
[LSF/MM TOPIC][LSF/MM ATTEND] Implement contiguous page hint for anonymous page in user space

    Contiguous page hint is a feature in arm/arm64 which could decrease the tlb miss and improve the performance by sharing a single TLB entry across 16 4k pages whenever the pages are also physically contiguous. Currently, it is only used in hugetlb which limited the scenario. This proposal want to discuss the possibility and design for implementing contiguous page hint in anonymous page in user space. There are already some off-list discussion on two aspects: how much performance gain we could get; how to implement it in a simple way.

    Hope could discuss the following items in lsf/mm:
    1.  Discuss the my current idea and/or prototype(I am actively working on the prototype, hope could get a work prototype with performance result before lsf).
        Allocate 64k(with GFP_NOWAIT to avoid evict any other pages) during pte fault, where we have already handled the possible transparent hugepage. Immediately split it up into 4k pages and only add one page at this time. Once the fault happens again in the same contiguous area, add all the remaining 15 pages and set the contiguous page hint. We will track the 64k pages in mm_struct.
        We will split the 64k page in mprotect, mremap, munmap, LRU handling and any other point similar to transparent hugepage.

    2.  Analysis the reason of performance result of specint in mix with 4k/64k page size, transparent hugepage(THP) and hugetlb.
        2.1 The following test result is compare with 4k page with THP with or without hugetlb through libhugetlbfs and hugectl. In this test, hugepage is allocated before THP, while in our idea, the contiguous page hint will be allocated after THP. Allocate 64k hugepage before THP could break the 2M THP. So we could see that the overall performance improvement of 2048k hugetlb is better than 64k hugetlb.
        With the performance monitor unit in arm cpu, we could see the positive correlation between tlb miss and performance improvement.
        We also notice xalancbmk downgrade in both 64k and 2048k hugetlb. This is very interesting thing I plan to investigate and discuss it in lsf.
        The following test results come from Cortex-A57 which is a classic high performance CPU in arm64. It support larger tlb than low power CPU(such as Cortex-A53). I would expect the more improvement in low power CPU.

                      64k hugetlb 2048k hugetlb
           401.bzip2:       2.33%         3.18%
             403.gcc:       0.13%         0.64%
             429.mcf:      -0.22%         0.77%
           445.gobmk:       0.00%         0.88%
           456.hmmer:       5.96%         5.30%
           458.sjeng:      -1.87%         0.00%
      462.libquantum:       3.73%         4.35%
         471.omnetpp:      -2.66%         0.89%
           473.astar:       2.19%         4.37%
       483.xalancbmk:      -4.10%        -2.46%

       2.2  In our another test, we found that there are some downgrade of 64k compare with 4k with or without THP. I think it show that there is some shortage of 64k of base page size, and we need to find a better way to improve the overall performance instead of increasing the base page size. As several distributions are already using 64k base pages, moving them to 4k pages with the continuous page hint should drastically improve performance in cases that are currently limited on the amount of memory, but ideally also keep the better performance in benchmarks that are limited by TLB misses.

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

    3.  Discuss the potential solution for mobile world. Android is usually base on 4k page and disable THP and hugetlb to save high order memories and total memories. Our idea of contiguous page hint could be a better balance for mobile or other limited memory scenario.

Regards

Bamvor

17:46 2017-01-15
----------------
kindle: 905a 2201 3505 05sg
amazon Japan telephone: +81 11 330 3000

10:08 2017-01-16
----------------
GTD
---
1.  today
    0.  misc
        10:46-11:05
        11:23-11:51
        I could not focus on in the morning. Hope I could track more than 3 hours in the afternoon.
    1.  plan
        10:08-10:45 走神10分钟。It is too long to plan a day.
    2.  linaro activity.
        11:05-11:09 Not finish. Need more test result.
    3.  kabi check.
        11:51-12:06 run the script.
        20' discuss with my colleague. TODO: wait for him response.
        14:33-14:53 check the kabi result. Est. 20'
                    delete the result by mistake. Update the script in order to call from script. Re-run it.
        15:40-16:00 discuss with my colleague.
        16:00-16:29 update the script.
    4.  linaro proposal. Est 30'
        14:57-15:28 I think I wrote the proposal so smoothly. But it actually just on time. I should consider more time for the works.
    5.  huawei department meeting.
        16:54-17:19
    3.  do_wp_page 3h.
        17:40 I could not find so much time doing it.
    4.  cont page hint analysis. see"12:09 2017-01-14"3
2.  next
    1.  MOVE TO 0118: test performance with latest ILP32 patches.
    2.  wrote kabi test script.
    3.  MOVE TO 0118: is there analysis of linux vdso?
    4.  fix the log jump.

10:47 2017-01-16
----------------
activity
--------
git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2017-01-09 to 2017-01-16

* KWG-192: Use of contiguous page hint to create 64K pages
    - Discuss the proposal of lsf/mm and send out this week.
    - Investigate the following test data(the baseline is 4k base page with transparent hugepage). Except xalancbmk, other test show good relationship with data tlb miss. I plan to calculate the calcorrelation coefficient, but I am not sure which one is better for discrete data.
      For xalancbmk, the tlb miss of 64k hugetlb is much smaller(maybe ~70%. I will post all the data later) than baseline. But L2 cache access is 20% more than baseline. Given than in armv8, L1 and L2 is inclusive, I decide to test the L1 i$ access, d$ access and d$ miss to verify the result.
      The other issue is about libquantum. The baseline of libquantum is not stable. The Coefficient of Variation(standard deviation divided by mean) of baseline is about 3%. The below 3.73% is the minimal improvement.
                      64k hugetlb 2048k hugetlb
           401.bzip2:       2.33%         3.18%
             403.gcc:       0.13%         0.64%
             429.mcf:      -0.22%         0.77%
           445.gobmk:       0.00%         0.88%
           456.hmmer:       5.96%         5.30%
           458.sjeng:      -1.87%         0.00%
      462.libquantum:       3.73%         4.35%
         471.omnetpp:      -2.66%         0.89%
           473.astar:       2.19%         4.37%
       483.xalancbmk:      -4.10%        -2.46%

* ILP32
    - Performance test. test the hikey with huntask. Huawei colleague find a root cause, I will re-test them this week.
                  ILP32_enable_aarch32  ILP32_disable_aarch32  ILP32_enable_aarch64 ILP32_disable_aarch64
   400.perlbench                 0.69%                  0.69%                -0.23%                -2.78%
       401.bzip2                -0.76%                  0.00%                -0.38%                -1.14%
         403.gcc                 0.26%                  0.52%                -0.25%                 0.00%
         429.mcf                 7.32%                  4.88%                -3.37%                -0.48%
       445.gobmk                -0.21%                 -0.21%                 1.27%                 0.84%
       456.hmmer                -0.33%                 -1.66%                 0.25%                 0.25%
       458.sjeng                -3.26%                  0.23%                 1.99%                 0.00%
  462.libquantum                -0.74%                 -0.74%                -2.68%                -1.79%
     464.h264ref                 0.42%                  0.56%                 3.82%                 2.69%
       473.astar                 1.02%                  0.34%                 0.73%                 0.73%
   483.xalancbmk                -0.24%                 -2.13%                 2.39%                 0.00%

=== Plans ===
* KWG-192: Use of contiguous page hint to create 64K pages
    Write the code in do_wp_page
    Continue to analysis the performance result.

* ILP32 performance test
    Test Lmbench, specint and other testsuite.

14:59 2017-01-16
----------------
linaro connect, bud17
---------------------
Presenter Name *
Bamvor Jian Zhang

Company *
Huawei

Presenter Title *
Senior Software Engineer

Presenter Bio
Bamvor Jian Zhang is a software engineer in Huawei who focuses on arm architecture relative things in linux kernel. He maintains ILP32 for ARM64 for huawei and work closely with community. ARM64 ILP32 supports running legacy 32bit binaries on ARM64. From the last year, He start to work on the optimization of page table for arm/arm64. He gave a presentation in Linuxcon europe 2016, Opensuse Asia Summit 2014 and also some presentations in local open source activities in Beijing China. He is also the member of Beijing Linux User Group(BLUG).

Presenter Contact Email *
bamvor.zhangjian@linaro.org

If known, which industry segment(s)?
Enterprise

Session/Demo Title *
Implement contiguous page hint for anonymous page in user space

Session/Demo Abstract (short description including technical focus areas, e.g. kernel, virtualization,...) *
Area: Kernel.

Contiguous page hint is a feature in arm/arm64 which could decrease the tlb miss and improve the performance by sharing a single TLB entry across 16 4k pages whenever the pages are also physically contiguous. Currently, it is only used in hugetlb which limited the scenario.

This proposal want to share and discuss following things:
1.  The current design of hugepage, transparent hugepage and page fault. And current design of bamvor'
2.  Compare and analysis the performance of different design, mix with transparent hugepage, hugepage and bamvor' design.
3.  Discuss the scenarios which are suitable for this work beyond the enterprise.

15:56 2017-01-17
----------------
GTD
---
1.  today
    1.  linaro activity(need collect the data)
        1.  cont page hint. 10'
            16:05-16:19 It is complex than I thought. I need more than 10 minutes to write 766 characters.
        2.  ILP32. 30'
            16:20-16:44 and finish activity
    2.  do_wp_page
        1.  more than 1h.
            16:57-17:20 prepare the environment and misc.
            17:28-18:46
            18:50-18:55 I feel I understand something.
2.  next
    1.  MOVE TO 0118; Reply the email.
    1.  write to mel?
    1.  dnspod(upload the picture of my ID card).
    1.  learn os courses?

17:50 2017-01-17
----------------
cont page hint
--------------
1.  how about set flags in page to indicate it belong to cont area?
2.  does cow_user_page lead to the current my failure?
3.  Could not understand:
         if (!trylock_page(vmf->page)) {

4. (11:57 2017-01-18)
    What does it mean after pte_mkdirty?
    If it is the read, it read the zero page allocated in do_anonymous_page. I think it should allocate the new page for read.
    TODO.
5.  (15:32 2017-01-20)
    The difficult of record in mm struct is we do not know the size of mm. And most of area is empty actually. I am thinking I should record in vma.
    There is always vma in vm_fault. So, I think it is good for me.
6.  The question is where does vma allocate?
    1.  I found where does file back vma allocate: elf_map->vm_mmap->vm_mmap_pgoff->do_mmap_pgoff
    2.  brk: set_brk->do_brk_flags->vma allocate
    3.  malloc: in mmap_region or `__vma_adjust`
7.  Think about maintain the cont page region bit.
    1.  

10:31 2017-01-18
----------------
GTD
---
1.  today
    1.  plan
        10:33-10:46
    2.  Diary
        1.  11:02-11:20
    2.  do_wp_page: start write the code.
        1.  read the rest of code.
            11:21-12:03
    3.  evus.
        30' 13:45-14:52 Finish the table on 14:20, but it takes 30' to review and save the result.
    1.  test performance with latest ILP32 patches.
        1.  plan
            15:05-15:07
        1.  automatically compile and update kernel and modules to board.
            15:07-15:46 It takes too long to replace in bash like this<http://stackoverflow.com/questions/13210880/replace-one-substring-for-another-string-in-shell-script>, This one works for me: <http://stackoverflow.com/questions/7718307/how-to-split-a-list-by-comma-not-space>
            16:36-17:33 install kernel and modules.
        2.  specint support select difference case.
            17:50-18:20
            aarch32: mcf hmmer sjeng h264ref astar xalancbmk
            aarch64: perlbench bzip2 mcf gobmk sjeng libquantum h264ref xalancbmk
        3.  Test with ssh.py script.
            DONE
        4.  kernel compile script support checkout commit.
            DONE
    1.  wrote docment for linux vdso for arm64.
    1.  Reply the email to Mark, Akashi.

2.  next
    1.  review the todo in 16,17 Jan.

10:31 2017-01-19
----------------
GTD
---
1.  today
    1.  check the reason of hikey and cubietruct reboot.
        10:31-10:45 5' I do not know. Buy heat sink later.
    2.  do_wp_page: start write the code.
        1.  read the rest of code.
            DO NOT DO IT IN TWO DAYS. I NEED TO CHANGE!
    2.  ILP32 performance test finish the following one:
        11:51-12:00 run aarch64: perlbench bzip2 mcf gobmk sjeng libquantum h264ref xalancbmk.
                    TODO aarch64 ILP32 enable.
            aarch32: mcf hmmer sjeng h264ref astar xalancbmk
    2.  1:1 with Mark.
        17:30-18:11
2.  next
    1.  buy heat sink for my ct and hikey.

11:17 2017-01-19
----------------
cubietruck, reboot
------------------
```
localhost:~ # journalctl --since 2017-01-17
Jan 19 07:00:03 localhost systemd[1]: Started Rotate log files.
Jan 19 10:12:39 localhost wickedd-dhcp4[502]: eth0: Committed DHCPv4 lease with address 192.168.1.202 (lease time 86400 sec, renew in 43200 sec, rebind in 75600 sec)
Jan 19 10:12:39 localhost wickedd[511]: route ipv4 0.0.0.0/0 via 192.168.1.1 dev eth0#2 type unicast table main scope universe protocol dhcp covered by a ipv4:dhcp le
Jan 19 10:30:53 localhost systemd[1]: Starting Cleanup of Temporary Directories...
Jan 19 10:30:53 localhost systemd[1]: Started Cleanup of Temporary Directories.
-- Reboot --
Jan 01 08:00:15 localhost systemd-journald[134]: Runtime journal (/run/log/journal/) is currently using 8.0M.
                                                 Maximum allowed usage is set to 100.3M.
                                                 Leaving at least 150.5M free (of currently available 995.8M of space).
                                                 Enforced usage limit is thus 100.3M, of which 92.3M are still available.
Jan 01 08:00:15 localhost kernel: Booting Linux on physical CPU 0x0
Jan 01 08:00:15 localhost kernel: Linux version 4.8.13-1-default (geeko@buildhost) (gcc version 6.2.1 20160830 [gcc-6-branch revision 239856] (SUSE Linux) ) #1 SMP PR
Jan 01 08:00:15 localhost kernel: CPU: ARMv7 Processor [410fc074] revision 4 (ARMv7), cr=10c5387d
```

10:01 2017-01-20
----------------
GTD
---
1.  today
    1.  misc
        9:50-10:01 Linaro leave.
        11:16-11:38 who and tmux.
        15:01-15:15 talk with yury.
        15:51-16:11 It takes 20 minutes to rest. Too long!
    2.  plan
    2.  do_wp_page: start write the code.
        1.  read the rest of code.
            11:38-12:08
            15:19-15:51
        2.  Think about how to modity the code.
            16:12-16:47 Where does new mmap do.
    3.  安装站立办公位.
        14:16-14:45 比计划多用了10分钟.
    2.  ILP32 performance test.
        1.  check the result. I should only use 30 minutes to work on the script recently.
            14:45-15:01 It will finish tonight. Check tonight or later.
    2.  check result of cont page hint.
2.  next
    1.  Does rt-thread support arm64? Search the current os which do not support arm/arm64. The new os from google?

10:07 2017-01-22
----------------
bjzhang.github.io, ip address
-----------------------------
bamvor@instance-uu77xy2w:~/works/source/small_tools_collection$ nslookup bjzhang.github.io
Server:         172.16.0.3
Address:        172.16.0.3#53

Non-authoritative answer:
bjzhang.github.io       canonical name = github.map.fastly.net.
Name:   github.map.fastly.net
Address: 151.101.100.133

bamvor@instance-uu77xy2w:~/works/source/small_tools_collection$ nslookup aarch64.me
Server:         172.16.0.3
Address:        172.16.0.3#53

Non-authoritative answer:
aarch64.me      canonical name = bjzhang.github.io.
bjzhang.github.io       canonical name = github.map.fastly.net.
Name:   github.map.fastly.net
Address: 151.101.100.133

10:39 2017-01-23
----------------
ILP32, aarch64
--------------
1.  ILP32 disable
    mcf and xalancbmk are not stable.

bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged/ --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/ --testresult 20170118_specint_aarch64/ILP32_disabled/
The test result:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/', '20170118_specint_aarch64/ILP32_disabled/']
The test base:
['20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged/', '20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/']
Original numbers:
{'462.libquantum': 10.933333333333332, '464.h264ref': 7.303333333333334, '401.bzip2': 2.643333333333333, '429.mcf': 2.0466666666666664, '400.perlbench': 4.33, '458.sjeng': 4.72, '483.xalancbmk': 3.69, '445.gobmk': 4.753333333333333}
{'462.libquantum': 10.9, '400.perlbench': 4.335, '401.bzip2': 2.635, '429.mcf': 2.07, '464.h264ref': 7.32, '458.sjeng': 4.710000000000001, '483.xalancbmk': 3.675, '445.gobmk': 4.76}

Diff:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/', '20170118_specint_aarch64/ILP32_disabled/']
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.12%    0.00%     0.12%
       401.bzip2:    0.32%    0.18%     0.57%
         429.mcf:  -1.13%    1.40%     0.00%
       445.gobmk:  -0.14%    0.10%     0.63%
       458.sjeng:    0.21%    0.00%     0.42%
  462.libquantum:    0.31%    0.43%     0.00%
     464.h264ref:  -0.23%    0.28%     0.00%
   483.xalancbmk:    0.41%    2.17%     1.22%
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged/ --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/
The test result:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/']
The test base:
['20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged/', '20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/']
Original numbers:
{'462.libquantum': 10.933333333333332, '464.h264ref': 7.303333333333334, '401.bzip2': 2.643333333333333, '429.mcf': 2.0466666666666664, '400.perlbench': 4.33, '458.sjeng': 4.72, '483.xalancbmk': 3.716666666666667, '445.gobmk': 4.753333333333333}
{'462.libquantum': 10.9, '400.perlbench': 4.335, '401.bzip2': 2.635, '429.mcf': 2.07, '464.h264ref': 7.32, '458.sjeng': 4.710000000000001, '483.xalancbmk': 3.675, '445.gobmk': 4.76}

Diff:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170120_2042/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_0920/', '20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/']
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.12%    0.00%     0.12%
       401.bzip2:    0.32%    0.18%     0.57%
         429.mcf:  -1.13%    1.40%     0.00%
       445.gobmk:  -0.14%    0.10%     0.63%
       458.sjeng:    0.21%    0.00%     0.42%
  462.libquantum:    0.31%    0.43%     0.00%
     464.h264ref:  -0.23%    0.28%     0.00%
   483.xalancbmk:    1.13%    2.03%     1.22%
-bash: /home/bamvor/works/source/small_tools_collection/misc/specint_get_data.py--testbase: No such file or directory
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 2017011
8_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/ --testresult 20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/
The test result:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/']
The test base:
['20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/']
Original numbers:
{'462.libquantum': 11.0, '400.perlbench': 4.33, '401.bzip2': 2.64, '429.mcf': 2.01, '464.h264ref': 7.28, '458.sjeng': 4.72, '483.xalancbmk': 3.61, '445.gobmk': 4.75}
{'462.libquantum': 10.9, '400.perlbench': 4.34, '401.bzip2': 2.65, '429.mcf': 2.07, '464.h264ref': 7.32, '458.sjeng': 4.69, '483.xalancbmk': 3.63, '445.gobmk': 4.73}

Diff:
['20170118_specint_aarch64/ILP32_disabled/a3eb14be_ilp32_disabled_20170121_1558/']
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.23%    0.00%     0.00%
       401.bzip2:  -0.38%    0.00%     0.00%
         429.mcf:  -2.90%    0.00%     0.00%
       445.gobmk:    0.42%    0.00%     0.00%
       458.sjeng:    0.64%    0.00%     0.00%
  462.libquantum:    0.92%    0.00%     0.00%
     464.h264ref:  -0.55%    0.00%     0.00%
   483.xalancbmk:  -0.55%    0.00%     0.00%

2.  ILP32 enable
Significant result:
         429.mcf:  -2.17%    1.73%     0.00%
       458.sjeng:  -1.06%    1.50%     0.42%
     464.h264ref:  -2.32%    1.82%     0.00%
   483.xalancbmk:    1.22%    1.08%     1.22%

bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 2017011
8_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/ --testresult 201701
18_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/ --testresult 20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled
The test result:
['20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/', '20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled']
The test base:
['20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged', '20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/']
Original numbers:
{'462.libquantum': 10.850000000000001, '400.perlbench': 4.325, '401.bzip2': 2.6399999999999997, '429.mcf': 2.025, '464.h264ref': 7.15, '458.sjeng': 4.66, '483.xalancbmk': 3.7199999999999998, '445.gobmk': 4.75}
{'462.libquantum': 10.9, '400.perlbench': 4.335, '401.bzip2': 2.635, '429.mcf': 2.07, '464.h264ref': 7.32, '458.sjeng': 4.710000000000001, '483.xalancbmk': 3.675, '445.gobmk': 4.76}

Diff:
['20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/', '20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled']
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.23%    0.12%     0.12%
       401.bzip2:    0.19%    0.38%     0.57%
         429.mcf:  -2.17%    1.73%     0.00%
       445.gobmk:  -0.21%    0.21%     0.63%
       458.sjeng:  -1.06%    1.50%     0.42%
  462.libquantum:  -0.46%    0.46%     0.00%
     464.h264ref:  -2.32%    1.82%     0.00%
   483.xalancbmk:    1.22%    1.08%     1.22%
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/ --testresult 20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/
The test result:
['20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/']
The test base:
['20170118_specint_aarch64/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_0525/']
Original numbers:
{'462.libquantum': 10.9, '400.perlbench': 4.33, '401.bzip2': 2.63, '429.mcf': 2.06, '464.h264ref': 7.02, '458.sjeng': 4.73, '483.xalancbmk': 3.68, '445.gobmk': 4.74}
{'462.libquantum': 10.9, '400.perlbench': 4.34, '401.bzip2': 2.65, '429.mcf': 2.07, '464.h264ref': 7.32, '458.sjeng': 4.69, '483.xalancbmk': 3.63, '445.gobmk': 4.73}

Diff:
['20170118_specint_aarch64/ILP32_enabled/a3eb14be_ilp32_enabled_20170121_2244/']
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.23%    0.00%     0.00%
       401.bzip2:  -0.75%    0.00%     0.00%
         429.mcf:  -0.48%    0.00%     0.00%
       445.gobmk:    0.21%    0.00%     0.00%
       458.sjeng:    0.85%    0.00%     0.00%
  462.libquantum:    0.00%    0.00%     0.00%
     464.h264ref:  -4.10%    0.00%     0.00%
   483.xalancbmk:    1.38%    0.00%     0.00%

10:44 2017-01-23
----------------
ILP32, aarch32
--------------
1.  ILP32 disable
    significant: mcf, sjeng, h264ref

bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged/ --testbase 20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/ --testresult 20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled --testresult 20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/
The test result:
['20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled', '20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/']
The test base:
['20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged/', '20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/']
Original numbers:
{'464.h264ref': 7.0, '429.mcf': 2.565, '473.astar': 2.9400000000000004, '458.sjeng': 4.195, '456.hmmer': 2.9800000000000004, '483.xalancbmk': 4.205}
{'464.h264ref': 7.130000000000001, '429.mcf': 2.66, '473.astar': 2.955, '458.sjeng': 4.295, '456.hmmer': 2.99, '483.xalancbmk': 4.225}

Diff:
['20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled', '20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/']
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -3.57%    1.75%     1.50%
      456.hmmer:  -0.33%    0.34%     0.33%
      458.sjeng:  -2.33%    2.26%     0.12%
    464.h264ref:  -1.82%    0.57%     0.28%
      473.astar:  -0.51%    0.34%     0.51%
  483.xalancbmk:  -0.47%    1.31%     1.07%
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 2017011
8_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/ --testresult 20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/
The test result:
['20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/']
The test base:
['20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/']
Original numbers:
{'464.h264ref': 6.96, '429.mcf': 2.61, '473.astar': 2.95, '458.sjeng': 4.1, '456.hmmer': 2.99, '483.xalancbmk': 4.26}
{'464.h264ref': 7.15, '429.mcf': 2.7, '473.astar': 2.94, '458.sjeng': 4.3, '456.hmmer': 3.0, '483.xalancbmk': 4.27}

Diff:
['20170118_specint_aarch32/ILP32_disabled/a3eb14be_ilp32_disabled_20170122_1204/']
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -3.33%    0.00%     0.00%
      456.hmmer:  -0.33%    0.00%     0.00%
      458.sjeng:  -4.65%    0.00%     0.00%
    464.h264ref:  -2.66%    0.00%     0.00%
      473.astar:    0.34%    0.00%     0.00%
  483.xalancbmk:  -0.23%    0.00%     0.00%

2.  ILP32 enable
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged/ --testbase 20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/ --testresult 20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled --testresult 20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/
The test result:
['20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled', '20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/']
The test base:
['20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged/', '20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/']
Original numbers:
{'464.h264ref': 7.12, '429.mcf': 2.63, '473.astar': 2.955, '458.sjeng': 4.285, '456.hmmer': 2.965, '483.xalancbmk': 4.255}
{'464.h264ref': 7.130000000000001, '429.mcf': 2.66, '473.astar': 2.955, '458.sjeng': 4.295, '456.hmmer': 2.99, '483.xalancbmk': 4.225}

Diff:
['20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled', '20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/']
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -1.13%    1.52%     1.50%
      456.hmmer:  -0.84%    0.84%     0.33%
      458.sjeng:  -0.23%    0.12%     0.12%
    464.h264ref:  -0.14%    0.14%     0.28%
      473.astar:    0.00%    0.17%     0.51%
  483.xalancbmk:    0.71%    0.12%     1.07%
bamvor@instance-uu77xy2w:~/works/source/test_results/ILP32_performance_regression$ ~/works/source/small_tools_collection/misc/specint_get_data.py --testbase 20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/ --testresult 20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/
The test result:
['20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/']
The test base:
['20170118_specint_aarch32/ILP32_unmerged/c84d0bb_ilp32_unmerged_20170122_2225/']
Original numbers:
{'464.h264ref': 7.11, '429.mcf': 2.59, '473.astar': 2.95, '458.sjeng': 4.29, '456.hmmer': 2.94, '483.xalancbmk': 4.26}
{'464.h264ref': 7.15, '429.mcf': 2.7, '473.astar': 2.94, '458.sjeng': 4.3, '456.hmmer': 3.0, '483.xalancbmk': 4.27}

Diff:
['20170118_specint_aarch32/ILP32_enabled/a3eb14be_ilp32_enabled_20170122_1715/']
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -4.07%    0.00%     0.00%
      456.hmmer:  -2.00%    0.00%     0.00%
      458.sjeng:  -0.23%    0.00%     0.00%
    464.h264ref:  -0.56%    0.00%     0.00%
      473.astar:    0.34%    0.00%     0.00%
  483.xalancbmk:  -0.23%    0.00%     0.00%

17:32 2017-01-23
----------------
git send-email --to private-kwg@linaro.org --cc broonie@linaro.org --cc arnd@arndb.de --cc bamvor.zhangjian@linaro.org

Subject: [ACTIVITY] (Bamvor Jian Zhang) 2017-01-17 to 2017-01-23

* KWG-192: Use of contiguous page hint to create 64K pages

* ILP32
    - Performance test. Coefficient of Variation in hikey is a little bit bigger than d03.
      aarch64(ILP32 disable compare with ILP32 unmerge)
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.12%    0.00%     0.12%
       401.bzip2:   0.32%    0.18%     0.57%
         429.mcf:  -1.13%    1.40%     0.00%
       445.gobmk:  -0.14%    0.10%     0.63%
       458.sjeng:   0.21%    0.00%     0.42%
  462.libquantum:   0.31%    0.43%     0.00%
     464.h264ref:  -0.23%    0.28%     0.00%
   483.xalancbmk:   0.41%    2.17%     1.22%

      aarch64(ILP32 enable compare with ILP32 unmerge)
       testcases: increase cv(base) cv(result) cv: Coefficient of Variation
   400.perlbench:  -0.23%    0.12%     0.12%
       401.bzip2:   0.19%    0.38%     0.57%
         429.mcf:  -2.17%    1.73%     0.00%
       445.gobmk:  -0.21%    0.21%     0.63%
       458.sjeng:  -1.06%    1.50%     0.42%
  462.libquantum:  -0.46%    0.46%     0.00%
     464.h264ref:  -2.32%    1.82%     0.00%
   483.xalancbmk:   1.22%    1.08%     1.22%

      aarch32(ILP32 disable compare with ILP32 unmerge)
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -3.57%    1.75%     1.50%
      456.hmmer:  -0.33%    0.34%     0.33%
      458.sjeng:  -2.33%    2.26%     0.12%
    464.h264ref:  -1.82%    0.57%     0.28%
      473.astar:  -0.51%    0.34%     0.51%
  483.xalancbmk:  -0.47%    1.31%     1.07%

      aarch32(ILP32 enable compare with ILP32 unmerge)
      testcases: increase cv(base) cv(result) cv: Coefficient of Variation
        429.mcf:  -1.13%    1.52%     1.50%
      456.hmmer:  -0.84%    0.84%     0.33%
      458.sjeng:  -0.23%    0.12%     0.12%
    464.h264ref:  -0.14%    0.14%     0.28%
      473.astar:    0.00%    0.17%     0.51%
  483.xalancbmk:    0.71%    0.12%     1.07%

===Holiday===
24, Jan to 2, Feb.

