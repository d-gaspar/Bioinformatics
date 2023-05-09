
########################################################################
#                                                                      #
# AUTHOR: Daniel Gaspar Goncalves                                      #
# git: https://github.com/d-gaspar/                                    #
#                                                                      #
########################################################################

suppressMessages({
    library(dplyr)
    library(readr)
    library(TCGAbiolinks)
    library(TCGAutils)
})

#####################################################################################

project = "TCGA-BRCA"

#####################################################################################
#####################################################################################
#####################################################################################

# clinical

query = GDCquery(
	project = project,
	data.category = "Clinical",
	file.type = "xml"
)

GDCdownload(query)

clinical = GDCprepare_clinic(query,"patient")

# save clinical & free memory
write_tsv(clinical, paste0(project, ".clinical.tsv.gz"))
rm(list = c("clinical", "query"))
gc()

#####################################################################################
#####################################################################################
#####################################################################################

# download rna-seq counting data (count + fpkm)

suppressMessages({
    query = GDCquery(
	project = project,
	data.category = "Transcriptome Profiling",
	data.type = "Gene Expression Quantification",
	experimental.strategy = "RNA-Seq",
	workflow.type = "STAR - Counts"
    )
})
GDCdownload(query = query, method = "api")

