#!/bin/bash

# run1.sh: a script to submit jobs to slurm scheduler for processing. \
# Once jobs are complete run run2.sh to generate analysis plots.

# load software and dependencies from bioconda
## Requires miniconda or anaconda see install instructions here: https://conda.io/miniconda.html

#conda create --name itsxpresstestenv python=3.6
# source activate itsxpresstestenv
# conda install -c bioconda itsxpress=1.5.6 itsx=1.1b

## global variables:

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
ITS1_derep_report=../output/its1_derep_report.txt
ITS2_derep_report=../output/its2_derep_report.txt
ITS1_derep_csv=../output/its1_derep_csv.txt
ITS2_derep_csv=../output/its2_derep_csv.txt
# Set the number of experimental reps
reps=5


#source activate itsxpresstestenv
source activate /project/gbru_fy18_soybean_gardner/biopythontestenv/

## Generate fasta files from fastq files
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
  



## Dereplicate the paired end merged fasta files saving merging data

for file in $ITS1_merged/*
  do
  	bname=`basename $file`
    vsearch  --derep_fulllength $file --output $ITS1_derep/$bname --strand both --threads 2  2>> $ITS1_derep_report
  done

for file in $ITS2_merged/*
  do
    bname=`basename $file`
    vsearch  --derep_fulllength $file --output $ITS2_derep/$bname --strand both --threads 2 2>> $ITS2_derep_report
  done
  
# Create a tabular report of the dereplication process
python derep.py -i $ITS1_derep_report -o $ITS1_derep_csv 
python derep.py -i $ITS2_derep_report -o $ITS2_derep_csv

## Slurm Job submission

# submit Array job to test timing of different samples using itsxress and itsx 
seq $reps | xargs -Iz sbatch --output=../output/its1_samples_%A_%a.out --error=../output/its1_samples_%A_%a.err test_samples.sh $ITS1 $ITS1_merged ../output/ ITS1
seq $reps | xargs -Iz sbatch --output=../output/its2_samples_%A_%a.out --error=../output/its2_samples_%A_%a.err test_samples.sh $ITS2 $ITS2_merged ../output/ ITS2


#SBATCH --output=its_threads_%A_%a.out
#SBATCH --error=its1-big-threads_%A_%a.err

# submit Array job to test timing of itsxress and itsx with different numbers of threads for the largest sample

seq $reps | xargs -Iz sbatch --output=../output/its1_threads_%A_%a.out  --error=../output/its1-threads_%A_%a.err test_threads.sh $ITS1_merged/4774-4-MSITS2a.fasta  $ITS1/r1/4774-4-MSITS2a_R1.fastq.gz $ITS1/r2/4774-4-MSITS2a_R2.fastq.gz ITS1
seq $reps | xargs -Iz sbatch --output=../output/its2_threads_%A_%a.out  --error=../output/its2-threads_%A_%a.err test_threads.sh $ITS2_merged/4774-13-MSITS3.fasta $ITS2/r1/4774-4-MSITS3_R1.fastq.gz $ITS2/r2/4774-4-MSITS3_R2.fastq.gz ITS2
