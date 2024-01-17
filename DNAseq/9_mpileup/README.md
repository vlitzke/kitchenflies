# Step 9: Pileup Output

Generate text pileup output for one or multiple BAM files. Each input file produces a separate group of pileup columns in the output.

Note that there are two orthogonal ways to specify locations in the input file; via -r region and -l file. The former uses (and requires) an index to do random access while the latter streams through the file contents filtering out the specified regions, requiring no index. The two may be used in conjunction. For example a BED file containing locations of genes in chromosome 20 could be specified using -r 20 -l chr20.bed, meaning that the index is used to find chromosome 20 and then it is filtered for the regions listed in the bed file.

Unmapped reads are not considered and are always discarded. By default secondary alignments, QC failures and duplicate reads will be omitted, along with low quality bases and some reads in high depth regions. See the --ff, -Q and -d options for changing this.

Pileup Format
Pileup format consists of TAB-separated lines, with each line representing the pileup of reads at a single genomic position.
Several columns contain numeric quality values encoded as individual ASCII characters. Each character can range from “!” to “~” and is decoded by taking its ASCII value and subtracting 33; e.g., “A” encodes the numeric value 32.

The first three columns give the position and reference:

Chromosome name.
1-based position on the chromosome.
Reference base at this position (this will be “N” on all lines if -f/--fasta-ref has not been used).
The remaining columns show the pileup data, and are repeated for each input BAM file specified:

Number of reads covering this position.
Read bases. This encodes information on matches, mismatches, indels, strand, mapping quality, and starts and ends of reads.
For each read covering the position, this column contains:

If this is the first position covered by the read, a “^” character followed by the alignment's mapping quality encoded as an ASCII character.
A single character indicating the read base and the strand to which the read has been mapped:
Forward	Reverse	Meaning
. dot	, comma	Base matches the reference base
ACGTN	acgtn	Base is a mismatch to the reference base
>	<	Reference skip (due to CIGAR “N”)
*	*/#	Deletion of the reference base (CIGAR “D”)
Deleted bases are shown as “*” on both strands unless --reverse-del is used, in which case they are shown as “#” on the reverse strand.

If there is an insertion after this read base, text matching “\+[0-9]+[ACGTNacgtn*#]+”: a “+” character followed by an integer giving the length of the insertion and then the inserted sequence. Pads are shown as “*” unless --reverse-del is used, in which case pads on the reverse strand will be shown as “#”.
If there is a deletion after this read base, text matching “-[0-9]+[ACGTNacgtn]+”: a “-” character followed by the deleted reference bases represented similarly. (Subsequent pileup lines will contain “*” for this read indicating the deleted bases.)
If this is the last position covered by the read, a “$” character.
Base qualities, encoded as ASCII characters.
Alignment mapping qualities, encoded as ASCII characters. (Column only present when -s/--output-MQ is used.)
Comma-separated 1-based positions within the alignments, in the orientation shown in the input file. E.g., 5 indicates that it is the fifth base of the corresponding read that is mapped to this genomic position. (Column only present when -O/--output-BP is used.)
Additional comma-separated read field columns, as selected via --output-extra. The fields selected appear in the same order as in SAM: QNAME, FLAG, RNAME, POS, MAPQ (displayed numerically), RNEXT, PNEXT.
Comma-separated 1-based positions within the alignments, in 5' to 3' orientation. E.g., 5 indicates that it is the fifth base of the corresponding read as produced by the sequencing instrument, that is mapped to this genomic position. (Column only present when --output-BP-5 is used.)
Additional read tag field columns, as selected via --output-extra. These columns are formatted as determined by --output-sep and --output-empty (comma-separated by default), and appear in the same order as the tags are given in --output-extra.
Any output column that would be empty, such as a tag which is not present or the filtered sequence depth is zero, is reported as "*". This ensures a consistent number of columns across all reported positions.

Works best if they're all written to the same folder and then move the pileup file over later. 

samtools mpileup -B -f dmel-all-chromosome-r6.54.fasta -b BAMlist.txt -q 20 -Q 20 | gzip > DrosEU.mpileup.gz


samtools mpileup -B \
-f ./PATH/TO/2_bam_libraries/reference_genome.fa  \
-b ./PATH/TO/7_realignInDels/BAMlist.txt \
-q 20 \
-Q 20 \
| bgzip > ./PATH/TO/9_mpileup/DrosEU.mpileup.gz (or just gzip?)
