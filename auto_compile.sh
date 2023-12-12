#!/bin/bash
# author: roderick

set -Eeux
set -o pipefail

NEED_PUSH=1
UASERNAME="roderickchan"

today=$(date +%Y%m%d)

# versions to compile
versions=("20.04" "22.04" "23.04" "23.10" "24.04")
glibcs=("2.31-0ubuntu9.14" "2.35-0ubuntu3.5" "2.37-0ubuntu2.2" "2.38-1ubuntu6" "2.38-3ubuntu1")

v_length=${#versions[@]}
g_length=${#glibcs[@]}

# check length of these two array
if [ "$v_length" -ne "$g_length" ]; then
    echo "Error --> The length of 'versions' and 'glibcs' is different, the former is $v_length, the latter is $g_length"
    exit 2
fi

if [ "$NEED_PUSH" -eq "1" ]; then
    # remember to change the UASERNAME in dockerhub
    docker login -u ${UASERNAME}
fi

regex_pattern="2\.[0-9]+-[0-9]+ubuntu[0-9]+\.?[0-9]*"

for ((i=0; i<v_length; i++))
do
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

    # let's build image
    docker build --no-cache --build-arg BUILD_VERSION=${v} -t debug_pwn_env:${v} .
    docker tag debug_pwn_env:${v} ${UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    docker rmi debug_pwn_env:${v}
    if [ "$NEED_PUSH" -eq "1" ]; then
        docker push ${UASERNAME}/debug_pwn_env:${v}-${search_res}-${today}
    fi

done
