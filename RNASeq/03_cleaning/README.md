# Cleaning

Now we will want to use `fastp` which has some pretty standard defaults that everyone seems to use, so you will not have to change much. For example, the default trimming length are reads > 150 base pairs long, and this will also automatically cut off adaptor sequences (trimming 50bp off the beginning and end of sequences) unless it has been otherwise specified. 

First install it with `conda install fastp`.

```
fastp \
-i ./PATH/TO/sampleName_read1.fq.gz \
-I ./PATH/TO/sampleName_read2.fq.gz \
-o ./PATH/TO/sampleName_1_trimmed.fq.gz \
-O ./PATH/TO/sampleName_2_trimmed.fq.gz \
--html ./PATH/TO/sampleName.log \
--json ./PATH/TO/sampleName.json 2> Dm_F10
```

