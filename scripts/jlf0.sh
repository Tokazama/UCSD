#!/bin/bash

#SBATCH --time=50:00:00
#SBATCH --ntasks=2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=32768M
#SBATCH -o /fslhome/zach8769/logfiles/ucsd/error_jlf0.txt
#SBATCH -e /fslhome/zach8769/logfiles/ucsd/output_jlf0.txt
#SBATCH -J "jlf0"
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

export ANTSPATH=/fslhome/zach8769/bin/antsbin/bin/
PATH=${ANTSPATH}:${PATH}

IFS=$'\n'
array=( $(find /fslhome/zach8769/compute/ucsd/*/t1/ -type f  -name "acpc.nii") )
for i in 0; do
t1=$(dirname ${array[$i]})
subjDir=$(dirname $t1)
mkdir ${subjDir}/atlas

temp=${rootdir}/compute/jlf/OASIS-TRT-20
antsJointLabelFusion.sh -d 3  -c 5 -u 40:00:00 -v 32gb -w 40:00:00 -z 32gb \
-o ${subjDir}/atlas/ \-t ${t1}/BrainExtractionBrain.nii.gz \
-g $temp-1.nii.gz -l $temp-1_DKT31_CMA_labels.nii.gz \
-g $temp-2.nii.gz -l $temp-2_DKT31_CMA_labels.nii.gz \
-g $temp-3.nii.gz -l $temp-3_DKT31_CMA_labels.nii.gz \
-g $temp-4.nii.gz -l $temp-4_DKT31_CMA_labels.nii.gz \
-g $temp-5.nii.gz -l $temp-5_DKT31_CMA_labels.nii.gz \
-g $temp-6.nii.gz -l $temp-6_DKT31_CMA_labels.nii.gz \
-g $temp-7.nii.gz -l $temp-7_DKT31_CMA_labels.nii.gz \
-g $temp-8.nii.gz -l $temp-8_DKT31_CMA_labels.nii.gz \
-g $temp-9.nii.gz -l $temp-9_DKT31_CMA_labels.nii.gz \
-g $temp-10.nii.gz -l $temp-10_DKT31_CMA_labels.nii.gz \
-g $temp-11.nii.gz -l $temp-11_DKT31_CMA_labels.nii.gz \
-g $temp-12.nii.gz -l $temp-12_DKT31_CMA_labels.nii.gz \
-g $temp-13.nii.gz -l $temp-13_DKT31_CMA_labels.nii.gz \
-g $temp-14.nii.gz -l $temp-14_DKT31_CMA_labels.nii.gz \
-g $temp-15.nii.gz -l $temp-15_DKT31_CMA_labels.nii.gz \
-g $temp-16.nii.gz -l $temp-16_DKT31_CMA_labels.nii.gz \
-g $temp-17.nii.gz -l $temp-17_DKT31_CMA_labels.nii.gz \
-g $temp-18.nii.gz -l $temp-18_DKT31_CMA_labels.nii.gz \
-g $temp-19.nii.gz -l $temp-19_DKT31_CMA_labels.nii.gz \
-g $temp-20.nii.gz -l $temp-20_DKT31_CMA_labels.nii.gz
done
