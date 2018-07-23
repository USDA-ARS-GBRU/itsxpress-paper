# This repository contains the workflow used to analyze ITSxpress in the paper

## Software Authors
* Adam R. Rivers
* Kyle Weber

## Paper

Rivers, A.R., Weber. K.C., Gardner T. G., Liu, S., and Armstrong, S.D. 2018.
ITSxpress: software to rapidly trim internally transcribed spacer sequences
with quality scores for marker gene analysis. F1000 Research.
In prep.

## Setup

* Create an Conda environment. For instructions on installing Anaconda or Miniconda see this page:
https://conda.io/miniconda.html
* The workflow is designed to be run on a HPC with a SLURM scheduler


```bash

# Create a new conda test environment
conda create --name itsxpresstestenv python=3.6 pandas

# activate the new environment
source activate itsxpresstestenv

# Install itsxpress and ITSx into the new environment
conda install -c bioconda itsxpress=1.6.1 itsx=1.1b

```

## Scripts

The workflow is broken into two parts. The first script, `run1.sh` distributes
tasks with the SLURM scheduler and creates the trimmed fastq's and timing data.
Specifically it:

* merges reads and creates fasta files for ITSx
* De-replicates fasta files to estimate the proportion of unique reads
* Creates a CSV file summarizing the number of unique reads with dedup.py
* Submits the script `its_samples.sh` for the ITS1 and ITS2 regions to calculate the
 	speedup from using ITSxpress
* Submits `its_threads.sh` sbatch jobs for the its1 and its2 regions to understand
 	how the program scales with more cores
* Submits the script `its_100_samples.sh` to compare alignment similarity at 100% identity clustering


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
|	  |	  |-- r2
|	  |  	`-- readme.txt
|   |-- its1_derep
|   |-- its2_merged
|	  |-- its1_fasta
|	  |-- its2
|   |   |-- r1
|  	|	  |-- r2
|  	|	  `-- readme.txt
| 	|-- its2_derep
|   |-- its2_merged
|	  `-- its2_fasta
|--scripts
|   |-- run1.sh
|   |-- run2.sh
|   |-- derep.py
|   |-- test_samples.sh
|   |-- test_100_samples.sh
|   |-- test_threads.sh
|   |-- compare_alignments.py
|   |-- parsetiming.py
|   `-- plots.R
|-- output
|-- dedup_out
|-- analysis
`-- README.md

```
