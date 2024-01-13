# Step 2: Trimming

Raw FASTQ reads will be trimmed for a minimum BQ >18 and a minimum length (fragments greater than 75 base pairs) using cutadapt[^1].

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
| -q     | trims low-quality ends from reads, with a specified single cutoff value which trims from the 3' end[^2] |
| --minimum length   | Discard processed reads that are shorter than 75 bp |
| -o | output file name |
| -p | output file name for second read in the pair |
| -b | detects and trims adaptor sequence on forward read |
| -B | detects and trims adaptor sequence on reverse read |
| -O | sets the minimum overlap parameters for adapters listed via the -b option |
| -n | looks to trim a minimum of 3 adaptor sequences from one read |
| - | input file 1.fq.gz |
| - | input file 2.fq.gz |

To keep things neat, I keep the output in the same folder ("1_cutadapt_trimmed folder") 

For more information about this tool, see <https://cutadapt.readthedocs.io/en/stable/>

[^1]: Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.
[^2]: For Illumina reads, this is sufficient as their quality is high at the beginning, but degrades towards the 3’ end. 

