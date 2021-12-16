# This has no protections, just a proof of concept for Magic Castle

# Make space for compat libraries
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia
cd /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia

# Install compat libraries
wget https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-compat-11-5-495.29.05-1.x86_64.rpm
rpm2cpio cuda-compat-11-5-495.29.05-1.x86_64.rpm | cpio -idmv
mv usr/local/cuda-11.5 .
rm -r usr
ln -sf cuda-11.5 latest

# Create the space to host the libraries for the release
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/2021.06/compat/linux/x86_64
# Symlink in the path to the latest libraries
ln -s /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia/latest/compat /cvmfs/pilot.eessi-hpc.org/host_injections/2021.06/compat/linux/x86_64/lib

# Install CUDA
source /etc/profile.d/z-01-site.sh
export EASYBUILD_PREFIX=/project/def-sponsor00/easybuild
export EASYBUILD_IGNORE_OSDEPS=1
export EASYBUILD_SYSROOT=${EPREFIX}
export EASYBUILD_RPATH=1
export EASYBUILD_FILTER_ENV_VARS=LD_LIBRARY_PATH
export EASYBUILD_FILTER_DEPS=Autoconf,Automake,Autotools,binutils,bzip2,cURL,DBus,flex,gettext,gperf,help2man,intltool,libreadline,libtool,Lua,M4,makeinfo,ncurses,util-linux,XZ,zlib
export EASYBUILD_MODULE_EXTENSIONS=1
module load EasyBuild
eb CUDAcore-11.3.1.eb

# Test CUDA
module use /project/def-sponsor00/easybuild/modules/all/
module load CUDAcore
tmp_dir=$(mktemp -d)
cp -r $EBROOTCUDACORE/samples $tmp_dir
current_dir=$PWD
cd $tmp_dir/samples/1_Utilities/deviceQuery
make HOST_COMPILER=$(which g++) -j
./deviceQuery

# Clean up
cd $current_dir
rm -r $tmp_dir
