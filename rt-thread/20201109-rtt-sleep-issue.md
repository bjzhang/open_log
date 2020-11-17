
复现过程
1.  切分支：[rv64_base_test](https://git.rt-thread.com/ITD/riscv64_openamp_outside/-/tree/rv64_base_test)
2.  进入rv64目录 `cd bsp/riscv64-virt`
3.  修改 `applications/thread_static_simple.c`, 注释其中的`SLEEP_IN_CHILD_THREAD`
4.  编译：`scons`
5.  参考 `rt-thread/bsp/riscv64-virt/readme.md`运行。
6.  在finsh中执行测试命令：`thread_test`，可以看到在主线程中sleep无问题。
```
finsh />thread_test()
before delay
thread1 count: 0
thread1 count: 1
thread1 count: 2
thread1 count: 3
thread1 count: 4
thread1 count: 5
thread1 count: 6
thread1 count: 7
thread1 count: 8
thread1 count: 9
thread0 count: 0
thread0 count: 1
thread0 count: 2
thread0 count: 3
thread0 count: 4
thread0 count: 5
thread0 count: 6
thread0 count: 7
thread0 count: 8
thread0 count: 9
after delay
        0, 0x00000000
finsh />thread_test()
```
7.  修改 `applications/thread_static_simple.c`, 不注释其中的`SLEEP_IN_CHILD_THREAD`，测试会卡住：
```
finsh />thread_test()
before delay
thread1 count: 0
thread0 count: 0
thread1 count: 1
```
