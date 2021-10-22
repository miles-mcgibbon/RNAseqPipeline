
# calculate the mean for all samples

# add the means as a column to the sample counts
bowtie_sams="$(pwd)/bowtie_alignments/"
sample_files=()

info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
groups=$(tail -n +2 $info_file | cut -f2 | sort -u )
time_points=$(tail -n +2 $info_file | cut -f4 | sort -u )
treatments=$(tail -n +2 $info_file | cut -f5 | sort -u )
mkdir group_files
IFS=$'\n'
for group in $groups; do
	for time_point in $time_points; do
		for treatment in $treatments; do
			mkdir group_files/${group}_${time_point}_${treatment}
			ls -d gene_counts/* | grep gene_counts/${group}_._${time_point}_${treatment} | xargs cp -t group_files/${group}_${time_point}_${treatment}/ 2>/dev/null || : 
			rmdir group_files/${group}_${time_point}_${treatment} 2>/dev/null || :
		done	
	done
done

for folder in $(pwd)/group_files/*; do
	group=$(basename $folder)
	echo -e "$group"
	for file in $folder/*; do
		filename=$(basename $file)
		filename="${filename//.tsv/_summary.tsv}"
		IFS=$'\t'
		if [[ "$file" == *"_1_"* ]];then
			cat $file | cut -f4,5,6 > "$folder/${filename}"
		else
			cat $file | cut -f6 > "$folder/${filename}"
			
		fi
	ls -d group_files/$group/* | grep summary | xargs paste >> "${group}_final.tsv" 
	done	
	
done
