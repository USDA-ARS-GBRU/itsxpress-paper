#!/bin/bash
#SBATCH --job-name=its_samples
#SBATCH --time=3:00:00
#SBATCH --array=1-15
#SBATCH -p short
#SBATCH -N 1
#SBATCH -n 40


source activate itsxpresstestenv

echo "Usage test_samples.sh [base its dir] [merged data directory] [output dir] [sampletype its1|its2]"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "My TMPDIR IS: " $TMPDIR

itsdir=$1
merged=$2
output=$3
sampletype=$4

farray=($itsdir/r1/*fastq.gz)
rarray=($itsdir/r2/*fastq.gz)

itsxarray=($merged/*.fasta)

finfile=${farray[$SLURM_ARRAY_TASK_ID - 1]}
rinfile=${rarray[$SLURM_ARRAY_TASK_ID - 1]}

itsxfile=${itsxarray[$SLURM_ARRAY_TASK_ID - 1]}

bname=$output/`basename $finfile _R1.fastq.gz`
logfile=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID".log

THREADS=4

outfile1=$output/itsxpress_"$sampletype"_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID".fastq.gz

echo $finfile
/usr/bin/time  -v itsxpress --fastq $finfile --fastq2 $rinfile --outfile $outfile1 --tempdir $TMPDIR \
  --region $sampletype --taxa Fungi --log $logfile --threads $THREADS --cluster_id 1.0
