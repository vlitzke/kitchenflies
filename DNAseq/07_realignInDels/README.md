# Step 7: Local realignment around Insertions/Deletions

Information taken from here[^1] but see [^2]. Now we perform local realignment to reads in these regions, which a) helps correct mapping errors made by genome aligners and b) makes read alignments more consistent in regions that contain indels.

Genome aligners can only consider each read independently, and the scoring strategies they use to align reads relative to the reference limit their ability to align reads well in the presence of indels. Depending on the variant event and its relative location within a read, the aligner may favor alignments with mismatches or soft-clips instead of opening a gap in either the read or the reference sequence. In addition, the aligner's scoring scheme may use arbitrary tie-breaking, leading to different, non-parsimonious representations of the event in different reads.In contrast, local realignment considers all reads spanning a given position. This makes it possible to achieve a high-scoring consensus that supports the presence of an indel event. It also produces a more parsimonious representation of the data in the region.

<img src="https://github.com/vlitzke/kitchenflies/blob/main/DNAseq/07_realignInDels/figures/7_img1.png" width="100" height="70">


![image](figures/7_img2.png)


## Changes to alignment records
Here is an example: 194 alignment records (blue) realign for ~89 sites (red) for both the realigned read and for its mate.

### Example realigned record:

- MAPQ increases from 60 to 70. The tool increases each realigned record's MAPQ by ten
- CIGAR string, now 72M20I55M4S, reflects the realignment containing a 20bp insertion
- OC tag has been added and retains the original CIGAR string (OC:Z:110M2I22M1D13M4S, could be used to pull out realigned reads) and replaces the MD tag that stored the string for mismatching positions
- NM tag counts the realigned record's mismatches, and changes from 8 to 24

### Realigned read's mate record:

- MC tag updates the mate CIGAR string (to MC:Z:72M20I55M4S)
- MQ tag updates to the new mapping quality of the mate (to MQ:i:70)
- UQ tag updates to reflect the new Phred likelihood of the segment, from UQ:i:100 to UQ:i:68

![image](figures/7_img3.png)

### Code 

As input, IndelRealigner takes a coordinate-sorted and indexed BAM and a target list/intervals file (from the previous step). Then performs local realignment on reads with the target intervals from indels present in the original alignment. Output is a coordinate-sorted and indexed BAM with changes to realigned records and their mates.

Since I am continuing the use of gatk3[^1], I still have to use Paul's environment: `conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`

```
gatk3 \
-T IndelRealigner \
-R ./PATH/TO/dmel-all-chromosome-r6.54.fasta  \
-I ./PATH/TO/sampleName_library-dedup_rg.bam \
-targetIntervals ./PATH/TO/sampleName_library-dedup_rg.list \
-o ./PATH/TO/sampleName_library-dedup_rg_InDel.bam
```

| Command      | Description |
| ----------- | ----------- |
| `-T` | tool from gatk3 |
| `-R` | reference .fasta file |
| `-I` | input .bam file |
| `-targetIntervals` | input .list file of where the indels are |
| `-o` | output .bam file of indels |

Possibly interesting information:
- By default it uses the USE_READS consensus model (constructs alternative alignments from all reads (ref sequence and indels spanning the site) over a given position in the alignment)
- No downsampling
- Uses two read filters: BadCigarFilter and MalformedReadFilter
- Processes reads flagged as duplicate (we already removed duplicates)

For the next step, you will need a file list. You could either just loop through the list of files or write them out to a text file: `ls *.bam > BAMlist.txt` and check `less BAMlist.txt` to make sure it looks alright.

[^1]: <https://github.com/broadinstitute/gatk-docs/blob/master/gatk3-tutorials/(howto)_Perform_local_realignment_around_indels.md>
[^2]: <https://github.com/broadinstitute/gatk-docs/blob/master/blog-2012-to-2019/2016-06-21-Changing_workflows_around_calling_SNPs_and_indels.md?id=7847>

https://github.com/lczech/popoolation2
https://speciationgenomics.github.io/variant_calling/
