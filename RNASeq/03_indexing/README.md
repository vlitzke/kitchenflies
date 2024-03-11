# Indexing

We will next need reference sequences, which is a fasta file type. In RNAseq, this is a collection of transcript sequences to which we align our raw reads so we can count/estimate abundance of the raw reads.

First we will go find the cDNA file off of Ensembl: /pub/release-110/fasta/drosophila_melanogaster/cdna

You would read this as for each entry > , then a defline (definition line) transcript id, cdna, exact location on chromosome, type of gene it is (protein coding), gene symbol and description and seqeunece itself 

Then we will use the program `kallisto` to build an index. This only needs to be done once for your analysis, unless the reference files have been updated.  

```
kallisto index \
-i Drosophila_melanogaster.BDGP6.46.cdna.all.index \
Drosophila_melanogaster.BDGP6.46.cdna.all.fa
```

took the file, chopped it off into 31 kmers and noticed that some poly a tails were clipped down (there are loong poly a tails) it also replace 10000000 nucleotides that weren’t the right characters and replaced them with pseudo nucleotides , then counted kmers..

Open file it just created, its quite large. Like four times larger. In order to make fasta file more searchable, has to be larger… this can be quite computationally expensive

Now we have an indexed transcriptome.
