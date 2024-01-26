#!/bin/bash

# run1.sh: a script to submit jobs to slurm scheduler for processing. \
# Once jobs are complete run run2.sh to generate analysis plots.

# load software and dependencies from bioconda
## Requires miniconda or anaconda see install instructions here: https://conda.io/miniconda.html

# conda create --name itsxpressV2 python=3.8
# source activate itsxpressV2
# conda install -c bioconda itsxpress=2.0.1 itsx=1.1.3
# conda create --name itsxpressV1 python=3.8
# source activate itsxpressV1
# conda install -c bioconda itsxpress=1.8.1 itsx=1.1.3

## global variables:
#Output directry for Samples threads and fraction unique experiments
OUTPUT=../output
# Output directory for samples dereplicated at 100% identity by itsxpress
derepout=../derep_out
analysis=../analysis
# Directory for ITS1 fastq files; 15 files in both the r1 and r2 subdirectories
ITS1=../data/ITS1
# Directory for ITS2 fastq files;; 15 files in both the r1 and r2 subdirectories
ITS2=../data/ITS2
# Directory for ITS1 paired end merged fasta files
ITS1_merged=../data/ITS1_merged
# Directory for ITS2 paired end merged fasta files
ITS2_merged=../data/ITS2_merged
# Directory for dereplicated, merged ITS1 fasta files
ITS1_derep=../data/ITS1_derep
# Directory for dereplicated merged ITS1 fasta files
ITS2_derep=../data/ITS2_derep
# files for summarizing vsearch data
ITS1_derep_report=$analysis/its1_derep_report.txt
ITS2_derep_report=$analysis/its2_derep_report.txt
ITS1_derep_csv=$analysis/its1_derep.csv
ITS2_derep_csv=$analysis/its2_derep.csv
# Set the number of experimental reps
reps=5


module load miniconda
conda activate itsxpressV2

for file in $ITS1/r1/*
 do
 	bname=`basename $file _1.fastq.gz`
   vsearch --fastq_mergepairs $file --reverse $ITS1/r2/"$bname"_2.fastq.gz  --fastaout $ITS1_merged/"$bname".fasta --fastq_maxdiffs 40 --fastq_maxee 2 --fastq_allowmergestagger
 done


for file in $ITS2/r1/*
  do
  	bname=`basename $file _1.fastq.gz`
    vsearch --fastq_mergepairs $file --reverse $ITS2/r2/"$bname"_2.fastq.gz  --fastaout $ITS2_merged/"$bname".fasta --fastq_maxdiffs 40 --fastq_maxee 2 --fastq_allowmergestagger
  done



# ## Cluster the merged fasta files at 99.5% identity as specified in the --cluster_id flag
echo "Details about vsearch merging are in the files $ITS1_derep_report and $ITS2_derep_report"

for file in ../data/ITS1_merged/*
 do
 	bname=`basename $file`
   vsearch  --cluster_size $file --centroids ../data/ITS1_derep/$bname --strand both --id 0.995 --threads 40  2>> ../analysis/ITS1_derep_report.txt
 done

for file in ../data/ITS2_merged/*
  do
    bname=`basename $file`
    vsearch  --cluster_size $file --centroids ../data/ITS2_derep/$bname --strand both --id 0.995 --threads 40 2>> ../analysis/ITS2_derep_report.txt
  done

#Create a tabular report of the dereplication process

python3 derep.py -i ./analysis/ITS1_derep_report.txt -t cluster -o ./analysis/its1_derep.csv
python3 derep.py -i ./analysis/ITS2_derep_report.txt -t cluster -o ./analysis/its2_derep.csv

# Slurm Job submission

# # submit Array job to test timing of itsxress and itsx with different numbers of threads for the largest sample
# 
for run in {1..5}; do
  sbatch --output=$OUTPUT/its1_threads_%A_%a.out  --error=$OUTPUT/its1-threads_%A_%a.err test_threads.sh $ITS1_merged/SRR10041227_ITS_amplicon_seqs_rumen_fluid_of_dairy_cows.fasta $ITS1/r1/SRR10041227_ITS_amplicon_seqs_rumen_fluid_of_dairy_cows_1.fastq.gz $ITS1/r2/SRR10041227_ITS_amplicon_seqs_rumen_fluid_of_dairy_cows_2.fastq.gz $OUTPUT ITS1
  sbatch --output=$OUTPUT/its2_threads_%A_%a.out  --error=$OUTPUT/its2-threads_%A_%a.err test_threads.sh $ITS2_merged/SRR19882410_META-seq_of_Salar_de_Huasco_microbial_mat.fasta $ITS2/r1/SRR19882410_META-seq_of_Salar_de_Huasco_microbial_mat_1.fastq.gz $ITS2/r2/SRR19882410_META-seq_of_Salar_de_Huasco_microbial_mat_2.fastq.gz $OUTPUT ITS2
done
# 
