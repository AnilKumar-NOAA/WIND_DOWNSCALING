#!/bin/sh -l
#
# -- Request that this job run on sJet
#SBATCH --partition=hera
#
# -- Request 16 cores
#SBATCH --ntasks=1860
#
# -- Specify a maximum wallclock of 4 hours
#SBATCH --time=8:00:00
#
# -- Specify under which account a job should run
#SBATCH --account=coastal 
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=coastal-act
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

nt=$SLURM_NTASKS


srun --ntasks=1860 --distribution=block:block --time=8:00:00 ./wrf.exe

