#!/bin/bash
# author: roderick
# https://github.com/RoderickChan/docker_pwn_env

set -Eeux
set -o pipefail

NEED_PUSH=1 # 1 or 0
CHECK_VERSION=1
DOCKERHUB_UASERNAME="roderickchan"
DOCKERHUB_PASSWORD=""

today=$(date +%Y%m%d)

# versions to compile
versions=("20.04" "22.04" "23.04" "23.10" "24.04")

if [ "$NEED_PUSH" -eq "1" ]; then

    glibcs=("2.31-0ubuntu9.14" "2.35-0ubuntu3.6" "2.37-0ubuntu2.2" "2.38-1ubuntu6.1" "2.38-3ubuntu1")

    v_length=${#versions[@]}
    g_length=${#glibcs[@]}

    # check length of these two array
    if [ "$v_length" -ne "$g_length" ]; then
        echo "Error --> The length of 'versions' and 'glibcs' is different, the former is $v_length, the latter is $g_length"
        exit 2
    fi

fi

if [ "$NEED_PUSH" -eq "1" ]; then
    # remember to change the DOCKERHUB_UASERNAME in dockerhub
    if [ -n "${DOCKERHUB_PASSWORD}" ]; then
        docker login -u ${DOCKERHUB_UASERNAME} -p ${DOCKERHUB_PASSWORD}
    else
        docker login -u ${DOCKERHUB_UASERNAME}
    fi
fi

regex_pattern="2\.[0-9]+-[0-9]+ubuntu[0-9]+\.?[0-9]*"

for ((i=0; i<v_length; i++))
do

if [ "$NEED_PUSH" -eq "1" ]; then
    v=${versions[i]}
    g=${glibcs[i]}
    docker pull ubuntu:${v}
    search_res=$(docker run --rm ubuntu:${v} bash -c "apt update; apt upgrade -y ; grep -E -o -a \"$regex_pattern\" /lib/x86_64-linux-gnu/libc.so.6" | tail -n 1)
    # The result must match the pattern
    if [[ ! $search_res =~ $regex_pattern ]]; then
        echo "Invalid search result: $search_res"
        exit 2
    fi

    if [ "$g" == "$search_res" ]; then
        echo "There is no need to update. Current glibc version of ubuntu $v is $search_res"
        continue
    else
        echo "Update ubuntu $v"
        # self update
        sed -i "s/$g/$search_res/g" $0
    fi

fi

    # let's build image
    docker build --no-cache --build-arg BUILD_VERSION=${v} -t debug_pwn_env:${v} .
    docker tag debug_pwn_env:${v} ${DOCKERHUB_UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    docker rmi debug_pwn_env:${v}
    if [ "$NEED_PUSH" -eq "1" ]; then
        docker push ${DOCKERHUB_UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    fi

done
