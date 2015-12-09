#!/bin/bash

#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8192M
#SBATCH -o /fslhome/zach8769/logfiles/ucsd/error_t1_0.txt
#SBATCH -e /fslhome/zach8769/logfiles/ucsd/output_t1_0.txt
#SBATCH -J "t1_0"
#SBATCH --mail-user=zchristensen7@gmail.com
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

rootdir=/fslhome/zach8769/

export ANTSPATH=/fslhome/zach8769/apps/ants/bin/
PATH=${ANTSPATH}:${PATH}

IFS=$'\n'
array=( $(find /fslhome/zach8769/compute/ucsd/*/t1/ -type f  -name "acpc.nii") )
for i in 0; do
t1=$(dirname ${array[$i]})
subjDir=$(dirname $t1)

N4BiasFieldCorrection -d 3 -i ${array[$i]} -o ${t1}/n4.nii.gz -s 8 -b [200] -c [50x50x50x50,0.000001]
N4BiasFieldCorrection -d 3 -i ${t1}/n4.nii.gz -o ${t1}/n4.nii.gz -s 4 -b [200] -c [50x50x50x50,0.000001]
N4BiasFieldCorrection -d 3 -i ${t1}/n4.nii.gz -o ${t1}/n4.nii.gz -s 2 -b [200] -c [50x50x50x50,0.000001]
ResampleImage 3 ${t1}/n4.nii.gz ${t1}/n4_resliced.nii.gz 1x1x1

antsBrainExtraction.sh -d 3 \
-a ${t1}/n4_resliced.nii.gz \
-e $rootdir/compute/template/T_template0.nii.gz \
-m $rootdir/compute/template/T_template0_BrainCerebellumProbabilityMask.nii.gz \
-o $t1/
done
