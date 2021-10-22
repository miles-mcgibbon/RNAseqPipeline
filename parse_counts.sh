declare -a headers=("Count" "Count2" "TCIL" "Protein")
echo -e -n "TCA" > counts_with_headers.tsv
for header in "${headers[@]}"; do
	echo -e	-n "\t$header" >> counts_with_headers.tsv
done
bowtie_sams="$(pwd)/bowtie_alignments/"
for file in $bowtie_sams*; do
	filename="$(basename $file)"
	echo -e	"$filename"
	echo -e -n "\t$filename" >> counts_with_headers.tsv
done	 
cat counts.txt >> counts_with_headers.tsv
