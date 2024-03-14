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

Time: ~ 1-2 hours

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

Time: ~1 min

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
| gzip > ~/SNPs_clean_ann_6.32.vcf.gz
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

Time: ~3 min
