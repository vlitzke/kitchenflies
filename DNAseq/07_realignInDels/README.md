# Step 7: Local realignment around Insertions/Deletions

Again, I still have to use Paul's environment: `conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`

Continuing the use of gatk3[^1].

Even though this goes extinct in gatk4, I think we're still using this because we're not following that entire workflow 

The resulting BAM reduces false positive SNPs and represents indels parsimoniously

Local realignment around indels allows us to correct mapping errors made by genome aligners and make read alignments more consistent in regions that contain indels.

Genome aligners can only consider each read independently, and the scoring strategies they use to align reads relative to the reference limit their ability to align reads well in the presence of indels. Depending on the variant event and its relative location within a read, the aligner may favor alignments with mismatches or soft-clips instead of opening a gap in either the read or the reference sequence. In addition, the aligner's scoring scheme may use arbitrary tie-breaking, leading to different, non-parsimonious representations of the event in different reads.

In contrast, local realignment considers all reads spanning a given position. This makes it possible to achieve a high-scoring consensus that supports the presence of an indel event. It also produces a more parsimonious representation of the data in the region .

This two-step indel realignment process first identifies such regions where alignments may potentially be improved, then realigns the reads in these regions using a consensus model that takes all reads in the alignment context together


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

For the next step, you could either just loop through the list of files or write them out to a text file: `ls *.bam > BAMlist.txt` and check `less BAMlist.txt` to make sure it looks alright.


[^1]: <https://github.com/broadinstitute/gatk-docs/blob/master/gatk3-tutorials/(howto)_Perform_local_realignment_around_indels.md>

https://github.com/broadinstitute/gatk-docs/blob/master/blog-2012-to-2019/2016-06-21-Changing_workflows_around_calling_SNPs_and_indels.md?id=7847
https://github.com/lczech/popoolation2
https://speciationgenomics.github.io/variant_calling/
