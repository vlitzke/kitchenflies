# Step 12: Post-filtering 
There are quite a few things left that we are going to have to do before we process some of the other data. 

## Biallelic SNP sites 
First warning I found, was I couldn't use vcftools because there were polyploids! Then after running rtg-stats, I found that ~0.8% of my SNPs were polyploid. This could be for many reasons; I first thought that there are polyploid individuals in Drosophila (XXY females, some chromosomal abnormalities), despite being a diploid organism, but this percentage seems too high. Other reasons could be sequencing error and/or contamination. On second thought, it actually might be that the poolsnp script had a format that misclassified multiallelic sites as polyploids. When looking at the data again, it seems like we could just 

Long story short, some programs (i.e. SNPRelate) have some "biallelic only" arguments, but it feels like this might be a necessary filtering step for me now. 

Take the clean + annotated SNPs file:

```
vcftools
--gzvcf fileName.vcf.gz
--recode-INFO-all
--max-alleles 2
--min-alleles 2
--out outputName
--recode
```

or: 

Take the vcf.gz file you made - its not in the right format (needs to be indexed) so:

`bgzip -d file_name.vcf.gz`

The re-zip it: `bgzip -c file_name.vcf > file_name.vcf.gz`

Then index: `bcftools index file_name.vcf.gz`

Then filter for biallelic sites:
bcftools view --max-alleles 2 input.vcf.gz
or 
bcftools view -m2 -M2 -v snps input.vcf.gz > output.vcf.gz (I used this one) 

or 

vcftools does not like working with biallelic SNPs and apparently there are polyploids in the data (which I'm also not sure of if this is possible but my reasoning is that polyploid individuals do exist in flies and we just happened to have one in a batch?!) `SNPRelate` by definining the argument `method='biallelic'`

Next, some statistics on the cleaned, annonated, biallelic vcf file of SNPS so we can get some relatively good sensible filtering thresholds. 

## Data Exploration

### Depth
This is the number of reads that have mapped to a position (per site, for all individuals and all alleles). We should be including a minimum depth milter because these will remove false positive calls and ensure higher quality calls and a maximum depth filter because regions with very high read depths could possible by repetitive regions mapping to multiple parts of the genome (likely reflects mapping/assembly errors).

Calculate mean depth coverage per individual: `vcftools --gzvcf $SUBSET_VCF --depth --out $OUT`
Calculate mean depth coverage per site: `vcftools --gzvcf $SUBSET_VCF --site-mean-depth --out $OUT`

Per site, it looks like we have a mean_depth of any where between 11 and 3447! But generally the meadian is around 34 and it looks like it cuts off at 50. So we will set a min to 10 (though conservative is ~15x) and a max to 50. For each individual, it doesn't seem there are any outliers to be concerned about. 

### Missing data
how much are you willing to lose? This looks athe proportion of missingness at each variant (no genotype at a given site) and individual. Typically any site with more than 25% missing data should be dropped. 
Proportion of missing data per individual: `vcftools --gzvcf $SUBSET_VCF --missing-indv --out $OUT`
Proportion of missing data per site: `vcftools --gzvcf $SUBSET_VCF --missing-site --out $OUT`

It seems like most have a call at every site, though if you look at the summary, there are some! So we can be conservative and remove sites where over 10% of individuals are missing a genotype. 10% threshold means the minimum 90% call rate is tolerated. 

For each individual however, it seems there are two individuals that have a lot of missing data. But for now we're going to keep them (both males) 

### Minor Allele Frequency
Distrubtion of allele frequencies. This can inflate statistics estimates downstream + cause other problems... ideally people generally use 0.05-0.10 as a reasonable cut-off (thhough demographic inference might be biased by MAF thresholds) 
Calculate allele frequency for each variant (--freq would return their identity): `vcftools --gzvcf $SUBSET_VCF --freq2 --out $OUT`

It looks like most alleles have a high frequency (possibly because our pools are so big?), but double checking the summary, max is 0.5, which makes sense. So low MAF alleles may only occur in a handful of individuals, and these may be unreliable base calls (or a source of error). An excess of low requency alleles can also cause errors (SNPs on into one ind) which means they maybe very uninformantive and make it difficult to model population structure. So it is best practice to keep one dataset with a good MAF threshold and one without. So we will set 0.1. 

### Calculate heterozygosity and inbreeding coefficient per individual
Computing heterozygosity and the inbreeding coefficient (F) for each individual can quickly highlight outlier individuals that are e.g. inbred (strongly negative F), suffer from high sequencing error problems or contamination with DNA from another individual leading to inflated heterozygosity (high F), or PCR duplicates or low read depth leading to allelic dropout and thus underestimated heterozygosity (stongly negative F). However, note that here we assume Hardy-Weinberg equilibrium. If the individuals are not sampled from the same population, the expected heterozygosity will be overestimated due to the Wahlund-effect. It may still be worth to compute heterozygosities even if the samples are from more than one population to check if any of the individuals stands out which could indicate problems.

vcftools --gzvcf $SUBSET_VCF --het --out $OUT

Well yikes, it looks like a lot of them are exremely inbred. However, this might check out? Because they're pooled samples and not individuals? Who knows. 

Then we are going over to R to check the plots....

## Filtering

Now we have an idea of how to set out thresholds, we will do just that.

```
vcftools --gzvcf SNPs_clean_annotated_biallelic.vcf.gz \
--maf 0.1 \
--max-missing 0.9 \
--min-meanDP 10 \
--max-meanDP 50 \
--minDP 10 \
--maxDP 50 \
--recode --stdout | gzip -c > SNPs_clean_annotated_biallelic_filtered.vcf.gz
```

What have we done here?

| Command      | Description |
| ----------- | ----------- |
| `--gvcf ` | input vcf.gz file |
| `--maf` | m set minor allele frequency |
| `--max-missing` | set minimum non-missing data. A little counterintuitive - 0 is totally missing, 1 is none missing. Here 0.9 means we will tolerate 10% missing data |
| `--min-meanDP ` | minimum mean depth for a site |
| `--max-meanDP` | maximum mean depth for a site |
| `--maf` | m set minor allele frequency |
| `--maf` | m set minor allele frequency |

- the .
 - the e.
--minDP - the minimum depth allowed for a genotype - any individual failing this threshold is marked as having a missing genotype.
--maxDP - the maximum depth allowed for a genotype - any individual failing this threshold is marked as having a missing genotype.
--recode - recode the output - necessary to output a vcf
--stdout - pipe the vcf out to the stdout (easier for file handling)
Now, how many variants remain? There are two ways to examine this - look at the vcftools log or the same way we tried before.

cat out.log

Additionally, you can filter for quality (extract quality score for each site) `vcftools --gzvcf $SUBSET_VCF --site-quality --out $OUT` --> this gives me all -1, maybe a problem to sort out later, but I've already filtered for this very early on. 
You generally filter for a minimum threshold of 30. 

and finally for all individuals with no missing data at any site:
`vcftools --gzvcf SNPsFIle.vcf.gz --max-missing-count 0 --recode --stdout | gzip -c > SNPs_filtered_nomissing.vcf.gz`

----
# Other Useful Commands/Tools

## Convert VCF to SYNC

Kapun says see Kofler et al. 2011, but they do an mpileup file to sync file format. Anyway, now that we've called our SNPs, cleaned, and annotated them (using two different versions of the D mel annotations), now convert them to a sync file. 

```
python scripts/VCF2sync.py \
--vcf SNPs_clean_ann.vcf.gz \
| gzip > SNPs_clean_ann.sync.gz
```

THE SYNC-FILE
1 2R 26 T 0:14:0:0:0:0 0:14:0:0:0:0
2 2R 27 G 0:0:0:14:0:0 0:0:0:14:0:0
3 2R 28 A 14:0:0:0:0:0 14:0:0:0:0:0
4 2R 29 G 0:0:0:14:0:0 0:0:0:14:0:0
I col 1: reference chromosome
I col 2: position
I col 3: reference character
I col 4: allele counts for first population
I col 5: allele counts for second population
I col n: allele counts for n-3 population
⇒ Allele counts are in the form ”A:T:C:G:N:del”
⇒ the sync-file provides a convenient summary of the allele counts of several populations (there
is no upper threshold of the population number).

# Splitting up the VCF files into individual samples (to look for a batch effect with Fst) and/or merging them! 

then you want to make sure you have your list of sample names:

```
for file in SNPs_clean-ann_6.32_bgzf.vcf.gz; do
  for sample in `bcftools query -l $file`; do
    bcftools view -c1 -Oz -s $sample -o ${file/.vcf*/.$sample.vcf.gz} $file
  done
done
```

And it will separate out each sample into its own vcf.gz file! 

To merge all vcf files they have to be in this format, then `bcftools merge file1.vcf.gz file1.vcf.gz -o combined.vcf.gz`

I merged them, then used `plink`
