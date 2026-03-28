# Prelim_SnakesAndSpiderVGViromes (UNDER CONSTRUCTION)
This is the repository for the scripts I used during a Fall 2025 project on snake and spider venom gland transcriptomes to characterize the virome

### First I need a conda env with bbmap, FastP, SPAdes, megahit

    conda create -n PullAss #creation of environment for pulling/assembling
.
    
    conda activate PullAss
.

    conda install -c conda-forge -c bioconda bbmap 
used to also install fastp, megahit, and spades, by subbing out "bbmap" part

Activate the environment:

    conda activate PullAss
Bash 

    bash PullAssInator.sh 
