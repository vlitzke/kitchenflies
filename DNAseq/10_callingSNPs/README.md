# Step 10: Calling, Cleaning and Annotating SNPs

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

This outputs:
- Temporary SNPs folder, which should be empty when finished (though I should check if there are hidden files)
- SNPs-cov-0.99.txt
- SNPs.vcf.gz (what you'll be working with)
- SNPs_BS.txt.gz 

However, you may also choose to use bcftools[^2] but I kept getting thrown this error: ` error while loading shared libraries: libgsl.so.25: cannot open shared object file: No such file or directory`. Internet consensus is that it only works well on mamba; I have tried downloading older versions, nothing seems to fix this problem. If you choose to use this tool, this pipeline looks good: <https://speciationgenomics.github.io/variant_calling/> 

Time: ~12-14 hours

## Stats on SNPs file 

You can then use vcfstats: `rtg vcfstats fileName.vcf.gz`.

## Identify sites in proximity of InDels 

To use the following script, you will have to use python v2.7, so if I were you, I would create a new conda environment where you download just python version 2.7, then call that environment before you activate his script. 

This will identify sites that are located close to InDels with a minimum count of 20 across all samples pooled and print them if they are within a predefined distance 5 bp up- and downstream to an InDel. It outputs a txt file with all positions. 

```
python scripts/DetectIndels.py \
--mpileup fileName_mpileup.gz \
--minimum-count 20 \
--mask 5 \
| gzip > InDel-positions_20.txt.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--mpileup` | input .mpileup or .mpileup.gz file |
| `--minimum-count` | minimum count of an indel across all samples pooled |
| `--mask` | number of basepairs masked at an InDel in either direction (up- and downstreams) |

Time: ~ 1 hour

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

`sed 's, ,_,g' -i FASTA_file` which edits it in place, or you can save it as a new file by removing the `-i`

Finally, you can run the program:

```
conda install bioconda::repeatmasker

RepeatMasker \
-pa 20 \
--lib dmel-all-transposon-r6.54_fixed-id.fasta \
--gff \
--qq \
--no_is \
--nolow \
dmel-all-chromosome-r6.54.fasta
```

| Command      | Description |
| ----------- | ----------- |
| `-pa` |  The number of processors to use in parallel (only works for batch files or sequences over 50 kb) |
| `--lib` |  Allows use of a custom library (e.g. here the transposon file) |
| `--gff` | creates an additional Gene Feature Finding format output |
| `--qq` | -qq Rush job; about 10% less sensitive, 4->10 times faster than default repeat options |
| `--no_is` | Skips bacterial insertion element check |
| `--nolow` | Does not mask low_complexity DNA or simple repeats |
| `-` | input chromosome .fasta file |

This generates a GFF file (General Feature Format) which is a tab-delimited text file and describes the locations and the attributes of gene and transcript features on the genome (chromosome or scaffolds/contigs) - in particular we want the known locations of transposable elements. 

##  Filter SNPs 

Now that you have a text file full of InDels and a .GFF file of known transposable elements, you can removes these sites from your SNPs VCF input file.

```
python2.7 scripts/FilterPosFromVCF.py \
--indel InDel-positions_20.txt.gz \
--te dmel-all-chromosome-r6.54.fasta.out.gff \
--vcf SNPs.vcf.gz \
| gzip > SNPs_clean.vcf.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--indel` |  input txt file with coordinates of the InDels |
| `--te` |  input gff file with coordinates of the transposable elements |
| `--vcf` | input VCF file |

--> pipes out to a compressed folder of "clean" SNPs

They were also filtered using RTF - it seems the stats from the cleaned up version only using the poolsnp pipeline is not based on quality so:

rtg vcffilter -q 30 -i variants/evol1.freebayes.vcf.gz -o variants/evol1.freebayes.q30.vcf.gz

https://docs.hpc.ufs.ac.za/training/genomics_tutorial/genomics_tutorial_8/

HERE!!!!!!

rtg vcfstats input.vcf.gz > output.stats.out

##  Annotate SNPs

Since we now have a file of cleaned up SNPs, we can use SnpEFF[^4] to annotate them; we would like to know more about these variants than just their genetic coordinates, such as if they are in a gene, an exon, or even more complex annotations, like do they change protein coding? SnpEff provides several degrees of annotations, from simple (e.g. which gene is each variant affecting) to extremely complex annotations (e.g. will this non-coding variant affect the expression of a gene?), but the more complex the annotation, the more it relies on computational predictions. 

1. Download latest version: `wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip`
2. Unzip the file: `unzip snpEff_latest_core.zip`
3. Download your reference genome annotation from their database (SnpEff has quite a few, you can look at the list): https://snpeff.blob.core.windows.net/databases/v5_2/snpEff_v5_2_Drosophila_melanogaster.zip
Ensembl genome annotation version BDGP6.82 and we did 6.32. 

Input is a VCF (variant call format) file with predicted variants (SNPs, insertions, deletions and MNPs). Output consists of annotated variants and calculates the effects they produce on known genes (e.g. amino acid changes) as well as an output summary report[^6]. 

```
snpEff \
-ud 2000 \
BDGP6.32.105 \
-c kitchenflies/DNA/2_Process/10_vcf/snpEff/snpEff.config \
-stats ~/SNPs_clean_6.32.html
kitchenflies/DNA/2_Process/10_vcf/SNPs_clean.vcf.gz
| gzip > ~/SNPs_clean-ann_6.32.vcf.gz
```

| Command      | Description |
| ----------- | ----------- |
| `-ud` |  set upstream/downstream interval length (in bases) (i.e. reports any upstream or downstream effect |
| `-` |  input reference genome (I used both the newer 6.32 and the older 6.28 versions |
| `-c` | input snpEff config file (already in the folder) |
| `-stats` | output stats file |
| `-` | input cleaned up SNP vcf file |
| `-` | output annotated vcf file |

-> pipes out to a compressed annotated VCF file.

Their documentation[^5] is very helpful.

----

## Convert VCF to SYNC

Kapun says see Kofler et al. 2011, but they do an mpileup file to sync file format. Anyway, now that we've called our SNPs, cleaned, and annotated them (using two different versions of the D mel annotations), now convert them to a sync file. 

```
python scripts/VCF2sync.py \
--vcf SNPs_clean-ann.vcf.gz \
| gzip > SNPs.sync.gz
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

Take the vcf.gz file you made - its not in the right format (needs to be indexed) so:

`bgzip -d file_name.vcf.gz`

The re-zip it: `bgzip -c file_name.vcf > file_name.vcf.gz`

Then index: `bcftools index file_name.vcf.gz`

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

https://speciationgenomics.github.io/pca/

VCF=combinedAllYears.vcf.gz
plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out flies

would output flies.log, flies.nosex, flies.prune.in, flies.prune.out

plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --extract flies.prune.in --make-bed --pca --out flies

awk '{$1="0";print $0}' flies.bim > flies.bim.tmp
mv flies.bim.tmp flies.bim

admixture --cv flies.bed 2 > log2.out

for i in {3..5}
do
 admixture --cv flies.bed $i > log${i}.out
done


https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13684
[^1]: <https://github.com/capoony/PoolSNP>
[^2]: <https://samtools.github.io/bcftools/bcftools.html>
[^3]: <https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>
[^4]: "A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of Drosophila melanogaster strain w1118; iso-2; iso-3.", Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly (Austin). 2012 Apr-Jun;6(2):80-92. PMID: 22728672
[^5]: <https://pcingola.github.io/SnpEff/snpeff/commandline/>
[^6]: <https://pcingola.github.io/SnpEff/snpeff/outputsummary/>
