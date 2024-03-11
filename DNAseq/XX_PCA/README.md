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