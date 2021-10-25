#!/bin/bash

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

# define fastq.gz file location
loop_dir=/localdisk/data/BPSM/AY21/fastq/

# define threads and make output directory
jobs=$threads
unset count
mkdir fastqc_output

# loop through all the files and perform quality check with fastwc
all_files=$(ls /localdisk/data/BPSM/AY21/fastq/*fq.gz| wc -l)
(
for file in $loop_dir*; do
        ((i=i%jobs)); ((i++==0)) && wait
	if [[ "$file" == *".fq.gz" ]]; then
		fastqc $file -o fastqc_output --quiet --extract &
		count=$((count+1))
		echo -e -n "\rProcessing $count of $all_files reads with fastqc..."
	fi
done
)

# wait for multiprocessing to finish
sleep 30s

# create master file of warnings for the user sorted by severity
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

# notify user of any warnings and get input on whether to proceed or not
num_warnings=$(cat fastqc.warnings|wc -l)

if [[ $num_warnings -gt 0 ]]; then
	echo -e "\n**********\nWARNING - quality check discovered $num_warnings potential issues with read files"
	echo -e "Details of issues have been written to fastqc.warnings\n**********"
	read -p "Continue with analysis? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	echo -e "Continuing..."
fi 
