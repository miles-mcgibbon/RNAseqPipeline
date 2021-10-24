unset IFS
IFS=$'\t'
mkdir bowtie_alignments
mkdir bowtie_outputs
jobs=5
unset count
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
info_file_lines=$(cat $info_file | grep 100k | wc -l)
while read ID Sample Replicate Time Treatment End1 End2; do
	((i=i%jobs)); ((i++==0)) && wait
	if [[ "$Sample" == "Sample" ]]; then
		:
	else
		count=$((count+1))
		bowtie2 \
   		--threads 5 \
		-x tcongo_index \
		-1 /localdisk/data/BPSM/AY21/fastq/$End1 \
		-2 /localdisk/data/BPSM/AY21/fastq/$End2 \
		-S $(pwd)/bowtie_alignments/${Sample}_${Replicate}_${Time}_${Treatment}.sam 2> bowtie_outputs/${Sample}_${Replicate}_${Time}_${Treatment}.txt &
		echo -e -n "\rAligned $count of $info_file_lines sample paired-end reads..." 
	fi
done < "$info_file"
echo -e "\nFinished alignment of all sample reads to reference genome..."
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
                        rm -f /bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                elif [[ "$response" == "Y" ]]; then
                        rm -f /bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                fi
        elif [[ "$numeric_alignment" -lt "80" ]]; then
                echo -e "WARNING - Reads for sample $sample_name have poor alignment ($alignment%)"  
                read -p "Remove these reads from the analysis (y/n): " response
                if [[ "$response" == "y" ]]; then
                        rm -f /bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                elif [[ "$response" == "Y" ]]; then
                        rm -f /bowtie_alignments/${sample_name}.sam
                        echo -e "Removed ${sample_name}.sam from analysis"
                fi
        fi
done 	
