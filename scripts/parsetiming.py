#!/usr/bin/env python
"""parsetiming.py: a script to reformat slurm log files
"""

import pandas
import os
import numpy as np
import argparse
import re
import glob


job_to_threads = {"1":1, "2":4, "3":8,"4":16, "5":30, "6":40}

def myparser():
	"""Creates parser object

	"""
	parser = argparse.ArgumentParser(description="parsetiming.py: A script to reformat slurm log files.")
	parser.add_argument('--indir', '-i', type=str, required=True,
						help='The error log produced from vsearch')

	parser.add_argument('--outfile', '-o', type=str, required=True,
						help='A csv file of filename, seqs, unique seqs, and the fraction unique')
	return parser


def time_string_to_secs(time_string):
	""" Converts different time string formats to seconds.

	From http://lexfridman.com/python-robust-conversion-of-time-string-to-seconds-with-missing-values/

	"""
	res = re.match('(\d\d?:)?(\d\d?:)?(\d\d?)(\.\d*)?$', time_string)
	assert res is not None # above regex should match all reasonable input. Instead of assert, can return None
	# some conditions to make sure that hours and minutes don't get confused:
	if res.group(1) is not None and res.group(2) is not None:
		hours = int(res.group(1)[:-1])
		mins = int(res.group(2)[:-1])
	elif res.group(1) is not None:
		assert res.group(2) is None
		hours = 0
		mins = int(res.group(1)[:-1])
	else:
		hours = 0
		mins = 0
	# the seconds are easy
	secs = 0 if res.group(3) is None else int(res.group(3))
	# have to keep microseconds as a string to not lose the leading zeros
	msecs_str = 0 if res.group(4) is None or res.group(4) == '.' else res.group(4)[1:]
	secs_int = hours * 3600 + mins * 60 + secs
	secs_float = float('{}.{}'.format(secs_int, msecs_str))
	return secs_float

def checkfile(file):
	"""Checks file to  to make sire itsx and itsxpress exited with an exit code of
		O and that ITSx did not throw a fatal error message
	Args:
		file: data file path

	Returns:
		Bool: True

	Raises:
		AssertError: if two lines with Exit Status 0 are not present
		ValueError: if ITSx returned a fatal error message (needed because ITSx does not return a nonzero exit status when doing so)

	"""
	status_count = 0
	with open(file, "r") as f:
		for line in f:
			if "Exit status: 0" in line:
				status_count += 1
			if "FATAL ERROR" in line:
				raise ValueError("There was an issue with how itsx ran in the file {}".format(file))
	assert (status_count==3),"There were not four nonzero exit codes in the file {}".format(file)
	return True


def parse_filename(file):
	"""Parses filename returning categorical data about the sample

	Args:
		file: data file path

	Returns:
		region (str): the region [its1 | its2]
		exptype (str): the experiment type [samples | threads]
		jobid (str): the jobid
		sample (str): the sample number
	"""
	try:
		basename = os.path.basename(file)
		bdict = re.split('\W+|_', basename.strip())
		region = bdict[0]
		exptype = bdict[1]
		jobid = bdict[2]
		gridid = bdict[3].split(".")[0]
		return region, exptype, jobid, gridid
	except IndexError as e:
		print("An error occured when parsing the filename {}. It should look like this file name its1_sample_4534523_1.err".format(file))
		raise e



def parse_sample_file(file):
	"""Parse a single timing file

	Args:
		file: data file path

	Returns:
		list: A list with the values [region, exptype, jobid, sample, itsx_sec, itsxpresss_sec]

	Raises:
		exceptions from checkfile or time_string_to Secs
	"""
	try:
		checkfile(file)
		region, exptype, jobid, gridid = parse_filename(file)
		tlist = [region, exptype, jobid, gridid]
		print(tlist)
		if tlist[1] == 'samples':
			tlist.append(40)
		elif tlist[1] == 'threads':
			tlist.append(job_to_threads[str(gridid)])
	except Exception as e:
		raise e
	try:
		with open(file, "r") as f:
			for line in f:
				if "Elapsed (wall clock) time (h:mm:ss or m:ss):" in line:
					seconds = time_string_to_secs(line.strip().split()[7])
					tlist.append(seconds)
				elif "Total number of reads in file" in line:
					totalcounts = line.strip('.').split()[11]
					tlist.append(totalcounts)
	except FileNotFoundError as f:
		print("Could not find the file {}".format(file))
		raise f
	except Exception as g:
		print("Could not parse timing dat for file {}".format(file))
		raise g
	return tlist



def main(args=None):
	"""Parse data files in directory

	"""
	parser = myparser()
	if not args:
		args = parser.parse_args()
	datalist = []
	for file in glob.glob(os.path.join(os.path.join(args.indir,"*.err"))):
		print(file)
		try:
			datalist.append(parse_sample_file(file))
		except Exception as e:
			print(e)
			continue
	#,"itsxpress_sec_zst"
	labels = ["region", "experiment_type", "jobid", "sample", "threads","V2_totalinputcount_R1","V2_totalinputcount_R2","V2_totaloutputcount","V2_Time_elapsed","V1_totalinputcount_R1","V1_totaloutputcount","V1__Time_elapsed","ITSx_time_elapsed"]
	print(datalist)
	df = pandas.DataFrame.from_records(datalist, columns=labels)
	print(df)
	df.to_csv(args.outfile)

if __name__ == "__main__":
	main()
