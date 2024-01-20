# Step 10: PoolSNP/Repeatmasker/snpeff

## Call SNPs 
Following the DrosEU pipeline, to call SNPs we are going to use Kapun's PoolSNP[^1]. It is a heuristic SNP caller for pooled sequencing data and requires Python3 (which usually comes with the conda environment, I think?) and GNU parallel (`conda install conda-forge::parallel`). As input, it takes an MPILEUP file and a reference genome in FASTA format. It creates the following output files:

- gzipped VCF file containing allele counts and frequencies for every position and library
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

However, you may also choose to use bcftools[^2] but I kept getting thrown this error: ` error while loading shared libraries: libgsl.so.25: cannot open shared object file: No such file or directory`. Internet consensus is that it only works well on mamba; I have tried downloading older versions, nothing seems to fix this problem. If you choose to use this tool, this pipeline looks good: <https://speciationgenomics.github.io/variant_calling/> 

## Identify sites in proximity of InDels 

Identify sites that are located close to InDels with a minimum count of 20 across all samples pooled and print them if they are within a predefined distance 5 bp up- and downstream to an InDel.

```
python scripts/DetectIndels.py \
--mpileup DrosEU.mpileup.gz \
--minimum-count 20 \
--mask 5 \
| gzip > InDel-positions_20.txt.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--mpileup` | input .mpileup or .mpileup.gz file |
| `--minimum-count` | minimum count of an indel across all samples pooled |
| `--mask` | number of basepairs masked at an InDel in either direction (up- and downstreams) |

## Repeatmasker

RepeatMasker is a program that screens DNA sequences for interspersed repeats and low complexity DNA sequences. The output of the program is a detailed annotation of the repeats that are present in the query sequence as well as a modified version of the query sequence in which all the annotated repeats have been masked (default: replaced by Ns).

First, you will need the transposon and the chromosome libraries to create a GFF file (see below). You can either do this manually by going to the flybase website[^3] and choosing the version you would like or you can use the `curl` command:

``` 
curl -O ftp://ftp.flybase.net/genomes/Drosophila_melanogaster//dmel_r6.10_FB2016_02/fasta/dmel-all-transposon-r6.10.fasta.gz
curl -O ftp://ftp.flybase.net/genomes/Drosophila_melanogaster//dmel_r6.10_FB2016_02/fasta/dmel-all-chromosome-r6.10.fasta.gz
```

Then, you will want to only keep contig name in headers - get rid of all the spaces. Kapun's script is as follows:

```
python2.7  scripts/adjust-id.py \
dmel-all-transposon-r6.10.fasta \
> dmel-all-transposon-r6.10_fixed-id.fasta
```


but I do not see it in any of his script folders, so another way to acommplish this is by using 

sed 's, ,_,g' -i FASTA_file which edits it in place, or you can save it as a new file by removing the -i 

This will be used to generate a GFF file (General Feature Format) which is a tab-delimited text file and describes the locations and the attributes of gene and transcript features on the genome (chromosome or scaffolds/contigs) - in particular we want the known locations of transposable elements. 

```
conda install bioconda::repeatmasker

scripts/RepeatMasker \
-pa 20 \
--lib dmel-all-transposon-r6.54_fixed-id.fasta \
--gff \
--qq \
--no_is \
--nolow \
dmel-all-chromosome-r6.54.fasta
```

RepeatMasker \
-pa 20 \
--lib dmel-all-transposon-r6.54_fixed-id.fasta \
--gff \
--qq \
--no_is \
dmel-all-chromosome-r6.54.fasta

| Command      | Description |
| ----------- | ----------- |
| `-pa` |  The number of processors to use in parallel (only works for batch files or sequences over 50 kb) |
| `--lib` |  Allows use of a custom library (e.g. here the transposon file) |
| `--gff` | creates an additional Gene Feature Finding format output |
| `--qq` | -qq Rush job; about 10% less sensitive, 4->10 times faster than default repeat options |
| `--no_is` | Skips bacterial insertion element check |
| `--nolow` | Does not mask low_complexity DNA or simple repeats |
| `-` | input chromosome .fasta file |


##  filter SNPs around InDels and in TE's from the original VCF produced with PoolSNP

Removes sites that are located in InDels or transposable elements from VCF input file

```
python2.7 scripts/FilterPosFromVCF.py \
--indel InDel-positions_20.txt.gz \
--te dmel-all-chromosome-r6.10.fasta.out.gff \
--vcf SNPs.vcf.gz \
| gzip > SNPs_clean.vcf.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--indel` |  input txt file with coordinates of the InDels |
| `--te` |  input gff file with coordinates of the transposable elements |
| `--vcf` | input VCF file |

--> pipes out to a compressed folder of "clean" SNPs

##  annotate SNPs with snpEff

SnpEFF[^4]
Genetic variant annotation, and functional effect prediction toolbox. It annotates and predicts the effects of genetic variants on genes and proteins (such as amino acid changes).


A typical SnpEff use case would be:

Input: The inputs are predicted variants (SNPs, insertions, deletions and MNPs). The input file is usually obtained as a result of a sequencing experiment, and it is usually in variant call format (VCF).
Output: SnpEff analyzes the input variants. It annotates the variants and calculates the effects they produce on known genes (e.g. amino acid changes). A list of effects and annotations that SnpEff can calculate can be found here.
Variants

By genetic variant we mean difference between a genome and a "reference" genome. As an example, imagine we are sequencing a "sample". Here "sample" can mean anything that you are interested in studying, from a cell culture, to a mouse or a cancer patient.

It is a standard procedure to compare your sample sequences against the corresponding "reference genome". For instance you may compare the cancer patient genome against the "reference genome".

In a typical sequencing experiment, you will find many places in the genome where your sample differs from the reference genome. These are called "genomic variants" or just "variants".

Typically, variants are categorized as follows:


ype	What is means	Example
SNP	Single-Nucleotide Polymorphism	Reference = 'A', Sample = 'C'
Ins	Insertion	Reference = 'A', Sample = 'AGT'
Del	Deletion	Reference = 'AC', Sample = 'C'
MNP	Multiple-nucleotide polymorphism	Reference = 'ATA', Sample = 'GTC'
MIXED	Multiple-nucleotide and an InDel	Reference = 'ATA', Sample = 'GTCAGT'
This is not a comprehensive list, it is just to give you an idea.

Annotations

So, you have a huge file describing all the differences between your sample and the reference genome. But you want to know more about these variants than just their genetic coordinates. E.g.: Are they in a gene? In an exon? Do they change protein coding? Do they cause premature stop codons?

SnpEff can help you answer all these questions. The process of adding this information about the variants is called "Annotation".

SnpEff provides several degrees of annotations, from simple (e.g. which gene is each variant affecting) to extremely complex annotations (e.g. will this non-coding variant affect the expression of a gene?). It should be noted that the more complex the annotations, the more it relies in computational predictions. Such computational predictions can be incorrect, so results from SnpEff (or any prediction algorithm) cannot be trusted blindly, they must be analyzed and independently validated by corresponding wet-lab experiments.



# Download latest version
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip

# Unzip file
unzip snpEff_latest_core.zip

Do I need the database? 
[https://snpeff.blob.core.windows.net/databases/v5_2/snpEff_v5_2_Drosophila_melanogaster.zip
Ensembl genome annotation version BDGP6.82 



```
DATA_DIR=kitchenflies/DNA/2_Process/10_vcf
java -Xmx4g -jar snpEff/scripts/snpEff-4.2/snpEff.jar \
-ud 2000 \
BDGP6.82 \
-stats  SNPs_clean.html \
SNPs_clean.vcf.gz \
| gzip > SNPs_clean-ann.vcf.gz
```

-ud , -upDownStreamLen <int> : Set upstream downstream interval length (in bases)

An alternative would be using Popoolation[^5].

[^1]: <https://github.com/capoony/PoolSNP>
[^2]: <https://samtools.github.io/bcftools/bcftools.html>
[^3]: <https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>
[^4]: "A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of Drosophila melanogaster strain w1118; iso-2; iso-3.", Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly (Austin). 2012 Apr-Jun;6(2):80-92. PMID: 22728672
[^5]: <https://github.com/lczech/popoolation2>
