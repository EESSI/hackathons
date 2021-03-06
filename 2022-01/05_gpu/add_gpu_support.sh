# Some of the TODO's just need to be migrated (with appropriate protections)
# from working_script.sh

# Drop into the prefix shell or pipe this script into a Prefix shell with
#   $EPREFIX/startprefix <<< /path/to/this_script.sh

# verify existence of nvidia-smi or this is a waste of time
# TODO: Check if nvidia-smi exists and can be executed without error


# Set up the minimum EESSI environment variables
# (this is using `latest` but we should actually be using a fixed version like $EESSI_PILOT_VERSION)
source /cvmfs/pilot.eessi-hpc.org/latest/init/minimal_eessi_env

##############################################################################################
# Check that the CUDA driver version is adequate
# (
#  needs to be r450 or r470 which are LTS, other production branches are acceptable but not
#  recommended, below r450 is not compatible [with an exception we will not explore,see
#  https://docs.nvidia.com/datacenter/tesla/drivers/#cuda-drivers]
# )
driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
# Now check driver_version for compatability
# TODO: Check driver is at least LTS driver R450, see https://docs.nvidia.com/datacenter/tesla/drivers/#cuda-drivers


# Check if the CUDA compat libraries are installed and compatible with the target CUDA version
# if not find the latest version of the compatibility libraries and install them

# Create a general space for our NVIDIA compat drivers
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia
cd /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia
# TODO: Do a lot better at guarding this stuff, space needs to be writable!

# Check if we have any version installed by checking for the existence of /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia/latest

driver_cuda_version=$(nvidia-smi  -q --display=COMPUTE | grep CUDA | awk 'NF>1{print $NF}' | sed s/\\.//)
eessi_cuda_version =$(LD_LIBRARY_PATH=/cvmfs/pilot.eessi-hpc.org/host_injections/nvidia/latest/compat/:$LD_LIBRARY_PATH nvidia-smi  -q --display=COMPUTE | grep CUDA | awk 'NF>1{print $NF}' | sed s/\\.//)
if [ "$driver_cuda_version" -gt "$eessi_cuda_version" ]; then  echo "You need to update your CUDA compatability libraries"; fi

# Check if our target CUDA is satisfied by what is installed already
# TODO: Find required CUDA version and see if we need an update

# If not, grab the latest compat library RPM
# (this needs separate scripting as we need the real time latest version, initial script available)
wget https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-compat-11-5-495.29.05-1.x86_64.rpm

# Unpack it
# (the requirements here are OS dependent, can we get around that?)
# (for rpms looks like we can use https://gitweb.gentoo.org/repo/proj/prefix.git/tree/eclass/rpm.eclass?id=d7fc8cf65c536224bace1d22c0cd85a526490a1e)
# (deb files can be unpacked with ar and tar)
rpm2cpio cuda-compat-11-5-495.29.05-1.x86_64.rpm | cpio -idmv
mv usr/local/cuda-11.5 .
rm -r usr

# Add a symlink that points to the latest version
ln -sf cuda-11.5 latest

# Create the space to host the libraries
# TODO: Need to also use envvars for OS and arch
mkdir -p /cvmfs/pilot.eessi-hpc.org/host_injections/${EESSI_PILOT_VERSION}/compat/linux/x86_64
# Symlink in the path to the latest libraries
ln -s /cvmfs/pilot.eessi-hpc.org/host_injections/nvidia/latest/compat /cvmfs/pilot.eessi-hpc.org/host_injections/${EESSI_PILOT_VERSION}/compat/linux/x86_64/lib
###############################################################################################

###############################################################################################
# Install CUDA
# - as an installation location just use $EESSI_SOFTWARE_PATH but replacing `versions` with `host_injections`
#   (CUDA is a binary installation so no need to worry too much about this)
# TODO: First need the symlink in EESSI
# TODO: The install is pretty fat, you need lots of space for download/unpack/install (~3*5GB), need to do a space check before we proceed
# TODO: Can we do a trimmed install?

# Test building something with CUDA and running
# TODO: Use samples from installation directory, `device_query` is a good option

# Test a CUDA-enabled module from EESSI
# TODO: GROMACS?
# TODO: Include a GDR copy test?
###############################################################################################
