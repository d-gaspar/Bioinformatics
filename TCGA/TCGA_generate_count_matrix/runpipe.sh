## EXAMPLE
#./runpipe TCGA/GDC_10.0/Nervous_System/RNA-Seq Nervous_System

# Configurations
path=$1
output_name=$(printf "output/"$2".tsv")
manifest=$3

# Create directories
mkdir -p temp
mkdir -p output

# Uncompress files
files=$(find $path -regex '.*htseq\.counts\.gz' -type f)

for i in $files; do
	temp_name=$(printf $i"\n" | awk -F'/' '{print $(NF-1)}')
	zcat $i > "temp/"$temp_name".txt"
done

# Create matrix
python src/merge_tables.py -i temp/ --ext txt -o output/temp.tsv 

# Toupper on samples names
(head -n1 output/temp.tsv | awk '{print toupper($0)}' && tail -n+2 output/temp.tsv) > $output_name

# replace fileid with barcode
if [ -z "$manifest" ]
then
	printf "variable manifest in unset\n"
else
	Rscript src/get_barcode_given_fileID.R --manifest "$manifest"
fi

# Delete temporary files
rm -f temp/*
rm output/temp.tsv
rmdir temp
