## PCA

population genetics? is it a good idea? questionable. shangzhe says take it with a grain of salt. see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7750941/ and https://doi.org/10.1101/2021.04.11.439381

The goal of a PCA is to try to cluster samples in how ever many degrees of a "principle component" that explains X% of variation among the samples while reducing noise. It's basically a visual check (and should be used as one) to measure how each variable is assoicated with another in a covariance matrix. It transforms some correlated features in data into orthogonal components. PCA uses eigen-decomposition to breakdown a matrix where we get a diagonal matrix of eigenvalues (the dimension of the matrix, coefficients applied to eigenvectors to give length/magnitude) and a matrix formed by the eigenvectors (unit vectors that assess the directions of the spread of the data). 

# LD Pruning
It seems like there is not really a solid consensus on how pruning should be done. So here are a few options:

1. SNPRelate before using this tool for a PCA 
2. Plink pruning
3. Brute force way, using the argument `--thin` and setting it to 10 kb (kept 12,944/2,280,074 sites). This will output a vcf file. 
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

plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 10 10 0.1 --out flies

would output flies.log, flies.nosex, flies.prune.in, flies.prune.out

plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --extract flies.prune.in --make-bed --pca --out flies

Then did this: plink --bfile [filename prefix] --allow-extra-chr --recode vcf --out [VCF prefix]

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

  
Unsure about the follwing: 

awk '{$1="0";print $0}' flies.bim > flies.bim.tmp
mv flies.bim.tmp flies.bim

admixture --cv flies.bed 2 > log2.out

for i in {3..5}
do
 admixture --cv flies.bed $i > log${i}.out
done
