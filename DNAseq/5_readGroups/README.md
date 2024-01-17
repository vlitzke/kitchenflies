# Add Read Group Tags

We used Picards AddorReplaceReadGroups to assign all the reads in a file with a tag to a single new read-group[^1]. Some other functions in Picard and GATK require the presence of at least one RG tag. This tool is kind of picky and for some of the fields you can actually just make some stuff up (otherwise the tool won't run).

After an extensive internet search it seems there is no consensus for a formal definition of what a 'read group' is, but Caetano-Anolles[^2] states that it refers to a set of reads generated from a single run from a sequencing instrument (a single library prep from one sample run on a single flow cell lane - all reads from this lane belong to the same read group, a separate read group would be if a subset of reads from a different library run on that lane).

Read groups are identified in the SAM/BAM file by a number of tags which help differentiate samples and several technical features that are associated with artifacts. Using this information, we can mitigate the effects of those artifacts during the duplicate marking and base recalibration steps.

To see read group information for a BAM file, use the following command: `samtools view -H sample.bam | grep '^@RG'`

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

[^1]: <https://gatk.broadinstitute.org/hc/en-us/articles/360037226472-AddOrReplaceReadGroups-Picard->
[^2]: <https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups>
