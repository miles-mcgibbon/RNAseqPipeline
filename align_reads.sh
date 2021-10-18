unset IFS
IFS=$'\t'
mkdir bowtie_alignments
unset count
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
info_file_lines=$(cat $info_file | grep 100k | wc -l)
while read ID Sample Replicate Time Treatment End1 End2; do
	if [[ "$Sample" == "Sample" ]]; then
		:
	else
		count=$((count+1))
		echo -e "$ID"
		bowtie2 --quiet \
   		--threads 5 \
		-x tcongo_index \
		-1 /localdisk/data/BPSM/AY21/fastq/$End1 \
		-2 /localdisk/data/BPSM/AY21/fastq/$End2 \
		-S $(pwd)/bowtie_alignments/$ID$Sample$Replicate$Time.sam
		echo -e -n "\rAligned $count of $info_file_lines sample \
                paired-end reads..." 
	fi
done < "$info_file"
echo -e "\nFinished alignment of all sample reads to reference genome!"	
