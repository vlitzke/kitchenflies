# Step 6: Target Insertions/Deletions

A common downstream analysis for DNA-seq data is variant calling, that is, the identification of positions in the genome that vary relative to the genome reference and between individuals. A popular analysis framework for this application is GATK for single nucleotide polymorphism (SNP) or small insertions/deletions (indels) 

Can't download gatk3 anymore, Paul: won't be able to use gatk4 for droseu pipeline without modifications because it relies on RealignerTargetCreator, which isn't part of gatk4.

so I actually had to use the bioinformaticians environment, because he has the older version working:
`conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`

1. Unzip your reference genome: `zcat ./PATH/TO/dmel-all-chromosome-r6.54.fasta.gz > ./PATH/TO//dmel-all-chromosome-r6.54.fasta`
2. Create a dictionary: `picard CreateSequenceDictionary R=./PATH/TO/dmel-all-chromosome-r6.54.fasta O=./PATH/TO/dmel-all-chromosome-r6.54.dict`
3. Create an index: `#amtools faidx ./PATH/TO/dmel-all-chromosome-r6.54.fasta`

```
gatk3 \
-T RealignerTargetCreator \
-R $DATA_DIR/6_targetInDels/dmel-all-chromosome-r6.54.fasta \
-I $DATA_DIR/5_readgroups/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.bam \
-o $DATA_DIR/6_targetInDels/${myArray[$SLURM_ARRAY_TASK_ID]}_library-dedup_rg.list
```

Output 
134710 reads were filtered out during the traversal out of approximately 26613240 total reads (0.51%) 
236734 reads were filtered out during the traversal out of approximately 31952878 total reads (0.74%) 
306211 reads were filtered out during the traversal out of approximately 31417942 total reads (0.97%) 
144020 reads were filtered out during the traversal out of approximately 33006790 total reads (0.44%) 
374018 reads were filtered out during the traversal out of approximately 42495798 total reads (0.88%) 
351562 reads were filtered out during the traversal out of approximately 38614402 total reads (0.91%) for failing BadMateFilter
358622 reads were filtered out during the traversal out of approximately 45029919 total reads (0.80%) 
458838 reads were filtered out during the traversal out of approximately 44924189 total reads (1.02%) 

F2_22: 144020 reads were filtered out during the traversal out of approximately 33006790 total reads (0.44%)
