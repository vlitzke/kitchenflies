# Step 15: Geographic Modelling 

We would like to know where our kitchen flies come from! So, I downloaded the data from this paper[^1] 

First I realized bcftools didnt recognize this as a bgzip file so `bgzip -d SNPs_clean_ann_biallelic_filtered.vcf.gz`
then `bgzip SNPs_clean_ann_biallelic_filtered.vcf` and finally `tabix SNPs_clean_ann_biallelic_filtered.vcf.gz`. Then merged them `bcftools merge dest.PoolSeq.PoolSNP/001.50.10Nov2020.ann.vcf.gz SNPs_clean_ann_biallelic_filtered.vcf.gz -o kitchAnDros.vcf.gz`

Merging doesn't work - trying to combine "ADP" "AD" and "FREQ" tag definitions of different lengths and types, so I found a way to remove these annotations (maybe this is shooting myself in the foot) because it threw me an error (Incorrect nuer of FORMAT/AD values at 2R:18615523, cannot merge. The tag is defined as Number =A but found 2 values and 4 alleles"
So I took that out `bcftools annotatE -x FORMAT/AD,INFO/FORMAT,FREQ SNPs_clean_ann_biallelic_filtered.vcf.gz -o SNPs_clean_noAnn_biallelic_filtered.vcf.gz`
and then indexed it again with `tabix SNPs_clean_noAnn_biallelic_filtered.vcf.gz`

still didn't work - i looked, and possibly it has to do something with a missing genotype? so i redid it with the no missing genotypes file

but shangzhe says thats not it, so we checked the DrosEU dataset and they have triploids! so I filtered the same way I did in 12_postfilter section for biallelic sites only then creatd an index (tabix) then merged them: `bcftools merge dest_ann_biallelic.vcf.gz SNPs_clean_ann_biallelic_filtered.vcf.gz -o kitchAndDros.vcf.gz`



Then I need to create an input text file of the sample names 

So I got the list of names: `bcftools query -l kitchAndDros.vcf.gz > sampleNames.txt` and then you need to put a tab in between that and the population (so I rewrote the first two bits, for example AT-Mau for Austria, Mautenbach) , saved it as a new text file


Going to start by using Dsuite.
https://github.com/millanek/Dsuite

Download:
$ git clone https://github.com/millanek/Dsuite.git
$ cd Dsuite
$ make

nput files:
Required files:
A VCF file, which can be compressed with gzip or bgzip. It can contain multiallelic loci and indels, but only biallelic SNPs will be used.
Population/species map SETS.txt: a text file with one individual per row and a tab separating the individual’s name from the name of the species/population it belongs to, as shown below:
Ind1    Species1
Ind2    Species1
Ind3    Species2
Ind4    Species2
Ind5    Species3
Ind6    Outgroup
Ind7    Outgroup
Ind8    xxx
...     ...
IndN    Species_n

To execute, I used the experimental Dquartets instead of Dtrio (I could have created an outgroup of our kitchenflies, I guess...)
`./Build/Dsuite Dquartets kitchAndDros.vcf.gz sampleNames.txt --out-prefix=kitchAndDros`

77 sets (populations/species), going to calcualte D and f4-ratio values for 1353275 quartets, VCFf contains 4093821 variants, block size of 204690 variants for 20 Jackknife blocks. I could / should run this in a slurm script.... 
