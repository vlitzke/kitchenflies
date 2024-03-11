# Quality Control

1. Each of the samples has two .fastq files in them which means that L1 – is the lane but the last number is always 1 or 2 (forward or reverse read). 
2. For those that have been run in the same lane, but different times (like twice for example, some that end in _1), these can be merged to give us higher coverage. This will not impact the data:

   `cat file1.gz file2.gz > allfiles.gz`

3. Once the samples are complete (and those that needed to be merged are now merged), you can run `fastQC` on them to look at their quality.

`fastqc sampleName.fq.gz` for each individual sample or if they are all in the same folder `fastqc *.gz`

On your laptop, you can use cores to process the files across threads (called multithreading)- use all 8 threads or 4 physical cores to process `fastqc *.gz -t 8`.

This generates an .html QC report.

:Note: When looking at RNASeq data sequence duplication percentage, we expect a number of genes in transcrioptome to be highly expressed and therefore to have repeated/duplicate sequences.
