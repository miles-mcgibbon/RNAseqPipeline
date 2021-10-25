#!/bin/bash

# set delimiter and make output directories
unset IFS
IFS=$'\t'
mkdir bowtie_alignments
mkdir bowtie_outputs

# get user argument for number of threads
while getopts t: flag
do
    case "${flag}" in
        t) threads=${OPTARG};;
    esac
done

# check threads argument has been supplied, if not default to one thread
re='^[0-9]+$'
if ! [[ $threads =~ $re ]] ; then
        threads="1"
fi

jobs=$threads

# define info file location and length
unset count
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
info_file_lines=$(cat $info_file | grep 100k | wc -l)

# loop through info file to extract read names and align them with the indexed reference genome using bowtie2
while read ID Sample Replicate Time Treatment End1 End2; do
	((i=i%jobs)); ((i++==0)) && wait
	if [[ "$Sample" == "Sample" ]]; then
		:
	else
		bowtie2 \
		--very-sensitive-local \
   		--threads 1 \
		-x tcongo_index \
		-1 /localdisk/data/BPSM/AY21/fastq/$End1 \
		-2 /localdisk/data/BPSM/AY21/fastq/$End2 \
		-S $(pwd)/bowtie_alignments/${Sample}_${Replicate}_${Time}_${Treatment}.sam 2> bowtie_outputs/${Sample}_${Replicate}_${Time}_${Treatment}.txt &
		count=$((count+1))
		echo -e -n "\rAligning $count of $info_file_lines sample paired-end reads..." 
	fi
done < "$info_file"
echo -e "\nFinished alignment of all sample reads to reference genome..."

# check for any poorly aligned files and remove them if user decides to
for output_file in bowtie_outputs/*; do
        sample_name=$(basename $output_file)
        sample_name="${sample_name//.txt/}"
        alignment=$(tail -1 $output_file | cut -c1-4)
        numeric_alignment=$(echo -e "$alignment" | cut -c1,2)
        numeric_alignment="${numeric_alignment//./0}"
        if [[ "$numeric_alignment" -lt "40" ]]; then
                echo -e "CONTAMINANT WARNING - Reads for sample $sample_name have very poor alignment ($alignment%) and are likely a contaminant"  
                read -p "Remove these reads from the analysis (y/n): " response
                if [[ "$response" == "y" ]]; then
                        rm -f bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                elif [[ "$response" == "Y" ]]; then
                        rm -f bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                fi
        elif [[ "$numeric_alignment" -lt "80" ]]; then
                echo -e "WARNING - Reads for sample $sample_name have poor alignment ($alignment%)"  
                read -p "Remove these reads from the analysis (y/n): " response
                if [[ "$response" == "y" ]]; then
                        rm -f bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                elif [[ "$response" == "Y" ]]; then
                        rm -f bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                fi
        fi
done 	
