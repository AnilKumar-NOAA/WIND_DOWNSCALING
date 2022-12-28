#!/bin/sh -l
#
# -- Request that this job run on sJet
#SBATCH --partition=hera
#
# -- Request 16 cores
#SBATCH --ntasks=1
#
# -- Specify a maximum wallclock of 4 hours
#SBATCH --time=6:00:00
#
# -- Specify under which account a job should run
#SBATCH --account=coastal 
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=metgrid
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

nt=$SLURM_NTASKS


srun --ntasks=1 --distribution=block:block --time=6:00:00 ncl < fort_regrid_time.ncl 

