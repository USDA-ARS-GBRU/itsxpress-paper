#!/usr/bin/env python
#compare_alignments.py fasta, fastq ['|F|ITS2' | '|F|ITS1']
# A script calculate the differences between itsx and itsxpress alignments
import sys
from collections import Counter

from Bio import Align
from Bio import SeqIO

aligner = Align.PairwiseAligner()
aligner.mode = 'global'
aligner.match_score = 2
aligner.mismatch_score = -1
aligner.open_gap_score = -0.5
aligner.extend_gap_score = -0.1



print("compare_alignments.py fasta, fastq ['|F|ITS2' | '|F|ITS1']")

file1 = sys.argv[1]
file2 = sys.argv[2]
itssuffix = sys.argv[3]
print(file1)
print(file2)
print(itssuffix)

f1 = SeqIO.to_dict(SeqIO.parse(file1, "fasta"))
f2 = SeqIO.parse(file2, "fastq")

diffcnt = Counter()
ndiff = []
n = 0
for rec in f2:
	#print(rec.id)
	name = rec.id + itssuffix
	#print(name)
	if name in f1:
		if rec.seq == f1[name].seq:
			#print(rec.seq,"-----",f1[name].seq)
			diffcnt[0] += 1
			n += 1
		else:
			#print(rec.seq,"-----",f1[name].seq)
			align = aligner.align(rec.seq, f1[name].seq)
			differences = align[0][0].count('-') + align[0][1].count('-')
			diffcnt[differences] += 1
			ndiff.append(differences/len(rec))
			n += 1
print(diffcnt.most_common())
print(sum(ndiff)/len(ndiff))
print(n)
