#!/bin/bash

# For a development build, start with:
source /cvmfs/pilot.eessi-hpc.org/versions/2021.12/init/bash
module use /mnt/shared/02_software_on_top/easybuild/modules/all
module load foss/2020a

# Load the CMake module for the particular GCCcore version:
module load CMake/3.16.4-GCCcore-9.3.0

# Load additional LAMMPS dependencies:
module load Eigen/3.3.7-GCCcore-9.3.0
module load FFmpeg/4.2.2-GCCcore-9.3.0

# These modules are already provided with foss/2020a
#module load OpenMPI
#module load FFTW

# Check if the RPATH wrapper script is in the path:
which gcc
file $(which gcc)

# If so, then proceed with the LAMMPS build:
wget https://download.lammps.org/tars/lammps-stable.tar.gz
tar zxvf lammps-stable.tar.gz
cd lammps-29Sep2021


# Create the following directory since rpath wrappers depend on it
mkdir -p /tmp/eb-eai87q5k

# Build LAMMPS with most plugins enabled
mkdir build && cd build && cmake -C ../cmake/presets/most.cmake ../cmake -DCMAKE_Fortran_COMPILER=gfortran -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=~/lammps
make -j8 all >& make.log &
make install
