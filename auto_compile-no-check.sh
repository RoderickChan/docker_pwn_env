#!/bin/bash
# author: roderick
# https://github.com/RoderickChan/docker_pwn_env

set -Eeux
set -o pipefail

NEED_PUSH=1 # 1 or 0
DOCKERHUB_UASERNAME="roderickchan"
DOCKERHUB_PASSWORD=""

today=$(date +%Y%m%d)

# versions to compile
versions=("20.04" "22.04" "23.04" "23.10" "24.04")
v_length=${#versions[@]}


if [ "$NEED_PUSH" -eq "1" ]; then
    # remember to change the DOCKERHUB_UASERNAME in dockerhub
    if [ -n "${DOCKERHUB_PASSWORD}" ]; then
        docker login -u ${DOCKERHUB_UASERNAME} -p ${DOCKERHUB_PASSWORD}
    else
        docker login -u ${DOCKERHUB_UASERNAME}
    fi
fi

exit 0

regex_pattern="2\.[0-9]+-[0-9]+ubuntu[0-9]+\.?[0-9]*"

for ((i=0; i<v_length; i++))
do
    v=${versions[i]}
    # let's build image
    docker build --no-cache --build-arg BUILD_VERSION=${v} -t debug_pwn_env:${v} .
    search_res=$(docker run --rm debug_pwn_env:${v} grep -E -o -a "$regex_pattern" /lib/x86_64-linux-gnu/libc.so.6)
    docker tag debug_pwn_env:${v} ${DOCKERHUB_UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    docker rmi debug_pwn_env:${v}
    if [ "$NEED_PUSH" -eq "1" ]; then
        docker push ${DOCKERHUB_UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    fi

done
