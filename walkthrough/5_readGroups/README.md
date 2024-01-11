
5. picard add read group tags – unsure of what information is used as input for some of the arguments.. 

java -jar -Xmx10g scripts/picard-tools-1.109/AddOrReplaceReadGroups.jar \
INPUT=librtary-dedup.bam \
OUTPUT=library-dedup_rg.bam \
SORT_ORDER=coordinate \
RGID=library \
RGLB=library \
RGPL=illumina \
RGSM=sample \
RGPU=library \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT
 
To see the read group information for a BAM file, use the following command.
samtools view -H sample.bam | grep '^@RG'
