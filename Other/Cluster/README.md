# Set Up
As processing this data is extensive and intensive, you are likely going to run your jobs on an external cluster instead of on your personal computer. 

Since I am a part of a consortium that includes the University of St Andrews, I following this documentation to create an account to use on the cluster, which is quite helpful: <https://help.cropdiversity.ac.uk/guest-accounts.html>

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

# Slurm Commands 

- Run a slurm (.sh) file: `sbatch fileName.sh`
- Cancel a job: `scancel jobID`
- See all active jobs : `squeue`
- See your activate jobs: `squeue –-me`
- Transferring a .txt file to unix: `dos2unix fileName.sh` or create it with `touch fileName.sh`. 



# File transferring
To copy a file from your local computer to your scratch folder on the cluster, open your local terminal and type in `scp /PATH/TO/filename.sh userID@cropdiversity.ac.uk:scratch/`, it will prompt your for your key passphrase. This takes a few seconds. (rsync works as well?) 

scp ./file.txt cecicluster:destination/path/

For longer jobs, you might want to increase the number of threads /jobs to 16 from 1, and allocate more memory (60 gb instead of 8) 

Couldnt use bcftools on the cluster- had problems downloading so i downloaded miniforge3 and that already comes with mamba installed! So I created a new environment (mamba create -n bcf) and then installed bcftools

To activate it: C:\Users\vl29\AppData\Local\miniforge3\Scripts\activate



