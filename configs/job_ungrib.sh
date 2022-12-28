#!/bin/sh -l
#
# -- Request that this job run on sJet
#SBATCH --partition=hera
#
# -- Request 16 cores
#SBATCH --ntasks=16
#
# -- Specify a maximum wallclock of 4 hours
#SBATCH --time=4:00:00
#
# -- Specify under which account a job should run
#SBATCH --account=coastal 
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=ungrib
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

nt=$SLURM_NTASKS

module load intel
module load impi

#cd /scratch2/COASTAL/coastal/save/Anil.Kumar/WPS-4.1

srun -n $nt ./ungrib.exe

