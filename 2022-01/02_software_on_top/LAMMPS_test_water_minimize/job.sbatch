#!/bin/bash
#SBATCH --partition=compute
#SBATCH --time=1:00:00
#SBATCH --nodes=4
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=1
#SBATCH --mem=5000

source /cvmfs/pilot.eessi-hpc.org/versions/2021.12/init/bash
module use /mnt/shared/02_software_on_top/easybuild/modules/all
module load foss/2020a

# Additional environment variables:
export LAMMPS_POTENTIALS=$HOME/lammps/share/lammps/potentials
export MSI2LMP_LIBRARY=$HOME/lammps/share/lammps/frc_files

echo 'begin'
date
echo '---'

mpiexec $HOME/lammps/bin/lmp -in in.spcf

echo '---'
date
echo 'end'

