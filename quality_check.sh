loop_dir=/localdisk/data/BPSM/AY21/fastq/
jobs=5
unset count
mkdir fastqc_output
all_files=$(ls /localdisk/data/BPSM/AY21/fastq/*fq.gz| wc -l)
(
for file in $loop_dir*; do
        ((i=i%jobs)); ((i++==0)) && wait
	if [[ "$file" == *".fq.gz" ]]; then
		fastqc $file -o fastqc_output --quiet &
		count=$((count+1))
		echo -e -n "\rProcessed $count of $all_files reads with fastqc..."
	fi
done
)
echo -e "\nFinished quality check of paired-end reads..."
