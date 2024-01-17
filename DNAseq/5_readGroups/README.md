# Add Read Group Tags

picard add read group tags – unsure of what information is used as input for some of the arguments.. 

Assigns all the reads in a file to a single new read-group.
Summary
Many tools (Picard and GATK for example) require or assume the presence of at least one RG tag, defining a "read-group" to which each read can be assigned (as specified in the RG tag in the SAM record). This tool enables the user to assign all the reads in the #INPUT to a single new read-group. For more information about read-groups, see the GATK Dictionary entry.
This tool accepts as INPUT BAM and SAM files or URLs from the Global Alliance for Genomics and Health (GA4GH).
Usage example:

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
