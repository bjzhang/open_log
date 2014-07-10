
使用ssh设置代理

# 参考文档：
- [Proxy Firefox through a SSH tunnel](https://calomel.org/firefox_ssh_proxy.html)
- 快速参考文档
    http://www.linuxjournal.com/content/use-ssh-create-http-proxy
    http://z9.io/2008/02/13/how-to-use-ssh-as-a-proxy-server/

# 用tutum 建立ubuntu 14.04
    https://app.tutum.co/container/apps/launch/


start launch app
![start launch app](tutum_01__start_launch_app.jpg "start launch app")

use tutum ubuntu image
![use tutum ubuntu image](tutum_02__use_tutum_ubuntu_image.jpg "use tutum ubuntu image")

or use other docker image
![use other docker image](tutum_03__use_other_docker_image.jpg "use other docker image")

application configuraiton: select tag
![image  select tag](tutum_04__image__select_tag.jpg "image  select tag")

application configuraiton: could export port
![image  could export port](tutum_05__image__could_export_port.jpg "image  could export port")

application configuraiton: different container size
![image  different container size](tutum_06__image__different_container_size.jpg "image  different container size")

could link to other container belong to you
![could link to other container belong to you](tutum_08__could_link_to_other_container_belong_to_you.jpg "could link to other container belong to you")

launch
![launch](tutum_09__launch.jpg "launch")

run successful
![run successful](tutum_10__run_successful.jpg "run_successful")

enter container page
![enter container](tutum_11__enter_container.jpg "enter_container")

ssh host name and port
![ssh host name and port](tutum 12  ssh host name and port.jpg "ssh host name and port")

here is the root password
![root password](tutum_13___root_password.jpg "_root_password")

# 开ssh端口
## 写入ssh cofnig
    tail -n 4 ~/.ssh/config

    Host ssh_proxy
    HostName ubuntu-2-bjzhangcaea6c03b19249ff.beta.tutum.io
    User root
    Port 49189

## 连接
    ssh -D 8080 ssh_proxy

# 如何在firefox里面设置socks5代理
![firefox proxy howto](firefox_proxy.jpg "Firefox proxy HOWTO")

## 设置代理前的ip
![before proxy](whatisyourip__without_proxy.jpg "设置代理前的ip")
## 设置代理后的ip
![after set proxy](whatisyourip__with_proxy.jpg "设置代理后的ip")

# 后记
tutum是amazon ec2?
> ping ubuntu-2-bjzhangcaea6c03b19249ff.beta.tutum.io
PING ec2-54-85-142-171.compute-1.amazonaws.com (54.85.142.171) 56(84) bytes of data.

