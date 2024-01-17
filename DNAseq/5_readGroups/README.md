# Add Read Group Tags

picard add read group tags – unsure of what information is used as input for some of the arguments.. 

Assigns all the reads in a file to a single new read-group.
Summary
Many tools (Picard and GATK for example) require or assume the presence of at least one RG tag, defining a "read-group" to which each read can be assigned (as specified in the RG tag in the SAM record). This tool enables the user to assign all the reads in the #INPUT to a single new read-group. For more information about read-groups, see the GATK Dictionary entry.
This tool accepts as INPUT BAM and SAM files or URLs from the Global Alliance for Genomics and Health (GA4GH).
Usage example:

```
picard AddOrReplaceReadGroups \
INPUT=./PATH/TO/4_dedup/sampleName_library-dedup.bam \
OUTPUT=./PATH/TO/5_readgroups/sampleName_library-dedup_rg.bam \ 
SORT_ORDER=coordinate \
RGID=sampleName \
RGLB=sampleName \
RGPL=illumina \
RGSM=sampleName \
RGPU=sampleName \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT
```

| Command      | Description |
| ----------- | ----------- |
| `Input=` | input library-sort.bam file, must be coordinate sorted |
| `Output=` | output library-dedup.bam file |
| `SORT_ORDER=` | File to write duplication metrics to |
| `RGID=` | File to write duplication metrics to |
| `RGLB=` | File to write duplication metrics to |
| `RGPL=` | File to write duplication metrics to |
| `RGSM=` | File to write duplication metrics to |
| `RGPU=` | File to write duplication metrics to |
| `CREATE_INDEX=` | File to write duplication metrics to |
| `VALIDATION_STRINGENCY=` | File to write duplication metrics to |


To see the read group information for a BAM file, use the following command.
`samtools view -H sample.bam | grep '^@RG'`
