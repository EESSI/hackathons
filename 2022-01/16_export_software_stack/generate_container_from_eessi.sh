#!/usr/bin/env bash

#includes ideas from https://betterdev.blog/minimal-safe-bash-script-template/

trap cleanup SIGINT SIGTERM EXIT

LOCAL=`mktemp -d`

cleanup() {
	trap - SIGINT SIGTERM EXIT
	rm -rf $LOCAL
}

usage() {
	cat <<EOF
Usage: $(basename "$BASH_SOURCE[0])") [-h] [-a] [-v] [-d] [-n]

Use this script to pack up your current EESSI environment and loaded modules
into a singularity container to preserve it for future use or use it offline.

Options:
-h, --help		Print this help and exit
-V, --verbose		See what this script is doing
-a, --author		Mandatory: you need to specify who the author is
-v, --version		Optional: string to append to container version (default: `date -I`)
-d, --destination 	Optional: path where to store container image (default: /tmp)
-n, --name		Optional: how to name container image (default: construct name from your last loaded module)
-g, --generic		Optional: use generic instead of specific CPU tuned software

EOF
	exit
}

msg() {
	echo >&2 -e "${1-}"
}

die() {
	local msg=$1
	local code=${2-1}
	msg "$msg"
	exit "$code"
}

parse_params() {
	version=`date -I`
	#construct image name from last loaded module
	LASTMODULE="`echo $LOADEDMODULES | tr ':' '\n' | tail -1`"
	name="EESSI_`echo $LASTMODULE | tr '/' '_'`"
	dest="/tmp"
	use_generic="false"
	verbose="false"

	while :; do
		case "${1-}" in
			-h | --help) usage ;;
			-V | --verbose)
				set -x 
				verbose="true"
				;;
			-a | --author) 
				author="${2-}"
				shift
				;;
			-v | --version)
				version="`date -I`-${2-}"
				shift
				;;
			-d | --destination)
				dest="${2-}"
				shift
				;;
			-n | --name)
				name="${2-}"
				shift
				;;
			-g | --generic)
				use_generic="true"
				shift
				;;
			-?*) die "Unknown option: $1" ;;
			*) break ;;
		esac
		shift
	done

	args=("$@")

	[[ -z "${author-}" ]] && die "I need to know whom to set as author"

	return 0
}

echo

#some safety nets
if [[ -z "$EESSI_PREFIX" ]]
then
	die "not in EESSI env"
fi
if ! env | grep -q EBROOT
then
	die "no modules loaded"
fi

parse_params "$@"

if ! which singularity >/dev/null 2>&1 
then
	die "singularity not found"
fi
if ! grep -q `whoami`: /etc/subuid 
then
    if ! grep -q `id -u`: /etc/subuid
    then
	    die "ask admin to add you to /etc/subuid" 
    fi
fi
if ! grep -q `whoami`: /etc/subgid
then
    if ! grep -q `id -u`: /etc/subgid # is this correct? or should this be id -g ?
    then
	die "ask admin to add you to /etc/subgid"
    fi
fi

#check that $dest is writable
if [[ ! -w "$dest" ]]
then
	die "Cannot write to $dest"
fi

if [[ "$use_generic" == "true" ]]
then
	export EESSI_SOFTWARE_SUBDIR=$EESSI_CPU_FAMILY/generic
	export EESSI_MODULEPATH=$EESSI_PREFIX/software/$EESSI_OS_TYPE/$EESSI_SOFTWARE_SUBDIR/modules/all
	module use $EESSI_MODULEPATH
fi

#we always need to copy compat layer and init
compat="$EESSI_PREFIX/compat/$EESSI_OS_TYPE/$EESSI_CPU_FAMILY"
init="$EESSI_PREFIX/init"
sw="`env | grep EBROOT | cut -f2 -d= | tr '\n' ' '`"
to_copy="$compat $init $EESSI_MODULEPATH $LMOD_RC $sw"

msg "Checking how much space we need ..."
needspace=$((`du -s $to_copy 2>/dev/null | cut -f1 -d'/' | tr '\n' '+'; echo 0`))

#check that we have least 3x that available in /tmp (we dump tarball here, copy it to container and untar it there)
if [[ `df /tmp | awk '/[0-9]%/{print $(NF-2)}'` -lt $((3*$needspace)) ]]
then
	die "not enough disk space in /tmp" 
fi
#and same for our destination
if [[ `df $dest | awk '/[0-9]%/{print $(NF-2)}'` -lt $needspace ]]
then
	die "not enough disk space in $dest" 
fi

msg "Building ${name}.sif ..."

#we have to do it like this to avoid singularity complaining about copying broken symlinks in compat layer
tar zcf $LOCAL/tarball.tgz --exclude "var/cache" --exclude "var/db" --exclude "var/tmp" --exclude "*.log" --exclude "*.cvmfscatalog" $to_copy 2>/dev/null

#prepare image definition
cat <<EOF > $LOCAL/image.def
Bootstrap: docker
From: rockylinux:latest
%files
  $LOCAL/tarball.tgz /
%post
#  yum -y update && yum -y install tar vim-minimal && yum clean all
  tar zxf /tarball.tgz -C / && rm /tarball.tgz
  echo "echo ; echo EESSI Snapshot created on `date` for $LASTMODULE built for $EESSI_SOFTWARE_SUBDIR; echo" >> \$SINGULARITY_ENVIRONMENT
  echo "if [ -n \"\\\$(env | grep ^MOD)\" -o -n \"\\\$(env | grep ^EESSI)\" ]; then" >> \$SINGULARITY_ENVIRONMENT
  echo "echo please run this container with --cleanenv; echo; exit 1" >> \$SINGULARITY_ENVIRONMENT
  echo "else" >> \$SINGULARITY_ENVIRONMENT
  echo "echo Enter these commands to start:; echo" >> \$SINGULARITY_ENVIRONMENT
  echo "echo \"  source $EESSI_PREFIX/init/bash\" " >> \$SINGULARITY_ENVIRONMENT
  echo "if [[ \"$use_generic\" == \"true\" ]]; then echo '  module use \\\$EESSI_PREFIX/software/\\\$EESSI_OS_TYPE/\\\$EESSI_CPU_FAMILY/generic/modules/all'; fi " >> \$SINGULARITY_ENVIRONMENT
  echo "echo \"  module load $LASTMODULE\" " >> \$SINGULARITY_ENVIRONMENT
  echo "echo; echo Happy computing,; echo EESSI team; echo" >> \$SINGULARITY_ENVIRONMENT
  echo "fi" >> \$SINGULARITY_ENVIRONMENT
%labels
  Author $author
  Version $version
EOF

#and build image
if [[ "$verbose" == "true" ]]
then
	singularity build --fakeroot -F ${dest}/${name}.sif $LOCAL/image.def
else
	singularity build --fakeroot -F ${dest}/${name}.sif $LOCAL/image.def >/dev/null 2>&1
fi

if [ $? -eq 0 ]
then
	echo
	msg "Congratulations, your image is now available at ${dest}/${name}.sif"
	msg "Run it with --cleanenv and happy computing"
	echo
fi
