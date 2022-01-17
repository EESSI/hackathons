#!/bin/bash
mkdir -p $HOME/easybuild
for repo in framework easyblocks easyconfigs; do
    cd $HOME/easybuild
    if [ ! -d easybuild-${repo} ]; then
        git clone https://github.com/easybuilders/easybuild-${repo}.git
    fi
    cd easybuild-${repo}/
    git checkout develop
    git pull origin develop
done
