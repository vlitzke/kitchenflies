Then kallisto maps 

First
Call kallisto:
Kallisto quant \ (continues on, just stacks the code)
-i (index file name) \
-o test \ specifes name of output folder and put the results in, call it whatever 
-t 8 \ (can use multiple threads) 
--paired -l (average length) 250 -s (and average standard deviation) of the library 30 \  this is kinda confusing, this is what a standard library prep is for illumine short read sequencing , however you could get more specific if you had access to Bioconductor profiles of our actual libraries before they went onto the seqeuner for accurate numbers…
Name of fastq file. 

This would give us standard output describing the results of the alignment – 
So we add \
&>test.log (another object to save results) 

Ohh for paired end it looks like this: (photo in word doc)

kallisto quant \
-i Drosophila_melanogaster.BDGP6.46.cdna.all.index \
-o test \
F3_EKRN230053769-1A_H7MJFDSX7_L2_1.fq.gz \
F3_EKRN230053769-1A_H7MJFDSX7_L2_2.fq.gz \
&> test.log


```
kallisto quant \
-i ./PATH/TO/Drosophila_melanogaster.BDGP6.46.cdna.all.index \
-o ./PATH/TO/DESTINATION 
./PATH/TO/sampleName_1_trimmed.fq.gz 
./PATH/TO/sampleName_2_trimmed.fq.gz
```


This is what I ran: 
kallisto quant -i ./4_Mapping_kallisto/Drosophila_melanogaster.BDGP6.46.cdna.all.index -o ./4_Mapping_kallisto/F5 ./3_CleanedReads_fastp/F5_EKRN230053771-1A_H7LCTDSX7_L3_1_cleaned.fq.gz ./3_CleanedReads_fastp/F5_EKRN230053771-1A_H7LCTDSX7_L3_2_cleaned.fq.gz

for F3 and F5, the reads were pretty well aligned!

Can use pseduobam to present piled-up reads of gene expression data – also performs well for lowly expressed transcripts (pseudoalignment method) Zheng2019 
