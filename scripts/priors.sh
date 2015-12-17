#!/bin/bash

#SBATCH --time=100:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=32768M
#SBATCH -o /fslhome/zach8769/logfiles/sobik/error_priors.txt
#SBATCH -e /fslhome/zach8769/logfiles/sobik/output_priors.txt
#SBATCH -J "sobikpriors"
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

# Link to images used to create priors https://drive.google.com/drive/folders/0B4SvObeEfaRySUNDOE5DWksyQ0k/0B4SvObeEfaRyZGhlUlJOcmItTVU
# user to change
HOME=/fslhome/zach8769/

NEWTEMPHOME=${HOME}compute/sobiktemp/
NEWTEMP=${NEWTEMPHOME}/T_template0.nii.gz
cd ${NEWTEMP}
DATA_DIR=${PWD}

OLDTEMP=${HOME}compute/template/
IMG=${OLDTEMP}/training-images/
IMGLABELS=${OLDTEMP}/training-labels/
mkdir ${NEWTEMPHOME}Output
OUT_DIR=${NEWTEMPHOME}/Output/

# Do antsCorticalThickness on template.  This is used to get the csf prior.

${ANTSPATH}antsCorticalThickness.sh -d 3 \
  -a ${NEWTEMP} \
  -e ${OLDTEMP}T_template0.nii.gz \
  -t ${OLDTEMP}T_template0_BrainCerebellum.nii.gz \
  -m ${OLDTEMP}T_template0_BrainCerebellumProbabilityMask.nii.gz \
  -f ${OLDTEMP}T_template0_BrainCerebellumExtractionMask.nii.gz \
  -p ${OLDTEMP}Priors2/priors%d.nii.gz \
  -o ${OUT_DIR}antsCT \
  -u 1

templateBrainMask=${OUT_DIR}antsCTBrainExtractionMask.nii.gz
templateBrain=${OUT_DIR}antsCTBrainExtractionBrain.nii.gz

${ANTSPATH}/ImageMath 3 $templateBrain m $templateBrainMask $NEWTEMP

# Do jlf labeling on extracted template brain.  This is used to get the rest of the priors
# including part of the csf prior.

${ANTSPATH}antsJointLabelFusion.sh -d 3  -c 5 -u 40:00:00 -v 16gb -w 40:00:00 -z 32gb \
-o ${OUT_DIR}/ants \
-t $templateBrain \
-g ${IMG}1000_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1000_3_glm.nii.gz \
-g ${IMG}1001_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1001_3_glm.nii.gz \
-g ${IMG}1002_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1002_3_glm.nii.gz \
-g ${IMG}1006_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1006_3_glm.nii.gz \
-g ${IMG}1007_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1007_3_glm.nii.gz \
-g ${IMG}1008_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1008_3_glm.nii.gz \
-g ${IMG}1009_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1009_3_glm.nii.gz \
-g ${IMG}1010_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1010_3_glm.nii.gz \
-g ${IMG}1011_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1011_3_glm.nii.gz \
-g ${IMG}1012_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1012_3_glm.nii.gz \
-g ${IMG}1013_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1013_3_glm.nii.gz \
-g ${IMG}1014_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1014_3_glm.nii.gz \
-g ${IMG}1015_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1015_3_glm.nii.gz \
-g ${IMG}1017_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1017_3_glm.nii.gz \
-g ${IMG}1036_3_BrainCerebellum.nii.gz -l ${IMGLABELS}1036_3_glm.nii.gz 

# convert labels to 6 tissue (4 in 2-D)
#  1. csf
#  2. gm
#  3. wm
#  4. subcortical gm
#  5. brain stem
#  6. cerebellum

csfLabels=( 4 46 49 50 51 52 )
wmLabels=( 44 45 )
corticalLabels=( 31 32 42 43 47 48 )  # also anything >= 100
subcorticalLabels=( 23 30 36 37 55 56 57 58 59 60 61 62 63 64 75 76 )
brainstemLabels=( 35 )
cerebellumLabels=( 11 38 39 40 41 71 72 73 )
 
tmp=${OUT_DIR}/tmpForRelabeling.nii.gz
jlf=${OUT_DIR}/antsLabels.nii.gz
jlf=${OUT_DIR}/antsjlf_6Labels.nii.gz

ThresholdImage 3 $jlf $jlf6 100 207 2 0

echo "csf: "
for(( j=0; j<${#csfLabels[@]}; j++ ));
  do
    echo ${csfLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${csfLabels[$j]} ${csfLabels[$j]} 1 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

echo "cortex: "
for(( j=0; j<${#corticalLabels[@]}; j++ ));
  do
    echo ${corticalLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${corticalLabels[$j]} ${corticalLabels[$j]} 2 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

echo "white matter: "
for(( j=0; j<${#wmLabels[@]}; j++ ));
  do
    echo ${wmLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${wmLabels[$j]} ${wmLabels[$j]} 3 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

echo "sub-cortex: "
for(( j=0; j<${#subcorticalLabels[@]}; j++ ));
  do
    echo ${subcorticalLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${subcorticalLabels[$j]} ${subcorticalLabels[$j]} 4 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

echo "brain stem: "
for(( j=0; j<${#brainstemLabels[@]}; j++ ));
  do
    echo ${brainstemLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${brainstemLabels[$j]} ${brainstemLabels[$j]} 5 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

echo "cerebellum: "
for(( j=0; j<${#cerebellumLabels[@]}; j++ ));
  do
    echo ${cerebellumLabels[$j]}
    ${ANTSPATH}/ThresholdImage 3 $jlf $tmp ${cerebellumLabels[$j]} ${cerebellumLabels[$j]} 6 0
    ${ANTSPATH}/ImageMath 3 $jlf6 + $tmp $jlf6
  done

# aded code her for brain only mask in future DTI steps
echo "Brain only mask: "
brainonlymask=${NEWTEMPHOME}T_template0_BrainExtractionMask.nii.gz
ThresholdImage 3 $jlf $brainonlymask 1 207 1 0
${ANTSPATH}/ThresholdImage $jlf $tmp 5 6 1 0 
${ANTSPATH}/ImageMath 3 $brainonlymask - $brainonlymask $tmp
${ANTSPATH}/SmoothImage 3 $brainonlymask 1 ${NEWTEMPHOME}T_template0_BrainExtractionProbabilityMask.nii.gz

# now convert each to a probability map

antsCtCsfPrior=${OUT_DIR}/antsCTPrior1.nii.gz
${ANTSPATH}/SmoothImage 3 ${OUT_DIR}/antsCTBrainSegmentationPosteriors1.nii.gz 1 $antsCtCsfPrior

for(( j=1; j<=6; j++ ));
  do
    prior=${OUT_DIR}/prior${j}.nii.gz
    ${ANTSPATH}/ThresholdImage 3 $jlf6 $prior $j $j 1 0
    ${ANTSPATH}/SmoothImage 3 $prior 1 $prior
  done

${ANTSPATH}/ImageMath 3 ${OUT_DIR}/prior1.nii.gz max ${OUT_DIR}/prior1.nii.gz $antsCtCsfPrior

# subtract out csf prior from all other priors

prior1=${OUT_DIR}/prior1.nii.gz
for(( j=2; j<=6; j++ ));
  do
    prior=${OUT_DIR}/prior${j}.nii.gz
    ${ANTSPATH}/ImageMath 3 $prior - $prior $prior1
    ${ANTSPATH}/ThresholdImage 3 $prior $tmp 0 1 1 0
    ${ANTSPATH}/ImageMath 3 $prior m $prior $tmp
  done

cp $templateBrainMask ${NEWTEMPHOME}T_template0_BrainCerebellumExtractionMask.nii.gz
cp $templateBrain ${NEWTEMPHOME}T_template0_BrainCerebellum.nii.gz
${ANTSPATH}/SmoothImage 3 $templateBrainMask 1 ${NEWTEMPHOME}T_template0_BrainCerebellumProbabilityMask.nii.gz
mkdir ${NEWTEMPHOME}Priors
cp ${OUTD_DIR}prior%d.nii.gz
rm $tmp

echo "Priors are cooked.  They can be found in ${OUT_DIR}"
