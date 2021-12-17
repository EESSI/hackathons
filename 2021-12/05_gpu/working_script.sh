# This does not full protections, just a proof of concept for Magic Castle
# The script can be injected into a Prefix shell with
#   chmod +x ./working_script.sh
#   $EPREFIX/startprefix <<< ./working_script.sh

cuda_compat_version="11.5"
cuda_compat_driver="495.29.05"
cuda_arch="x86_64"
cuda_os="rhel8"
cuda_compat_libs="cuda-compat-${cuda_compat_version//[.]/-}-${cuda_compat_driver}-1.${cuda_arch}.rpm"
eessi_version="2021.06"
eessi_cuda_version="11.3.1"

# We need our environment variables so let's source our init scripts
source /cvmfs/pilot.eessi-hpc.org/${eessi_version}/init/bash
eessi_cpu_family="${EESSI_CPU_FAMILY:-x86_64}"

# TODO: Only need this line for 2021.06
EESSI_SOFTWARE_PATH=${EESSI_SOFTWARE_PATH//2021.06/versions\/2021.06}

default_eessi_host_easybuild_prefix=${EESSI_SOFTWARE_PATH//versions/host_injections}
easybuild_prefix="${EASYBUILD_PREFIX:-${default_eessi_host_easybuild_prefix}}"

# Make space for compat libraries
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia
cd /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia

# TODO: Add a check to ensure there is enough space in the installation directory to host the installation
# For sources, build and install you will need ~16GB available

# Install compat libraries
if [ ! -f $cuda_compat_libs ]; then
  echo "$cuda_compat_libs not found, downloading..."
  wget https://developer.download.nvidia.com/compute/cuda/repos/${cuda_os}/${cuda_arch}/${cuda_compat_libs}
fi
if [ ! -d "cuda-${cuda_compat_version}" ] 
then
  rpm2cpio $cuda_compat_libs | cpio -idmv
  mv usr/local/cuda-${cuda_compat_version} .
  rm -r usr
  ln -sf cuda-${cuda_compat_version} latest
fi

# Create the space to host the libraries for the release
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/${eessi_version}/compat/linux/${eessi_cpu_family}
# Symlink in the path to the latest libraries (if needed)
if [ ! -d "/cvmfs/pilot.eessi-hpc.org/host_injections/${eessi_version}/compat/linux/${eessi_cpu_family}/lib" ]
then
  ln -s /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia/latest/compat /cvmfs/pilot.eessi-hpc.org/host_injections/${eessi_version}/compat/linux/${eessi_cpu_family}/lib
fi

# Install CUDA
export EASYBUILD_PREFIX=${easybuild_prefix}
export EASYBUILD_IGNORE_OSDEPS=1
export EASYBUILD_SYSROOT=${EPREFIX}
export EASYBUILD_RPATH=1
export EASYBUILD_FILTER_ENV_VARS=LD_LIBRARY_PATH
# No need for this since we are doing a binary install with no deps
# export EASYBUILD_FILTER_DEPS=Autoconf,Automake,Autotools,binutils,bzip2,cURL,DBus,flex,gettext,gperf,help2man,intltool,libreadline,libtool,Lua,M4,makeinfo,ncurses,util-linux,XZ,zlib
export EASYBUILD_MODULE_EXTENSIONS=1
module load EasyBuild
eb CUDAcore-${eessi_cuda_version}.eb
# eb CUDA-${eessi_cuda_version}.eb

# Test CUDA
module use ${easybuild_prefix}/modules/all/
module load CUDAcore
# module load CUDA
tmp_dir=$(mktemp -d)
cp -r $EBROOTCUDACORE/samples $tmp_dir
# cp -r $EBROOTCUDA/samples $tmp_dir
current_dir=$PWD
cd $tmp_dir/samples/1_Utilities/deviceQuery
make HOST_COMPILER=$(which g++) -j
./deviceQuery

if [ $? -eq 0 ] 
then
  # Set the color variable
  green='\033[0;32m'
  # Clear the color after that
  clear='\033[0m'
  echo -e ${green}
  echo "Congratulations, your GPU is working with EESSI!"
  echo "  - To build CUDA enabled modules use ${easybuild_prefix} as your EasyBuild prefix"
  echo "  - To use these modules:"
  echo "      module use ${easybuild_prefix}/modules/all/"
  echo -e ${clear}
else 
  echo "Uff, your GPU doesn't seem to be working with EESSI :(" >&2 
fi


# Clean up
cd $current_dir
rm -r $tmp_dir
