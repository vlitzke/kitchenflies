On the other side, as RNA transcribed from DNA is further processed into mRNA (i.e. introns removed), many RNA-seq reads will fail to align to a genome reference sequence. Instead, we need to either align them to transcriptome reference sequences 


Raw read files were quality checked using fastQC (vXXX) and any samples that had multiple paired-end files run on different lanes were merged. Reads were filtered and cleaned using fastp (vXXX, default settings), cutting off reads less than 150 bp and automatically trimming adaptor sequences (50 bp from both ends). Sequences were aligned to the Drosophila melanogaster cDNA reference file (vBDGP6.46) from Ensembl (https://ftp.ensembl.org/pub/release-110/fasta/drosophila_melanogaster/cdna/). Kallisto (vXXX) was used to build an index file and aligned using the quant command. This provided us with abundance (.tsv) files containing the total number of counts. The differential gene expression analysis was carried out using R (cite XXX). Annotations (transcript ID and gene names) were fetched using biomaRt (vXXX), using the Drosophila melanogaster gene ensemble. Transcript abundances and count data were pulled. Using edgeR, we got our counts per million and log2 the data. Samples were then filtered to remove genes with zero read counts and normalized using the TMM method (see Supplementary Figures XXX). Continue XXX


Quality Control
1, Each of the samples has two .fastq files in them which means that L1 – is the lane but the last number is always 1 or 2 (F or R). 
2. Can merge the ones that have multiple files (for example, those that end in _1) – will give us higher coverage and won’t impact the data, even those these were samples that were run twice 
cat file1.gz file2.gz > allfiles.gz

3. Moving all the samples (the merged ones too) into a new folder back in RNAseq called QC (quality control) underneath Batch3 

4. Running fastqc on them 

Get an .html QC report

Use fastqc to look at quality (in envrioinment with kallisto)

Conda activate rnaseq 
Fastqc XXX.fastq.gz oooor for all of them fastqc *.gz

Can use cores on the laptop and process the file across threads (multithreading)- use all 8 threads or 4 physical cores to process  fastqc *.gz -t 8

With rna seq – click on sequence duplication and we get the % of sequnces that have been duplicated a number of times : we expect a number of genes in transcrioptome to be highly expressed and therefore to have repeated/duplicate sequences 

I want to do this to loop over all the files 
So I should probably rename them all first and cut out all the middle data. 
Then I should just keep the first characters up until the first _ 
And rename them all 
And then run fastqc on all of them, and save the output as something different



Conda install fastp

This cleans the read, fastp has good defaults, don’t have to change much  - shangzhe says the default it cuts off reads less than 150 bp and will automatically cut off the adapter sequences (trims 50bp off beginning and end)

Fast -i file_1.fq.gz -I file_.fq.gz -o file_1_cleaned.fq.gz -O file_2_cleaned.fq.gz

Now that they’re cleaned, I put them in the cleaned folder 

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

--
Weirdly enough I ran some of these files individually instead of altogether, but if you kept all the files from each step in the same directory, you could run multiqc which basically sorts out the various files and summarizes them into one html file. 

Batch3  % multiqc -d . 

Or just: multiqc Batch3 . 

This honestly works for a whoooole range of bioinformatic outputs (remember to may use later?) 

Now we have an indexed transcriptome 

RNA seq is count data -we are counting the number of reads that map to a particular transcript, so we need to consider the units we can use to quantify the expression of a gene  normalization 

---
 
Get abundance.htv, abundance.h5 and .json is a log file (number of processed reads, pseudoaligned). If you open the htv file on sublime text, it opens a text file with 5 columns, the ifrst is a transcript identifier (ensemble transcript id), they can have different versions (different annotation versions, so they might also end in a .1), then theres a length (how long the transcript is), an effective length, and estimated counts (number of reads that mapped to that transcript) and tpm (transcripts per million) which tells us that if we sampled 1 million transcripts from that particular sample, 5 (whatever the number is) of those 1 millon transcripts would be coming from this gene , then you search the gene to see what its like (go?) 

The effective length of a transcript is the length after adjusting for the total number of possible positions a fragment of size X could originate from 
Leffective = Lactual – Lfragment +1 
How possible is it that a fragment of length XXX could come from the transcript – just how many places it can fit within that transcript 

RNAseq gives the relative quantification of gene expression – there is no exception to this rule! 

Now we need to normalize the data: generic term that refers to any ways that a dataset is globally altered in order to improve our ability to detect differentially expressed genes 
-  if you have a gene that is overexpressed in comparison to the rest has a high standard deviation. This creates a problem – as gene expression goes up, STD goes up – harder to pull out genes that are differentially expressed between conditions becasu they have a high STD, but if they are highly expressed, then they must be quite important. This is called heteroscedasticty.  – variance is not even across different levels of expression value. So we take the raw counts and transform them using a log2 scale but this can create another problem… those with low expression now have highest std but its better to have more noise down here 

These samples are pooled, then sequenced then we get fastq files out. In an ideal world, expected reads per sample should be even but its not, which has an implication for how we count genes and measure their relative expression 

If sequencing depth differs between samples, by default, we will more reads aligned to it if it was better. So then between different samples the genes might be disproportionately expressed. So we need to account of sequencing depth – we know how many reads each sample has, if we divide the reads / sequencing depth, we account for this – this is between samples

We should also maybe scale within the sample, if genes are different lengths, they will have different numbers of reads mapping to them. Smaller regions will generate fewer fragments for seqeuencing, when instead we should normalize to a unit length 

So this is rpkm – reads per kilobase (scaling by length) per million reads (sequencing depth of the sample)  same with fpkm  this is no longer a good way of expressing units 
Soooooo true sampling normalization variance should probably be by using DESeq and EdgeR

So to fix it it, you can scale by gene length first, and then total up the row . so you divide the reads per kb / total rpk in sample = TPM -> always total to one (abundance of all the transcripts)  so *10^6  now its transcripts per million meet the criteria of the average relative molar concentration if mapped to same reference file 

We need to also normalize between samples. We have to account for “funky genes” and ignore them if one is extremely highly expressed in one sample – want to find a set of genes with minimal variance across samples for normalization – TMM method 


--



