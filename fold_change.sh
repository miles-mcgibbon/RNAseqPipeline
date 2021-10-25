#!/bin/bash

# get information on groups again from info file
# this code will work if new groups and timepoints are added
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
groups=$(tail -n +2 $info_file | cut -f2 | sort -u )
time_points=$(tail -n +2 $info_file | cut -f4 | sort -u )
treatments=$(tail -n +2 $info_file | cut -f5 | sort -u )

# make final output directory for fold change data
mkdir fold_changes
IFS=$'\n'

# loop through the groups to combine mean gene count columns in one file for each group (Induced vs Uninduced)
for group in $groups; do
        for time_point in $time_points; do
		group_files=$(ls -d groupwise_counts/*| grep "${group}_$time_point")
		num_files=$(echo -e $group_files | awk -F'.tsv' '{print NF}')
                count=0
		if [[ "$num_files" != "2" ]]; then
			for file in $group_files; do
				if [[ "$count" == "0" ]]; then
					echo -e "Gene_Name\tProtein" > ${group}_${time_point}.id_cols
			        	cut $file -d$'\t' -f1,2 >> ${group}_${time_point}.id_cols
					means_col=$(cat $file | rev | cut -f1 | rev)
					sample_name="${file//.tsv/_mean}"
					sample_name="${sample_name//groupwise_counts\//}"
					echo -e "$sample_name\n$means_col" > ${file}.means
					paste ${group}_${time_point}.id_cols ${file}.means > ${group}_${time_point}_fold_change.tsv.temp
					mv ${group}_${time_point}_fold_change.tsv.temp ${group}_${time_point}_fold_change.tsv
					count=$((count+1))
				else
					means_col=$(cat $file | rev | cut -f1 | rev)
                                        sample_name="${file//.tsv/_mean}"
					sample_name="${sample_name//groupwise_counts\//}"
                                        echo -e "$sample_name\n$means_col" > ${file}.means
                                        paste ${group}_${time_point}_fold_change.tsv ${file}.means > ${group}_${time_point}_fold_change.tsv.temp
                                        mv ${group}_${time_point}_fold_change.tsv.temp fold_changes/${group}_${time_point}_fold_change.tsv
					rm -f ${group}_${time_point}_fold_change.tsv
				fi
			done
		fi 
	done
done

rm -f *.id_cols

# calculate fold change by dividing induced mean count by uninduced mean count
for file in fold_changes/*; do
	awk -F'\t' '{OFS=FS};
	{
	if(NR==1)
	{$5 = "Expression Level Change (Induced/Uninduced)"}
	else if ($4 == 0 && $3 != 0)
	{$5 = "Inf"}
	else if ($4 == 0 && $3 == 0)
	{$5 = 0}
	else
	{$5 = $3/$4}
	print $0}' $file > ${file}.temp

	# sort in decreasing order of fold change
	(head -n 1 ${file}.temp && tail -n +2 ${file}.temp | sort -t$'\t' -k5 -nr) > $file
	rm -f ${file}.temp
	
done
