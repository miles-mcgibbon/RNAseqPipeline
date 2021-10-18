#!/bin/bash
echo -e "Creating bowtie2-indexed reference genome..."
ref_genome=/localdisk/data/BPSM/AY21/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz
bowtie2-build "$ref_genome" tcongo_index --threads 5
echo -e "Reference genome indexed!"
