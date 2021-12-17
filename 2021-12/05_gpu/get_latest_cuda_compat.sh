#!/bin/bash

# get arch type from environment variable
if [[ -z "${EESSI_CPU_FAMILY// }" ]]; then
        echo "You are not in an EESSI environment..."
        exit 1
fi
# get OS type
# TODO: needs testing on more OS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    os=$NAME
    ver=$VERSION_ID
    if [[ "$os" == *"Rocky"* ]]; then
        os="rhel"
    fi
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    os=$(lsb_release -si)
    ver=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    os=$DISTRIB_ID
    ver=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    os=Debian
    ver=$(cat /etc/debian_version)
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    os=$(uname -s)
    ver=$(uname -r)
fi
# convert to major versions, e.g. rhel8.5 -> rhel8
# TODO: needs testing for e.g. Ubuntu 20.04
ver=${ver%.*}
# build URL for CUDA libraries
cuda_url="https://developer.download.nvidia.com/compute/cuda/repos/"${os}${ver}"/"${EESSI_CPU_FAMILY}"/"
# get latest version, files are sorted by date
# TODO: probably better to explicitly check version numbers than trusting that it is sorted
latest_file=$(curl -s "${cuda_url}" | grep 'cuda-compat' | tail -1)
if [[ -z "${latest_file// }" ]]; then
        echo "Could not find any files under" ${cuda_url}
        exit 1
fi
# extract actual file name from html snippet
file=$(echo $latest_file | sed 's/<\/\?[^>]\+>//g')
# build final URL for wget
cuda_url="${cuda_url}$file"
echo $cuda_url
