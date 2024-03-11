## Differential Gene Expression Anaylsis 

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
