# Alignment 

Next, we're going to map our trimmed reads to the reference genome. This is the point in which we determine the position in the genome based on the read sequence. For this, we will use BWA[^1]. `bwa mem` is preferable to `bwa aln`,  especially for longer reads and directly produces SAM files. 

Then we will pipe them into Samtools[^2] for filtering with MQ > 20 

:exclamation: *This takes a very long time!* :exclamation:

```
bwa mem \
-M \
./kitchenflies/DNA/2_Process/2_bam_libraries/dmel-all-chromosome-r6.54.fasta \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read1.fq.gz \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read2.fq.gz \

| samtools view \
-Sbh -q 20 -F 0x100 - > ./kitchenflies/DNA/2_Process/2_bam_libraries/F1_22_library.bam \
```




[^1]: https://github.com/lh3/bwa
[^2]: https://www.htslib.org/
