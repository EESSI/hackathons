#!/usr/bin/env bash

# setting up the environment:
shopt -s expand_aliases
export EASYBUILD_SOURCEPATH=/software/easybuild/sources
export EASYBUILD_INSTALLPATH=/apps/easybuild
export EASYBUILD_BUILDPATH="/dev/shm"
export EASYBUILD_TMPDIR="/dev/shm/easybuild"
export EASYBUILD_PARALLEL=8
export MODULEPATH=/apps/easybuild/modules/all
export EASYBUILD_ACCEPT_EULA_FOR="Intel-oneAPI,NVHPC"
alias eb="eb --robot --download-timeout=100"
export PYTHONIOENCODING="utf-8"

# somehow the cluster's environment modules go through
# into the container. So we simply source the script again
ml use /apps/easybuild/modules/all

# loading the right EasyBuild module:
ml EasyBuild/4.5.1

# check what we got
eb --version

# check the loaded modules
ml

# building stuff
eb --fetch zlib-1.2.11.eb 
eb zlib-1.2.11.eb 

# building stuff using EasyStack
eb --fetch --experimental --easystack /mnt/shared/home/sassy-crick/git/hackathons/2021-12/03_workflow/scripts/softwarelist.yaml 
eb --experimental --easystack /mnt/shared/home/sassy-crick/git/hackathons/2021-12/03_workflow/scripts/softwarelist.yaml 

# check all available modules
ml spider

