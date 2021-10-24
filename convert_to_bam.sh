#!/bin/bash
bowtie_sams="$(pwd)/bowtie_alignments/"
mkdir bam_files
mkdir gene_counts
wd=$(pwd)
unset count
total_files=$(ls bowtie_alignments/*sam|wc -l)
echo "Converting reads and calculating counts data..."
for file in $bowtie_sams*; do
	count=$((count+1))
        filename="${file//.sam/.bam}"
        bam_filename="${filename//bowtie_alignments/bam_files}"
	sort_filename="${bam_filename//.bam/.sorted.bam}"
	count_filename="${bam_filename//.bam/.tsv}"
	count_filename="${count_filename//bam_files/gene_counts}"
	echo -e -n "\rProcessing file $count of $total_files: $(basename $file)"
	samtools view -S -b $file > $bam_filename 
	samtools sort $bam_filename > $sort_filename
	samtools index $sort_filename 
	bedtools multicov \
        -bams $sort_filename \
        -bed /localdisk/data/BPSM/AY21/TriTrypDB-46_TcongolenseIL3000_2019.bed \
        > $count_filename
done
