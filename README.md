[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10685007.svg)](https://doi.org/10.5281/zenodo.10685007)

# This repository contains the workflow used to analyze ITSxpress in the paper

## Software Authors
* Adam R. Rivers
* Sveinn Einarsson

## Paper

Version 2 - ITSxpress: Software to rapidly trim internally transcribed spacer sequences with quality scores for marker gene analysis. Microbiology Spectrum. In prep.

## Setup

* Create an Conda environment. For instructions on installing Anaconda or Miniconda see this page:
https://conda.io/miniconda.html
* The workflow is designed to be run on a HPC with a SLURM scheduler
* We recommend using mamba to install the software in the conda environment


```bash

# Create a new conda test environment
mamba create --name itsxpressv2 python=3.8 
mamba activate itsxpressv2
mamba install -c bioconda itsxpress=2.0.1 itsx=1.1.3

mamba create --name itsxpressv1 python=3.8 
mamba activate itsxpressv1
mamba install -c bioconda itsxpress=1.8.1 itsx=1.1.3


```

## Scripts

The workflow is as follows:
The first script, `run1.sh` distributes tasks with the SLURM scheduler and creates the trimmed fastq's and timing data for 
comparison between ITSxpressV2, ITSxpressV1 and ITSx.
Specifically it:

* merges reads and creates fasta files for ITSx
* De-replicates fasta files to estimate the proportion of unique reads
* Creates a CSV file summarizing the number of unique reads with dedup.py
* Submits `its_threads.sh` sbatch jobs for the its1 and its2 regions to understand
 	how the program scales with more cores

Next, we submit individual jobs to itsxpressV2 to trim reads with clustering set to 100% identity. This is done to compare alignment scores between ITSxpressV2 and ITSx.

```bash
itsxpress --fastq ../data/its1/r1/SRR10041227_ITS_amplicon_seqs_rumen_fluid_of_dairy_cows_1.fastq.gz --fastq2 ../data/its1/r2/SRR10041227_ITS_amplicon_seqs_rumen_fluid_of_dairy_cows_2.fastq.gz --outfile outITS1.fastq --tempdir ./ --region ITS1 --taxa Fungi --log logfileITS1.txt --threads 16 --cluster_id 1


itsxpress --fastq ../data/its2/r1/SRR19882410_META-seq_of_Salar_de_Huasco_microbial_mat_1.fastq.gz --fastq2 ../data/its2/r2/SRR19882410_META-seq_of_Salar_de_Huasco_microbial_mat_2.fastq.gz --outfile outITS2.fastq --tempdir ./ --region ITS2 --taxa Fungi --log logfileITS2.txt --threads 16 --cluster_id 1


```

Then we use the `compare_alignments.py` script to compare the alignment scores between ITSxpressV2 and ITSx. This script requires the output from the previous step.

```bash
compare_alignments.py ../data/its1_merged/itsx.ITS1.fasta outITS1.fastq '|F|ITS1'
compare_alignments.py ../data/its2_merged/itsx_12347732_1.ITS2.fasta outITS2.fastq '|F|ITS2'

```

Next, we parse the timing data from the slurm output files with `parsetiming.py` and create a CSV file with the timing data.

```bash

parsetiming.py -i ../output/ -o timing.csv

```

Finally, to recreate the figure in the paper we use the jupyter notebook `Thread_figures.ipynb'


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
|   |-- derep.py
|   |-- test_threads.sh
|   |-- compare_alignments.py
|   |-- parsetiming.py
|-- output
|-- dedup_out
|-- analysis
`-- README.md

```
