#!/bin/bash

#SBATCH --job-name="kallisto_Batch1_f"
#SBATCH --mail-user=vl29@st-andrews.ac.uk
#SBATCH --mail-type=END
#SBATCH --ntasks=16                    # Run on a single CPU
#SBATCH --mem=50G                     # Job memory request
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --output=kallisto_Batch1_f.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"
conda activate rnaseq 

kallisto quant -i ./kitchenflies/RNAseq/2_QC/Batch3/4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./kitchenflies/RNAseq/2_QC/Batch1/4_Mapping_kallisto/Dm_F10 ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10_1_trimmed.fq.gz ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10_2_trimmed.fq.gz

kallisto quant -i ./kitchenflies/RNAseq/2_QC/Batch3/4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./kitchenflies/RNAseq/2_QC/Batch1/4_Mapping_kallisto/Dm_F5 ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F5_1_trimmed.fq.gz ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F5_2_trimmed.fq.gz

kallisto quant -i ./kitchenflies/RNAseq/2_QC/Batch3/4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./kitchenflies/RNAseq/2_QC/Batch1/4_Mapping_kallisto/Dm_F6 ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F6_1_trimmed.fq.gz ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F6_2_trimmed.fq.gz

kallisto quant -i ./kitchenflies/RNAseq/2_QC/Batch3/4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./kitchenflies/RNAseq/2_QC/Batch1/4_Mapping_kallisto/Dm_F8 ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F8_1_trimmed.fq.gz ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F8_2_trimmed.fq.gz

kallisto quant -i ./kitchenflies/RNAseq/2_QC/Batch3/4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./kitchenflies/RNAseq/2_QC/Batch1/4_Mapping_kallisto/Dm_F9 ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F9_1_trimmed.fq.gz ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F9_2_trimmed.fq.gz

echo "Job finished"
