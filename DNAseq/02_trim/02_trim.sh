#!/bin/bash

#SBATCH --job-name="01_trim"
#SBATCH --ntasks=8                    # Run on a single CPU
#SBATCH --mem=20G                     # Job memory request
#SBATCH --partition=short
#SBATCH --array=0-9 		# number of samples, index starts at 0
#SBATCH --output=01_trim.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq 

cd ./PATH/TO/

mkdir 02_trimming

cutadapt \
./PATH/TO/01_RawData/${myArray[$SLURM_ARRAY_TASK_ID]}_1.fq.gz \
./PATH/TO/01_RawData/${myArray[$SLURM_ARRAY_TASK_ID]}_2.fq.gz \
-q 18 \
--minimum-length 75 \
-b ACACTCTTTCCCTACACGACGCTCTTCCGATC \
-B CAAGCAGAAGACGGCATACGAGAT \
-O 15 \
-n 3 \
-o ./PATH/TO/02_trimming/${myArray[$SLURM_ARRAY_TASK_ID]}_trimmed-read1.fq.gz \
-p ./PATH/TO/02_trimming/${myArray[$SLURM_ARRAY_TASK_ID]}_trimmed-read2.fq.gz 

echo "Job finished"