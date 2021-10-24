loop_dir=/localdisk/data/BPSM/AY21/fastq/
jobs=10
unset count
mkdir fastqc_output
all_files=$(ls /localdisk/data/BPSM/AY21/fastq/*fq.gz| wc -l)
(
for file in $loop_dir*; do
        ((i=i%jobs)); ((i++==0)) && wait
	if [[ "$file" == *".fq.gz" ]]; then
		fastqc $file -o fastqc_output --quiet --extract &
		count=$((count+1))
		echo -e -n "\rProcessed $count of $all_files reads with fastqc..."
	fi
done
)
echo -e "Read\tQuality Check\tStatus" > fastqc.warnings
for summary_file in fastqc_output/*/summary.txt; do
		awk -F'\t' '{OFS=FS};
		{
                if ($1 == "FAIL"|| $1 == "WARN")
                {print $3, $2, $1}
                }' $summary_file >> fastqc.warnings
done
(head -n 1 fastqc.warnings && tail -n +2 fastqc.warnings | sort -t$'\t' -k3) > fastqc.warnings.temp
mv fastqc.warnings.temp fastqc.warnings
num_warnings=$(cat fastqc.warnings|wc -l)

if [[ $num_warnings -gt 0 ]]; then
	echo -e "\n**********\nWARNING - quality check discovered $num_warnings potential issues with read files"
	echo -e "Details of issues have been written to fastqc.warnings\n**********"
	read -p "Continue with analysis? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	echo -e "Continuing..."
fi 
