# Mark and Remove Duplicates 

Already used Picard in the last step, this time we are using the function `MarkDuplicates`[^1]. This helps identify any duplicate reads from a BAM or SAM file that might have occurred during sample preparation:

- library construction using PCR
- optical duplcates: an artefact from one amplified cluster on the sequencing machine, which could have been detected as multiple clusters

It compares seuqneces in the 5' positions, then an algorithm differentates primary and duplicate reads by ranking the sums of read base-quality scores. Here duplicates were removed by indicated `REMOVE_DUPLICATES=TRUE`. If falst, it would output a new BAM/SAM file with duplicates marked by a flag (0x0400), instead we have just removed them and it also provides us with a metrics file which states the number of duplicates for the paired-end reads. 
 
🐻: Bear in mind that the syntax of these lines have changed in newer versions (I think from `I=` to `-I`).

```
picard MarkDuplicates
REMOVE_DUPLICATES=true 
I=./PATH/TO/3_sortbam_libraries/sampleName_library-sort.bam 
O=./PATH/TO/4_dedup/sampleName_library-dedup.bam 
M=./PATH/TO/4_dedup/sampleName_library-dedup.txt 
```

| Command      | Description |
| ----------- | ----------- |
| `I=` | input library-sort.bam file, must be coordinate sorted |
| `O=` | output library-dedup.bam file |
| `M=` | File to write duplication metrics to |

[^1]: <https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard->
