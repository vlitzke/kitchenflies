# Alignment 

Next, we're going to map our trimmed reads to the reference genome. This is the point in which we determine the position in the genome based on the read sequence. For this, we will use BWA[^1]. `bwa mem` is preferable for longer Illumina reads  > 70 bp and < 1Mbp. It also directly produces SAM files. 

Then we will pipe them into Samtools[^2] for filtering with MQ > 20 

:exclamation: *This takes a very long time!* :exclamation:

bwa mem 

./PATH/TO/reference_genome.fa 
./PATH/TO/read_1.fq.gz 
./PATH/TO/read_2.fq.gz

```
bwa mem \
-M \
./kitchenflies/DNA/2_Process/2_bam_libraries/dmel-all-chromosome-r6.54.fasta \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read1.fq.gz \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read2.fq.gz \

| samtools view \
-Sbh -q 20 -F 0x100 - > ./kitchenflies/DNA/2_Process/2_bam_libraries/F1_22_library.bam \
```




[^1]: Li H. and Durbin R. (2009) Fast and accurate short read alignment with Burrows-Wheeler Transform. Bioinformatics, 25:1754-60. [PMID: 19451168] <https://github.com/lh3/bwa>
[^2]: https://www.htslib.org/
