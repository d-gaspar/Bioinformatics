
########################################################################
#                                                                      #
# AUTHOR: Daniel Gaspar Goncalves                                      #
# git: https://github.com/d-gaspar/                                    #
#                                                                      #
########################################################################

suppressMessages({
    library(dplyr)
    library(readr)
})

#####################################################################################

project = "TCGA-BRCA"

#####################################################################################

# list files
files = list.files(path = "GDCdata", pattern = "\\.tsv", recursive = TRUE, full.names = TRUE)

# sample ID
files = files %>%
	as.data.frame %>%
	setNames("path") %>%
	mutate(path_dir_name = gsub(".*/(.*)/.*", "\\1", path))
	
# append barcode
files = files %>%
	left_join(
		TCGAutils::UUIDtoBarcode(files$path_dir_name, from_type = "file_id") %>%
		setNames(c("path_dir_name", "barcode")),
		by = "path_dir_name"
	) %>%
	mutate(barcode_min = gsub("(TCGA-.{2}-.{4}).*", "\\1", barcode))

# save file
write_tsv(files, paste0(project, ".files.tsv.gz"))

#####################################################################################
#####################################################################################
#####################################################################################

# merge count

column_data = "unstranded"

# gene_id & gene_name
aux = read_tsv(files[1,"path"], skip=6, col_names=FALSE)
df = data.frame(
	gene_id = aux$X1,
	gene_name = aux$X2
)

# append samples to output data.frame
for (f in 1:nrow(files)) {
	aux = read.table(
		file = files[f, "path"],
		skip = 1,
		na.strings = "N_.*",
		fill = TRUE,
		header = TRUE
	) %>% filter(!grepl(pattern = "N_", x = gene_id))
	
	# output
	df = df %>% left_join(
		aux %>%
			select("gene_id", all_of(column_data)) %>%
			setNames(c("gene_id", files[f, "path_dir_name"])),
		by = "gene_id"
	)
}

# save file
write_tsv(df, paste0(project, ".count.tsv.gz"))

#####################################################################################
#####################################################################################
#####################################################################################

# merge fpkm

column_data = "fpkm_unstranded"

# gene_id & gene_name
aux = read_tsv(files[1,"path"], skip=6, col_names=FALSE)
df = data.frame(
	gene_id = aux$X1,
	gene_name = aux$X2
)

# append samples to output data.frame
for (f in 1:nrow(files)) {
	aux = read.table(
		file = files[f, "path"],
		skip = 1,
		na.strings = "N_.*",
		fill = TRUE,
		header = TRUE
	) %>% filter(!grepl(pattern = "N_", x = gene_id))
	
	# output
	df = df %>% left_join(
		aux %>%
			select("gene_id", all_of(column_data)) %>%
			setNames(c("gene_id", files[f, "path_dir_name"])),
		by = "gene_id"
	)
}

# save file
write_tsv(df, paste0(project, ".fpkm.tsv.gz"))

