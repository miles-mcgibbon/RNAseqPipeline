loop_dir=/localdisk/data/BPSM/AY21/fastq/
mkdir reads
for file in $loop_dir*; do
	if [[ "$file" == *".fq.gz" ]]; then 
		outfile="$(cut -d'/' -f7 <<<"$file")"
		# echo "$outfile"
		pigz  -dc "$file" > "reads/$outfile"
	fi
done
