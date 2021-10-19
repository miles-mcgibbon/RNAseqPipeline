#!/bin/bash
bowtie_sams="$(pwd)/bowtie_alignments/"
output_dir="$(pwd)/bam_files/"
mkdir bam_files
wd=$(pwd)
for file in $bowtie_sams*; do
        filename="${file//.sam/.bam}"
        filename="${filename//bowtie_alignments/bam_files}"
	echo -e "$filename"
	samtools view -S -b $file > $filename
done
