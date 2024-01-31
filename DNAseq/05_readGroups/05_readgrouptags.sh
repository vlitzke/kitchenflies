#!/bin/bash

#SBATCH --job-name="05_readgrouptags"
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=8G                     # Job memory request
#SBATCH --partition=short
#SBATCH --array=0-9
#SBATCH --output=05_readgrouptags.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq 

cd ./PATH/TO/

mkdir 05_readgroups

mapfile -t myArray < samples.txt

picard AddOrReplaceReadGroups \
INPUT=./04_dedup/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup.bam \
OUTPUT=./05_readgroups/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.bam \
SORT_ORDER=coordinate \
RGID=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGLB=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGPL=illumina \
RGSM=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGPU=${myArray[$SLURM_ARRAY_TASK_ID]} \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT

echo "Job finished"