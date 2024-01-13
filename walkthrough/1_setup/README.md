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

The RawData folder contains the raw data of each sample, which is in a *.fq.gz (compressed FASTQ file) and will include two runs on it, since we have paired data. For example: 
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz
   
Each sequence read in FASTQ format is stored in four lines as follows:

@A00184:509:H3253DSXY:4:1101:2067:1000 2:N:0:ATCCTTGG+TAGCCACT
TTTTACTCCCTCCGTCCCATAATATAAGGGATTTTAGAGGGATATGACACATCCTAGGACAACGAATCTAGTCAGGAGCTTGTCTAGATTCGTTGTCCTACGATGTGTCACCTCCCTCCAAAATCCCTTATATTATGGGATGGAGGGAGT
+
FFFFFFFFFFFFFFFFFF,FFFFFFFFFFF:FFFFFFFFFFFFFFF:,FFFF,FFFFFFFFFFFFF:FFFFF,FFFFF:FFFF:F:FFFF:FF,FFFFFF:F,FFFFFFFF,FFFFFFFFFFFFF:FFFFFFFFFFF,FFF:F:FF,FFF

Line 1 begins with an '@' character and is followed by the Illumina Sequence Identifiers and an optional description.
Line 2 is the raw sequence read. 
Line 3 begins with a '+' character and is optionally followed by the same sequence identifier and description (optional). 
Line 4 encodes the quality data for the sequence in Line 2, and must contain the same number of characters as there are bases in the sequence. 

Illumina Sequence Identifier details:

| A00184 | Unique instrument name |
| ---- |
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

This will prove useful if you want to run your samples on the cluster and want to loop through all of them. 

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

# Downloading the reference genome 

Download reference genome from here: <https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>

To unzip: `gunzip -f dmel-all-chromosome-r6.54.fasta.gz`

Note: Leeban says I can map the RNA-seq data  to the reference genome to get Fst values 
I mapped it to cDNA (no introns) 
Mapping to the DNA reference means you need an aligner aware of splice junctions, such as Tophat or STAR

[^1]: Taken from the Novogene README file. 
