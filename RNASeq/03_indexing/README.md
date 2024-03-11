kallisto quant \
-i ./PATH/TO/Drosophila_melanogaster.BDGP6.46.cdna.all.index \
-o ./PATH/TO/DESTINATION 
./PATH/TO/sampleName_1_trimmed.fq.gz 
./PATH/TO/sampleName_2_trimmed.fq.gz

Indexing: 
Going to need reference sequences – fasta file, in RNAseq this is a collection of transcript sequences to which we align our raw reads so we can count/estimate abundance of the raw reads.. can use Ensembl – we want the cDNA file. Now its in a folder called ensemble -
/pub/release-110/fasta/drosophila_melanogaster/cdna
Each entry > , then a defline (definition line) transcript id, cdna, exact location on chromosome, type of gene it is (protein coding), gene symbol and description and seqeunece itself 

Now we need to build it as an index
Open conda environment, use kallisto to. Build an index – only need to do this once (only rebuild it if the reference files are updated) 
kallisto index -i Drosophila_melanogaster.BDGP6.46.cdna.all.index Drosophila_melanogaster.BDGP6.46.cdna.all.fa

took the file, chopped it off into 31 kmers and noticed that some poly a tails were clipped down (there are loong poly a tails) it also replace 10000000 nucleotides that weren’t the right characters and replaced them with pseudo nucleotides , then counted kmers..
\
Open file it just created, its quite large. Like four times larger. In order to make fasta file more searchable, has to be larger… this can be quite computationally expensive

Now we have an indexed transcriptome 
