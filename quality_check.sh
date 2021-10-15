loop_dir=/localdisk/data/BPSM/AY21/fastq/
mkdir fastqc_output
for file in $loop_dir*; do
	if [[ "$file" == *".fq.gz" ]]; then
		echo -e "$file"
		fastqc $file -o fastqc_output --quiet
	fi
done
