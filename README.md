# Prelim_SnakesAndSpiderVGViromes (UNDER CONSTRUCTION)
This is the repository for the scripts I used during a Fall 2025 project on snake and spider venom gland transcriptomes to characterize the virome

### First I need a conda env with bbmap, FastP, SPAdes, megahit

    conda create -n PullAss #creation of environment for pulling/assembling
.
    
    conda activate PullAss
.

    conda install -c conda-forge -c bioconda bbmap 
used to also install fastp, megahit, sra-tools, and spades, by subbing out "bbmap" part
Note: I am retracing my steps and moving my work to another server. In doing this, I discovered that the process breaks at the bbnorm step, so I had to rercreate the environment with the specific version that worked, which is bbmap=39.37

### Next you need to create the list and metadata files to inform our bash script:
sralist="snsSRAs.csv" #File with SRA #s on their own. Should look like: 

    SRR10216514
    SRR10216523
    SRR10216522
    SRR23434845
    SRR17250293
    ...
meta="SnakeNspiderSRAs.csv" #File with metadata: SRA#,RNA/DNA,single/paired,Illumina/Pacbio:

    SRR10216514,RNA,paired,Illumina
    SRR10216523,RNA,paired,Illumina
    SRR10216522,RNA,paired,Illumina
    SRR23434845,RNA,paired,Illumina
    SRR17250293,RNA,paired,Illumina
    ...
Activate the environment:

    conda activate PullAss
Bash 

    bash PullAssInator.sh 

At some point I also tried to download in some raw files for genome assembly, as well as assembled genomes after that took too long. Eventually the genome aspect was dropped altogether in the interest of time (This was a semester project, initially).

### Next step: GenomeMAD for first pass annotation

.
#Genomad env wasn't fully operational w/o stable Python version (3.10), so install as so:

    conda create -n genomad_env -c conda-forge -c bioconda python=3.10 genomad

    conda activate genomad_env
Run the Maddinator2000:

    bash Maddinator2000.sh
Let's do some cleaning

    rm ./*.fasta
    ls ./*_spades
    rm -r ./*_spades
Let's check the out dir:

    cd GeNomad
    ls ./*_output/*_transcripts_summary 
### Next I must extract all viral seq and use checkV
Let's activate a screen:

    screen -r CheckPlease
And Bash:

    bash checkVit.sh
Note: It is at this point that I became unsure of the next steps for the process, and I am unsure how far I got but the following was planned (if not executed): 

    screen -S PHA
*

        conda activate pharokka
*

        bash pharokkaTime.sh

### Here's where I really started to get confused:
I have to do stuff before visualizing, including pulling the raw seq again 

    screen -S PullOnly
*

        conda activate PullAss
*

        bash pull.sh 
Two are not paired. Why? I tried to investigate this:

    SRR3141929
        #Did not work. Replacing with SRR25747561- Brown Vine Snake-- Worked! Now I have to repeat all the steps for it tho...
        SRR7609626.fastq
                /work/programs/sratoolkit.3.0.10-centos_linux64/bin/fasterq-dump --split-files -p -e 4 SRR7609626
        #Worked
I wrote the following next: 
After this, I may want to make a loop that creates the bam we need... Or process all 20 samples individually. 

    screen -S bowtie2
*

        conda activate mapback
*

        bash index.sh
I'm not certain if index.sh and mapinator.sh are the same yet. Needs further verification

        mkdir Mapping
*

        mv ./*_index* Mapping/
I wanted to sort the viromes, so I took the columns with top viral hits and made files with each (snakes, spiders) using the following: 

    tr ',' '\n' < snake_viromes.txt | sed 's/^ *//; s/ *$//'| grep -E '^[0-9]+' | awk '
      {
        count=$1
        $1=""; tax=substr($0,2)
        sum[tax]+=count
      }
      END {
        for(t in sum) printf "%d\t%s\n", sum[t], t
      }
    ' | sort -nr > unique_sorted_counts2.tsv

