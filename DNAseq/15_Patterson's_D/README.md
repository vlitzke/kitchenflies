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

Then I need to create an input text file of the sample names and populations, so I got the list of names and wrote it to a text file: `bcftools query -l kitchAndDros.vcf.gz > sampleNames.txt`. The Dsuite text file format requires one individual per row and a tab between the sample name and the population (so for example AT-Mau for Austria, Mautenbach): I rewrote it and saved it as a new text file. (You can do this by copying and pasting the sample name in Excel, then adding a new column with the population name specificed [and Outgroup for dtrio], then Save As -> Text file (Tab delimited)) 

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
fastqc -> multiqc -> cutadapt -> fastqc -> bwa-mem -> picard -> gatk3 

Afterwards I've called ALL the SNPs together again (so our data and these 2 Ghana Populations) using PoolSNP. 

As for the DrosEU data from 2023, I don't have the raw data, just the SNPs that have already been called 
Then I'm also going to pull just the African samples but these are haploid embryos in pools of 5 individuals, Alan said it would work! so I downloaded the metadata from Alan Berglands github, then used R to pull out only the African samples:

Got a list of samples: `bcftools query -l dest.PoolSeq.PoolSNP.001.50.10Nov2020.ann.vcf.gz > sampleList.txt`

```
library(readr)
destv2_samples <- read_csv("data/2024_04/dest_v2.samps_13Jan2023.csv")

destv2_africa <- subset(destv2_samples, destv2_samples$continent == "Africa")

wantedSamples <- destv2_africa$sampleId
```

Save it as a generic text file, then:
`bcftools view -S sampleList_v2_Africa.txt -o outputfile.vcf.gz inputfile.vcf.gz`

But it seems like MA_Tan_Lar_1_2021_06_07 does not exist in the header (got a warning, I am not ready to go down this rabbit hole so I'm going to ignore this) 

I wanted to filter them in the same way as step 12 (postfilter) but i dont think this works well for haploid... so I will leave it as is. 

Then merge those once again with the destv2 vcf file. `bcftools merge destv2_all_biallelic.vcf.gz.record.vcf.gz destv2_african_subset.vcf.gz -o destv2_allBiallelicAndAfr.vcf.gz --force-samples` (the last arguments was added because there were duplicate sample names (CM-Nor-Oku) so, I shall see what that looks like afterwards. 

Ok so it looks like all of the African samples are duplicates, so I'll keep them in for now because I don't see an easy way to compare them within the same merged vcf file. And continue on.... then remvove these samples at the end of necessary (2:XXXX) 

Then I want to merge this with the kitchen+otherAfrican sample vcf file I have.

Then I create a SETS file


Okay so I combined them and they look kind of weird (the d statistics are very low, but the f4 ratios are really high) so I'm going to just merge the destv2 data + ghana + kitchen flies without the added African samples 

## Processed
1. You can first look at the _BBAA.txt file. ABBA is always more than BABA and the D statistic is always positive because Dsuite orients P1 and P2 in this way. Since these results are for coalescent simulations without gene-flow, the ABBA and BABA sites arise purely through incomplete lineage sorting and the difference between them is purely random - therefore, even though the D statistic can be quite high (e.g. up to 8% on the last line), this is not a result of gene flow.

   Question 1: Can you tell why the BBAA, ABBA, and BABA numbers are not integer numbers but have decimal positions?

Integer counts of ABBA and BABA sites would only be expected if each species would be represented only by a single haploid sequence. With diploid sequences and multiple samples per species, allele frequences are taken into account to weigh the counts of ABBA and BABA sites as described by equations 1a to 1c of the Dsuite paper.

Also the _DMin.txt file: here trios are arranged so that the D statistic is minimised - providing a kind of "lower bound" on gene-flow statistics. This can be useful in cases where the true relationships between species are not clear, as illustrated for example in this paper (Fig. 2a).
Next, let's look at the results in more detail, for example in R. We load the _BBAA.txt file and first look at the distribution of D values:

D_BBAA_noGF <- read.table("species_sets_no_geneflow_BBAA.txt",as.is=T,header=T)
plot(D_BBAA_noGF$Dstatistic, ylab="D",xlab="trio number")

n fact, the D statistics for 9 trios are >0.7, which is extremely high. So how is this possible in a dataset simulated with no geneflow?

ruby plot_f4ratio.rb kitchAndDrosNames_DTrio_BBAA.txt plot_order.txt 0.2 kitchAndDrosNames_DTrio_BBAA_f4ratio.svg

1) I ran it with kitch + dros eu + dros eu african added again + Ghana (so with the African duplicates) and it took ~17 hours, and results looked pretty weird...so I'm going to try and rerun dtrio again without the african duplicates
2) Also running it on a subset of four populations (texas, ghana, two kitchen flies from 2019)
3) oops, it wants another population, so again with fivepop
   bcftools view -s ES_Ciu_Tom_1_2020-09-30,US_Tex_Lub_2_2013-09-15,ERR706014,F1_19,F2_19 all_merged_noAfduplicates.vcf.gz > fivepopsubset.vcf.gz
   Then you gotta update the SETS file with the new sample IDs and populations
   4) Also not great because it doesn't run based off of sample, just instead off of population:
  
So I used 
ES_Ciu_Tom_1_2017-10-04
ES_Gra_Cor_1_2017-07-28
ES_Ler_Gim_1_2017-07-24
US_Cal_And_17_2013-10-15
US_Cal_Esp_1_2013-05-07
US_Cal_Tuo_1_2013-05-14
ERR706014
F1_19
F2_19
M1_10

Then you need to set the -p flag ( in this case --pool-seq=17) 

I had an issue with this flag, it says that the AD tag is malformed (so Leeban suggested I check the format of it) and also as a sanity check make sure that the DP tag has a min depth of whatever we're listing here as the argument. the format for AD says Number=. instead of Number=1 or R, so I tried changing the header, that din't do anyhing.... 

`bcftools query -f '%CHROM %POS [ %DP]\n' inputFile.vcf > outputFile` --> depth seems fine, so this is ACROSS ALL INDIVIDUALS, there has to be at least 10 reads. so I filtered the nine population subset again with the postfilter (section 12) but when I do that i end up with literally 100,000 variants and its not enough to use jackknife methods, so it doesn't run. So let me try just filtering for min depth, that's fine, but still a problem with a malformed AD tag, so I removed it (bcftools annotate) bute the -p argument needs that tag , sooo then I downloaded the tsv file of AD tags  and I checked to make sure there were no other numbers in there
and then ran this in R: 
```
sum(is.na(AD[,])) # no NAs

char_count <- 0

for (i in 1:nrow(AD)) {
  for (j in 3:ncol(AD)) {
    if (nchar(AD[i,j]) > 2) {
      char_count <- char_count + 1
    }
  }
}

# No more than two characters per cell 
```

In some of them instead of a 0, there is a dot (this was the Ghana population, so I think this means that there was no SNP at that position called, but instead of filling it in as a 0, it filled it in as a . 

So actually Leeban says that if I make them a 0, that will absoutely bias the results of dsuite- that because something was technically different in the way they got their samples/how they mapped/how everything was called together, he says to just remove them, even if thats like 73,000/120,000 .... that people have used dsuite with many less SNPs... so I will take out a list of these positions where the . occurs in the ghana population and subset them out of the original VCF file and try again.

`awk -F'\t' '$10 !~ /\./' ninepopsubset.vcf.gz  > ninepopsubset_ADfiltered.vcf.gz` hoping that its actually the 10th field 


`awk -F'\t' '{print $10}' input.vcf > allelic_depth.txt`

or I think I can do the one above:

`bcftools query -f '%CHROM %POS [ %AD]\n' inputFile.vcf > allelic_depth2.tsv`


`bcftools query -f '%CHROM %POS [ %AD]\n' ninepopsubset_ADfiltered.vcf.gz | head -3`

 Does not seem like it filtered so ill try again 
awk -F '\t' '$0 ~ /^#/ || $10=="."' ninepopsubset_ADfiltered.vcf.gz >ninepopsubset_ADfiltered2.vcf.gz

This just printed out the header so I deleted the file.

Quentin says its always a bad idea to touch the headers. 


I am now pullng out all the individual vcf data
`bcftools query -f '%CHROM %POS [\t%RD]\n' inputfile.vcf.gz > output.tsv`

can't actually pull out the QUAL data - apparently it loses the QUAL tag when calling the SNPs and creating the original vcf file (from martins stuff). - and I checked their original VCF destv2 file, and there are no QUAL values either! SO now I'm tempted to recall the SNPs but using freebayes instead. 

[^1]: Kapun, M., Nunez, J. C., Bogaerts-Márquez, M., Murga-Moreno, J., Paris, M., Outten, J., ... & Bergland, A. O. (2021). Drosophila evolution over space and time (DEST): a new population genomics resource. Molecular biology and evolution, 38(12), 5782-5805.
[^2]: Malinsky, M., Matschiner, M., & Svardal, H. (2021). Dsuite‐Fast D‐statistics and related admixture evidence from VCF files. Molecular ecology resources, 21(2), 584-595.
