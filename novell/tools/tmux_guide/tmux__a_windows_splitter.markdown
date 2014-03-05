# 使用tmux分割窗口

## 参考文档
reference [tmux howto](https://wiki.freebsdchina.org/software/t/tmux)

## 安装
> zypper in tmux

## 简介
tmux分为session, window, panel.
![tmux window and panel](tmux.jpg)

上图的0-4表示五个window, 左右是两个panel. 所有5个windows都在一个session里面. tmux支持多个session.

## 配置
### configuration file
cat ~/.tmux.conf
>     # change send-prefix
>     unbind C-b
>     set -g prefix ^A
>     bind   C-a         send-prefix
>     
>     set -g buffer-limit 9999
>     set -g display-time 1000
>     
>     # reload config file
>     bind R source-file ~/.tmux.conf \; display-message "tmux.conf reloaded!"
>     
>     # using vi style in tmux copy and paste
>     set-window-option -g mode-keys vi
>     
>     #copy with system clipboard
    bind C-c run-shell "tmux show-buffer | xclip -sel clip -i" \; display-message "Copied tmux buffer to system clipboard"
    bind C-v run-shell "tmux set-buffer -- \"$(xclip -o -selection clipboard)\"; tmux paste-buffer"\; display-message "Copied system clipboard to tmux buffer"

xclip在xclip包中, 默认已经安装.

上面配置文件快捷键(bind命令)是Ctrl+A, Ctl+A,?是帮助. 下文都忽略Ctl+A.
例如
> o: move to the Other panel
> 
> n: Next window
> 
> p: Previous window
> 
> c: Create windows
> %: 纵向分割窗口
> ": 横向分割窗口

## copy and paste
### 在tmux间复制和粘贴
[: 复制模式. 可以选择vim风格还是emcs风格. 我选择的是vim风格. 用hjkl等vim快捷键移动, 用空格开始复制区域的选择(区域会反白), 用回车结束.
]: paste.

### 在tmux与系统剪切板间复制
Ctl+c, Ctl+v

### 参考
(https://wiki.archlinux.org/index.php/tmux)
(http://joncairns.com/2013/06/copying-between-tmux-buffers-and-the-system-clipboard/)
(http://blog.csdn.net/yangzhongxuan/article/details/6890232)

## attach and detach
tmux有个亮点，就是如果ssh连接断开，tmux session不会关闭。用tmux启动的程序会在后台运行，不会退出。
如果网络连接断了，可以用tmux ls查看session并用tmux attach连接。
bamvor@laptop-work:~> tmux ls
0: 6 windows (created Wed Mar  5 13:00:04 2014) [146x37]
bamvor@laptop-work:~> tmux attach -t 0
[detached]
注：d是detach。如果有多个session，可以自如切换。

## 小技巧
tmux里面同样是Ctl+s, 表示suspend当前panel. suspend时就像是当前panel死掉了, 其实用Ctl+q resume就活了.

## markdown reference
[Markdown 语法说明 (简体中文版)](http://wowubuntu.com/markdown/)

