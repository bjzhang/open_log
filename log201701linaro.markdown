
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
