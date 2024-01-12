as soon as I log in , write:
srun --pty bash 

or this:
srsh -p short --mem=4G

should activate a node to run stuff on 

and then to use conda and activate my specific environment (where all my packages are downloaded)
conda activate rnaseq 

If you can’t even install packages: $ srun --partition=short --cpus-per-task=8 --mem=16G --pty bash

Run something like this ^ to increase the memory 

How you print everything 
Squeue –-me

Dos2unix for text files anytime we’re transferring a file to unix 
