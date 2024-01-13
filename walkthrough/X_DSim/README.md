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



