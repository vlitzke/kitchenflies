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
| `Input=` | input library-dedup.bam file |
| `Output=` | output library-dedup_rg.bam file |
| `SORT_ORDER=` | Optional sort order to output in, though its redundant here because our input file is already coordinate sorted (it will output the order the input file was |
| `RGID=` | Read-Group ID (I think possibly unnecessary) |
| `RGLB=` | Read-Group Library |
| `RGPL=` | Read-Group Platform (likely Illumina sequencing)|
| `RGSM=` | Read-Group Sample Name |
| `RGPU=` | Read-Group Platform Unit (I think this is unnecessary) |
| `CREATE_INDEX=` | Creates a BAM index |
| `VALIDATION_STRINGENCY=` | Set to SILENT, should improve performance when processing a BAM file where variable-length data (read, qualities, tags) do not need to be decoded |


To see the read group information for a BAM file, use the following command.
`samtools view -H sample.bam | grep '^@RG'`
