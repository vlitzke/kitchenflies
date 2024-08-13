



to take out all snp positions that have missing genotypes from any of the samples 
```sh
bcftools view -g ^miss inputfile.vcf.gz > outputfile.vcf.gz
```

VCFtools has similar functionality for this purpose but it only supports bi-allelic SNPs

```sh
vcftools --vcf <input>.vcf --recode --recode-INFO-all --max-missing-count --out <output>.vcf
```

to see how many are left: 
```sh
grep -v "^#" intput_file.vcf.gz | wc -l
```
> note that in above example the VCF file in uncompressed though it has .gz suffix.

For compressed VCF files, the command line is:

```sh
zcat intput_file.vcf.gz | grep -v "^#" | wc -l
```

which in my case goes from 2166168 to 142647 SNPs. 

















# Calculation of unbiased population genetics estimators 
Moving over from Kapun's pipeline, now I am going to start using Popoolation2[^1].


## Subsampling
This script reduces the coverage in a synchronized file for every population to the targeted coverage by random sampling of bases.

As genomic reads are randomly distributed in the genome the coverage of mapped reads shows marked fluctuations along chromosomes. There are also well known biases like the GC bias, in this case regions having a high GC content also have elevated coverages. Statistical test's, like the Fisher's exact test or the CMH-test, more readily identify allele frequency differences between populations in regions having high coverages. This may result in artefactual results as for example a higher density of significant allele frequency differences in regions having a high GC content. This script allows to subsample bases to a uniform coverage, which should thus eliminate artefactual results that are caused by coverage fluctuations.

However, several methods for subsampling have been implemented (with replacement, without replacement, exact fraction).

Several population genetic estimators are sensitive to sequencing errors. For example a very low
Tajima’s D, usually indicative of a selective sweep, may be, as an artifact, frequently be found in
highly covered regions because these regions have just more sequencing errors. To avoid these
kinds of biases we recommend to subsample to an uniform coverage.
1 perl ˜/programs/popoolation/basic-pipeline/subsample-pileup.pl --
min-qual 20 --method withoutreplace --max-coverage 50 --
fastq-type sanger --target-coverage 10 --input pe.idf.
mpileup --output pe.ss10.idf.mpileup
I –min-qual minimum base quality
I –method method for subsampling, we recommend without replacement
I –target-coverage which coverage should the resulting mpileup file have
I –max-coverage the maximum allowed coverage, regions having higher coverages will be
ignored (they may be copy number variations and lead to wrong SNPs)
I –fastq-type (sanger means offset 33)



FST


CALCULATING TAJIMA’S π
1 perl ˜/programs/popoolation/Variance-sliding.pl --fastq-type
sanger --measure pi --input pe.ss10.idf.mpileup --min-count
2 --min-coverage 4 --max-coverage 10 --min-covered-fraction
0.5 --pool-size 500 --window-size 1000 --step-size 1000 --
region 2R:7800000-8300000 --output cyp6gi.pi --snp-output
cyp6gi.snps
I –min-coverage –max-coverage: for subsampled files not important; should contain target
coverage, i.e.: 10
I –min-covered-fraction minimum percentage of sites having sufficient coverage in the
given window
I –min-count minimum occurrence of allele for calling a SNP
I –measure which population genetics measure should be computed (pi/theta/D)
I –pool-size number of chromosomes (thus number of diploids times two)
I –region compute the measure only for a small region; default is the whole genome
I –output a file containing the measure (π) for the windows
I –snp-output a file containing for every window the SNPs that have been used for
computing the measure (e.g. π)
I –window-size –step-size control behavior of sliding window; if step size is smaller than
window size than the windows will be overlapping.














----
Extra

## Resample SNPS 

Resamples the allele counts in a sync file to a target coverage (40x, we have 40 individuals in each pool) if the counts are above a minimum-coverage threshold (--min-cov). Note, sites with less coverage than the target will be sampled with replacement, whereas sites with larger coverage will be sampled with replacement.

:memo: The X chromosome will be sampled by half since this script is intended for pools of only male individuals. 

```
python scripts/SubsampleSync.py \
--sync SNPs.sync.gz \
--target-cov 40 \
--min-cov 10 \
| gzip > SNPs-40x.sync.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--sync` | input .sync file |
| `--target-cov ` | target coverage |
| `--min-cov` | minimum-coverage threshold |

--> pipes out to a compressed sync file. 

## Calculate "true" window-sizes 

(e.g. for non-overlapping 200kb windows) based on the number of sites that passed the coverage criteria (as calculated from PoolSNP) are not located within TE's and that are not located close to InDels; See Material and Methods in Kapun et al. (2020)

This script generates an output (--out) which contains the number of sites that passed the quality criteria during SNP calling (--badcov), are not located within TE's (--te) and that are not located close to InDels (--indel) in sliding windows with a given window and step-size. 

This file can be used as on input for the calculation of population genetics parameters with PopGen-var.py.
You will need to pass the length of the chromosomes that should be considered in the output (--chromosomes )
Note: this script is quite memory hungry. Thus, I would run the script for the different chromsomal arms separately unless you have >64 GB of RAM memory


```
python scripts/TrueWindows.py \
--badcov SNP_BS.txt.gz \
--indel InDel-positions_20.txt.gz \
--te te.gff \
--window 200000 \
--step 200000 \
--output truewindows
```

| Command      | Description |
| ----------- | ----------- |
| `--badcov` | input bad coverage file with the extension BS from SNP calling |
| `--indel ` | input indel positions file |
| `--te` | te database in gff fileformat from flybase or from Repeatmasker |
| `--window` | window-size |
| `--step` | step-size |
| `--output` | output file |

parser.add_option("--chromosomes", dest="chrom", help="the name and length of chromosomes to be considered, Name and length Need to be saparated by a colon and different chromosomes need to be separated by a comma, e.g. 2L:23513712,2R:25286936")



## Calculate window-wise Population Genetics parameters 

Tajima's pi, Watterson's Theta and Tajima's D using Pool-Seq corrections following Kofler et al. (2011)
```
python scripts/PoolGen_var.py \
--input SNPs-40x.sync.gz \
--pool-size 80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,66,80,80,80,80,80,80,80,80,70,80,80,80 \
--min-count 2 \
--window 200000 \
--step 200000 \
--sitecount truewindows-200000-200000.txt \
--min-sites-frac 0.75 \
--output Popgen
```



# Getting FST by gene

First I think I need to separate them out to just autotomes + X Chromosome? or not who cares. 
Then to separate out by Batch / Year (B1_19) because I want to run FST on sexes 

Then convert to a bed file
vcf2ned 
.....

First you need to download bedops to convert vcf files to bed files (you need them)
then you need a population file 

then you need to install pixy 


With Pixy 
download it 

vcf2bed --max-mem 2G  < <(gunzip -c SNPs_clean_ann_biallelic_filtered_nomissing_19B1.vcf.gz)  > SNPs_clean_ann_biallelic_filtered_nomissing_19B1.bed

pixy --stats fst --vcf SNPs_clean_ann_biallelic_filtered_nomissing_19B1.vcf.gz --populations 19B1.txt --bed_file SNPs_clean_ann_biallelic_filtered_nomissing_19B1.bed --bypass_invariant_check yes --output_prefix 19B1

for real names: less dmel-all-r6.58.gff | sed '/^#/d' | awk '$3=="gene"' | awk '{print $1, $4, $5, $9}' | cut -d'=' -f3 | cut -d';' -f1 > flybase_realgenenames.id

paste dmel-gene-r6.58.tmp flybaseIDs.tmp > dmel-gene-coords-flybaseIDs.bed



sed gets rid of header
Add tab: -v FS='\t' -v OFS='\t


less dmel-all-r6.58.gff | sed '/^#/d' | awk '$3=="gene"' | awk -v FS='\t' -v OFS='\t' '{print $1, $4, $5}' > dmel-gene-r6.58.tmp


[^1]: https://sourceforge.net/p/popoolation2/
