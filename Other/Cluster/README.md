# Set Up
As processing this data is extensive and intensive, you are likely going to run your jobs on an external cluster instead of on your personal computer. 

Since I am a part of a consortium that includes the University of St Andrews, I following this documentation to create an account to use on the cluster, which is quite helpful: <https://help.cropdiversity.ac.uk/guest-accounts.html>

Then, you're going to want to install conda if it isn't already there:
`install-bioconda`

You will also want to create several different environments in which to run your projects. This helps you download tools + packages unique to that environment. 
`conda create --name <env_name>`

and then to move into that envivonment 

`conda activate <env_name>`

you can then start installing certain tools:

`conda install anaconda::wget`

can export environment (see the one I have in DNAseq folder) - `conda env export > envrionment.yml`
# Daily Use

Once you log into the cluster, you will want to allocate your local jobs some memory on a node: 
`srsh -p short --mem=4G` or `srun --pty bash` 

and then to use conda and activate my specific environment (where all my packages are downloaded)
conda activate rnaseq 

If you can’t even install packages, increase your memory like such: $ srun --partition=short --cpus-per-task=8 --mem=16G --pty bash



## Cluster commands 
sbatch
srun
squeue 

How you print everything 
Squeue –-me

Dos2unix for text files anytime we’re transferring a file to unix 

I followed this: https://protocols.hostmicrobe.org/conda
Downloaded miniconda to my computer

scancel <jobid>



test that it works: conda –version
and then I also downloaded all the packages to the conda on the cluster! 
Soooo..

Create new .sh file in terminal in cluster with `touch 9_mpileup.sh`
download vim
to get out of vim editor use `:q` and hit enter. 






Created a bunch of small envrionments
Keep the base environment relatively clear, rather than downloading packages to the base environment 

Type in conda activate ‘program name’ 

 View text files in Terminal on Mac - `less <file_name>` 

# File transferring
To copy a file from your local computer to your scratch folder on the cluster, open your local terminal and type in `scp /PATH/TO/filename.sh userID@cropdiversity.ac.uk:scratch/`, it will prompt your for your key passphrase. This takes a few seconds. (rsync works as well?) 

scp ./file.txt cecicluster:destination/path/

For longer jobs, you might want to increase the number of threads /jobs to 16 from 1, and allocate more memory (60 gb instead of 8) 

Couldnt use bcftools on the cluster- had problems downloading so i downloaded miniforge3 and that already comes with mamba installed! So I created a new environment (mamba create -n bcf) and then installed bcftools

To activate it: C:\Users\vl29\AppData\Local\miniforge3\Scripts\activate


## Compressing
To compress a directory ```tar -czvf folderName.tar.gz *folderName```
