#!/bin/bash
#SBATCH --partition=compute
#SBATCH --time=0:01:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=1
#SBATCH --mem=5000

source /cvmfs/pilot.eessi-hpc.org/versions/2021.12/init/bash
#module use /mnt/shared/02_software_on_top/easybuild/modules/all
module load foss/2020a

# Additional environment variables:
#export LAMMPS_POTENTIALS=$HOME/lammps/share/lammps/potentials
#export MSI2LMP_LIBRARY=$HOME/lammps/share/lammps/frc_files
export PYTHONPATH=$PYTHONPATH:$HOME/getfem/lib/python3.8/site-packages/getfem
export LD_LIBRARY_PATH=$HOME/getfem/lib

echo 'begin'
date
echo '---'

python3 -m cantilever

echo '---'
date
echo 'end'

