## PCA

population genetics? is it a good idea? questionable. shangzhe says take it with a grain of salt. see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7750941/ and https://doi.org/10.1101/2021.04.11.439381

The goal of a PCA is to try to cluster samples in how ever many degrees of a "principle component" that explains X% of variation among the samples while reducing noise. It's basically a visual check (and should be used as one) to measure how each variable is assoicated with another in a covariance matrix. It transforms some correlated features in data into orthogonal components. PCA uses eigen-decomposition to breakdown a matrix where we get a diagonal matrix of eigenvalues (the dimension of the matrix, coefficients applied to eigenvectors to give length/magnitude) and a matrix formed by the eigenvectors (unit vectors that assess the directions of the spread of the data). 

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
      
