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

echo -e "Creating bowtie2-indexed reference genome..."

# define location of reference genome fasta file and build indexed reference genome
ref_genome=/localdisk/data/BPSM/AY21/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz
bowtie2-build "$ref_genome" tcongo_index --threads $threads --quiet
echo -e "Reference genome indexed..."
