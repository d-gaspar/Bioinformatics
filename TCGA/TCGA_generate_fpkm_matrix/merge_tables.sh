
########################################################################
#                                                                      #
# AUTHOR: Daniel Gaspar Goncalves                                      #
# git: https://github.com/d-gaspar/                                    #
#                                                                      #
########################################################################

# ./src/merge_tables.sh temp/ txt output/temp.tsv

path=$1
ext=$2
output=$3

files=$(find $path -regex '.*txt' -type f)

cut -f1 $(printf "$files" | head -n1) | datamash transpose | awk '{print "\t"$0}' > a1234567890_temp_aux.tsv

for i in $files; do
	cut -f2 $i | datamash transpose | awk -v barcode=$i '{match(barcode, "/(.*).txt", a); print a[1]"\t"$0}' >> a1234567890_temp_aux.tsv
done

cat a1234567890_temp_aux.tsv | datamash transpose > $output

rm a1234567890_temp_aux.tsv
