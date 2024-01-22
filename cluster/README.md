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

## Screens 
Run this on a screen 
Screen -r (if there are any screens that are running)
Type in screen 
Paste the command 
Control + a +d 
Then it goes back 
Reaccess screen – screen -r 
Type exit to get out of it




Created a bunch of small envrionments
Keep the base environment relatively clear, rather than downloading packages to the base environment 

Type in conda activate ‘program name’ 

 View text files in Terminal on Mac - `less <file_name>` 

To copy a file from your local computer to your scratch folder on the cluster, open your local terminal and type in `scp /PATH/TO/filename.sh userID@cropdiversity.ac.uk:scratch/`, it will prompt your for your key passphrase. This takes a few seconds. (rsync works as well?) 

scp ./file.txt cecicluster:destination/path/
