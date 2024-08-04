ARG BUILD_VERSION

FROM ubuntu:$BUILD_VERSION

ARG DEBIAN_FRONTEND=noninteractive
ARG HUB_DOMAIN=github.com
ARG NORMAL_USER_NAME=ctf

ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /root

RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y --fix-missing python3 python3-pip python3-dev lib32z1 \
    xinetd curl gcc gdb gdbserver g++ git libssl-dev libffi-dev build-essential tmux \
    vim iputils-ping gdb-multiarch \
    file net-tools socat ruby ruby-dev locales autoconf automake libtool make && \
    gem install one_gadget && \
    gem install seccomp-tools && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# 先执行容易失败的操作
RUN git clone https://${HUB_DOMAIN}/pwndbg/pwndbg && \
    cd ./pwndbg && \
    ./setup.sh

RUN git clone https://${HUB_DOMAIN}/NixOS/patchelf.git && \
    cd ./patchelf && \
    ./bootstrap.sh && \
    ./configure && \
    make && \
    make install

RUN git clone https://${HUB_DOMAIN}/hugsy/gef.git && \
    git clone https://${HUB_DOMAIN}/RoderickChan/Pwngdb.git && \
    git clone https://${HUB_DOMAIN}/Gallopsled/pwntools && \
    (mv /usr/lib/python3.1?/EXTERNALLY-MANAGED /etc/EXTERNALLY-MANAGED.bck || true) && \
    pip3 install --upgrade --editable ./pwntools && \
    git clone https://${HUB_DOMAIN}/RoderickChan/pwncli.git && \
    pip3 install --upgrade --editable ./pwncli


COPY ./gdb-gef /bin
COPY ./gdb-pwndbg /bin
COPY ./update.sh /bin
COPY ./test-this-container.sh /bin
COPY ./heaptrace /bin
COPY ./.tmux.conf ./
COPY ./.gdbinit ./
COPY ./flag /
COPY ./flag /flag.txt

RUN chmod +x /bin/gdb-gef /bin/gdb-pwndbg /bin/update.sh /bin/test-this-container.sh /bin/heaptrace && \
    echo "root:root" | chpasswd && \
    (python3 -m pip install --upgrade pip || true ) && \
    pip3 install ropper capstone z3-solver qiling lief

# normal user
RUN useradd ${NORMAL_USER_NAME} -d /home/${NORMAL_USER_NAME} -m -s /bin/bash -u 1001 && \
    echo "${NORMAL_USER_NAME}:${NORMAL_USER_NAME}" | chpasswd && \
    cp -r /root/pwndbg /home/${NORMAL_USER_NAME} && \
    cp -r /root/gef /home/${NORMAL_USER_NAME} && \
    cp -r /root/pwntools /home/${NORMAL_USER_NAME} && \
    cp -r /root/Pwngdb /home/${NORMAL_USER_NAME} && \
    cp -r /root/pwncli /home/${NORMAL_USER_NAME} && \
    cp /root/.tmux.conf /home/${NORMAL_USER_NAME} && \
    cp /root/.gdbinit /home/${NORMAL_USER_NAME} && \
    cp /flag /home/${NORMAL_USER_NAME} && \
    cp /flag.txt /home/${NORMAL_USER_NAME} && \
    chown -R ${NORMAL_USER_NAME}:${NORMAL_USER_NAME} /home/${NORMAL_USER_NAME}

USER ${NORMAL_USER_NAME}:${NORMAL_USER_NAME}

WORKDIR /home/${NORMAL_USER_NAME}

RUN pip3 install --upgrade --editable ./pwntools && \
    pip3 install --upgrade --editable ./pwncli


# switch to root and install zsh
USER root:root
RUN apt-get install -y sudo zsh && usermod -s /bin/zsh ${NORMAL_USER_NAME} && \
    echo "${NORMAL_USER_NAME} ALL=(ALL) NOPASSWD : ALL" | tee /etc/sudoers.d/${NORMAL_USER_NAME}sudo 

# switch 2 normal user
USER ${NORMAL_USER_NAME}:${NORMAL_USER_NAME}
WORKDIR /home/${NORMAL_USER_NAME}


# install on-my-zsh
RUN curl -fsSL -O https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
    chmod +x  ./install.sh && \ 
    sed -i -e 's/read[[:space:]]*-r[[:space:]]*opt/opt=n/g' ./install.sh && \
    ./install.sh && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

COPY ./.zshrc ./

# expose some ports
EXPOSE 20 21 22 80 443 23946 10001 10002 10003 10004 10005

CMD ["/bin/update.sh"]
