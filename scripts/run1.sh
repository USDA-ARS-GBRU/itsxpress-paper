#!/bin/bash

# run1.sh: a script to submit jobs to slurm scheduler for processing. \
# Once jobs are complete run run2.sh to generate analysis plots.

# load software and dependencies from bioconda
## Requires miniconda or anaconda see install instructions here: https://conda.io/miniconda.html

#conda create --name itsxpresstestenv python=3.6
# source activate itsxpresstestenv
# conda install -c bioconda itsxpress=1.6.1 itsx=1.1b

## global variables:
#Output directry for Samples threads and fraction unique experiments
OUTPUT=../output1
# Output directory for samples dereplicated at 100% identity by itsxpress
derepout= ../derep_out
analysis= ../analysis
# Directory for ITS1 fastq files; 15 files in both the r1 and r2 subdirectories
ITS1=../data/its1
# Directory for ITS2 fastq files;; 15 files in both the r1 and r2 subdirectories
ITS2=../data/its2
# Directory for ITS1 paired end merged fasta files
ITS1_merged=../data/its1_merged
# Directory for ITS2 paired end merged fasta files
ITS2_merged=../data/its2_merged
# Directory for dereplicated, merged ITS1 fasta files
ITS1_derep=../data/its1_derep
# Directory for dereplicated merged ITS1 fasta files
ITS2_derep=../data/its2_derep
# files for summarizing vsearch data
ITS1_derep_report=$analysis/its1_derep_report.txt
ITS2_derep_report=$analysis/its2_derep_report.txt
ITS1_derep_csv=$analysis/its1_derep.csv
ITS2_derep_csv=$analysis/its2_derep.csv
# Set the number of experimental reps
reps=5


source activate itsxpresstestenv


# Generate fasta files from fastq files
for file in $ITS1/r1/*
  do
  	bname=`basename $file _R1.fastq.gz`
    bbmerge.sh in=$file in2=$ITS1/r2/"$bname"_R2.fastq.gz out=$ITS1_merged/"$bname".fasta
  done


for file in $ITS2/r1/*
  do
  	bname=`basename $file _R1.fastq.gz`
    bbmerge.sh in=$file in2=$ITS2/r2/"$bname"_R2.fastq.gz out=$ITS2_merged/"$bname".fasta
  done



## Cluster the merged fasta files at 99.5% identity as specified in the --cluster_id flag
echo "Details about vsearch merging are in the files $ITS1_derep_report and $ITS2_derep_report"

for file in $ITS1_merged/*
  do
  	bname=`basename $file`
    vsearch  --cluster_size $file --centroids $ITS1_derep/$bname --strand both --id 0.995 --threads 8  2>> $ITS1_derep_report
  done

for file in $ITS2_merged/*
  do
    bname=`basename $file`
    vsearch  --cluster_size $file --centroids $ITS2_derep/$bname --strand both --id 0.995 --threads 8 2>> $ITS2_derep_report
  done

# Create a tabular report of the dereplication process
python derep.py -i $ITS1_derep_report -t cluster -o $ITS1_derep_csv
python derep.py -i $ITS2_derep_report -t cluster -o $ITS2_derep_csv

## Slurm Job submission

# submit Array job to test timing of different samples using itsxress and itsx
for run in {1..$reps}
do
  sbatch --output=$OUTPUT/its1_samples_%A_%a.out --error=$OUTPUT/its1_samples_%A_%a.err test_samples.sh $ITS1 $ITS1_merged $OUTPUT ITS1
  sbatch --output=$OUTPUT/its2_samples_%A_%a.out --error=$OUTPUT/its2_samples_%A_%a.err test_samples.sh $ITS2 $ITS2_merged $OUTPUT ITS2
done

#SBATCH --output=its_threads_%A_%a.out
#SBATCH --error=its1-big-threads_%A_%a.err

# submit Array job to test timing of itsxress and itsx with different numbers of threads for the largest sample

for run in {1..$reps}
do
	sbatch --output=$OUTPUT/its1_threads_%A_%a.out  --error=$OUTPUT/its1-threads_%A_%a.err test_threads.sh $ITS1_merged/4774-4-MSITS2a.fasta $ITS1/r1/4774-4-MSITS2a_R1.fastq.gz $ITS1/r2/4774-4-MSITS2a_R2.fastq.gz $OUTPUT ITS1
	sbatch --output=$OUTPUTits2_threads_%A_%a.out  --error=$OUTPUT/its2-threads_%A_%a.err test_threads.sh $ITS2_merged/4774-13-MSITS3.fasta $ITS2/r1/4774-4-MSITS3_R1.fastq.gz $ITS2/r2/4774-4-MSITS3_R2.fastq.gz $OUTPUT ITS2
done

# submit an arrayjob to run each sample once with itsxpress only at 100% identity
sbatch --output=$derepout/its1_samples_%A_%a.out --error=$derepout/its1_samples_%A_%a.err test_100_samples.sh $ITS1 $ITS1_merged $derepout ITS1
sbatch --output=$derepout/its2_samples_%A_%a.out --error=$derepout/its2_samples_%A_%a.err test_100_samples.sh $ITS2 $ITS2_merged $derepout ITS2
