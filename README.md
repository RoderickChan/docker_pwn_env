
- [Docker Image Based On Ubuntu For Pwn Debug](#docker-image-based-on-ubuntu-for-pwn-debug)
  - [Pull Image](#pull-image)
  - [Example](#example)
  - [Run Container](#run-container)
  - [Attach Container](#attach-container)
  - [Check Container](#check-container)
  - [Build Image](#build-image)
  - [Use Zsh](#use-zsh)
  - [Feature](#feature)


# Docker Image Based On Ubuntu For Pwn Debug

基于`Ubuntu`构建并用于快速调试`pwn`题的镜像

## Pull Image

Pull images from <https://hub.docker.com/r/roderickchan/debug_pwn_env/tags>, such as `docker pull roderickchan/debug_pwn_env:23.04-2.37-0ubuntu2.1-20231127`. The tag of the image means `Ubuntu 23.04`, glibc version `2.37-0ubuntu2.1` and image built in `2023-11-27`. 

I introduce how to use `docker` in a Chinese [blog](https://www.roderickchan.cn/zh-cn/2023-02-13-%E4%BD%BF%E7%94%A8docker%E8%B0%83%E8%AF%95pwn%E9%A2%98/). 

点击[博客](https://www.roderickchan.cn/zh-cn/2023-02-13-%E4%BD%BF%E7%94%A8docker%E8%B0%83%E8%AF%95pwn%E9%A2%98/)查看如何使用`docker`调试`pwn`题。

Current tags in the [dockerhub](https://hub.docker.com/r/roderickchan/debug_pwn_env/tags):  
现有的镜像[列表](https://hub.docker.com/r/roderickchan/debug_pwn_env/tags)：

| Ubuntu Version | Glibc Version    | Pull command                                                 | User/Password| Status |
| :------------: | :--------------: | :----------------------------------------------------------: | :-- | :-: |
| Ubuntu 23.10   | 2.38-1ubuntu6  | docker pull roderickchan/debug_pwn_env:23.10-2.38-1ubuntu6-20231127 | 1. root/root<br />2. ctf/ctf | **Updating** |
| Ubuntu 23.04   | 2.37-0ubuntu2.1  | docker pull roderickchan/debug_pwn_env:23.04-2.37-0ubuntu2.1-20231127 | 1. root/root<br />2. ctf/ctf | **Updating** |
| Ubuntu 22.04   | 2.35-0ubuntu3.4  | docker pullroderickchan/debug_pwn_env:22.04-2.35-0ubuntu3.4-20231127 | 1. root/root<br />2. ctf/ctf | **Updating** |
| Ubuntu 22.04   | 2.35-0ubuntu3.1  | docker pull roderickchan/debug_pwn_env:22.04-2.35-0ubuntu3.1-20230213 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 22.04   | 2.35-0ubuntu3    | docker pull roderickchan/debug_pwn_env:22.04-2.35-0ubuntu3-20220707 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 20.04   | 2.31-0ubuntu9.12 | docker pull roderickchan/debug_pwn_env:20.04-2.31-0ubuntu9.12-20231127 | 1. root/root<br />2. ctf/ctf | **Updating** |
| Ubuntu 20.04   | 2.31-0ubuntu9.9  | docker pull roderickchan/debug_pwn_env:20.04-2.31-0ubuntu9.9-20230213 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 20.04   | 2.31-0ubuntu9.7  | docker pull roderickchan/debug_pwn_env:20.04-2.31-0ubuntu9.7-20220525 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 21.10   | 2.34-0ubuntu3.2  | docker pull roderickchan/debug_pwn_env:21.10-2.34-0ubuntu3.2-20220707 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 21.04   | 2.33-0ubuntu5    | docker pull roderickchan/debug_pwn_env:21.04-2.33-0ubuntu5-20220908 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 18.04   | 2.27-3ubuntu1.6  | docker pull roderickchan/debug_pwn_env:18.04-2.27-3ubuntu1.6-20230213 | 1. root/root<br />2. roderick | Archived |
| Ubuntu 18.04   | 2.27-3ubuntu1.5  | docker pull roderickchan/debug_pwn_env:18.04-2.27-3ubuntu1.5-20220525 | 1. root/root<br />2. roderick | Archived |



Two users in the image:  
- `root` user and password: `root/root`  
- `ctf` user and password: `ctf/ctf`

## Example  

This example uses the old image. The normal username in old image was `roderick`, the current username is now `ctf`.

示例采用原来的镜像。原来的普通用户名为`roderick`，现在的普通用户名为`ctf`。

[![asciicast](https://asciinema.org/a/623588.svg)](https://asciinema.org/a/623588)

This example uses the updating image:  

[![asciicast](https://asciinema.org/a/623673.svg)](https://asciinema.org/a/623673)

## Run Container

启动容器：

```shell
docker run -it -d -v host_path:container_path -p host_port:container_port --cap-add=SYS_PTRACE IMAGE_ID # auto update 自动执行update.sh脚本

docker run -it -d -v host_path:container_path -p host_port:container_port --cap-add=SYS_PTRACE IMAGE_ID /bin/sh # do not update 不会自动更新

docker run -it -d -v host_path:container_path -p host_port:container_port --privileged IMAGE_ID # privileged enabled and auto update 给特权标志和自动更新

docker run -it -d -v host_path:container_path -p host_port:container_port --privileged IMAGE_ID /bin/sh # privileged enabled and auto update 给特权标志和自动更新
```

## Attach Container

进入容器(enter a container)：

```shell
docker exec -it CONTAINER_ID /bin/sh
docker exec -it -u root CONTAINER_ID /bin/sh
```

## Check Container 

检查容器是否正常：
```
/bin/test-this-container.sh
```

input `q` in gdb to exit.  
进入`gdb`后输入`q`退出。


## Build Image

构建镜像(single build)：

```shell
docker build --build-arg BUILD_VERSION=20.04 -t debug_pwn_env:20.04 .
```

自动构建(auto build):

```shell

chmod +x ./auto_compile.sh
./auto_compile.sh
```

## Use Zsh

注意：镜像中安装了`oh-my-zsh`，提供`zsh-autosuggestions`和`zsh-syntax-highlighting`插件，推荐使用`zsh`作为`shell`登入。

I have installed `oh-my-zsh` and `zsh-autosuggestions` plugin, `zsh-syntax-highlighting` plugin in the image, if you like it, please launch a container with `/bin/zsh`.

example:

```shell
docker run -it -d -v $PWD:/home/ctf/hacker -p 10001:10001 --privileged IMAGE_ID /bin/zsh # privileged enabled and auto update 给特权标志和自动更新
```

## Feature 

Software and packages in the image:   
镜像中含有的软件和包：

- pwncli
- pwntools  
- pwndbg  
- Pwngdb
- gef  
- one_gadget  
- ropper 
- ropgadget
- seccomp-tools  
- patchelf  
- capstone  
- z3-solver  
- qiling  
- lief  
- socat  
- tmux 
- zsh 
- gdb-multiarch
- vim 
- curl 
- gdbserver

Read `Dockerfile` to get more infomation.

阅读`Dockerfile`获得更多信息。
