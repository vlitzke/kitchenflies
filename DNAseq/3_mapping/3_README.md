# Alignment 

Next, we're going to map our trimmed reads using BWA and filter using SamTools with MQ > 20 using samtools – but this didn’t work, so I am doing this separately "bwa mem" is preferable to "bwa aln",  especially for longer reads. Moreover "bwa mem" produces directly the SAM files 

 
#bwa mem \
#./kitchenflies/DNA/2_Process/2_bam_libraries/dmel-all-chromosome-r6.54.fasta \
#./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read1.fq.gz \
#./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read2.fq.gz \

*takes a very long time* submitted the batch file 

But actually it does work, it just takes… a long long time, they appeared in the folder!  So I’ll try their original code :
bwa mem \
-M \
./kitchenflies/DNA/2_Process/2_bam_libraries/dmel-all-chromosome-r6.54.fasta \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read1.fq.gz \
./kitchenflies/DNA/2_Process/1_cutadapt_trimmed/F1_22_trimmed-read2.fq.gz \
| samtools view \
-Sbh -q 20 -F 0x100 - > ./kitchenflies/DNA/2_Process/2_bam_libraries/F1_22_library.bam \
