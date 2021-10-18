#!/bin/bash
ref_genome=/localdisk/data/BPSM/AY21/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz
bowtie2-build "$ref_genome" tcongo_index --threads 5
