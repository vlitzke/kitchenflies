# Quality Control of Raw Reads 

Next, you might want to run some basic quality control of your FASTQ files. This is often done using a popular tool called FastQC[^2]. This can either be done through a GUI which the institute developed, or over the comand line: 

```
conda install bioconda::fastqc
fastqc file1.fq.gz file2.fq.gz .. filen.fq.gz -o ./PATH/TO/QC
```

| Command      | Description |
| ----------- | ----------- |
| - | input file 1.fq.gz |
| - | input file 2.fq.gz |
| `-o` | output file directory |

This can take in a sequence of *.fq.gz files. 

It outputs an HTML file which contains summary statistics for each individual read. To combine all HTML reports, we use MultiQC[^3] using to generate a single large report (which apparently may also use information from other downstream tools, e.g. adapter trimming, alignment).

```
conda install bioconda::multiqc
multiqc . #where "." indicates the directory in which to find the html reports
```

This information allows us to flag any samples that might have poor quality and should be discarded, although any sort of consensus is subjective. If our samples were processed in a similar way, they should have similar metrics. If some of the criteria turn out to be poor, depending on how poor this is, it might be good to proceed with downstream analyses while keeping this information in mind. 

:memo: Threw an error: "No module named typing_extensions". Run `pip install typing-extensions`

|Sample Name|% Dups|% GC|Average Read Length|Median Read Length|% Failed|M Seqs|
|-----|----|----|-----|------|------|------|
|F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1|26.5%|41%|150 bp|150 bp|9%|34.6|
|F1_22_EKDN230045336-1A_HVMCLDSX7_L4_2|26.8%|41%|150 bp|150 bp|0%|34.6|
|F1_23_EKDN230045344-1A_HVMCLDSX7_L4_1|28.3%|41%|150 bp|150 bp|9%|33.8|
|F1_23_EKDN230045344-1A_HVMCLDSX7_L4_2|28.1%|41%|150 bp|150 bp|0%|33.8|
|F2_22_EKDN230045337-1A_HVLM3DSX7_L1_1|18.9%|41%|150 bp|150 bp|0%|22.6|
|F2_22_EKDN230045337-1A_HVLM3DSX7_L1_2|19.5%|41%|150 bp|150 bp|0%|22.6|
|F2_23_EKDN230045345-1A_HVLM3DSX7_L1_1|16.8%|41%|150 bp|150 bp|0%|17.7|
|F2_23_EKDN230045345-1A_HVLM3DSX7_L1_2|17.2%|41%|150 bp|150 bp|0%|17.7|
|M1_22_EKDN230045340-1A_HVLM3DSX7_L1_1|20.2%|41%|150 bp|150 bp|0%|22.3|
|M1_22_EKDN230045340-1A_HVLM3DSX7_L1_2|20.8%|41%|150 bp|150 bp|0%|22.3|
|M1_23_EKDN230045348-1A_HVMCLDSX7_L4_1|28.8%|41%|150 bp|150 bp|9%|31.8|
|M1_23_EKDN230045348-1A_HVMCLDSX7_L4_2|28.4%|41%|150 bp|150 bp|0%|31.8|
|M2_23_EKDN230045349-1A_HVLM3DSX7_L1_1|19.8%|41%|150 bp|150 bp|0%|22.8|
|M2_23_EKDN230045349-1A_HVLM3DSX7_L1_2|20.3%|41%|150 bp|150 bp|0%|22.8|
|M3_22_EKDN230045342-1A_HVMCLDSX7_L4_1|30.6%|41%|150 bp|150 bp|9%|37.2|
|M3_22_EKDN230045342-1A_HVMCLDSX7_L4_2|30.3%|41%|150 bp|150 bp|0%|37.2|
