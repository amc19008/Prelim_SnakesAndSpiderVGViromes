#!/bin/bash
set -euo pipefail

sralist="snsSRAs.csv"   # File with SRA IDs, one per line
meta="SnakesNspiderSRAs.csv"         # Metadata: SRA#,RNA/DNA,single/paired,Illumina/Pacbio

# Check SRA list exists
if [[ ! -f "$sralist" ]]; then
    echo "Radn't, SRA list not found in current wd ):"
    exit 1
fi

echo "Rad, the SRA list is present."
echo "Alright, file present. Let's get it started in here."

# Main loop
while read -r x; do
    [[ -z "$x" ]] && continue  # skip blank lines

    echo
    echo "LOOP STARTING ----------------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "Starting processing for $x at $(date)"

    # Untar the SPAdes archive
    if [[ ! -f "${x}_spades.tar.gz" ]]; then
        echo "ERROR: Archive ${x}_spades.tar.gz not found"
        continue
    fi

    tar -xzvf "${x}_spades.tar.gz"

    # Ensure the directory exists
    if [[ ! -d "${x}_spades" ]]; then
        echo "ERROR: Expected directory ${x}_spades not found after untar"
        continue
    fi

    # Determine RNA or DNA from metadata
    type=$(grep -w "$x" "$meta" | awk -F "," '{print $2}')

    if [[ -z "$type" ]]; then
        echo "WARNING: Could not find metadata entry for $x. Skipping."
        continue
    fi

    if [[ "$type" == "RNA" ]]; then
        echo "Sample $x is RNA"
        if [[ ! -f "${x}_spades/transcripts.fasta" ]]; then
            echo "ERROR: transcripts.fasta missing for $x"
            continue
        fi

        mv "${x}_spades/transcripts.fasta" "${x}_transcripts.fasta"

        genomad end-to-end --cleanup "${x}_transcripts.fasta" "./GeNomad/${x}_output" /Users/maddlab_apollo365/databases/genomad_db --threads 2

    else
        echo "Sample $x is DNA"
        if [[ ! -f "${x}_spades/contigs.fasta" ]]; then
            echo "ERROR: contigs.fasta missing for $x"
            continue
        fi

        mv "${x}_spades/contigs.fasta" "${x}_contigs.fasta"

        genomad end-to-end --cleanup "${x}_contigs.fasta" "./GeNomad/${x}_output" /work/databases/genomad_db --threads 10
    fi

    echo "Finished $x at $(date)"
    echo

done < "$sralist"
