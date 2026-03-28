# Prelim_SnakesAndSpiderVGViromes (UNDER CONSTRUCTION)
This is the repository for the scripts I used during a Fall 2025 project on snake and spider venom gland transcriptomes to characterize the virome

### First I need a conda env with bbmap, FastP, SPAdes, megahit

    conda create -n PullAss #creation of environment for pulling/assembling
.
    
    conda activate PullAss
.

    conda install -c conda-forge -c bioconda bbmap 
used to also install fastp, megahit, and spades, by subbing out "bbmap" part

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

### Next step: GenomeMAD for first pass annotation

.

    conda activate genomad
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

