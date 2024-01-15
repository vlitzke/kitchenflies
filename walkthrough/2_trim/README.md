# Step 2: Trimming

Raw FASTQ reads will be trimmed for a minimum BQ >18 and a minimum length (fragments greater than 75 base pairs) using cutadapt[^1]. It uses a semiglobal alignment algorithm (free-shift, ends-free or overlap alignment). In a regular (global) alignment, the two sequences are compared from end to end and all differences occuring over that length are counted. In semiglobal alignment, the sequences are allowed to freely shift relative to each other and differences are only penalized in the overlapping region between them:

![image](alg_text_eg.png)

The prefix ELE and the suffix ASTIC do not have a counterpart in the respective other row, but this is not counted as an error. The overlap FANT has a length of four characters.

Traditionally, alignment scores are used to find an optimal overlap aligment: This means that the scoring function assigns a positive value to matches, while mismatches, insertions and deletions get negative values. The optimal alignment is then the one that has the maximal total score. Usage of scores has the disadvantage that they are not at all intuitive: What does a total score of x mean? Is that good or bad? How should a threshold be chosen in order to avoid finding alignments with too many errors?

For Cutadapt, the adapter alignment algorithm primarily uses unit costs instead. This means that mismatches, insertions and deletions are counted as one error, which is easier to understand and allows to specify a single parameter for the algorithm (the maximum error rate) in order to describe how many errors are acceptable.

There is a problem with this: When using costs instead of scores, we would like to minimize the total costs in order to find an optimal alignment. But then the best alignment would always be the one in which the two sequences do not overlap at all! This would be correct, but meaningless for the purpose of finding an adapter sequence.

The optimization criteria are therefore a bit different. The basic idea is to consider the alignment optimal that maximizes the overlap between the two sequences, as long as the allowed error rate is not exceeded.

Conceptually, the procedure is as follows:

Consider all possible overlaps between the two sequences and compute an alignment for each, minimizing the total number of errors in each one.

Keep only those alignments that do not exceed the specified maximum error rate.

Then, keep only those alignments that have a maximal number of matches (that is, there is no alignment with more matches). (Note: This has been changed, see the section below for an update.)

If there are multiple alignments with the same number of matches, then keep only those that have the smallest error rate.

If there are still multiple candidates left, choose the alignment that starts at the leftmost position within the read.

In Step 1, the different adapter types are taken into account: Only those overlaps that are actually allowed by the adapter type are actually considered.
Note: both Compressed in- and output files are supported (.gz). 

```
cutadapt \
-q 18 \
--minimum-length 75 \
-o ./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read1.fq.gz \
-p ./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read2.fq.gz \
-b ACACTCTTTCCCTACACGACGCTCTTCCGATC \
-B CAAGCAGAAGACGGCATACGAGAT \
-O 15 \
-n 3 \
./kitchenflies/DNA/1_Raw/2023/2023_Raw/01.RawData/F1_22/F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz \
./kitchenflies/DNA/1_Raw/2023/2023_Raw/01.RawData/F1_22/F1_22_EKDN230045336-1A_HVMCLDSX7_L4_2.fq.gz
```

| Command      | Description |
| ----------- | ----------- |
| `-q`     | trims low-quality ends from reads, with a specified single cutoff value which trims from the 3' end[^2] |
| `--minimum length`   | Discard processed reads that are shorter than 75 bp |
| `-o` | output file name |
| `-p` | output file name for second read in the pair |
| `-b` | detects and trims adaptor sequence on forward read |
| `-B` | detects and trims adaptor sequence on reverse read |
| `-O` | sets the minimum overlap parameters for adapters listed via the -b option |
| `-n` | looks to trim a minimum of 3 adaptor sequences from one read |
| - | input file 1.fq.gz |
| - | input file 2.fq.gz |

To keep things neat, I keep the output in the same folder ("1_cutadapt_trimmed folder") 

For more information about this tool, see <https://cutadapt.readthedocs.io/en/stable/>

[^1]: Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.
[^2]: For Illumina reads, this is sufficient as their quality is high at the beginning, but degrades towards the 3’ end. 

