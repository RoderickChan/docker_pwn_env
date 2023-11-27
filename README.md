## pull image

pull from <https://hub.docker.com/r/roderickchan/debug_pwn_env/tags>, such as `docker pull roderickchan/debug_pwn_env:23.04-2.37-0ubuntu2.1-20231127`. The tag of the image means `Ubuntu 23.04`, glibc version `2.37-0ubuntu2.1` and image built in `2023-11-27`. 

I introduce how to use `docker` in a Chinese [blog](https://www.roderickchan.cn/zh-cn/2023-02-13-%E4%BD%BF%E7%94%A8docker%E8%B0%83%E8%AF%95pwn%E9%A2%98/). 

可以根据镜像的`tag`查找自己所需的镜像。

点击[博客](https://www.roderickchan.cn/zh-cn/2023-02-13-%E4%BD%BF%E7%94%A8docker%E8%B0%83%E8%AF%95pwn%E9%A2%98/)查看如何使用`docker`调试`pwn`题。

## run container

启动容器：

```shell
docker run -it -d -v host_path:container_path -p host_port:container_port --cap-add=SYS_PTRACE IMAGE_ID # auto update 自动执行update.sh脚本

docker run -it -d -v host_path:container_path -p host_port:container_port --cap-add=SYS_PTRACE IMAGE_ID /bin/sh # do not update 不会自动更新

docker run -it -d -v host_path:container_path -p host_port:container_port --privileged IMAGE_ID # privileged enabled and auto update 给特权标志和自动更新

docker run -it -d -v host_path:container_path -p host_port:container_port --privileged IMAGE_ID /bin/sh # privileged enabled and auto update 给特权标志和自动更新
```

## attach container

进入容器(enter a container)：

```shell
docker exec -it CONTAINER_ID /bin/sh
docker exec -it -u root CONTAINER_ID /bin/sh
```

## check container 

检查容器是否正常：
```
/bin/test-this-container.sh
```

input `q` after launching `gdb` successfully.
进入`gdb`后输入`q`退出。


## build image

构建镜像(single build)：

```shell
docker build --build-arg BUILD_VERSION=20.04 -t debug_pwn_env:20.04 .
```

自动构建(auto build): 
```shell
chmod +x ./auto_compile.sh
./auto_compile.sh
```

## Note 

注意：镜像中安装了`oh-my-zsh`，提供`zsh-autosuggestions`和`zsh-syntax-highlighting`擦火箭，推荐使用`zsh`作为`shell`登入。

I have install `oh-my-zsh` and `zsh-autosuggestions` plugin, `zsh-syntax-highlighting` plugin in the image, if you like it, please launch a container with `/bin/zsh`.

example:

```shell
docker run -it -d -v $PWD:/home/ctf/hacker -p 10001:10001 --privileged IMAGE_ID /bin/zsh # privileged enabled and auto update 给特权标志和自动更新
```

## Feature 

software and packages in the image: 
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
