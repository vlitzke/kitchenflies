#!/bin/bash

#SBATCH --job-name="7_realignInDels"
#SBATCH --mail-user=vl29@st-andrews.ac.uk
#SBATCH --mail-type=END
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=8G                     # Job memory request
#SBATCH --partition=short
#SBATCH --array=0-7
#SBATCH --output=7_realignInDels.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/

DATA_DIR=${SCRATCH}/kitchenflies/DNA/2_Process

mapfile -t myArray < $DATA_DIR/samples.txt

gatk3 \
-T IndelRealigner \
-R $DATA_DIR/6_targetInDels/dmel-all-chromosome-r6.54.fasta  \
-I $DATA_DIR/5_readgroups/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.bam \
-targetIntervals $DATA_DIR/6_targetInDels/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.list \
-o $DATA_DIR/7_realignInDels/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg_InDel.bam
echo "Job finished"
