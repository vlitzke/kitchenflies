# Alignment 

Next, we're going to map our trimmed reads to the reference genome. This is the point in which we determine the position in the genome based on the read sequence. For this, we will use BWA[^1]. `bwa mem` is preferable for longer Illumina reads  > 70 bp and < 1Mbp. It also directly produces SAM files. 

The BWA-MEM algorithm performs local alignment. It may produce multiple primary alignments for different part of a query sequence. This is a crucial feature for long sequences. However, some tools such as Picard’s markDuplicates does not work with split alignments. One may consider to use option -M to flag shorter split hits as secondary.

The output of the ‘aln’ command is binary and designed for BWA use only. BWA outputs the final alignment in the SAM (Sequence Alignment/Map) format.

Then we will pipe them into Samtools[^2], filtering with MQ (mapped quality score) > 20. Using `samtools view` views and converts SAM/BAM/CRAM files. 

:exclamation: *Computationally and time consuming* :exclamation:

```
bwa mem \
-M \
./PATH/TO/reference_genome.fa  \
./PATH/TO/read_1.fq.gz  \
./PATH/TO/read_2.fq.gz \

| samtools view \
-Sbh -q 20 -F 0x100 - > ./kitchenflies/DNA/2_Process/2_bam_libraries/F1_22_library.bam \
```

| Command      | Description |
| ----------- | ----------- |
| `-M` | Mark shorter split hits as secondary (for Picard compatibility) |
| - | reference genome |
| - | input file 1.fq.gz |
| - | input file 2.fq.gz |
| `-S` | Ignored for compatibility with previous samtools versions. Previously this option was required if input was in SAM format, but now the correct format is automatically detected by examining the first few characters of input. |
| `-b` |Output in the BAM format.|
| `-h` | Includes header in the output|
| `-q` | filtering alignments with MAPQ smaller than 20 |
| `-F` | Do not output alignments with bits set in FLAG present in the FLAG field |
| `0x100` |	SECONDARY	secondary alignment, specified by hex|

[^1]: Li H. and Durbin R. (2009) Fast and accurate short read alignment with Burrows-Wheeler Transform. Bioinformatics, 25:1754-60. [PMID: 19451168] <https://github.com/lh3/bwa>
[^2]: Danecek, P., Bonfield, J. K., Liddle, J., Marshall, J., Ohan, V., Pollard, M. O., ... & Li, H. (2021). Twelve years of SAMtools and BCFtools. Gigascience, 10(2), giab008. <https://doi.org/10.1093/gigascience/giab008> <https://www.htslib.org/>
