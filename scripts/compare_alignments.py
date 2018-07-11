#!/usr/bin/env python
#compare_alignments.py fasta, fastq
import sys
from collections import Counter

from Bio import pairwise2
from Bio import SeqIO

file1 = sys.argv[1]
file2 = sys.argv[2]
itssuffix = "|F|ITS2"

f1 = SeqIO.to_dict(SeqIO.parse(file1, "fasta"))
f2 = SeqIO.parse(file2, "fastq")

diffcnt = Counter()
ndiff = []
n = 0
for rec in f2:
	name = rec.id + itssuffix
	if name in f1:
		align = pairwise2.align.globalms(rec.seq, f1[name].seq,  2, -1, -.5, -.1)
		differences = align[0][0].count('-') + align[0][1].count('-')
		if differences > 0:
			print(align)
		diffcnt[differences] += 1
		ndiff.append(differences/len(rec))
		n += 1
print(diffcnt.most_common())
print(sum(ndiff)/len(ndiff))
print(n)

		