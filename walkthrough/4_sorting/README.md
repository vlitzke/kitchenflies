3. 3) sort BAM by reference position using picard

java \
-Xmx20g \
-Dsnappy.disable=true \
-jar scripts/picard-tools-1.109/SortSam.jar \
I=library.bam \
O=library-sort.bam \
SO=coordinate \
VALIDATION_STRINGENCY=SILENT

The following worked instead: 
picard SortSam -I ./kitchenflies/DNA/2_Process/2_bam_libraries/F1_23_library.bam -O=./kitchenflies/DNA/2_Process/3_sortbam_libraries/F1_23_library-sort.bam SO=coordinate 

