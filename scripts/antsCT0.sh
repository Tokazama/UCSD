#!/bin/bash

#SBATCH --time=20:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8192M
#SBATCH -o /fslhome/zach8769/logfiles/ucsd/output_antsCT0.txt
#SBATCH -e /fslhome/zach8769/logfiles/ucsd/error_antsCT0.txt
#SBATCH -J "antsCT0"
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

IFS=$'\n'
array=( $(find /fslhome/zach8769/compute/ucsd/*/t1/ -type f  -name "acpc.nii") )
for i in 0; do
t1=$(dirname ${array[$i]})
subjDir=$(dirname ${t1})
mkdir ${t1}/CT
output=${t1}/CT/
temp=/fslhome/zach8769/ucsdtemp/

sh ${ANTSPATH}antsCorticalThickness.sh -d 3 \
-a ${subjDir}n4_resliced.nii.gz \
-e ${temp}T_template0.nii.gz \
-m ${temp}T_template0_BrainCerebellumProbabilityMask.nii.gz \
-f ${temp}T_template0_BrainCerebellumExtractionMask.nii.gz \
-p ${temp}Priors/priors%d.nii.gz \
-t ${temp}T_template0_BrainCerebellum.nii.gz \
-k 1 \
-n 3 \
-w 0.25 \
-q 1 \
-o ${output}thick_

# Create white matter, grey matter, csf, and whole brain warp images for analysis

segdir=${temp}/Priors/
warpimg=${output}brainWarp.nii.gz

# whole-brain
${ANTSPATH}/ImageMath 3 ${warpimg} m ${output}SubjectToTemplate1Warp.nii.gz ${temp}T_template0_BrainCerebellumExtractionMask.nii.gz
# white-matter
${ANTSPATH}/ImageMath 3 ${output}wmWarp.nii.gz m ${warpimg} ${segdir}priors3.nii.gz 
# grey-matter
${ANTSPATH}/ImageMath 3 ${output}gmWarp.nii.gz m ${warpimg} ${segdir}priors2.nii.gz
# csf
${ANTSPATH}/ImageMath 3 ${output}csfWarp.nii.gz m ${warpimg} ${segdir}priors1.nii.gz
done
