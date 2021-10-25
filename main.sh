#!/bin/bash

while getopts t: flag
do
    case "${flag}" in
        t) threads=${OPTARG};;
    esac
done

re='^[0-9]+$'
if ! [[ $threads =~ $re ]] ; then
        threads="1"
fi
./quality_check.sh -t $threads && ./create_bowtie_database.sh -t $threads && ./align_reads.sh  -t $threads && ./convert_to_bam.sh && ./group_means.sh && ./fold_change.sh
