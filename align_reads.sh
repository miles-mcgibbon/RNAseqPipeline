unset IFS
IFS=$'\t'
mkdir bowtie_alignments
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
while read ID Sample Replicate Time Treatment End1 End2; do
	if [[ "$Sample" == "Sample" ]]; then
		:
	else
		echo -e "$ID"
		bowtie2 --quiet \
   		--threads 5 \
		-x tcongo_index \
		-1 /localdisk/data/BPSM/AY21/fastq/$End1 \
		-2 /localdisk/data/BPSM/AY21/fastq/$End2 \
		-S $(pwd)/bowtie_alignments/$ID$Sample$Replicate$Time.sam 
	fi
done < "$info_file"	
