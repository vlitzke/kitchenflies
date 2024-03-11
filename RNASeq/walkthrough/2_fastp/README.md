```
fastp \
-i ./PATH/TO/sampleName_read1.fq.gz \
-I ./PATH/TO/sampleName_read2.fq.gz \
-o ./PATH/TO/sampleName_1_trimmed.fq.gz \
-O ./PATH/TO/sampleName_2_trimmed.fq.gz \
--html ./PATH/TO/sampleName.log \
--json ./PATH/TO/sampleName.json 2> Dm_F10
```
Conda install fastp

This cleans the read, fastp has good defaults, don’t have to change much  - shangzhe says the default it cuts off reads less than 150 bp and will automatically cut off the adapter sequences (trims 50bp off beginning and end)

Fast -i file_1.fq.gz -I file_.fq.gz -o file_1_cleaned.fq.gz -O file_2_cleaned.fq.gz

Now that they’re cleaned, I put them in the cleaned folder 
