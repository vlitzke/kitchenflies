multiqc.

#--
If you kept all the files from each step in the same directory, you could run multiqc which basically sorts out the various files and summarizes them into one html file. 

Batch3  % multiqc -d . 

Or just: multiqc Batch3 . 

This honestly works for a whoooole range of bioinformatic outputs (remember to may use later?) 
