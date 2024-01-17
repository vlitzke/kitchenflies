samtools mpileup -B \
-f reference.fa \
-b BAMlist.txt \
-q 20 \
-Q 20 \
| gzip > DrosEU.mpileup.gz
