# Step 2: Trimming

Raw FASTQ reads will be trimmed for a minimum BQ >18 and a minimum length (fragments greater than 75 base pairs) using cutadapt[^1]. It uses a semiglobal alignment algorithm (free-shift, ends-free or overlap alignment). The following is taken from Marcel's documentation: In a regular (global) alignment, the two sequences are compared from end to end and all differences occuring over that length are counted. In semiglobal alignment, the sequences are allowed to freely shift relative to each other and differences are only penalized in the overlapping region between them:

![image](alg_text_eg.png)

The prefix ELE and the suffix ASTIC do not have a counterpart in the respective other row, but this is not counted as an error. The overlap *FANT* has a length of four characters.

To find optimal overlap alignment, alignment scores would assign a positive value to matches, and negative values to mismatches, insertions and deletions, resulting in a total score, but this isn't that intuitive.  Marcel's algorithm instead counts mismatches, insertions and deletions as one error (renamed "unit costs"). This returns a single parameter, the maximum error rate, which helps us decide the number of acceptable errors. Optimization criteria is to consider the alignment optimal that maximizes the overlap between the two sequences, as long as the allowed error rate is not exceeded.

## Method: 

1. Consider all possible overlaps between the two sequences and compute an alignment for each, minimizing the total number of errors in each one. (different adapter types are taken into account: Only those overlaps that are actually allowed by the adapter type are actually considered.)
2. Keep alignments that do not exceed the specified maximum error rate.
3. Keep alignments that have a maximal number of matches (that is, there is no alignment with more matches) and uses both edit distance (for all possible overlaps between the read and the adaptor) and score (decides which overlap is the best one based on a matrix).
     ![image](alg_text_eg2.png)

   The trimmed read is `CCTGAGAGT`.

4. If there are multiple alignments with the same number of matches, then keep only those that have the smallest error rate.
5. If there are still multiple candidates left, choose the alignment that starts at the leftmost position within the read.

:memo: **Note**: both Compressed in- and output files are supported (.gz). 

## Code 
```
cutadapt \
-q 18 \
--minimum-length 75 \
-o ./PATH/TO/1_cutadapt_trimmed/filename_trimmed-read1.fq.gz \
-p ./PATH/TO/1_cutadapt_trimmed/filename_trimmed-read2.fq.gz \
-b ACACTCTTTCCCTACACGACGCTCTTCCGATC \
-B CAAGCAGAAGACGGCATACGAGAT \
-O 15 \
-n 3 \
./PATH/TO/Raw_Data/filename_1.fq.gz \
./PATH/TO/Raw_Data/filename_2.fq.gz
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

To keep things neat, I keep the output in the same folder ("1_cutadapt_trimmed folder").

Can also run multiqc on these results (in base pairs):

|Sample Name |Total Reads Processed|Pairs too short|Pairs passing filters |Total base pairs processed|Total Quality Trimmed|Total filtered|Read|With adaptor|Base pairs processed|Quality Trimmed|filtered|
|-----|-----|-----|-----|-----|-----|-----|---------|-----|-----|-----|-----|
F1_22| 34,567,085|32,986 (0.1%)|34,534,099 (99.9 %)|10,370,125,000|12,742,357  (0.1%)|10,350,938,250  (99.8%)|Read 1|33 (0.0%)|5,185,062,750|4,713,193|5,176,283,874
||||||||Read 2|24(0.0 %)|5,185,062,750|8,029,164|5,174,654,376
F1_23|33,821,722|34,024 (0.1%) |33,787,698 (99.9%)|10,146,516,600 |13,500,307  (0.1%)|10,126,353,863  (99.8%)|Read 1|51 (0.0%)|5,073,258,300 |4,602,604 |5,064,446,548 
||||||||Read 2|21 (0.0%)|5,073,258,300 |8,897,703 |5,061,907,315 
F2_22|||||||||||
||||||||||||
F2_23|17,682,971|21,976 (0.1%)|17,660,995 (99.9%)|5,304,891,300 |8,780,240  (0.2%)|5,291,830,776  (99.8%)|Read 1|24 (0.0%)|2,652,445,650 |3,999,716 |2,645,937,733 
||||||||Read 2|6 (0.0%)|2,652,445,650 |4,780,524 |2,645,893,043 
M1_22|22,296,880|29,877 (0.1%)|22,267,003 (99.9%)|6,689,064,000 |12,601,532  (0.2%)|6,670,632,397  (99.7%)|Read 1|39 (0.0%)|3,344,532,000 |5,780,546 |3,335,405,821 
||||||||Read 2|18 (0.0%)|3,344,532,000 |6,820,986 |3,335,226,576 
M1_23|31,841,106|33,627 (0.1%)|31,807,479 (99.9%)|9,552,331,800 |14,974,446  (0.2%)|9,530,734,750  (99.8%)|Read 1|33,627 (0.1%)|4,776,165,900 |5,049,903 |4,766,891,502 
||||||||Read 2|25 (0.0%)|4,776,165,900 |9,924,543 |4,763,843,248 
M2_23|22,841,343|32,422 (0.1%)|22,808,921 (99.9%)|6,852,402,900 |13,475,734  (0.2%)|6,832,628,348  (99.7%)|Read 1|52 (0.0%)|3,426,201,450 |5,928,373 |3,416,580,652 
||||||||Read 2|8 (0.0%)|3,426,201,450 |7,547,361 |3,416,047,696 
M3_22|37,151,417|41,722 (0.1%)|37,109,695 (99.9%)|11,145,425,100 |18,489,981  (0.2%)|11,118,727,214  (99.8%)|Read 1|68 (0.0%)|5,572,712,550 |6,537,255 |5,561,008,944 
||||||||Read 2|76 (0.0%)|5,572,712,550 |11,952,726 |5,557,718,270 



For more information about this tool, see <https://cutadapt.readthedocs.io/en/stable/>

[^1]: Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.
[^2]: For Illumina reads, this is sufficient as their quality is high at the beginning, but degrades towards the 3’ end. 

