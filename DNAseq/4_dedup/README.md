4. Remove duplicates 

java \
-Xmx20g \
-Dsnappy.disable=true \
-jar scripts/picard-tools-1.109/MarkDuplicates.jar \
REMOVE_DUPLICATES=true \
I=library-sort.bam \
O=library-dedup.bam \
M=library-dedup.txt \
VALIDATION_STRINGENCY=SILENT
