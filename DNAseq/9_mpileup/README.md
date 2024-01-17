





samtools mpileup -B \
-f ./PATH/TO/2_bam_libraries/reference_genome.fa  \
-b ./PATH/TO/7_realignInDels/BAMlist.txt \
-q 20 \
-Q 20 \
| gzip > ./PATH/TO/9_mpileup/DrosEU.mpileup.gz
