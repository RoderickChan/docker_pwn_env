#!/bin/bash

update_repo(){
    cd ~/$1
    git pull
}

update_repo gef
update_repo Pwngdb
update_repo pwntools
update_repo pwncli

exec /bin/bash

