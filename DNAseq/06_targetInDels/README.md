# Step 6: Target Insertions/Deletions

A common downstream analysis for DNA-seq data is variant calling, that is, the identification of positions in the genome that vary relative to the genome reference and between individuals. To do so, we will need to figure out where small insertions/deletions (indels) are.

I am not using gatk4 for the DrosEU pipeline because it relies on the tool RealignerTargetCreator, which is not a part of gatk4. However, I was not able to download gatk3 to my conda (it is now considered obsolete, and there are arguments about the necessity of running this tool/it might now be combined in other tools). So I used our bioinformaticians environment, because he has the older version working:

`conda activate /mnt/shared/scratch/pjohnsto/apps/conda/envs/gatk3/`

You will also need the following steps-
1. Unzip your reference genome: `zcat ./PATH/TO/dmel-all-chromosome-r6.54.fasta.gz > ./PATH/TO//dmel-all-chromosome-r6.54.fasta`
2. Create a dictionary: `picard CreateSequenceDictionary R=./PATH/TO/dmel-all-chromosome-r6.54.fasta O=./PATH/TO/dmel-all-chromosome-r6.54.dict`
3. Create an index: `samtools faidx ./PATH/TO/dmel-all-chromosome-r6.54.fasta`

```
gatk3 \
-T RealignerTargetCreator \
-R ./PATH/TO/dmel-all-chromosome-r6.54.fasta \
-I ./PATH/TO/sampleName_library-dedup_rg.bam \
-o ./PATH/TO/sampleName_library-dedup_rg.list
```

| Command      | Description |
| ----------- | ----------- |
| `-T` | tool from gatk3 |
| `-R` | reference .fasta file |
| `-I` | input .bam file |
| `-o` | output .list file of indels |


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

