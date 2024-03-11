kallisto quant \
-i ./PATH/TO/Drosophila_melanogaster.BDGP6.46.cdna.all.index \
-o ./PATH/TO/DESTINATION 
./PATH/TO/sampleName_1_trimmed.fq.gz 
./PATH/TO/sampleName_2_trimmed.fq.gz

Indexing: 
Going to need reference sequences – fasta file, in RNAseq this is a collection of transcript sequences to which we align our raw reads so we can count/estimate abundance of the raw reads.. can use Ensembl – we want the cDNA file. Now its in a folder called ensemble -
/pub/release-110/fasta/drosophila_melanogaster/cdna
Each entry > , then a defline (definition line) transcript id, cdna, exact location on chromosome, type of gene it is (protein coding), gene symbol and description and seqeunece itself 

Now we need to build it as an index
Open conda environment, use kallisto to. Build an index – only need to do this once (only rebuild it if the reference files are updated) 
kallisto index -i Drosophila_melanogaster.BDGP6.46.cdna.all.index Drosophila_melanogaster.BDGP6.46.cdna.all.fa

took the file, chopped it off into 31 kmers and noticed that some poly a tails were clipped down (there are loong poly a tails) it also replace 10000000 nucleotides that weren’t the right characters and replaced them with pseudo nucleotides , then counted kmers..
\
Open file it just created, its quite large. Like four times larger. In order to make fasta file more searchable, has to be larger… this can be quite computationally expensive

Now we have an indexed transcriptome 

Then kallisto maps 

First
Call kallisto:
Kallisto quant \ (continues on, just stacks the code)
-i (index file name) \
-o test \ specifes name of output folder and put the results in, call it whatever 
-t 8 \ (can use multiple threads) 
--paired -l (average length) 250 -s (and average standard deviation) of the library 30 \  this is kinda confusing, this is what a standard library prep is for illumine short read sequencing , however you could get more specific if you had access to Bioconductor profiles of our actual libraries before they went onto the seqeuner for accurate numbers…
Name of fastq file. 

This would give us standard output describing the results of the alignment – 
So we add \
&>test.log (another object to save results) 

Ohh for paired end it looks like this: (photo in word doc)

kallisto quant \
-i Drosophila_melanogaster.BDGP6.46.cdna.all.index \
-o test \
F3_EKRN230053769-1A_H7MJFDSX7_L2_1.fq.gz \
F3_EKRN230053769-1A_H7MJFDSX7_L2_2.fq.gz \
&> test.log

This is what I ran: 
kallisto quant -i ./4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./4_Mapping_kallisto/F5 ./3_CleanedReads_fastp/F5_EKRN230053771-1A_H7LCTDSX7_L3_1_cleaned.fq.gz ./3_CleanedReads_fastp/F5_EKRN230053771-1A_H7LCTDSX7_L3_2_cleaned.fq.gz

for F3 and F5, the reads were pretty well aligned!

Can use pseduobam to present piled-up reads of gene expression data – also performs well for lowly expressed transcripts (pseudoalignment method) Zheng2019 
