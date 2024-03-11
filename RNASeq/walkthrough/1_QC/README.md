# fastQC 

fastqc sampleName.fq.gz 


Quality Control
1, Each of the samples has two .fastq files in them which means that L1 – is the lane but the last number is always 1 or 2 (F or R). 
2. Can merge the ones that have multiple files (for example, those that end in _1) – will give us higher coverage and won’t impact the data, even those these were samples that were run twice 
cat file1.gz file2.gz > allfiles.gz

3. Moving all the samples (the merged ones too) into a new folder back in RNAseq called QC (quality control) underneath Batch3 

4. Running fastqc on them 

Get an .html QC report

Use fastqc to look at quality (in envrioinment with kallisto)

Conda activate rnaseq 
Fastqc XXX.fastq.gz oooor for all of them fastqc *.gz

Can use cores on the laptop and process the file across threads (multithreading)- use all 8 threads or 4 physical cores to process  fastqc *.gz -t 8

With rna seq – click on sequence duplication and we get the % of sequnces that have been duplicated a number of times : we expect a number of genes in transcrioptome to be highly expressed and therefore to have repeated/duplicate sequences 

I want to do this to loop over all the files 
So I should probably rename them all first and cut out all the middle data. 
Then I should just keep the first characters up until the first _ 
And rename them all 
And then run fastqc on all of them, and save the output as something different
