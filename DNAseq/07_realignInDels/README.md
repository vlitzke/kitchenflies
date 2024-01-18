# Step 7: Realign Insertions/Deletions

Again, having to use Paul's environment... `conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`

Even though this goes extinct in gatk4, I think we're still using this because we're not following that entire workflow (i.e. not using haplotypecaller or Mutect...

```
gatk3 \
-T IndelRealigner \
-R ./PATH/TO/dmel-all-chromosome-r6.54.fasta  \
-I ./PATH/TO/sampleName_library-dedup_rg.bam \
-targetIntervals ./PATH/TO/sampleName_library-dedup_rg.list \
-o ./PATH/TO/sampleName_library-dedup_rg_InDel.bam
```

For the next step, you could either just loop through the list of files or write them out to a text file: `ls *.bam > BAMlist.txt` and check `less BAMlist.txt` to make sure it looks alright.

https://github.com/broadinstitute/gatk-docs/blob/master/gatk3-tutorials/(howto)_Perform_local_realignment_around_indels.md

https://github.com/broadinstitute/gatk-docs/blob/master/blog-2012-to-2019/2016-06-21-Changing_workflows_around_calling_SNPs_and_indels.md?id=7847
https://github.com/lczech/popoolation2
https://speciationgenomics.github.io/variant_calling/
