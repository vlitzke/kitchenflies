# Remove PCR duplicates 

Next....use picard[^1].

```
picard MarkDuplicates
REMOVE_DUPLICATES=true 
I=./PATH/TO/3_sortbam_libraries/sampleName_library-sort.bam 
O=./PATH/TO/4_dedup/sampleName_library-dedup.bam 
M=./PATH/TO/4_dedup/sampleName_library-dedup.txt 
```

