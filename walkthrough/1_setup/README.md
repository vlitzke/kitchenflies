# Downloading your data

Once you have sent off your DNA samples to the sequencer, you will likely want to download your data from their website to somewhere with enough storage (probably not your personal computer!) 

For example, Novogene has a tab on top that says: > Click on Export Link

Then you'll download an excel table, that has a few links. 

get an excel table full of the result files:

In linux, use the command 
`Wget [insert link here]`

To Unzip: 
`unzip filename.zip` 

The folder where the company provides you with
1. Raw Data
2. Quality (QC) report,

## Raw Data
Each folder will be named after the sample you've chosen and will include two runs on it.

For example: 
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz
F1_22_EKDN230045336-1A_HVMCLDSX7_L4_1.fq.gz

As well as a file called MD5.txt which is not super useful for us, but is a "message-digest algorithm" used for content verification.

# Creating a sample file 

This will prove useful if you want to run your samples on the cluster and want to loop through all of them. 

# Downloading the reference genome 

Download reference genome from [here]<https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.54_FB2023_05/fasta/>

To unzip: `gunzip -f dmel-all-chromosome-r6.54.fasta.gz`
