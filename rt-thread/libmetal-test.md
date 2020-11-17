
# libmetal测试用例

目前上传的用例是mutex测试。

## Mutex测试
测试内容：测试mutex acquire和release，循环一千次。

测试过程
1.  切分支：[zhangjian-libmetal](https://git.rt-thread.com/ITD/riscv64_openamp_outside/-/tree/zhangjian-libmetal)
2.  进入rv64目录 `cd bsp/riscv64-virt`
4.  编译：`scons`
5.  参考 `rt-thread/bsp/riscv64-virt/readme.md`运行。
6.  在finsh中执行测试命令：`mutex_test`，每100次mutex会打印counter，测试1000次，测试结束。
7.  也可以在msh中输入`metal_tests_run_wrapper`测试。

