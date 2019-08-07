
########################################################################
#                                                                      #
# AUTHOR: Daniel Gaspar Goncalves                                      #
# git: https://github.com/d-gaspar/                                    #
#                                                                      #
########################################################################

## EXAMPLE
#./runpipe TCGA/GDC_10.0/Nervous_System/RNA-Seq Nervous_System manifest.txt

# Configurations
path=$1
output_name=$(printf "output/"$2".tsv")
output_name_tumor=$(printf "output/"$2"_TUMOR.tsv")
manifest=$3

# Create directories
mkdir -p temp
mkdir -p output

# Uncompress files
files=$(find $path -regex '.*FPKM\.txt\.gz' -type f)

for i in $files; do
	temp_name=$(printf $i"\n" | awk -F'/' '{print $(NF-1)}')
	zcat $i > "temp/"$temp_name".txt"
done

# Create matrix
# python src/merge_tables.py -i temp/ --ext txt -o output/temp.tsv 
./src/merge_tables.sh temp/ txt output/temp.tsv

# Toupper on samples names
(head -n1 output/temp.tsv | awk '{print toupper($0)}' && tail -n+2 output/temp.tsv) > output/temp2.tsv

# replace fileid with barcode
if [ -z "$manifest" ]
then
	printf "variable manifest in unset\n"
else
	Rscript src/get_barcode_given_fileID.R --manifest "$manifest"
	
	# All samples
	(cat temp/fileid_barcode.tsv && head -n1 output/temp2.tsv) | awk -F'\t' -v lines=$(wc -l temp/fileid_barcode.tsv | cut -d' ' -f1) '
		NR>1&&NR<=lines{
			split($3, b, "-");
			a[toupper($2)] = toupper(b[1]"-"b[2]"-"b[3]"-"substr(b[4], 1, 2));
		}
		NR==lines+1{
			for(i=2;i<=NF;i++){
				printf "\t"a[$i];
			}
			print "";
		}
	' | (cat && tail -n+2 output/temp2.tsv) > $output_name
	
	# Tumor samples
	cat $output_name | datamash transpose | awk -F'\t' 'NR==1||$1~/01$/' | datamash transpose | awk -F'\t' '
		NR==1{
			for(i=2;i<=NF;i++){
				printf "\t"substr($i, 1, 12);
			}
			print "";
		}
		NR>1{
			print
		}' > $output_name_tumor
fi

# Delete temporary files
rm -f temp/*
rm output/temp.tsv
rm output/temp2.tsv
rmdir temp
