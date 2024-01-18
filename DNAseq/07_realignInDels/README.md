# Step 7: Realign Insertions/Deletions

Again, having to use Paul's environment... `conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`


```
gatk3 \
-T IndelRealigner \
-R ./PATH/TO/dmel-all-chromosome-r6.54.fasta  \
-I ./PATH/TO/sampleName_library-dedup_rg.bam \
-targetIntervals ./PATH/TO/sampleName_library-dedup_rg.list \
-o ./PATH/TO/sampleName_library-dedup_rg_InDel.bam
```

For the next step, you could either just loop through the list of files or write them out to a text file: `ls *.bam > BAMlist.txt` and check `less BAMlist.txt` to make sure it looks alright.
