# Step 13: Linkage Disequilibrium (Optional)

Figuring out your optimal r^2 and doing any LD pruning seems to be a questionable thing to do, i.e. there are SO MANY arbitrary, subjective, vague (any other synonym you can think of) thresholds to choose from and to be honest some argue for it as a necessary step (towards doing a PCA), others say it is not at all important and so on. However, if you have a large dataset, this is problem a useful way to subset your data to independent SNPs if you have too much to work with. 

## Decay

Two methods, you can either do this using plink.....

To compare, I did it on 1) all SNPs, and then on 2) biallelic SNPs only 

⚠️ This uses a LOT of memory, so make sure you have requested enough on a node within an interactive job (if not using a slurm file). 

```
plink \
--vcf SNPs_clean_ann.vcf.gz \
--allow-extra-chr \
--recode \
--r2 \
--ld-window-r2 0 \
--ld-window 999999 \
--ld-window-kb 1000 \
--out plink_ld
```

| Command      | Description |
| ----------- | ----------- |
| `vcf` | input vcf.gz file |
| `--allow-extra-chr` | allows additional chromosomes beyond the set humans have (plink works with human data usually) |
| `--recode` | creates a new text fileset |
| `--r2` | reports squared correlations |
| `--ld-window-r2` | default set to 0.2, meaning SNPs with r2 value below 0.2 are ignored, so I set this to be 0 to report all  |
| `--ld-window` | analyse SNPs that are not more than XXX SNPs apart |
| `--ld-window-kb` | specify a kb window |
| `--out` | output prefix |

This exports the file XXX.ld with all pairwise comparisons and r2 values. 


https://www.biostars.org/p/300381/

cat snp-thin.ld | sed 1,1d | awk -F " " 'function abs(v) {return v < 0 ? -v : v}BEGIN{OFS="\t"}{print abs($5-$2),$7}' | sort -k1,1n > snp-thin.ld.summary

this step is soooo long...

so I've taken the biallelic, filtered SNPs and had a go..
First I thinned it with vcftools, --thin being 6000, keeping 19984 out of 1237687 sites 

vcftools --gzvcf SNPs_clean_ann_biallelic_filtered.vcf.gz --thin 6000 --recode --stdout | gzip -c > thinned.vcf.gz
Then I ran plink 

```
plink \
--vcf thinned.vcf.gz \
--allow-extra-chr \
--recode \
--r2 \
--make-bed \
--ld-window-r2 0 \
--ld-window 999999 \
--ld-window-kb 1000 \
--out thinned_ld

```
then 

cat thinned_ld.ld | sed 1,1d | awk -F " " 'function abs(v) {return v < 0 ? -v : v}BEGIN{OFS="\t"}{print abs($5-$2),$7}' | sort -k1,1n > thinned.ld.summary

Or you can use tomahawk (https://www.biostars.org/p/347796/)

1. Thin down your vcf.gz file to about 20,000 SNPs: `vcftools --gzvcf fileName.vcf.gz --recode --recode-INFO-all --thin 6000 --out XXX`
2. convert vcf to bcf (you need tabix indexed, see step 12): `bcftools view fileName.vcf -O b -o fileName.bcf`

3.
```
git clone --recursive https://github.com/mklarqvist/tomahawk
cd tomahawk
make
```

./install.sh local

4. tomahawk import -i snp.bcf -o snp -m 0.2 -h 0.001
5. 

## Pruning
It seems like there is not really a solid consensus on how pruning should be done. So here are a few options:

1. SNPRelate before using this tool for a PCA


2. Plink pruning

Method A[^1]:

First, do a linkage analysis 

```
plink --gzvcf fileName.vcf.gz 
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--indep-pairwise 10 10 0.2 \
--out XXX
```

| Command      | Description |
| ----------- | ----------- |
| `gzvcf` | input vcf.gz file |
| `--double-id` | for plink to duplicate sample ID (since plink usually expects both a family and individual ID) |
| `--allow-extra-chr` | allows additional chromosomes beyond the set humans have (plink works with human data usually) |
| `--set-missing-var-ids @:#` | sets a variant ID for SNPs, where the `@` ells u where the chrosome code should go and the `#` where the base-pair position belongs |
| `--indep-pairwise` | the linkage pruning part, with 10 Kb as a window size, 10 as a window step size (move 10 bp each  time you calculate linkage) and 0.2 as an r^2 threshold (of what we want to tolerate) |
| `--out` | the output prefix all your files will have |

This will write out two files we will specifically need, `XXX.prune.in`, `XXX.prune.out`, which shoe us a list of sites which fell below the linkage threshold (the ones we want to keep) and the those that are above the threshold (the ones we want to throw away). 

Next, we want to use the output to produce files that are necessary for a PCA.

```
plink --gzvcf fileName.vcf.gz \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--extract XXX.prune.in \
--make-bed
--pca
--out XXX
```

| Newer Commands      | Description |
| ----------- | ----------- |
| `--extract` | input file of positions we wanted to retain before |
| `--make-bed` | writes out additional files for another type of population structure analysis |
| `--pca` | writes out eigenvector and eigenvalue files |

Where you now end up with the eigenvector and eigenvalue files, as well as a `.bed` file is which a binary file for admixture analyes (gives us the genotypes of pruned dataset as 1s and 0s, the `.bim` file which is a map/information file of the variants and a `.fam` file which is a map file for all the individuals in the `.bed` file.

Finally, you might want to keep the plink output as a VCF file, but see the memo below: `plink --bfile [filename prefix] --allow-extra-chr --recode vcf --out [VCF prefix]`

3. Brute force way, using the argument `--thin` and setting it to 10 kb (kept 12,944/2,280,074 sites). This will output a vcf file: `vcftools --ggzvcf fileName.vcf.gz --thin 10000 --recode --out outputPrefix`
   
4. bcftools
- bcftools +prune -m 0.2 -w 10000 input.vcf.gz -Oz -o output.vcf.gz
though it seems that the -l has been replaced by -m in the newer version..... ughhh and then do i prune every 1000 or 10000?? 
- bcftools +prune -w 10000 -n 1 -N 1st
- bcftools +prune -w 10000 -n 1 -N maxAF
- bcftools +prune -w 10000 -n 1 -N rand

with the options for --nsites-per-win-mode STR 
where -N, 
where STR can be  maxAF (keeps sites with biggest AF, default), 1st (keeps sites that come first) and rand (picks sites randomly) 

  where the default was removing sites with low AF first but could then cause problems in downstream analyses because it assumed that the thin stes are an unbiased sample of the full sites. 

 see https://github.com/samtools/bcftools/issues/1050

:memo: Converting plink files does not seem to be a good idea, it kind of messes things up/lose metadata, it seems you may/may not need allele reference data input too. For example, it seemed I lost the sex data, so I tried to add the argument `--update-sex txtFile` and I created a random text file with Year, sample id, sex with tabs in between in notepad... did not work. I think the formatting is off but I'm not sure why...

[^1]:https://speciationgenomics.github.io/pca/
