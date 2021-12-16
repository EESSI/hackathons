#!/usr/bin/env bash

#some sanity checks
[ -z $EESSI_PREFIX ] && echo "not in EESSI env" && exit 0
env | grep -q EBROOT || echo "no modules loaded" || exit 0
which singularity >/dev/null || echo "singularity not found" || exit 0

#this should have enough space
LOCAL=`mktemp -dp .` #TODO: proper tmpdir check

#we always need to copy compat layer
compat="$EESSI_PREFIX/compat/$EESSI_OS_TYPE/$EESSI_CPU_FAMILY"

COPYCMD="rsync -aR"
#TODO handle naming properly, possibly from the last loaded module
TARBALL=tarball.tgz

#save whole env and figure out later what we need out of it
env > $LOCAL/env

echo "copying stuff from EESSI ..."

#this is the slow one - excludes save us almost 2GB
$COPYCMD --exclude "*/var/cache/*" --exclude "*/var/db/*" --exclude "*/var/tmp/*" $compat $LOCAL/ 2>/dev/null &

#these can be done in parallel
env | grep EBROOT | cut -f2 -d= | while read mpath
do
	$COPYCMD --exclude "*/easybuild/*" $mpath $LOCAL/ 2>/dev/null &
done

wait

echo "cleaning it ..."
find $LOCAL -type f -name "*.log" -exec rm {} \;
find $LOCAL -type f -name ".cvmfscatalog" -exec rm {} \;
#there's probably more that can be cleaned up

echo "packing it up ..."
#this tar/untar is here because this was developed on two different system
cd $LOCAL; tar zcf ../$TARBALL . ; cd ..

echo "cleaning up ..."

rm -rf $LOCAL & #this can be done in bg

#this image template also still needs work
cat image.def.tmpl | sed "s/TARBALL/$TARBALL/g" > image.def

echo "we need your password for singularity build:"

sudo singularity build eessi_container.sif image.def
