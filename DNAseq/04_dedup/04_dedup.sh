#!/bin/bash

#SBATCH --job-name="04_dedup"
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=8G                     # Job memory request
#SBATCH --partition=short
#SBATCH --array=0-9
#SBATCH --output=04_dedup.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq 

cd ./PATH/TO/

mkdir 04_dedup

mapfile -t myArray < samples.txt

picard MarkDuplicates \
REMOVE_DUPLICATES=true \
I=./03_sorting/${myArray[$SLURM_ARRAY_TASK_ID]}_library-sort.bam \
O=./04_dedup/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup.bam \
M=./04_dedup/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup.txt 

echo "Job finished"