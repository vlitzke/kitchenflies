B –DSim Contamination 
Downloaded from here:
https://ftp.flybase.net/genomes/Drosophila_simulans/dsim_r2.02_FB2020_03/fasta/

unzipped the file

Combined with melanogaster file


DATA_DIR=${SCRATCH}/kitchenflies/DNA/2_Process

# obtain D. simulans genome
wget -O $DATA_DIR/8_DSim_Cont/sim_genome.fa http://datadryad.org/bitstream/handle/10255/dryad.62629/dsim-all-chromosome-M252_draft_4-chrnamesok.fa?sequence=1
# add "sim_" to FASTA headers
sed 's/>/>sim_/g' $DATA_DIR/8_DSim_Cont/dsim-all-chromosome-r2.02.fasta.gz | gzip -c > $DATA_DIR/8_DSim_Cont/dsim-all-chromosome-r2.02_prefix.fa.gz
# combine with D. melanogaster reference
zcat $DATA_DIR/8_DSim_Cont/dsim-all-chromosome-r2.02_prefix.fa.gz | cat $DATA_DIR/2_bam_libraries/dmel-all-chromosome-r6.54.fasta.gz - | gzip -c > $DATA_DIR/8_DSim_Cont/combined.fa.gz


for the sam to bam crap F1_22: 101393 reads could not be matched to a mate and were not exported


Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F1_23_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F1_23_2
This looks like paired data from lane 841.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M1_23_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M1_23_2
This looks like paired data from lane 841.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M3_22_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M3_22_2
This looks like paired data from lane 778.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M2_23_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M2_23_2
This looks like paired data from lane 841.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F1_22_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F1_22_2
This looks like paired data from lane 778.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F2_22_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F2_22_2
This looks like paired data from lane 778.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F2_23_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/F2_23_2
This looks like paired data from lane 778.
Output will be in /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M1_22_1 and /mnt/shared/scratch/vlitzke//kitchenflies/DNA/2_Process/8B_sam2fastq/M1_22_2
26384633 sequences in the BAM file
26384633 sequences exported
WARNING: 235017 reads could not be matched to a mate and were not exported
Job finished
31149268 sequences in the BAM file
31149268 sequences exported
WARNING: 387616 reads could not be matched to a mate and were not exported
Job finished
31680066 sequences in the BAM file
31680066 sequences exported
WARNING: 363710 reads could not be matched to a mate and were not exported
Job finished
32722027 sequences in the BAM file
32722027 sequences exported
WARNING: 246009 reads could not be matched to a mate and were not exported
Job finished
38285093 sequences in the BAM file
38285093 sequences exported
