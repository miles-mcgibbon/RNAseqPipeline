
# calculate the mean for all samples

# add the means as a column to the sample counts
bowtie_sams="$(pwd)/bowtie_alignments/"
sample_files=()

info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
groups=$(tail -n +2 $info_file | cut -f2 | sort -u )
time_points=$(tail -n +2 $info_file | cut -f4 | sort -u )
treatments=$(tail -n +2 $info_file | cut -f5 | sort -u )
echo -e "$time_points"
echo -e "$treatments"
IFS=$'\n'
for group in $groups; do
	for time_point in $time_points; do
		for treatment in $treatments; do
			echo -e "$group $time_point $treatment"
		done
	done
done

