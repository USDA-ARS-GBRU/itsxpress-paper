#!/bin/bash

# run2.sh: a script to process files and log files fun with slurm


# Parse the log files from the samples and threads experiments
./parsetimeing.py --indir ../output --outfile ../analysis/timingdata.csv

# User input is required here. Select jobids from one of the 5 runs
itsx1jobid =
itsx12obid =
itsxpress1jobid =
itsxpress2jobid =

# Concatenate files for comparison
cat ../output/itsx_$itsx1jobid*.ITS1.fasta > ../output/itsx_all.ITS1.fasta
cat ../output/itsx_$itsx2jobid*.ITS2.fasta > ../output/itsx_all.ITS2.fasta
zcat ../ouinput/itsxpress_ITS1_$itsxpress1jobid*.fastq.gz > ../output/itsxpress_all.ITS1.fastq
zcat ../ouinput/itsxpress_ITS2_$itsxpress1jobid*.fastq.gz > ../output/itsxpress_all.ITS2.fastq
zcat ../derep_out/itsxpress_ITS1_*.fastq.gz > ../derep_out/itsxpress_all.ITS1.fastq
zcat ../derep_out/itsxpress_ITS2_*.fastq.gz > ../derep_out/itsxpress_all.ITS2.fastq

# Compare alignments for itsx and ITSXpress at 99.5% indentity
./compare_alignments ../output/itsx_all.ITS1.fasta ../output/itsxpress_all.ITS1.fastq '|F\ITS1' > ../analysis/ca1_its1.txt
./compare_alignments ../output/itsx_all.ITS2.fasta ../output/itsxpress_all.ITS2.fastq '|F\ITS2' > ../analysis/ca1_its2.txt

# Compare alignments for itsx and ITSXpress at 100% indentity
./compare_alignments ../output/itsx_all.ITS1.fasta ../derep_out/itsxpress_all.ITS1.fastq '|F\ITS1' > ../analysis/ca2_its1.txt
./compare_alignments ../output/itsx_all.ITS2.fasta ../derep_out/itsxpress_all.ITS2.fastq '|F\ITS2' > ../analysis/ca2_its2.txt

# Create the plots and the HDI summary data on speedups
Rscript plots.R > ../analysis/hdisummary.txt
