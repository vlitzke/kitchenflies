#!/bin/bash

#SBATCH --job-name="03_map"
#SBATCH --ntasks=16                    # Run on a single CPU
#SBATCH --mem=60G                     # Job memory request
#SBATCH --partition=long
#SBATCH --array=0-9
#SBATCH --output=03_map.log   # Standard output and error log


pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq 

cd ./PATH/TO/

mkdir 03_mapping

# make sure you have a reference file in the mapping folder

mapfile -t myArray < samples.txt

bwa mem \
-M \
./03_mapping/dmel-all-chromosome-r6.54.fasta \
./02_trimming/${myArray[$SLURM_ARRAY_TASK_ID]}_trimmed-read1.fq.gz \
./02_trimming/${myArray[$SLURM_ARRAY_TASK_ID]}_trimmed-read2.fq.gz \
| samtools view \
-Sbh -q 20 -F 0x100 - > $DATA_DIR/03_mapping/${myArray[$SLURM_ARRAY_TASK_ID]}_library.bam \

echo "Job finished"
