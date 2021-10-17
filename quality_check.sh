loop_dir=/localdisk/data/BPSM/AY21/fastq/
jobs=5
mkdir fastqc_output
(
for file in $loop_dir*; do
        ((i=i%jobs)); ((i++==0)) && wait
	if [[ "$file" == *".fq.gz" ]]; then
		echo -e "$file"
		fastqc $file -o fastqc_output --quiet &
	fi
done
)
