# Step 15: Patterson's D/ABBA-BABA 

We would like to know where our kitchen flies come from! The following method/information is taken from here[^2].

A common way to do this is by using Patterson's D/ABBA-BABA statistic, along with the f4-ratio (estimate of admixture fraction *f*), to look at gene flow between populations. Both statistics are based on correlations of allele frequencies across populations.
Originally used to look at introgression between modern human and Neanerthal populations (Green et al 2010).each calculation of D and f applies to four populations or taxa, the number of calculations/quartets grows rapidly with the size of the data set. f-branch metric tries to assign gene flow to specific internal branches 
Patterson's D - identify introgressed loci by sliding window scans across the genome (Fontaine et al 2015)
Only biallelic sNPs 

Assumptions: 

1. Individuals share a substantial amount of genetic variation due to ancestry and incomplete lineage sorting
2. Recurrent and back mutations at the samesites are negligible
3. Substitution rates are uniform accross species

use of the D and f4-ratio statistics involves fitting a simple explicit phylogenetic tree model to a quartet of populations or species (Figure 1a, b) and provides a formal test for a history of admixture in that context (Patterson et al., 2012). 

## Method 
1. I downloaded the data from this paper[^1], head over *[here](https://dest.bio/)*, click on Data Files ->  SNP Tables -> scroll down to VCF files, then `Click to download a .txt file with a list of all download links`, open the link and in the terminal grab the vcf files (version 2) and their index: 

```
wget http://berglandlab.uvadcos.io/vcf/dest.PoolSeq.PoolSNP.001.50.10Nov2020.ann.vcf.gz
wget http://berglandlab.uvadcos.io/vcf/dest.PoolSeq.PoolSNP.001.50.10Nov2020.ann.vcf.gz.tbi
```

2. bcftools only recognizes bgzip files so make sure both your own data, and the DrosEU data is in this format AND you have an index.
   
```
bgzip -d SNPs_clean_ann_biallelic_filtered.vcf.gz
bgzip SNPs_clean_ann_biallelic_filtered.vcf
tabix SNPs_clean_ann_biallelic_filtered.vcf.gz
```

3. Merging. Initially, this did not work. First, I got a few warning messages "trying to combine "ADP" "AD" and "FREQ" tag definitions of different lengths and types", so I found a way to remove these annotations (maybe this is shooting myself in the foot) because it threw me an error ("Incorrect number of FORMAT/AD values at 2R:18615523, cannot merge. The tag is defined as Number =A but found 2 values and 4 alleles" by doing `bcftools annotate -x FORMAT/AD,INFO/FORMAT,FREQ SNPs_clean_ann_biallelic_filtered.vcf.gz -o SNPs_clean_noAnn_biallelic_filtered.vcf.gz`. However, Shangzhe helped me check the DrosEU dataset and apparently when they have triploids (or more), they have multiple values of allelic depth for each. Therefore, I filtered their dataset the same way I did in 12_postfilter section for biallelic sites only, then creatd an index (tabix) and merged them: `bcftools merge dest_ann_biallelic.vcf.gz SNPs_clean_ann_biallelic_filtered.vcf.gz -o kitchAndDros.vcf.gz`

4. Going to start using **[Dsuite](https://github.com/millanek/Dsuite)**[^2]. Download it using:

```
$ git clone https://github.com/millanek/Dsuite.git
$ cd Dsuite
$ make
```

Then I need to create an input text file of the sample names and populations, so I got the list of names and wrote it to a text file: `bcftools query -l kitchAndDros.vcf.gz > sampleNames.txt`. The Dsuite text file format requires one individual per row and a tab between the sample name and the population (so for example AT-Mau for Austria, Mautenbach): I rewrote it and saved it as a new text file.

Ind1    Species1
Ind2    Species1
...     ...
IndN    Species_n

To execute, I used the experimental Dquartets instead of Dtrio (I could have created an outgroup of our kitchenflies, I guess...)

```
./Build/Dsuite Dquartets \
kitchAndDros.vcf.gz \
sampleNames.txt \
--out-prefix=kitchAndDros
```

| Command      | Description |
| ----------- | ----------- |
| `-` | input vcf.gz file (compressed with gzip or bzip), only uses biallelic SNPs |
| `-` | input text file with samples/populations |
| `--out-prefix=XXX` | output prefix for all your resulting files |

77 sets (populations/species), going to calcualte D and f4-ratio values for 1353275 quartets, VCFf contains 4093821 variants, block size of 204690 variants for 20 Jackknife blocks. I could / should run this in a slurm script.... 


For DTrios though, I can specify the -p flag as a pooled population but I also don't have an Outgroup population (like what they want you to state as having the ancestral allele), in the dataset of dest.bio, there are no pooled populations from Africa, so I could download one from another paper..? They have haploid embryos, but those aren't biallelic (which is what dsuite needs) 

So I found some pooled populations of isofemale lines from Ghana: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4331666/
using the table https://f1000research.com/articles/4-31/v1#DS0 I went to https://www.ebi.ac.uk/ena/browser/view/PRJEB8027 to download the 4 fasta files.

ERR706014 - Ghpool15
ERR706015 - Ghpool32
```
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR706/ERR706014/ERR706015_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR706/ERR706014/ERR706015_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR706/ERR706015/ERR706015_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR706/ERR706015/ERR706015_2.fastq.gz
```
Isofemale strains were selected randomly from the full population samples reported in Verspoor & Haddrill (2011). Genomic DNA for isofemale lines was prepared by snap freezing females in liquid nitrogen, then extracting DNA using a standard phenol-chloroform extraction protocol with ethanol and ammonium acetate precipitation. DNA samples were generated for each isofemale lines using 50, 25, and 25 adult females for the FR, GA and GH populations, respectively.

For pooled samples, single adult females from each isofemale line were used to construct two samples for each population. The first pooled sample contains one fly from each of the same strains that were sequenced as isofemale lines (FR_pool_20, GA_pool_15, GH_pool_15). The second pooled sample contains one fly from all isofemale lines sampled for each population reported in Verspoor & Haddrill (2011) (FR_pool_39, GA_pool_30, GH_pool_32).






(This study https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1003080#s4 has isofemale lines, mixes sexes.. I guess that doesn't matter, unsure what pool sizes they are, these are individual flies: https://www.ncbi.nlm.nih.gov/biosample?linkname=bioproject_biosample&from_uid=329555)

Now dealing with them in the same way:
fastqc -> multiqc -> cutadapt -> fastqc -> 

[^1]: Kapun, M., Nunez, J. C., Bogaerts-Márquez, M., Murga-Moreno, J., Paris, M., Outten, J., ... & Bergland, A. O. (2021). Drosophila evolution over space and time (DEST): a new population genomics resource. Molecular biology and evolution, 38(12), 5782-5805.
[^2]: Malinsky, M., Matschiner, M., & Svardal, H. (2021). Dsuite‐Fast D‐statistics and related admixture evidence from VCF files. Molecular ecology resources, 21(2), 584-595.
