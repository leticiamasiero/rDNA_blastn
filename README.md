![Status](https://img.shields.io/badge/status-active-success.svg)
# rDNA_blastn: Characterization of ribosomal DNA arrays in genomes or long-read sequencing data with integrated BLASTn

## 🧬 Ribosomal DNA arrays
The 45S ribosomal DNA unit is organized in a specific structure, with genes and internal and external spacers that composes a cluster that repeats tandemly and it is located in the nucleolar organizing regions (NORs). The ribosomal genes are highly conserved, specially the 5.8S, making this sequence an ideal BLASTn reference. 
>
<img width="2235" height="343" alt="Image" src="https://github.com/user-attachments/assets/fc615717-1be4-48b9-a11b-7d39e890f92b"/>

>

To see the cluster organization and structure, as well as the neighbouring regions and therefore form longer arrays within the same region (scaffold or chromosome), this custom script performs after the BLASTn search a bidirectional extension in the BLASTn hits. The user can edit to a value of preference just adjusting the value of base pairs that the script extend in both strands. The script verifies overlapping regions resulting in only scaffolds with unique sequences. If the BLASTn hits of the reference input overlaps, the script extend the region in the same scaffold output. 

>
## 🔍 BLASTn
The Basic Local Alignment Search Tool (BLAST; Altschul et al., 1990) is a powerful tool to alignments, comparing the nucleotide sequence of your reference to a nucleotide database. Therefore, the BLASTn approach allows in the script to search for any reference in complete genomes and/or raw long-read sequencing, which the parameters can be modified to adapt to your targeted sequence and goals.

>

## ⚙️ Run
The script has two required inputs: the library file containing the **raw long-reads or the genome**, and the **reference sequence**, both in fasta format. 
>
The user must have the BLASTn installed in their environment. 
>
To run the bash script:
>
```bash
chmod +x rdna_array.sh
./rdna_array.sh
```
>
The script will ask which are the two inputs, that needs to be in the **same folder** that the user is running the code. Then, the user enters with the name of the raw BLASTn output with all the hits, and the name of the final output with the unique scaffolds.
>
### 🛠️ Modifications
To personalize the script to your targets, you can adjust the minimum coverage and the evalue of the BLASTn analysis, in the command line of the program. 
>
You can also adjust the number of base pairs that you want to extend bidirectionally to result in the arrays. The script by default extends 50,000 bp in each direction. To do this, you need to modify this value in the awk block region of the code:
>
```
awk '
BEGIN {
    prim_crom = "";
    prim_start = 0;
    prim_end = 0;
}
{
    chrom = $1;
    start = ($2 < 50000) ? 0 : $2 - 50000;
    end = $3 + 50000;

...
```


>
## 🖥️ Output files
There are six output files:
- `coordenades_hits.bed` Contains the coordenades hits of the BLASTn alignment to the input files, with three columns: scaffold name, start position, and end position.
- `neighbouring_positions.tsv` Contains the scaffold name, start position and end position of the array with the extended neighbouring region. 
- `scaffolds_name.bed` Contains just the scaffolds names retrieved from the BLASTn analysis.
- `sequences.fa` Contains the entire sequences (scaffolds or chromosomes) that BLASTn found some hit with the reference sequence. 
- `blast_hits.tsv` The name is entered by the user, we recommend to standardize to `blast_hits.tsv`. The file contains all twelve columns of the BLASTn analysis: qseqid, sseqid, pident, length, mismatch, gapopen, qstart, qend, sstart, send, evalue, and bitscore. It is possible to see every single hit in your library with the reference sequence. 
- `species_arrays.fa` The name is entered by the user, we recommend to standardize to `species_arrays.fa` with the name of your targeted species. The file contains the scaffolds without overlapping hit regions. To see the organization and structure of the rDNA arrays, you can use a viewer software such as Geneious, annotating your genes and reference sequence.
>
