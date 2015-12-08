#!/bin/bash

#SBATCH --time=100:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8192M
#SBATCH -o /fslhome/zach8769/logfiles/ucsd/output_temp.txt
#SBATCH -e /fslhome/zach8769/logfiles/ucsd/error_temp.txt
#SBATCH -J "ucsdtemp"
#SBATCH --mail-user=zchristensen7@gmail.com
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

export ANTSPATH=/fslhome/zach8769/bin/antsbin/bin/
PATH=${ANTSPATH}:${PATH}

inputPath=/fslhome/zach8769/compute/ucsdtemp/
cd ${inputPath}

${ANTSPATH}/buildtemplateparallel.sh -d 3 -o T_ -i 4 -m 1x0x0 -c 5 -n 0 -r 1 -s CC -t GR *.nii.gz
${ANTSPATH}/buildtemplateparallel.sh -d 3 -o T_ -i 4 -c 5 -n 0 -r 0 -s CC -t GR -z T_template.nii.gz *.nii.gz
