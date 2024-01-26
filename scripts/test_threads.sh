#!/bin/bash
#SBATCH --job-name=its_threads
#SBATCH --time=12:00:00
#SBATCH -A gbru_fy21_tomato_ralstonia
#SBATCH -p atlas
#SBATCH --array=1-6
#SBATCH -N 1
#SBATCH -n 40


module load miniconda
conda activate itsxpressV2

echo "Usage test_threads.sh [merged file] [forward file] [reverse file] [output dir] [sampletype its1|its2]"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "My TMPDIR IS: " $TMPDIR

threadarray=(1 4 8 16 30 40)

itsxfile=$1
finfile=$2
rinfile=$3
output=$4
sampletype=$5
echo $itsxfile
echo $finfile
echo $rinfile
echo $output
echo $sampletype

THREADS=${threadarray[$SLURM_ARRAY_TASK_ID - 1]}
echo $THREADS

bname=`basename $finfile _1.fastq.gz`

outfile1=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"_V2.fastq.gz
outfile2=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"_V1.fastq.gz

outfile3=$output/itsx_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"
logfile1=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"_V2.log
logfile2=$output/itsxpress_"$SLURM_JOB_ID"_"$SLURM_ARRAY_TASK_ID"_V1.log


echo "Threads used: " $THREADS
echo "itsxpressV2"
/usr/bin/time  -v itsxpress --fastq $finfile --fastq2 $rinfile --outfile $outfile1 --tempdir $TMPDIR \
  --region $sampletype --taxa Fungi --log $logfile1 --threads $THREADS --cluster_id 0.995

echo "itsxpressV1"
source activate itsxpressV1

/usr/bin/time  -v itsxpress --fastq $finfile --fastq2 $rinfile --outfile $outfile2 --tempdir $TMPDIR \
  --region $sampletype --taxa Fungi --log $logfile2 --threads $THREADS --cluster_id 0.995

echo "itsx"
/usr/bin/time  -v ITSx -i  $itsxfile -o $outfile3 --cpu $THREADS --heuristics --save_regions $sampletype -t f --complement F
