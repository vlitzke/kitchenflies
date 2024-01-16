# Downloading your data

Once you have sent off your DNA samples to the sequencer, you will likely want to download your data from their website to somewhere with enough storage (probably not your personal computer!) 

For example, Novogene has a tab on top that says: 
> Click on Export Link

Then you'll download an excel table, that has a few links. 

get an excel table full of the result files:

In linux, use the command:

`Wget [insert link here]`

To Unzip: 

`unzip filename.zip` 

The folder where the company provides you with
1. Raw Data
2. Quality (QC) report

## Raw Data[^1]

The original image data by high throughput sequencers are transformed to raw data (Raw reads) by CASAVA base calling. The raw data are recorded in a FASTQ (FQ for short) file, which contains sequence information (reads) and corresponding quality information.

The RawData folder contains the raw data of each sample, which is in a *.fq.gz (compressed FASTQ file, typically large files ~ 2000-4000 MB) and will include two runs on it, since we have paired data. For example: 
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz
   
Each sequence read is stored in four lines as follows:

> @A00184:509:H3253DSXY:4:1101:2067:1000 2:N:0:ATCCTTGG+TAGCCACT
TTTTACTCCCTCCGTCCCATAATATAAGGGATTTTAGAGGGATATGACACATCCTAGGACAACGAATCTAGTCAGGAGCTTGTCTAGATTCGTTGTCCTACGATGTGTCACCTCCCTCCAAAATCCCTTATATTATGGGATGGAGGGAGT
> 
>\+
> 
> FFFFFFFFFFFFFFFFFF,FFFFFFFFFFF:FFFFFFFFFFFFFFF:,FFFF,FFFFFFFFFFFFF:FFFFF,FFFFF:FFFF:F:FFFF:FF,FFFFFF:F,FFFFFFFF,FFFFFFFFFFFFF:FFFFFFFFFFF,FFF:F:FF,FFF

Line 1 begins with an '@' character and is followed by the Illumina Sequence Identifiers and an optional description.
Line 2 is the raw sequence read. 
Line 3 begins with a '+' character and is optionally followed by the same sequence identifier and description (optional). 
Line 4 encodes the quality data for the sequence in Line 2, and must contain the same number of characters as there are bases in the sequence. 

Most importantly, FASTQ files contain the nucleotide sequence and the per-base calling quality for millions of reads.

Illumina Sequence Identifier details:

| Code | Description |
| ---- |:--------- |
| A00184 | Unique instrument name |
| 509 | Run ID | 
| H3253DSXY | Flowcell ID |
| 4 | Flowcell lane |
| 1101 | Tile number within the flowcell lane |
| 2067 | 'x'-coordinate of the cluster within the tile |
| 1000 | 'y'-coordinate of the cluster within the tile |
| 2 | Member of a pair, 1 or 2 (paired-end or mate-pair reads only) |
| N | Y if the read fails filter (read is bad), N otherwise |
| 0 | 0 when none of the control bits are on, otherwise it is an even number |
|ATCCTTGG+TAGCCACT | Index sequence |

The quality values of the raw sequence read are the ASCII value from the each character in the fourth row minus the 33.
The quality score of each base is calculated by the ASCII value of its corresponding char minus the constant value 33.


As well as a file called MD5.txt which is not super useful for us, but is a "message-digest algorithm" used to check the file integrity.

# Creating a sample file 

This will prove useful if you want to run your samples on the cluster and want to loop through all of them (by using an array). 

| Sample ID |
| --- |
| F1_23
F1_22 
F2_22 
F2_23 
M1_22
M1_23
M2_23
M3_22 |


# Quality Control of Raw Reads - fastQC

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

This can take in a sequence of *.fq.gz files. It outputs an HTML file which contains summary statistics for each individual read.

### Per base sequence quality
Provides the average quality for each position along the read (aiming for > 30), and should expect consistently high quality along the read. However, there are phasing errors, in which you might see a decline in quality towards the end of the reads. 

### Per sequence quality scores
Similar information to help us see if a subset of sequences have universally low quality values but represented as the average quality across all of reads. Would hope to see high quality sequences and not a bi-modal distribution (might see a bump at lower measures).

### Per tile sequence quality 
Provides the physical structure of each cluster subdivided into tiles in the flowcell. Helps us see which bit in the flow cell produced low quality reads (should expect blue dots all over), where you might see patches of warmer colors (phasing issues or other problems). In the worst case, there could be a bubble on the slide, which means you should go back and tell the sequencing facility (on them)! That’s on them.

### Per base sequence and GC content 
In each position of read, we should know which base is called, therefore the chances of getting ATCG should not change throughout the course of the run (though you might get noise  at the start). Squiggles in these plots could indicate adaptor contamination or a bias towards a certain base. 

### Per sequence GC content
We expect to see GC content curve normally distributed around the GC content specific to this organism, as they are randomly selected from the genome. If there are spikes in the plot or the distribution does not fit within the expected distribution (like a hump on one side of the GC content), there might be possibilities of contamination/you have another organism in your sample (like bacteria, parasites).

### Per sequence N content
Good data should show no N's or consistently low N's (N is what is assigned when a base cannot be read). There might be some bias/contamination if there are peaks of Ns in a specific base position. 

### Sequence duplication levels
We would rarely find that if we took two random samples from genomic DNA, that two reads would be exactly the same, so we expect a low number of duplicates. Duplications are often an artefact from the library prep or some bias in PCR amplification (enrichment bias), but THIS has to be taken with a piece of salt With RNA – duplicated sequences are expected! Means you have a really highly expressed gene that gets read time and time again.

### Overrepresented sequences
The amount of times we get particular sequences. If we get particular bits of sequences over and over again but they get no hits (in RNA seq) then its ok. 

# MultiQC
To combine all HTML reports, we use MultiQC[^3] using to generate a single large report (which apparently may also use information from other downstream tools, e.g. adapter trimming, alignment).

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

# Novogene's QC Report

|Sample|Lane|Raw bases(bp)|Clean bases(bp)|Effective rate(%)|Error rate(%)|Q20(%)|Q30(%)|GC content(%)|
|----|-------------------------|-----------|-------|------------|--------------|---------|----------|---------------|
|F1_22|EKDN230045336-1A_HVMCLDSX7_L4|10,370,125,500|10,235,704,500|98.7|0.03|97.19|92.59|41.47|
|F2_22|EKDN230045337-1A_HVLM3DSX7_L1|6,770,294,100|6,670,142,700|98.52|0.03|96.69|91.45|41.14|
|M1_22|EKDN230045340-1A_HVLM3DSX7_L1|6,689,064,000|6,545,327,700|97.85|0.03|96.5|91.27|41.14|
|M3_22|EKDN230045342-1A_HVMCLDSX7_L4|11,145,425,100|10,886,277,300|97.67|0.03|96.76|91.82|41.14|
|F1_23|EKDN230045344-1A_HVMCLDSX7_L4|10,146,516,600|9,993,457,200|98.49|0.03|96.95|92.07|41.2|
|F2_23|EKDN230045345-1A_HVLM3DSX7_L1|5,304,891,300|5,212,344,600|98.26|0.03|96.36|90.85|41.34|
|M1_23|EKDN230045348-1A_HVMCLDSX7_L4|9,552,331,800|9,342,282,900|97.8|0.03|96.75|91.72|41.1|
|M2_23|EKDN230045349-1A_HVLM3DSX7_L1|6,852,402,900|6,704,172,600|97.84|0.03|96.36|90.88|41.02|


Statistics of Sequencing Data
1. Sample name
2. Lane: The flowcell ID and lane number during the sequencing (FlowcellID_LaneNumber).
3. Raw bases(bp): The original sequence data volume, (Raw reads) * (sequence length), calculating in bp.
4. Clean bases(bp): The sequence data volume calculated by clean data, (Clean reads) * (sequence length), calculating in bp.
5. Effective (%): The ratio of clean data to raw data.
6. Error (%): Overall error rate of base.
7. Q20 (%): The percentage of bases with higher Phred score than 20.
8. Q30 (%): The percentage of bases with higher Phred score than 30.
9. GC: The percentage of G and C in the total bases.

# Downloading the reference genome 

Download reference genome from here: <https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>

To unzip: `gunzip -f dmel-all-chromosome-r6.54.fasta.gz`

Note: Leeban says I can map the RNA-seq data to the reference genome to get Fst values 
I mapped it to cDNA (no introns) 
Mapping to the DNA reference means you need an aligner aware of splice junctions, such as Tophat or STAR

[^1]: Taken from the Novogene README file. 
[^2]: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
[^3]: https://multiqc.info/
