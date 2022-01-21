wget http://download-mirror.savannah.gnu.org/releases/getfem/stable/getfem-5.4.1.tar.gz
tar zxvf getfem-5.4.1.tar.gz
cd getfem-5.4.1

source /cvmfs/pilot.eessi-hpc.org/versions/2021.12/init/bash
module use /mnt/shared/02_software_on_top/easybuild/modules/all
module load foss/2020a

module load Python/3.8.2-GCCcore-9.3.0
module load OpenBLAS/0.3.9-GCC-9.3.0
module load SciPy-bundle/2020.03-foss-2020a-Python-3.8.2

mkdir -p $HOME/getfem
mkdir -p /tmp/eb-eai87q5k

export CC=`which gcc`
export CXX=`which g++`
export FC=`which gfortran`
export LD=`which ld`

./configure --prefix=$HOME/getfem --enable-shared --enable-python --enable-metis --with-blas=`pkgconf --variable=libdir  openblas`/libopenblas.so
make -j8 >& make.log &
make install

