# Step 10: Calling SNPs

When sequencing samples, you will find many places in the genome where your sample differs from the reference genome ("variants"). These could be alterations such as:

| Type  | Example |
| ----------- | ----------- |
| SNP (Single-Nucleotide Polymorphism) |'A' -> 'C'|
| Ins (Insertion) | 'A' ->  'AGT'|
| Del (Deletion) | 'AC' ->  'C'|
| MNP (Multiple-nucleotide polymorphism) |'ATA'->  'GTC'|
| MIXED (Multiple-nucleotide and an InDel) | 'ATA' -> 'GTCAGT'|

First we have to call our SNPs, compare our sample sequences against the reference genome (figure out what happened) and then find out where they are! 

## Call SNPs 

Following the DrosEU pipeline, to call SNPs we are going to use Kapun's PoolSNP[^1]. It is a heuristic SNP caller for pooled sequencing data and requires Python3 (which usually comes with the conda environment, I think?) and GNU parallel (`conda install conda-forge::parallel`). As input, it takes an MPILEUP file and a reference genome in FASTA format. It creates the following output files:

- gzipped VCF file containing allele counts and frequencies for every position and library --> ℹ️ The original PDF of how to read & understand a VCF file is in this folder 
- Max-coverage file containing the maximum coverage thresholds for all chromosomal arms and libraries in the mpileup file (separated by a column)
- (Optional) Bad-sites file (by setting the parameter BS=1), which contains a list of (variable and invariable) sites that did not pass the SNP calling criteria. This file can be used to weight windows for the calculation of population genetic estimators with PoolGEN_var

The script he wrote also only works with a BASH shell, and it uses GNU parallel to use multiple threads. You need to make sure you download all three scripts from the `/scripts` folder and that they are in the same working directory when you are calling the command! 

```
bash scripts/PoolSNP/PoolSNP.sh \
mpileup=DrosEU.mpileup.gz \
reference=reference.fa.gz \
names=F1_23,F1_22,F2_22,F2_23,M1_22,M1_23,M2_23,M3_22\
max-cov=0.99 \
min-cov=10 \
min-count=10 \
min-freq=0.001 \
miss-frac=0.2 \
jobs=24 \
BS=1 \
output=SNPs
```

| Command      | Description |
| ----------- | ----------- |
| `mpileup=` | input .mpileup or .mpileup.gz file |
| `output=` | output prefix |
| `reference=` | reference FASTA file |
| `names=` | comma separated list of samples names according to the order in the mpileup file |
| `min-cov=` | sample-wise minimum coverage, across all libraries |
| `max-cov=` | Either the maximum coverage percentile to be computed or an input file, is calculated for every library and chromosomal arm as the percentile of a coverage distribution; e.g. max-cov=0.98 will only consider positions within the 98% coverage percentile for a given sample and chromosomal arm.|
| `min-count=` | minimum alternative allele count across all populations pooled; e.g. min-count=10 only considers a position as polymorphic if the cumulative count of a minor allele across all samples in the input mpileup is >= threshold |
| `min-freq=` | minimum alternative allele frequency across all populations pooled; e.g. min-freq=10 will only consider a position as polymorphic if the relative frequency of a minor allele calculated from cummulative counts across all samples in the input mpileup is >= threshold |
| `miss-frac=` | maximum allowed fraction of samples not fullfilling all parameters; e.g. if miss-frac=0.2 is set, the script will report sites even if 20% of all samples (e.g. 2 out of 10) do not fulfill the coverage criteria |
| `jobs=` | number of parallel jobs/cores used for the SNP calling |
| `BQ=` | minimum base quality for every nucleotide |

His PoolSNP.sh provides more information about the parameters. 

This outputs:
- Temporary SNPs folder, which should be empty when finished (though I should check if there are hidden files)
- SNPs-cov-0.99.txt (max coverage percentage file) 
- SNPs.vcf.gz (what you'll be working with)
- SNPs_BS.txt.gz (bad sites file)

However, you may also choose to use bcftools[^2] but I kept getting thrown this error: ` error while loading shared libraries: libgsl.so.25: cannot open shared object file: No such file or directory`. Internet consensus is that it only works well on mamba; I have tried downloading older versions, nothing seems to fix this problem. If you choose to use this tool, this pipeline looks good: <https://speciationgenomics.github.io/variant_calling/> 

Time: ~12-14 hours

## Stats on SNPs file 

You can then use vcfstats: `rtg vcfstats fileName.vcf.gz`.



https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13684
[^1]: <https://github.com/capoony/PoolSNP>
[^2]: <https://samtools.github.io/bcftools/bcftools.html>
[^3]: <https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>
[^4]: "A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of Drosophila melanogaster strain w1118; iso-2; iso-3.", Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly (Austin). 2012 Apr-Jun;6(2):80-92. PMID: 22728672
[^5]: <https://pcingola.github.io/SnpEff/snpeff/commandline/>
[^6]: <https://pcingola.github.io/SnpEff/snpeff/outputsummary/>
