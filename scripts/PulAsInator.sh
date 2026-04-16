#Before running: conda activate PulAs
#!/bin/bash

#rough pipeline for dinornav and coral reef metaanalysis -- AS OF 2/4/2024 YOU NEED TO ACTIVATE THE "bigtime" CONDA ENVIRONMENT TO RUN
#threads set to 10 for now

# creating and assigning variables
sralist="snsSRAs.csv" #File with SRA #s on their own
meta="SnakeNspiderSRAs.csv" #File with metadata: SRA#,RNA/DNA,single/paired,Illumina/Pacbio

#checking to make sure the file you said above is available in the current working directory
if [[ $(ls | grep -xc "$sralist") -eq 1 ]]; then echo "Rad, the sra's present."; else echo "Radn't, SRA list not found in current wd. ):"; exit 1; fi

# Starting big loop
echo "Alright, file present. Let's get it started in here."
for x in $(cat $sralist)
do      echo "LOOP STARTING ----------------------------------------------------------------------------------------------------------------------------------------------------------"
        echo "Starting the download for $x at $(date)"
        export TMPDIR=/Users/maddlab_apollo365/Asherc/Prelim_Data_SNS/temp
	prefetch $x
        fasterq-dump -p -e 10 --concatenate-reads $x
        
	echo "Finished the download for $x at $(date). Confirming download....."
        
#confirming the the files were downloaded succesfully
        if [[ $(ls | grep -xc ""$x".fastq") -eq 1 ]]; 
        then    echo "ALRIGHT FILES ARE THERE AND WE'LL MOVE FORWARD (˶ᵔ ᵕ ᵔ˶) ++++++++++++++++++___++++++++++++++++++++____+++++++++++++++++++++++++++++++++++___++++++++++++++++++++____+++++++++++++++++"
                
#Ok now that we have files downloaded and confirmed they are there, need to clean with fastp
                R12=$(ls | grep "$x" | grep "fastq") #here R12 is the output, or fastq file pulled from previous step
                echo "Cleaning raw reads...₊˚⊹♡"
                if [[ $(grep -w "$x" $meta | awk -F "," '{print $3}') == "single" ]]; #this checks third column of meta file for single or paired reads
                then    echo "single"
                        fastp -i $R12 -o "$x"_cln.fastq --average_qual 25 -q 20 -l 50 -y -Y 30 -g -x -n 2 -c --overrepresentation_analysis --html .fastp.html --json .fastp.json --thread 10 
                        ck=""$x"_cln.fastq" #Sets ck as the output of this fastp step for next step
                else    echo "paired"
                        fastp -i $R12 --interleaved_in -o "$x"_1_cln.fastq -O "$x"_2_cln.fastq --average_qual 25 -q 20 -l 50 -y -Y 30 -g -x -n 2 -c --overrepresentation_analysis --html .fastp.html --json .fastp.json --thread 10
                        ck=""$x"_1_cln.fastq" #Sets ck as the output of this fastp step for next step
                fi
                echo "FastP seems to be done, lets clean up a bit...(*ᴗ͈ˬᴗ͈)"
                #alright, raw reads cleaned, no need for them anymore can get them anytime we need from SRA. To save space I will remove before normalizing.
                rm $R12
                echo "before moving on, let's make sure there are enough reads in the cleaned file ꕤ*.ﾟ"
                if [ $( wc -l $ck | awk '{print $1}') -eq 0 ]; #here we are checking first column of the fastp output
                then    echo ""$x" has failed QC (ᵕ—^—)"
                        echo "$x" >> FailedQC.list
			rm "$x"*cln.fastq & #This deletes the fastp output for the one that failed
		else	echo "Alright, time for normilization, dont matter if single or paired, bbnorm gone do it...⋆˙⟡"
                        if [[ $(grep -w "$x" $meta | awk -F "," '{print $3}') == "single" ]]; 
                        then    echo "single"
                                bbnorm.sh in="$x"_cln.fastq out="$x".norm.fq.gz  target=100 min=1 threads=10 -eoom
                        else    echo "paired"
                                bbnorm.sh in1="$x"_1_cln.fastq in2="$x"_2_cln.fastq out1="$x".norm.R1.fq.gz out2="$x".norm.R2.fq.gz target=100 min=1 threads=10 -eoom
                        fi
                        echo "Normalization seems to be done, lets clean up a bit...(*ᴗ͈ˬᴗ͈)"
                        #alright, to save space we will remove the non-normed reads before assembly.
                        rm "$x"*cln.fastq &
        #(WE CAN ADD SOMETHING HERE TO CHECK FOR DNA or RNA to run different programs)
                        if [[ $(grep -w "$x" $meta | awk -F "," '{print $2}') == "RNA" ]]; 
                        then    echo "RNA"
                                if [[ $(grep -w "$x" $meta | awk -F "," '{print $3}') == "single" ]]; 
                                then    echo "single"
                                        spades.py --rna -s "$x".norm.fq.gz -t 10 -m 300 -o "$x"_spades
                                        tar -czvf "$x"_spades.tar.gz "$x"_spades 
                                        #mv ./"$x"_spades/scaffolds.fasta ./"$x"_scaffolds.fasta
                                        #pigz -p 30 "$x"_scaffolds.fasta
                                        rm -r ./"$x"_spades
                                else    echo "paired"
                                        spades.py --rna -1 "$x".norm.R1.fq.gz -2 "$x".norm.R2.fq.gz -t 10 -m 300 -o "$x"_spades
                                        tar -czvf "$x"_spades.tar.gz "$x"_spades
                                        #mv ./"$x"_spades/scaffolds.fasta ./"$x"_scaffolds.fasta
                                        #pigz -p 30 "$x"_scaffolds.fasta
                                        rm -r ./"$x"_spades
                                fi
                        else    echo "Skipping RNA pipeline for DNA sample: $x"
                         # DNA-specific workflow can go here, for example:
                                if [[ $(grep -w "$x" $meta | awk -F "," '{print $3}') == "single" ]]; 
                                then    megahit -r "$x".norm.fq.gz -t 10 -m 300 -o "$x"_megahit
                                else    megahit -1 "$x".norm.R1.fq.gz -2 "$x".norm.R2.fq.gz -t 10 -m 300 -o "$x"_megahit
                                fi
                                 tar -czvf "$x"_megahit.tar.gz "$x"_megahit
                                 rm -r "$x"_megahit
                        fi
                        echo "Assembly seems to be done, lets clean up a bit..."
                        #alright, to save space we will remove the normed reads to make sure we have the space
                        rm "$x".norm.* &
                        echo "Everything is completed ⊹₊ ˚‧︵‿₊୨୧₊‿︵‧ ˚ ₊⊹ ++++++++++++++++++___++++++++++++++++++++____+++++++++++++++++++++++++++++++++++___++++++++++++++++++++____+++++++++++++++++++++++++++++++++++___++++++++++++++++++++____+++++++++++++++++"
                fi
        else    echo ""$x" failed download (ᵕ—^—)" >> failed_downloads.out
                echo ""$x" failed download (ᵕ—^—)"
        fi
        if [ $( ls | grep -c "tmp") -gt 0 ]; then rm -r *tmp*; fi
	echo "LOOP DONE %ᵕ‿‿ᵕ%----------------------------------------------------------------------------------------------------------------------------------------------------------"
done
