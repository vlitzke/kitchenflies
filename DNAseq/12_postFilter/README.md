## Filter for biallelic SNP sites only 

First warning I found, was I couldn't use vcftools because there were polyploids! Then after running rtg-stats, I found that ~0.8% of my SNPs were polyploid. This could be for many reasons; I first thought that there are polyploid individuals in Drosophila (XXY females, some chromosomal abnormalities), despite being a diploid organism, but this percentage seems too high. Other reasons could be sequencing error and/or contamination. On second thought, it actually might be that the poolsnp script had a format that misclassified multiallelic sites as polyploids. When looking at the data again, it seems like we could just 

Long story short, some programs (i.e. SNPRelate) have some "biallelic only" arguments, but it feels like this might be a necessary filtering step for me now. 

So I used `vcftools --gzvcf fileName.vcf.gz --recode-INFO-all --max-alleles 2 --min-alleles 2 -- recode --out output`

or: 

Take the vcf.gz file you made - its not in the right format (needs to be indexed) so:

`bgzip -d file_name.vcf.gz`

The re-zip it: `bgzip -c file_name.vcf > file_name.vcf.gz`

Then index: `bcftools index file_name.vcf.gz`

Then filter for biallelic sites:
bcftools view --max-alleles 2 input.vcf.gz
or 
bcftools view -m2 -M2 -v snps input.vcf.gz > output.vcf.gz (I used this one) 


# LD Pruning
It seems like there is not really a solid consensus on how pruning should be done. So here are a few options:

1. SNPRelate before using this tool for a PCA 
2. Plink pruning
3. bcftools
- bcftools +prune -l 0.25 -w 1000 input.bcf -Ob -o output.bcf
though it seems that the -l has been replaced by -m in the newer version..... ughhh and then do i prune every 1000 or 10000?? 
- bcftools +prune -w 10000bp -n 1 -N 1st
- bcftools +prune -w 10000bp -n 1 -N maxAF
- bcftools +prune -w 10000bp -n 1 -N rand

with the options for --nsites-per-win-mode STR 
where -N, 
where STR can be  maxAF (keeps sites with biggest AF, default), 1st (keeps sites that come first) and rand (picks sites randomly) 

  where the default was removing sites with low AF first but could then cause problems in downstream analyses because it assumed that the thin stes are an unbiased sample of the full sites. 

  see https://github.com/samtools/bcftools/issues/1050

Should do LD-pruning first. 

Has to be bi-allelic. vcftools does not like working with biallelic SNPs and apparently there are polyploids in the data (which I'm also not sure of if this is possible but my reasoning is that polyploid individuals do exist in flies and we just happened to have one in a batch?!) 
1.  Take the clean + annotated SNPs file:

```
vcftools --gzvcf SNPs_clean_ann.vcf.gz --recode-INFO-all
	--max-alleles 2
	--min-alleles 2
	--out SNPs_clean_ann_biallelic
	--recode
```

2. You can also do this in `SNPRelate` by definining the argument `method='biallelic'`

Then to prune, you can....
1. Do it the brute force way, using the argument `--thin` and setting it to 10 kb (kept 12,944/2,280,074 sites). This will output a vcf file. 



Visualize:

1. Use allele frequency data for each pool --> R packages stats V.3.6.1
2. 

Converting plink files
```
plink --bfile Gwas.Chr20.Phased.Output \
      --recode vcf \
      --out Gwas.Chr20.Phased.Output.VCF.format
```

or 
```
#!/bin/sh
 
##-- SCRIPT PARAMETER TO MODIFY--##
 
PLINKFILE=csOmni25
 
REF_ALLELE_FILE=csOmni25.refAllele
 
NEWPLINKFILE=csOmni25Ref
 
PLINKSEQ_PROJECT=csGWAS
 
## ------END SCRIPT PARAMETER------ ##
 
#1. convert plink/binary to have the specify reference allele
 
plink --noweb --bfile $PLINKFILE --reference-allele $REF_ALLELE_FILE --make-bed --out $NEWPLINKFILE
 
#2. create plink/seq project
 
pseq $PLINKSEQ_PROJECT new-project
 
#3. load plink file into plink/seq
 
pseq $PLINKSEQ_PROJECT load-plink --file $NEWPLINKFILE --id $NEWPLINKFILE
 
#4. write out vcf file, as of today 4/6/2012  using vcftools version 0.1.8, although the documentation says that you can write out a compressed vcf format using --format BGZF option, vcftools doesn't recognize what this option is. So, I invented my own solution
pseq $PLINKSEQ_PROJECT write-vcf | gzip > $NEWPLINKFILE.vcf.gz
```
      

or
```
Use plink/seq (http://atgu.mgh.harvard.edu/plinkseq/)
Note: you need the reference allele file to have plink to specify reference allele
#!/bin/sh
# 1. have plink binary to specify reference allele
plink --noweb --bfile $plink_file --reference-allele $ref_Allele_file --make-bed --out $plink_file_modified
# 2. create plinkseq project
pseq $pseq_project new-project
#3. load plink file into plink/seq
pseq $pseq_project load-plink --file $plink_file_modified --id $plink_file_modified
#4. write out vcf file
pseq $pseq_project write-vcf | gzip > $plink_file_modified.vcf.gz
```
or 
```
plink --file your_ped_map_input --recode vcf
```
 
sometimes need a reference allele file:
```
# for dbSNP_BUILD_ID=144 (reference=GRCh38.p2):
wget ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606/VCF/All_20150603.vcf.gz
zcat All_20150603.vcf.gz | grep -v "^#" | cut -f 3,4 > reference_allele_GRCh38.txt
```


https://speciationgenomics.github.io/pca/

VCF=combinedAllYears.vcf.gz
plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out flies

would output flies.log, flies.nosex, flies.prune.in, flies.prune.out

plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --extract flies.prune.in --make-bed --pca --out flies

Then did this: plink --bfile [filename prefix] --recode vcf --out [VCF prefix]

Then tried to add the argument --update-sex txtFile  and I created a random text file with Year, sample id, sex with tabs in between in notepad... did not work

Another method?:Also did this with plink:
plink --vcf SNPs_clean_ann.vcf.gz --maf 0.05 --recode --alow-extra-chr --r2 --ld-window-kb 1 --ld-window 1000 --ld-window-r2 0 --out SNPs_ld

but I am unsure with what to do with this output (SNPs_ld)

so with flies..
plink --vcf 5_filter/SNPs_clean_ann.vcf.gz --double-id --allow-extra-chr \
--set-missing-var-ids @:# \
--indep-pairwise 10 10 0.2 --out 5_filter/plink_flies/flies

and then
plink --vcf 5_filter/SNPs_clean_ann.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
--extract 5_filter/plink_flies/flies.prune.in \
--make-bed --pca --out 5_filter/plink_flies/flies

from speciation genomics... to make it even with the rest of my LD Pruning. (10 kb windows, R2>0.2)
  
----

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
