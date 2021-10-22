
# calculate the mean for all samples
awk '{sum = 0; 
     for (i = 6; i <= NF; i++) sum += $i; 
     sum /= NF; print sum}' sample_counts/all_sample_counts.tsv > sample_means.tsv

# add the means as a column to the sample counts
paste sample_counts/all_sample_counts.tsv sample_means.tsv > fold_data.tsv 

# count the number of sample columns in the gene counts data
mean_col=$(awk '{ FS = "\t" } ; {print NF}' fold_data.tsv | tail -1)
declare -i start_data_index=6
end_data_index=$(($mean_col - 1))

num_cols="$mean_col"
# loop through sample columns and calculate fold change for each sample
for i in $(seq $start_data_index $end_data_index); do
        num_cols=$((num_cols+1))	
        echo -e "$num_cols"
	echo -e "$mean_col"
	echo -e "$i"
	awk -v data_col=$i -v fold_col=$num_cols -v mean_c=$mean_col 'BEGIN {FS="\t";OFS = "\t"};
	{
	if($data_col == 0||$mean_c == 0)
	{
	$fold_col = 0
	}
	else
	{
	$fold_col = ($data_col/$mean_c)
	}
	print $0}' fold_data.tsv > temp_fold_data.tsv && mv temp_fold_data.tsv fold_data.tsv
done

declare -a headers=("Count" "Count2" "TCIL" "Protein")
echo -n "TCA" > fold_data_with_headers.tsv
for header in "${headers[@]}"; do
        echo -e -n "\t$header" >> fold_data_with_headers.tsv
done
bowtie_sams="$(pwd)/bowtie_alignments/"
sample_files=()

for file in $bowtie_sams*; do
    	filename="$(basename $file)"
	filename="${filename//.sam/}"
	sample_files+=("$filename")
done
for file in "${sample_files[@]}"; do
	echo -e "$file"
        echo -e -n "\t$file" >> fold_data_with_headers.tsv
done
echo -e -n "\tMean" >> fold_data_with_headers.tsv
for file in "${sample_files[@]}"; do
        suffix="_fold_change_from_mean"
	echo -e "$file$suffix"
        echo -e -n "\t$file$suffix" >> fold_data_with_headers.tsv
done
 echo -e -n "\n" >> fold_data_with_headers.tsv
# read -n 1 -p "Input Selection:" "mainmenuinput"
cat fold_data.tsv >> fold_data_with_headers.tsv 

