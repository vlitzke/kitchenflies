# Calculation of unbiased population genetics estimators Tajima's pi, Watterson's Theta and Tajima's D

## Convert VCF to SYNC

Kapun says see Kofler et al. 2011, but they do an mpileup file to sync file format. 

```
python scripts/VCF2sync.py \
--vcf SNPs_clean-ann.vcf.gz \
| gzip > SNPs.sync.gz
```

## Resample SNPS 

Resamples the allele counts in a sync file to a target coverage (40x, we have 40 individuals in each pool) if the counts are above a minimum-coverage threshold (--min-cov). Note, sites with less coverage than the target will be sampled with replacement, whereas sites with larger coverage will be sampled with replacement.

:memo: The X chromosome will be sampled by half since this script is intended for pools of only male individuals. 

```
python scripts/SubsampleSync.py \
--sync SNPs.sync.gz \
--target-cov 40 \
--min-cov 10 \
| gzip > SNPs-40x.sync.gz
```

| Command      | Description |
| ----------- | ----------- |
| `--sync` | input .sync file |
| `--target-cov ` | target coverage |
| `--min-cov` | minimum-coverage threshold |

--> pipes out to a compressed sync file. 

## Calculate "true" window-sizes 

(e.g. for non-overlapping 200kb windows) based on the number of sites that passed the coverage criteria (as calculated from PoolSNP) are not located within TE's and that are not located close to InDels; See Material and Methods in Kapun et al. (2020)
```
python scripts/TrueWindows.py \
--badcov SNP_BS.txt.gz \
--indel InDel-positions_20.txt.gz \
--te te.gff \
--window 200000 \
--step 200000 \
--output truewindows
```

## Calculate window-wise Population Genetics parameters 

Tajima's pi, Watterson's Theta and Tajima's D using Pool-Seq corrections following Kofler et al. (2011)
```
python scripts/PoolGen_var.py \
--input SNPs-40x.sync.gz \
--pool-size 80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,66,80,80,80,80,80,80,80,80,70,80,80,80 \
--min-count 2 \
--window 200000 \
--step 200000 \
--sitecount truewindows-200000-200000.txt \
--min-sites-frac 0.75 \
--output Popgen
```
