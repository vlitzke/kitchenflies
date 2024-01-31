#!/bin/bash

#SBATCH --job-name="02_QC"
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=16G                     # Job memory request
#SBATCH --partition=medium
#SBATCH --output=02_QC.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq

cd ./PATH/TO/01_trimming/

fastqc *.fq.gz

echo "Job finished"
