# Add Read Group Tags

picard add read group tags – unsure of what information is used as input for some of the arguments.. 


```
picard AddOrReplaceReadGroups \
INPUT=$DATA_DIR/4_dedup/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup.bam \
OUTPUT=$DATA_DIR/5_readgroups/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.bam \
SORT_ORDER=coordinate \
RGID=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGLB=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGPL=illumina \
RGSM=${myArray[$SLURM_ARRAY_TASK_ID]} \
RGPU=${myArray[$SLURM_ARRAY_TASK_ID]} \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT
```

To see the read group information for a BAM file, use the following command.
`samtools view -H sample.bam | grep '^@RG'`
