D) Calculation of unbiased population genetics estimators Tajima's pi, Watterson's Theta and Tajima's D
1) convert the VCF to SYNC file format (see Kofler et al. 2011)
python scripts/VCF2sync.py \
--vcf SNPs_clean-ann.vcf.gz \
| gzip > SNPs.sync.gz
2) resample SNPS to a 40x coverage
python scripts/SubsampleSync.py \
--sync SNPs.sync.gz \
--target-cov 40 \
--min-cov 10 \
| gzip > SNPs-40x.sync.gz
3) Calculate "true" window-sizes (e.g. for non-overlapping 200kb windows) based on the number of sites that passed the coverage criteria (as calculated from PoolSNP) are not located within TE's and that are not located close to InDels; See Material and Methods in Kapun et al. (2020)
python scripts/TrueWindows.py \
--badcov SNP_BS.txt.gz \
--indel InDel-positions_20.txt.gz \
--te te.gff \
--window 200000 \
--step 200000 \
--output truewindows
4) Calculate window-wise Population Genetics parameters Tajima's pi, Watterson's Theta and Tajima's D using Pool-Seq corrections following Kofler et al. (2011)
python scripts/PoolGen_var.py \
--input SNPs-40x.sync.gz \
--pool-size 80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,66,80,80,80,80,80,80,80,80,70,80,80,80 \
--min-count 2 \
--window 200000 \
--step 200000 \
--sitecount truewindows-200000-200000.txt \
--min-sites-frac 0.75 \
--output Popgen