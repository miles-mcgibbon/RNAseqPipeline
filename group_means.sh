
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
mkdir groupwise_counts
for folder in $(pwd)/group_files/*; do
	group=$(basename $folder)
	echo -e "$group"
	unset files_in_folder
	for file in $folder/*; do
		filename=$(basename $file)
		filename="${filename//.tsv/_summary.tsv}"
		IFS=$'\t'
		if [[ "$file" == *"_1_"* ]];then
			cat $file | cut -f4,5,6 > "$folder/${filename}"
		else
			cat $file | cut -f6 > "$folder/${filename}"
			
		fi
		files_in_folder=$((files_in_folder+1))
	done		
	#echo -e "$files_in_folder"
	ls -d group_files/$group/* | grep summary | xargs paste >> group_files/${group}_final.tsv
	#echo -e -n "Gene\tProtein\t" >> groupwise_counts/${group}.tsv
	#for i in $(seq 1 $files_in_folder); do
	#	echo -e "$i"
 	#	echo -e "$files_in_folder"
	#	if [[ "$i" == "$files_in_folder" ]]; then
	#		echo -e "${group}_replicant_$i" >> groupwise_counts/${group}.tsv
	#	else
	#		echo -e -n "${group}_replicant_$i\t" >> groupwise_counts/${group}.tsv
	#	fi
	#done
	cat group_files/${group}_final.tsv >> groupwise_counts/${group}.tsv
done
rm -r -f group_files/

for file in groupwise_counts/*; do
	awk -F'\t' '{OFS=FS} {sum=0;for (i=3; i<=NF; i++) sum += $i;sum /= (NF-2); print $0,sum}' $file > ${file}.means && mv ${file}.means $file
	echo -e "$file"
done 
