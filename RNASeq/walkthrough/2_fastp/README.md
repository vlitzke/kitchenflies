fastp \
-i sampleName_read1.fq.gz \
-I sampleName_read32.fq.gz \
-o ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10_1_trimmed.fq.gz \
-O ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10_2_trimmed.fq.gz \
--html ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10.log \
--json ./kitchenflies/RNAseq/2_QC/Batch1/3_CleanedReads_fastp/Dm_F10.json 2> Dm_F10

