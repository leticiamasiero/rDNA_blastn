#!/bin/bash

# Enable autocompletion for filenames
shopt -s progcomp

# Autocompletion function
_autocomplete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    # Use compgen to generate matching filenames
    COMPREPLY=( $(compgen -f -- "$cur") ) 
}

# Assign the autocompletion function to the 'read' command
complete -F _autocomplete read

# Prompt for the library file name (contains the sequenced genome)
read -e -p "Enter the name of the library file: " input_library

# Prompt for the reference to be used (changes according to what is being searched)
read -e -p "Enter the name of the reference sequence to be used: " reference

# Prompt for the output name (BLAST output file, which has several columns with information)
read -e -p "Enter the desired name for the BLAST output file: " blast_hits

# Prompt for the final output file name (containing the final sequences)
read -e -p "Enter the name of the output file containing the final sequences and rDNA arrays: " species_arrays

# Minimum coverage percentage for BLASTn
minimum_coverage=60

# Prepare the library for blast (create a BLAST database)
echo "Preparing BLAST database from '$input_library'..."
makeblastdb -in "$input_library" -dbtype nucl

# Execute blastn
echo "Executing blastn..."
blastn -task blastn -outfmt 6 -db "$input_library" -query "$reference" -out "$blast_hits" -evalue 1e-50 -qcov_hsp_perc "$minimum_coverage"

# Extract reads from the output:
echo "Extracting reads from the BLAST output..."
# Column $2 contains the subject ID (read/contig name from the library)
cat "$blast_hits" | awk '{print $2}' | sort -u > scaffolds_name.bed

# Retrieve the sequences corresponding to the extracted reads:
echo "Retrieving reads/sequences..."
# seqtk subseq extracts sequences from $input_library based on the IDs in scaffolds_name.bed
seqtk subseq "$input_library" scaffolds_name.bed > sequences.fa

# Export the output variable (though it's not strictly necessary for the rest of the script, 
# it was in the original and might be used elsewhere)
export blast_hits

# Create a BED-like file (contig, start, end)
echo "Creating temporary BED file..."
# Column $2 is the contig/read ID, $9 and $10 are start and end of the alignment on the subject
awk '{print $2,$9,$10}' "$blast_hits" > coordenades_hits.bed

# Delimit the contig regions, merging overlapping regions and extending by 50kb
echo "Analyzing overlapping regions and extending..."

awk '
BEGIN {
    # Initialize variables for the current region
    init_crom = "";
    init_start = 0;
    init_end = 0;
}
{
    # $1: Chromosome/Contig name
    # $2: Start position on contig
    # $3: End position on contig
    chrom = $1;
    # Extend start by 50kb, ensuring it does not go below 0
    start = ($2 < 50000) ? 0 : $2 - 50000;
    # Extend end by 50kb
    end = $3 + 50000;

    # Check for overlap with the previous region
    if (chrom == init_crom && start <= init_end) {
        # If there is overlap, extend the region
        init_end = (end > init_end) ? end : init_end;
    } else {
        # If it is a new chromosome or a non-overlapping region, print the previous one
        if (init_crom != "") {
            # Output format: contig, start, end (space-separated)
            print init_crom, init_start, init_end;
        }
        # Update variables for the new region
        init_crom = chrom;
        init_start = start;
        init_end = end;
    }
}
END {
    # Print the last processed region
    if (init_crom != "") {
        print init_crom, init_start, init_end;
    }
}' coordenades_hits.bed > neighbouring_positions

echo "Finalizing the final file (extracting sequences based on neighborhood positions)..."
# Extract sequences from the library based on the coordinates in neighbouring_positions
seqtk subseq "$input_library" neighbouring_positions > "$species_arrays"

echo "Script execution finished. Final sequences saved to '$species_arrays'."
