#!/bin/bash

#SBATCH --time=75:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=32768M
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

rootdir=/fslhome/zach8769/
tempdir=${rootdir}compute/ucsdtemp/

cd ${tempdir}

###clean up code
tmp=${rootdir}tmp$RANDOM
mkdir ${tmp}
cp ${tempdir}* ${tmp}/
###

# Create common template space to register images to with rigid transform
${ANTSPATH}/antsMultivariateTemplateConstruction.sh -d 3 \
-o T_ \
-i 4 \
-m 10x0x0 \
-c 5 \
-n 0 \
-r 1 \
-s CC \
-t GR \
*.nii.gz

# Construct template
${ANTSPATH}/antsMultivariateTemplateConstruction.sh -d 3 \
-o T_ \
-i 4 \
-c 5 \
-n 1 \
-r 1\
-s CC \
-t GR \
-z T_template0.nii.gz \
*.nii.gz

### Clean up code
cp T_template0.nii.gz ${tmp}/T_template0.nii.gz
rm ${tempdir}/*
mv ${tmp}/* ${tempdir}/
rm -r ${tmp}
rmdir ${tempdir}T_
###
