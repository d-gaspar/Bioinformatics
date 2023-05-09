"""

python merge_tables.py -i input/count/ -o input/count_matrix.txt --ext count --sub input/samples_subtype.txt
python merge_tables.py -i ../pipeline/output/FPKM/ -o teste.txt --ext FPKM

"""
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description=
'''
Creates a matrix from a directory of tables (m:2) with the first column in common.
Daniel Gaspar Gonçalves - 25/04/2017

input format:
	| row 1 | value 1 |
	| row 2 | value 2 |
	...
	| row m | value m |

output format:
	|       | file_name 1 | file_name 2 | ... | file_name n |
	| row 1 |             |             | ... |             |
	| row 2 |             |             | ... |             |
	...
	| row m |             |             | ... |             |
''')

parser.add_argument('-i', action = 'store', dest = 'dir', required = True, help = 'get files in this directory')
parser.add_argument('-o', action = 'store', dest = 'output', required = True, help = 'output file name')
parser.add_argument('--ext', action = 'store', dest = 'ext', required = False, help = 'specify the file extension (! the file must have an extension)')
args = parser.parse_args()

###################################################################################################################################################
# FUNCTIONS

import os
import re
import operator

def get_file_list(dir, ext): # get list of files
	if(ext):
		return([dir + x for x in os.listdir(dir) if (re.findall('.*\.' + ext, x) != [])])
	else:
		return([dir + x for x in os.listdir(dir)])

def get_files(file_list):
	row0 = {} # row0 = {aux_row0: {file_name: value}}
	row0_sort = [] # row sort
	file_name_sort = [] # file_name sort

	for f in file_list:
		file_name = f.split('/')[-1].split('.')[0]

		if(file_name not in file_name_sort): file_name_sort.append(file_name) # file_name sort

		with open(f, 'r') as i:
			for line in i:
				line_split = line.rstrip().split('\t')
				aux_row0 = line_split[0]
				aux_row1 = line_split[1]

				if(aux_row0 not in row0):
					row0[aux_row0] = {file_name: aux_row1}
					row0_sort.append(aux_row0) # row sort
				else:
					row0[aux_row0].update({file_name: aux_row1})
	return(row0, row0_sort, file_name_sort)

def print_matrix(files, output, row0_sort, file_name_sort):
	o = open(output, 'w')

	# sort by "file_name / pattern"
	file_name_sort = sorted(file_name_sort)
	for i in file_name_sort:
		o.write('\t' + i)
	o.write('\n')

	# print remaining rows
	row0_sort = sorted(row0_sort)[:] # row sort
	for i in row0_sort:
		o.write(i)
		for j in file_name_sort:
			if(j in files[i]):
				o.write('\t' + files[i][j])
			else:
				o.write('\t0')
		o.write('\n')

	o.close()

###################################################################################################################################################
# MAIN

file_list = get_file_list(args.dir, args.ext)
files, row0_sort, file_name_sort  = get_files(file_list)
print_matrix(files, args.output,row0_sort, file_name_sort)