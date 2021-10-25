#!/bin/bash

# define location of alignment files and make output directories
bowtie_sams="$(pwd)/bowtie_alignments/"
mkdir bam_files
mkdir gene_counts
wd=$(pwd)

# loop over the alignment sam files and process them to get gene counts
unset count
total_files=$(ls bowtie_alignments/*sam|wc -l)
echo "Converting reads and calculating counts data..."
for file in $bowtie_sams*; do
	count=$((count+1))

	# define various output filenames with correct locations and extensions
        filename="${file//.sam/.bam}"
        bam_filename="${filename//bowtie_alignments/bam_files}"
	sort_filename="${bam_filename//.bam/.sorted.bam}"
	count_filename="${bam_filename//.bam/.tsv}"
	count_filename="${count_filename//bam_files/gene_counts}"
	echo -e -n "\rProcessing file $count of $total_files: $(basename $file)"

	# convert sam to bam
	samtools view -S -b $file > $bam_filename

	# sort the bam file
	samtools sort $bam_filename > $sort_filename

	# create bam.bai index for sorted file
	samtools index $sort_filename 

	# generate gene counts for sorted bam file
	bedtools multicov \
	-F \
 	-f 0.5 \
        -bams $sort_filename \
        -bed /localdisk/data/BPSM/AY21/TriTrypDB-46_TcongolenseIL3000_2019.bed \
        > $count_filename
done
