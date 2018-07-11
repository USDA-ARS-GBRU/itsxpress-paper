#!/bin/bash

# run2.sh: a script to process files and log files fun with slurm 

# Summarize Sample timing data
# Region, sample ,rep ,program, time

for file in ../output/its?_sample.err
do
  grep "Elapsed (wall clock)" file | cut -d ' ' -f 8 >
done

# summarize thread timing data
# Region, threads, rep, program, time
