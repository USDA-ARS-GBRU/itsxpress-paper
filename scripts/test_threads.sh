#!/bin/bash
#SBATCH --job-name=its_threads
#SBATCH --time=08:00:00
#SBATCH --array=1-6
#SBATCH -p short
#SBATCH -N 1
#SBATCH -n 40


#source activate itsxpresstestenv
source activate /project/gbru_fy18_soybean_gardner/biopythontestenv/

echo "Usage test_threads.sh [merged file] [forward file] [reverse file] [output dir] [sampletype its1|its2]"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "My TMPDIR IS: " $TMPDIR

threadarray=(1 4 8 16 30 40)

itsxfile=$1
finfile=$2
rinfile=$3
output=$4
sampletype=$5

THREADS=${threadarray[$SLURM_ARRAY_TASK_ID - 1]}

bname=`basename $finfile _R1.fastq.gz`

outfile1=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID".fastq.gz
outfile2=$output/itsx_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"
logfile=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID".log

echo "Threads used: " $THREADS
echo "itsxpress"
/usr/bin/time  -v itsxpress --fastq $finfile --fastq2 $rinfile --outfile $outfile1 --tempdir $TMPDIR \
  --region $sampletype --taxa Fungi --log logfile --threads $THREADS 
rm $outfile1
rm $logfile

echo "itsx"
/usr/bin/time  -v ITSx -i  $itsxfile -o $outfile2 --cpu $THREADS --heuristics --save_regions $sampletype -t f
rm $outfile2*
