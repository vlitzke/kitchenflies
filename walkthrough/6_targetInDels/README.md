6. 

Difference between .index and .fai:

index fai : used by the tool to list the chromosome and quickly fetch a sequence from the fasta sequence

dict: list the chromosomes but also provides informations about the MD5 Sum of the fasta sequences (to be sure that you're using the same REF), the name of the organism(s), the names for aliases, the URL where we can retrieve the sequences, etc... this dict file will be inserted in/compared with the BAM and VCF headers


