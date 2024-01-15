On the other side, as RNA transcribed from DNA is further processed into mRNA (i.e. introns removed), many RNA-seq reads will fail to align to a genome reference sequence. Instead, we need to either align them to transcriptome reference sequences 

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

Now we go to R

We are going to create a data frame that states the name of the sample + year 

PCA: linear combination of variables that captures the largest spread in the data, what does PC1 mean then? Sometimes we can relate it to a real thing (that’s the hope) reduce data from a multidimensional dataset to a limited number and then attach meaning to those dimensions. We can never figure out what drives the spread for each dimension but we can attach a meaning sometimes (like weight + height, can probably be interpreted as size and shape at the extremes)

--
Public RNA-seq data – Sequence Read Archive (SRA) – getting data is just by: 
fasterq-dump SRAnumber -e 4

if you want to get data AND the meta data:
grabseqs sra -t 4 -m metadata.csv SRAascensionnumber

ARCHS4 – All RNAseq and Chip-seq sample sequence search, its all stored in an H5 structure, where all of the data is stored! Largely from data and mouse.. analyzed on hiseq or nextseq
Orrr.. DEE2 – digital expression explorer 2 , which can also be accessed via an R package! 
- need to look at DEE2…. 

HD5 files are hierarchical, each elements within the HD5 file have annotations and metadata available, like its own directory. Instead of folders and files, they’re made up of groups and datasets 

Uncertainty in RNAseq counts – can do kallisto bootstraps of the readmapping step (doing many remappings with subsets of the data, with each time generating expression levels, but any variance is just random) – this helps us uncertainty in our counts 

Differential gene expression – can be different in different conditions but we can also look at differential transcript expression – we do have our data at the transcript level but a lot of people relate to gene level data in a more simplistic way than in large ensemble transcript identifiers. But there is also evidence that transcript level data is not as reliable as gene level data. Genes can be more accurately measured (if you look at estimated TPM/actual TPM) – so instead we can aggregte transcript data to the gene data. Also differential transcript usage  -> take 100% of a genes output and this isn’t changing, then you can see where the expression comes from – if a particular isoform expresses it – isoform switching.  are not mutually exclusive 
Differential Transcript usage: genes produce different isoforms ~6 on average per gene, and most of them have protein coding potential (~3 per gene) – they have a strong association with disease – I don’t think I need to do this  maybe ask Mike? (lecture 8, video 5)

Clustering – need to create modules of co-ordinately expressed genes 
Just because a gene is differently expressed doesn’t mean it has the same biological processes in this comparison – we need to separate out genes that are behaving in different waves in our set of differentially expressed genes. There is this underlying assumption that genes that behave in a similar manner are more likely to be functionally related. 

We find to find patterns of co-variation, group those genes together – we care more about pattern instead of magnitude of expression. 

There are many types of clustering methods (blind to groups – hierarchal, k-means, SOM -self organizing maps, WGCNA- weighted gene coexpression network analysis) – more like data partitioning networks – all assigned to one bin, genes can only belong to one module and supervised (random forest, neural network, dirichlet multinomial) – definitely for larger datasets. There is also bicopam – leaves out 50% of the genes, decides they don’t fit in tight clusters as coordinate gene expression. Good if you want tightly organized clusters. Its an ensemble clustering approach. Takes multiple methods and finds a consensus between those methods. Can see different modules consisting of different genes 

Need DEG file and a reps file (condition) if you want

I ran clust on the terminal: first installed it, then had to add it to path in my environment
 
(photo in word doc)

Final folder is in the rnaseq R project folder 

Functional enrichment analysis (pathway analysis) or signature analysis, referring to the attempt to go from a collection of genes that have patterns to them, to an understanding of what these genes might be doing. You may want to identify key targets/hits that are good candidates for mechanistic studies. Genes where expression hs increased (red) and blue(decreased) and just take a look at the values of those that change by the greatest order of magnitudes 

Gene Ontology (GO) – requires arbitrary selection of genes, need to set a cutoff that returns a set of genes out of the larger universe of genes. Good because it doesn’t require any data. Our data is presumably what led us to the selection of the genes (just need gene identifies). It is species specific and we don’t control the vocabulary, genes are already annotated with certain labels (functional terms). That ontology is handled by ontologists. 

Gene Set Enrichment Analysis- here you don’t need to pre-select genes, this is one of the main advantages, you can just arrive at a more unbiased position to do the analysis because you’re not selection genes. But it requires identifiers and data, the algorithm needs all the data and identifiers to do a ranking to carry out this analysis. This is often not species specific the way most people do it – assume people are working with humans – but you can coerce it to not be.. and users can control the vocabulary. The way GSEA analysis is carried out are you have signatures that were curated in a database, but you could make your own signature, and group together genes however you want (could be they share a function in your particular system, or located near each other on a chronomosome etc). 

Many options fo GO: WEBESTALT, GOSTATS, G-Profiler, GENETRAIL, DAVID, GORILLA, TOPPGENE, CLUSTER-PROFILER, PANTHER, ENRICHR 
 David and Panther are both web tools, David is heavily cited. But in the script we will use G-profiler and cluster profiler 

GO has three different ontologies:
1. Cellular components – where is the gene product localized 
2. Biological processes – what functions does that  gene product carry out
3. Molecular function – how does it carry out that function, via which mechanisms 

GO is mostly focused on BP 

MSigDB – signatures that have been curated already! These signatures have been grouped into collections which have themes to them 
Eg. C1 are genes based on where they are on the chromosome 

GSEA is like counting cards- You choose two phenotypes and GSEA will rank your genes /transcripts in order of magnitude change between the two phenotype classes. Like high genes, and the middle of the list are genes that don’t change between the two classes and so on. Once the genes are rank ordered, that is used for the GSEA analysis. Then we take any genes in the signature and march down the rank of genes and look to see where they fall in our rank list of genes. If the genes are at the top, they probably involved in one sex over the other. 

It then turns one of the process on its side to assemble a running sum statistics – so it commonly has  its ranked list of gene on the side and then anytime one of the genes from the signature (you only evaluate one signature) a vertical line is drawn, this could suggest a strong enrichment in one of the groups 
GSEA comes in two flavors:
1.  self-contained – are any of the genes in my set differentially expressed. This does not consider genes outside my set. 
2. competitive: are genes in my set more commonly differentially expressed than genes outside the set. This does consider genes outside the set. If there are tons of differentially expressed genes it can be hard to find a signature. This is the most popular version though .

Permutations are done to determined if a GSEA score is significant. You can permute your samples (pretend you mislabelld the samples), if there is really a signature that is enriched, we will lose the signals but this isn’t effective for small groups (need more than 7 a group)
Common alternative is to permute genes- scramble the genes and rerun enrichment analysis. Still rank by samples, but once you have the rankings, you scramble the rows but this is subject to inter-gene correlations which can have a substantial effect of inflating type 1 error (of having a gene signature enriched when its actually not) 

featurecount, edgeR, 

abunace .tsv – tarncript level information , length ,effect length, ttpm, we cannot attach meaning to long transcript identifiers, need to know which gene it originates from
so annotation packages help us take all those transcripts and map them to gene symbols, so that’s why we need some extra information (the transcript identifier and gene name) 

Need to: FST between the sexes and the genetic diversity in each population were estimated using the R package PopGenome 
(MCMCglmm package) to data on relative male and female fitness: Y  =  S + L + ε, where S (sex) is a fixed effect, L (line) is a 2×2 matrix that specifies the variance structure of the random effects, allowing for estimates of sex-specific variances among lines and their covariance, and ε is a matrix of sex-specific, within-line residual variances. Flat priors for the correlation were used.

