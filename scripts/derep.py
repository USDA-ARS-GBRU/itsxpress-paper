#!/usr/bin/env python
"""derep.py: a script to reformat Vsearch output files into a csv file

"""

import pandas
import os
import numpy as np
import argparse


def myparser():
	"""Creates parser object

	"""
	parser = argparse.ArgumentParser(description="dedup.py: format vsearch output files")
	parser.add_argument('--infile', '-i', type=str, required=True,
						help='The error log produced from vsearch')
	parser.add_argument('--type', '-t', choices=["dedup", "cluster"],
						help='A csv file of filename, seqs, unique seqs, and the fraction unique')
	parser.add_argument('--outfile', '-o', type=str, required=True,
						help='A csv file of filename, seqs, unique seqs, and the fraction unique')
	return parser


def parse(filename, type):
	""" parses Vsearch output returning a pandas dataframe

	Args:
		filename (str): Name of the file to parse
		type (str): dedup or cluster depending on which vsearch program was used

	Returns
		(obj): Pandas Dataframe object
	"""
	dat = {"sample":[], "seqs":[], "unique":[] }
	with open(filename, 'r') as f:
		for line in f:
			ll = line.strip().split()
			if len(ll)>1:
				if ll[0] == "Reading":
					dat["sample"].append(os.path.basename(ll[2]))
				elif ll[1] == 'nt':
					dat["seqs"].append(int(ll[3]))
				elif ll[1] == 'unique' and type =='dedup':
					dat["unique"].append(int(ll[0]))
				elif ll[0] == 'Clusters:' and type =='cluster':
					dat["unique"].append(int(ll[1]))
	# Add fraction column
	dat["frac"] = list(np.array(dat['unique'])/np.array(dat['seqs']))
	# Create dataframe
	df = pandas.DataFrame.from_dict(dat)
	return df


def main(args=None):
	"""Parse the input file writing a csv out

	Args:
		args (list): A list of args

	"""
	parser = myparser()
	if not args:
		args = parser.parse_args()
	df = parse(filename=args.infile, type=args.type)
	df.to_csv(args.outfile)

if __name__ == '__main__':
	main()
