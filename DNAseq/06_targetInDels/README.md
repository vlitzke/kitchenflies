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

Reads filtered out for failing BadMateFilter

| Sample | Filtered Reads | Total Reads | % | 
|-----|------|------|-----|
| F1_23 | 134710 | 26613240 | 0.51 |
| F1_22 | 236734 | 31952878 | 0.74 |
| F2_22 | 144020 | 33006790 | 0.44 |
| F2_23 | 306211 | 31417942 | 0.97 |
| M1_22 | 374018 | 42495798 | 0.88 |
| M1_23 | 351562 | 38614402 | 0.91 |
| M2_23 | 358622 | 45029919 | 0.80 |
| M3_22 | 458838 | 44924189 | 1.02 |

