
########################################################################
#                                                                      #
# AUTHOR: Daniel Gaspar Goncalves                                      #
# git: https://github.com/d-gaspar/                                    #
#                                                                      #
########################################################################

args = commandArgs(trailingOnly=TRUE)

args.manifest = args[grep("--manifest", args)+1]

########################################################################

library(TCGAutils)

########################################################################

df = read.table(args.manifest, header = T)

output = filenameToBarcode(df$filename, legacy = FALSE)

write.table(x = output, file = "temp/fileid_barcode.tsv", sep ="\t", quote = F, row.names = F)
