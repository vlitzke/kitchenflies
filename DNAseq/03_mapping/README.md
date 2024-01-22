# Step 3: Alignment 

Next, we're going to map our trimmed reads to the reference genome. This is the point in which we determine the position in the genome based on the read sequence. For this, we will use BWA[^1]. `bwa mem` is preferable for longer Illumina reads  > 70 bp and < 1Mbp. It also directly produces SAM files. 

The BWA-MEM algorithm performs local alignment. It may produce multiple primary alignments for different part of a query sequence. This is a crucial feature for long sequences. However, some tools such as Picard’s markDuplicates does not work with split alignments. One may consider to use option -M to flag shorter split hits as secondary.

Then we will pipe them into Samtools[^2], filtering with MQ (mapped quality score) > 20. Using `samtools view` views and converts SAM/BAM/CRAM files. 

In Kapun's supplementary material he maps his samples to a compound reference (D. melanogaster AND commensals + pathogens,
:exclamation: *Computationally and time consuming* :exclamation:

```
conda install bioconda::bwa

bwa mem \
-M \
./PATH/TO/2_bam_libraries/reference_genome.fa  \
./PATH/TO/1_cutadapt_trimmed/sampleName_trimmed_read_1.fq.gz  \
./PATH/TO/1_cutadapt_trimmed/sampleName_trimmed_read_2.fq.gz \

| samtools view \
-Sbh -q 20 -F 0x100 - > ./PATH/TO/2_bam_libraries/sampleName_library.bam \
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

# Sorting
Using Picard [^3], the SAM file is going to be sorted by coodinate (SortOrder is found in the SAM file header), here read alignments are sorted into subgroups by the reference sequence name (RNAME) field using the reference sequence dictionary (@SQ tag), then secondarily sorted using the left-most mapping position of the read (POS). Doing this by coordinate makes SAM files smaller, visualizing more efficient, and helps when marking duplicates (for paired reads, this is done by looking at 5' mapping positions of both reads) because this guarantees that the reads physically closer inside the SAM file are also close in the genome.
 
```
conda install bioconda::picard

picard SortSam \
I=./PATH/TO/2_bam_libraries/samplename_library.bam \
O=./PATH/TO/3_sortbam_libraries/samplename_library-sort.bam \
SO=coordinate 
```

| Command      | Description |
| ----------- | ----------- |
| `-I` | input library .bam |
| `-O` | output sorted library .bam |
| `SO` | Sort order of output file. |

# Output Statistics 

I saved the stats output in this third folder, then created a new folder for the plot-bamstats output ("bamstats").

`samtools stats ./PATH/TO/samplename_library-sort.bam > ./PATH/TO/samplename_library-sort.stats`

```
conda install conda-forge::libjpeg-turbo
conda install conda-forge::gnuplot=5.2.7
# Reinstall samtools
conda install bioconda::samtools

plot-bamstats -p ./PATH/TO/samplename_bamStatOutput ./PATH/TO/bamstat/samplename_library-sort.stats 
```
:memo: plot-bamstats has a dependency with gnuplot (the internet suggests v5.2.7) 

You actually end up with a bunch of plots and an html file that only works if all of the figures are there. There must be another way to manipulate these kinds of plots, so I found:

https://ucdavis-bioinformatics-training.github.io/2019-March-Bioinformatics-Prerequisites/wednesday/Data_in_R/data_in_R.html


There's also : 
Step #1. Calculate the depth along the genomic locus by Samtools.

samtools depth reads.sort.bam > reads.sort.coverage
Step #2. Plot the coverage by ggplot function in R. (The demo data only includes one chromosome)

setwd("D://R")  # working path
coverage=read.table("reads.sort.coverage", sep="\t", header=F)
install.packages('reshape')
library(reshape)
coverage=rename(coverage,c(V1="Chr", V2="locus", V3="depth")) # renames the header
ggplot(coverage, aes(x=locus, y=depth)) +
geom_point(colour="red", size=1, shape=20, alpha=1/3) +
scale_y_continuous(trans = scales::log10_trans(), breaks = scales::trans_breaks("log10", function(x) 10^x))

Leeban says: only care about relationship between mapped things and those properly paired , and mapping rate 

[^1]: Li H. and Durbin R. (2009) Fast and accurate short read alignment with Burrows-Wheeler Transform. Bioinformatics, 25:1754-60. [PMID: 19451168] <https://github.com/lh3/bwa>
[^2]: Danecek, P., Bonfield, J. K., Liddle, J., Marshall, J., Ohan, V., Pollard, M. O., ... & Li, H. (2021). Twelve years of SAMtools and BCFtools. Gigascience, 10(2), giab008. <https://doi.org/10.1093/gigascience/giab008> <https://www.htslib.org/>
[^3]: <http://broadinstitute.github.io/picard>
