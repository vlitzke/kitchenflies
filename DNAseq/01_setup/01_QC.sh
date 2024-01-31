#!/bin/bash			

#SBATCH --job-name="01_QC"		# job name
#SBATCH --ntasks=4                    # Run on a single CPU
#SBATCH --mem=8G                     # Job memory request
#SBATCH --partition=short	  # ~how long a job will take
#SBATCH --output=01_QC.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate dnaseq

cd ./PATH/TO/01_RawData

fastqc *.fq.gz

echo "Job finished"

