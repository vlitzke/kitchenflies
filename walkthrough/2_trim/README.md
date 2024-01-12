# Step 2: Trimming

Raw FASTQ reads will be trimmed for a minimum BQ >18 and a minimum length (fragments greater than 75 base pairs) using cutadapt[^1].

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

Saved as trimmed files in the 1_cutadapt_trimmed folder

For more information about this tool, see <https://cutadapt.readthedocs.io/en/stable/>
[^1]: Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.

