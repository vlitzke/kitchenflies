# Step 9: Pileup 

Create an mpileup file using Samtools[^1]. It takes in the BAMList.txt file you created in the last step and creates an mpileup file, which retains nucleotides with BQ >20 and reads with MQ > 20. Pileup format consists of TAB-separated lines, with each line representing the pileup of reads at a single genomic position.
  
The first three columns give the position and reference:
- Chromosome name.
- 1-based position on the chromosome.
- Reference base at this position (this will be “N” on all lines if -f/--fasta-ref has not been used).

The remaining columns show the pileup data, and are repeated for each input BAM file specified:

- Number of reads covering this position
- Read bases. This encodes information on matches, mismatches, indels, strand, mapping quality, and starts and ends of reads. For more information see[^1]
- Base qualities
- (Optional) Alignment mapping qualities
- (Optional) Comma-separated 1-based positions within the alignments, in the orientation shown in the input file. E.g., 5 indicates that it is the fifth base of the corresponding read that is mapped to this genomic position.
- (Optional) Additional comma-separated read field columns, as selected via --output-extra. The fields selected appear in the same order as in SAM: QNAME, FLAG, RNAME, POS, MAPQ (displayed numerically), RNEXT, PNEXT.
- (Optional) Comma-separated 1-based positions within the alignments, in 5' to 3' orientation. E.g., 5 indicates that it is the fifth base of the corresponding read as produced by the sequencing instrument, that is mapped to this genomic position.
- (Optional) Additional read tag field columns 

Any output column that would be empty, such as a tag which is not present or the filtered sequence depth is zero, is reported as "*". This ensures a consistent number of columns across all reported positions.

Note:
- Unmapped reads, secondary alignments, QC failures and duplicate reads, those with low quality bases and some reads in high depth regions are omitted (some of these options can be changed).

```
samtools mpileup -B \
-f ./PATH/TO/reference_genome.fa  \
-b ./PATH/TO/BAMlist.txt \
-q 20 \
-Q 20 \
| gzip > ./PATH/TO/dros.mpileup.gz
```

:memo: Works best if they're all in and written to the same folder (previous indels) and then move the pileup file over to the new folder (mpileup) later. 

[^1]: https://www.htslib.org/doc/samtools-mpileup.html
