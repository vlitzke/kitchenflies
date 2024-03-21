# Set Up
As processing this data is extensive and intensive, you are likely going to run your jobs on an external cluster instead of on your personal computer. 

Since I am a part of a consortium that includes the University of St Andrews, I following this documentation to create an account to use on the cluster, which is quite helpful: <https://help.cropdiversity.ac.uk/guest-accounts.html>

To log on, you can either use some sort of medium (PuTTy, MobaXTerm, etc) or you can log on by typing in `ssh yourUserName` to connect to a remote server (secure shell).

# Conda Installation
Then, you're going to want to install conda if it isn't already there:`install-bioconda`. Then test that it worked `conda –version`.

You will also want to create several different environments in which to run your projects and keep the base environment relatively clear. This helps you download tools + packages unique to that environment: `conda create --name <env_name>`

To move into that envivonment: `conda activate <env_name>`

To start installing certain tools: `conda install anaconda::wget`

To export an environment: `conda env export > envrionment.yml`

📝 Alternatively, you can download miniconda to use on your PC: https://protocols.hostmicrobe.org/conda

# Daily Use

1. Log into the cluster (passphrase, ssh key likely necessary), allocate your local jobs some memory on a node: 
`srsh -p short --mem=4G` or `srun --pty bash`. Sometimes installing packages might need more memory so specify when necessary (`$ srun --partition=short --cpus-per-task=8 --mem=16G --pty bash`)

2. Start conda and activate specific environment (where all my packages are downloaded): `conda activate rnaseq`
 
## Slurm Commands 

| Basic Commands | Description |
| ----------- | ----------- |
| `sbatch fileName.sh` | run a slurm (.sh) file |
| `scancel jobID` |  cancel a job |
| `squeue` |  see all active jobs |
| `squeue --me` |  see your active jobs |
| `sinfo` |  see information about nodes |
| `touch fileName.sh` | create a .sh file |
| `dos2unix fileName.sh` | convert a .txt file to unix |
| `scp /PATH/TO/filename.sh userID@cropdiversity.ac.uk:DESTINATION/TO/PATH`  | copy a file from your local computer to your scratch folder on the cluster (or vice versa), but here you open your local terminal, and once this has been typed in, it will prompt your for your key passphrase. This takes a few seconds (rsync works as well). |
| `curl`  | transfer data to and from a server |
| `htop`  | display current jobs |
| `kill`  | terminate process |

📝 If you want to download things (in this case, a whole folder) from the cluster, it might ask you for your key: `scp -r -i ./PATH/TO/key username@clusterName:PATH/TO/FOLDER DESTINATION/PATH`

To get out of an interactive job, press `ctrl+d`. 

## Typical Slurm File

You probably will not have the memory, time, CPUs etc to run jobs on your own laptop, hence why the cluster exists! So you would probably create a slurm (.sh) file, with the following content:

| Basic Commands | Description |
| ----------- | ----------- |
| `#SBATCH --job-name` | set job name |
| `#SBATCH --ntasks` |  request a number of tasks (cores) |
| `#SBATCH --nodes` |  request a number of nodes |
| `#SBATCH --mem` |  request amount of memory |
| `#SBATCH --partitiom` |  request the partiion or queue to submit job to |
| `#SBATCH --output` | create an output file |

There are also other things you could specify, such as an sending an email when your job has finished, setting a maximum time limit for a job, or printing out error output. Below is an example script: 

```
#!/bin/bash

#SBATCH --job-name=“XXXX”
#SBATCH --mail-user=XXXX
#SBATCH --mail-type=END
#SBATCH --ntasks=16                    # Run on a single CPU
#SBATCH --mem=30G                     # Job memory request
#SBATCH --partition=long
#SBATCH --output=XXXX.log   # Standard output and error log

pwd; hostname; date

echo "Starting job on $HOSTNAME"
echo [`date +"%Y-%m-%d %H:%M:%S"`]

eval "$(conda shell.bash hook)"

cd PATH/TO/DESTINATION/

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

echo "Job finished"
```

The first line is always default, telling the laptop that we are writing in bash script. Then comes an option, if you'd like the cluster to send you an email when the job has finished (with some information like job ID, how long it took, how much memory it used, etc). Then you define how many tasks/nodes you would like your job to run on, and how much memory the cluster should allocate for it (do NOT overestimate, then you are taking up memory and nodes that other people could be using!). Partition tells the cluster how long it will probably take to run the job, this is so when the cluster knows its going to be a long job (no end time), that it might wait until it has enough excess memory free for it to run your job so other people can still run thing simulatenously. Short jobs should take 8 hours max, medium will be cut off at 24 hours and long jobs will go on until they are done. The output means you will get a .log file (can be opened with a text editor) which shows you any potential errors that occurred, or if you wanted anything printed from your job. 

I then chose to print where, when and how long things took, asked the cluster to use conda, provided the directory I have my files/scripts in, the commands you'd like the cluster to do, and then for it to print that the job has finished (if it indeed has! helpful when you have an error to know it did not finish). 

📝 For long jobs, you might want to increase the number of threads/jobs to 16 from 1, and allocate more memory (60 gb instead of 8).
