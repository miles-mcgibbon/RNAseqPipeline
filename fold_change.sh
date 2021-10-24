
info_file=/localdisk/data/BPSM/AY21/fastq/100k.fqfiles
groups=$(tail -n +2 $info_file | cut -f2 | sort -u )
time_points=$(tail -n +2 $info_file | cut -f4 | sort -u )
treatments=$(tail -n +2 $info_file | cut -f5 | sort -u )
mkdir induced_vs_uninduced
IFS=$'\n'
for group in $groups; do
        for time_point in $time_points; do
		group_files=$(ls -d groupwise_counts/*| grep "${group}_$time_point")
		num_files=$(echo -e $group_files | awk -F'.tsv' '{print NF}')
		if [[ "$num_files" != "2" ]]; then
			for file in $group_files; do
				cat $file | rev | cut -f1 | rev > ${file}.means
			done
		fi 
	done
done
