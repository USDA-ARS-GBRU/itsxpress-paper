# This repository contains the workflow used to analyze ITSxpress

## Authors
* Adam R. Rivers
* Kyle Weber

## Paper 

ITSxpress: software to rapidly trim internally transcribed spacer sequences with quality 
scores for marker gene analysis.
In prep.

## Setup

Create an Conda environment. For instructions on installing Anaconda or Miniconda see this page: 
https://conda.io/miniconda.html

```bash

# Create a new conda environment 
conda create --name itsxpresstestenv python=3.6
conda create -p /project/gbru_fy18_soybean_gardner/biopythontestenv/ python=3.6

# activate the new environment
source activate itsxpresstestenv 
source activate /project/gbru_fy18_soybean_gardner/biopythontestenv/

# Install itsxpress and ITSx into the new environment
conda install -c bioconda itsxpress=1.5.6 itsx=1.1b pandas

```
 
## Scripts

The workflow is broken into two parts The first script, `run1.sh` distributes tasks with the SLURM 
scheduler and creates the trimmed fastq's and timing data. Specifically it:

* merges reads and reates fasta files for ITSx
* Dereplicates fasta files to estimate the proportion of unique reads
* Creates a CSV file summarizing the number of unique reads with dedup.py
* submits the script its_samples.sh for the ITS1 and ITS2 regions to calculate the
 	speedup from using ITSxpress
* Submits its\_threads.sh' sbatch jobs for the its1  and its2 regions to understand 
 	how the program scales with more cores 


The second script, `run2.sh`, summarizes the data and creates graphs. specifically it:

* Creates CSV's summarizing the timing data for the sample and thread experiments
* Runs pairwise alignment on the ITSx and ITSxpress results summarizing the differences
* Creates the plots in the paper using itsxpress_plots.R


## Directory structure

```

.
|-- data
|   |-- its1
|   |   |-- r1
|	|	|-- r2
|	|	`-- readme.txt
|   |-- its1_derep
|	|-- its1_fasta
|	|-- its2
|   |   |-- r1
|	|	|-- r2
|	|	`-- readme.txt
|	|-- its2_derep
|	`-- its2_fasta
|--scripts
|   |-- run1.sh
|   |-- run2.sh
|   |-- derep.py
|   |-- test_samples.sh
|   |-- test_threads.sh
|   |-- compare_alignments.py
|   `-- itsxpress_plots.R
|-- output
`-- README.md

```