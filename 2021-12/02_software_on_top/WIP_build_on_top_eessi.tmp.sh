#!/bin/bash

## USAGE ##
# build_on_top_eessi.tmp.sh $ARCH $REPO
# where ARCH is the architecture in use
# where REPO is the repo you have your recipe(s) and patch(es)
# example:
# ARCH="linux/x86_64/intel/haswell"
# REPO="/mnt/shared/home/kErica/EB_TEST/repo/"



ARCH=$2 # linux/x86_64/intel/haswell
MYREPO_NAME=$1
archsElements=(${ARCH//\// })
OS=${archsElements[0]}
SUBARCH1=${archsElements[1]}
SUBARCH2=${archsElements[2]}
SUBARCH3=${archsElements[3]}
eb_version=eb --version | cut -f 4 -d ' '
source /cvmfs/pilot.eessi-hpc.org/2021.06/compat/$OS/$SUBARCH1/bin/bash

ml EasyBuild
eb_version=eb --version | cut -f 4 -d ' '

# Changes in EasyBuild configuration to install in the proper arch
#export EASYBUILD_INSTALLPATH="/cvmfs/pilot.eessi-hpc.org/2021.06/software/$ARCH"
export EASYBUILD_ROBOT="$MYREPO_NAME"
export EASYBUILD_SYSROOT=GENTOPREFIX_path 

# Find the recipe to be installed
EB_LIST=(${`find $MYREPO_NAME -name "*eb"`// /})
B=(${EB_TEST// / })
