#!/bin/bash
bowtie_sams="$(pwd)/bowtie_alignments/"
bowtie
mkdir bam_files
mkdir gene_counts
wd=$(pwd)
for file in $bowtie_sams*; do
        filename="${file//.sam/.bam}"
        bam_filename="${filename//bowtie_alignments/bam_files}"
	sort_filename="${bam_filename//.bam/.sorted.bam}"
	count_filename="${bam_filename//.bam/.txt}"
	count_filename="${count_filename//bam_files/gene_counts}"
	echo -e "$filename"
	samtools view -S -b $file > $bam_filename 
	samtools sort $bam_filename > $sort_filename
	samtools index $sort_filename 
done

bedtools multicov \
        -bams $sort_filename \
        -bed /localdisk/data/BPSM/AY21/TriTrypDB-46_TcongolenseIL3000_2019.bed \
        > $count_filename
