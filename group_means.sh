#!/bin/bash
echo "Calculating groupwise changes..."

# get information on groups, time points and treatments from info file so
# code will work with any future sample input
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
groups=$(tail -n +2 $info_file | cut -f2 | sort -u )
time_points=$(tail -n +2 $info_file | cut -f4 | sort -u )
treatments=$(tail -n +2 $info_file | cut -f5 | sort -u )

# make temporary output directory
mkdir group_files

# loop over the group, time points and treatments and copy files for all relevant replicants to individual temporary directory
IFS=$'\n'
for group in $groups; do
	for time_point in $time_points; do
		for treatment in $treatments; do
			# make temporary group time treatment specific directory
			mkdir group_files/${group}_${time_point}_${treatment}
			
			# copy relevant gene counts files to specific directory
			ls -d gene_counts/* | grep gene_counts/${group}_._${time_point}_${treatment} | xargs cp -t group_files/${group}_${time_point}_${treatment}/ 2>/dev/null || : 
			
			# remove directory if it is empty and no relevant files found		
			rmdir group_files/${group}_${time_point}_${treatment} 2>/dev/null || :
		
		done	
	done
done

# make output directory for groupwise gene counts
mkdir groupwise_counts

# for each group, make new file containing gene name, protein name, and all columns from replicant gene counts
# this code will work with any number of replicants in case more are added, or the user excludes some
# based on fastqc output or poor alignment
for folder in $(pwd)/group_files/*; do
	group=$(basename $folder)
	unset files_in_folder
	for file in $folder/*; do
		filename=$(basename $file)
		filename="${filename//.tsv/_summary.tsv}"
		IFS=$'\t'
		if [[ "$file" == *"_1_"* ]];then
			# if the file is the first replicant, add gene and protein columns and gene counts to temporary summary file
			cat $file | cut -f4,5,6 > "$folder/${filename}"
		else
			# otherwise just add gene counts to temporary summary file
			cat $file | cut -f6 > "$folder/${filename}"
			
		fi
		files_in_folder=$((files_in_folder+1))
	done
	# combine columns from temporary summary files and output to permanent direcroty
	ls -d group_files/$group/* | grep summary | xargs paste >> group_files/${group}_final.tsv
	cat group_files/${group}_final.tsv >> groupwise_counts/${group}.tsv
done

# remove temporary directory
rm -r -f group_files/

# calculate the mean gene count for each group 
# this code also works for any number of replicants
# mean starts at column three and goes to final column
for file in groupwise_counts/*; do
	awk -F'\t' '{OFS=FS} {sum=0;for (i=3; i<=NF; i++) sum += $i;sum /= (NF-2); print $0,sum}' $file > ${file}.means && mv ${file}.means $file
	echo -e "$file"
done 
