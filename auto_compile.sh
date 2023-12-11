#!/bin/bash

set -ex

NEED_PUSH=0

# versions to compile
versions=(20.04 22.04 23.04 23.10 24.04)
today=$(date +%Y%m%d)
username="roderickchan"
if [ "$NEED_PUSH" = "1" ]; then
    # remember to change the username in dockerhub
    docker login -u ${username}
fi

for v in ${versions[@]}
do
    docker build --no-cache --build-arg BUILD_VERSION=${v} -t debug_pwn_env:${v} .
    res=$(docker run --rm debug_pwn_env:${v} strings /lib/x86_64-linux-gnu/libc.so.6 | grep -Eo "[0-9]+\.[0-9]+-[0-9]+ubuntu[0-9]+\.?[0-9]*")
    docker tag debug_pwn_env:${v} ${username}/debug_pwn_env:${v}-${res}-${today}
    docker rmi debug_pwn_env:${v}
    if [ "$NEED_PUSH" = "1" ]; then
        docker push ${username}/debug_pwn_env:${v}-${res}-${today}
    fi

done
