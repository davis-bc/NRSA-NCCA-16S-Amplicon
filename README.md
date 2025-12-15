# NRSA NCCA 16S rRNA Amplicon 
This repository is for sharing pre-processed 16S rRNA amplicon annotation data from the U.S. EPA's National Rivers and Streams Assessment (NRSA) 2013/2014 and National Coastal Condition Assessment (NCCA) 2015 surveys. 

Included are the scripts and classifier used for analysis in [QIIME2](https://amplicon-docs.qiime2.org/en/stable/), as well as the [ASV and OTU tables](out/) and associated taxonomies needed for downstream analysis.

Published reports and metadata associated with the National Aquatic Resource Surveys (NARS) can be found here: (https://www.epa.gov/national-aquatic-resource-surveys)

Raw sequencing data has been deposited to the Sequence Read Archive (SRA) under BioProject: PRJNA1335231

See the publication in Scientific Data (link) for recommendations on data usage.

<img width="3000" height="2400" alt="sample-map" src="https://github.com/user-attachments/assets/11204975-53d9-4760-b731-826c346bd079" />

## Table of Files
| [QIIME2 Files](out/) | Description |
|:---:|---|
|  nrsa.ncca-sequences-qualityplot.qzv | Quality plots from raw imported amplicon sequences 
|  nrsa.ncca-denoising-stats*          | Output from DADA2 denoising algorithm
|  nrsa.ncca-rep-sequences*            | Post-DADA2 representative sequences at different clustering identities  
|  nrsa.ncca-table*                    | ASV and OTU tables
|  nrsa.ncca-taxonomy-classification*  | Taxonomic assignments for ASV and OTU tables

## qiime2R 
Example for extracting taxonomic information from the provided [QIIME2 artefacts](out/), bypassing the RAM overhead from `qiime2R::summarize_taxa()`

For visualizing and/or extracting data provided in QIIME2 visualization artefacts (.qzv), simply drop them in https://view.qiime2.org/

For more examples of how to use QIIME2 in R see (https://github.com/jbisanz/qiime2R)

```R
if (!requireNamespace("devtools", quietly = TRUE)){install.packages("devtools")}
devtools::install_github("jbisanz/qiime2R")

libraries <- c("tidyverse", "qiime2R")

invisible(lapply(libraries, function(x) {suppressMessages(suppressWarnings(library(x, character.only = T)))}))

### Read in table and taxonomy, merge
ASV <- as.data.frame(read_qza("nrsa.ncca-table.qza")$data) %>%
                      rownames_to_column(var="Feature.ID")

taxonomy <- read_qza("nrsa.ncca-taxonomy-classification-ASV.qza")$data %>% 
            parse_taxonomy() %>% 
            rownames_to_column(var="Feature.ID")

asv_tax <- left_join(ASV, taxonomy, by="Feature.ID")

### Sum counts by phylum for each sample
phylum_abund <- asv_tax %>%
        dplyr::select(-Feature.ID, -Kingdom, -Class, -Order, -Family, -Genus, -Species) %>%
        group_by(Phylum) %>%
        summarise(across(everything(), sum)) %>%
        drop_na(Phylum) %>% column_to_rownames(var="Phylum")

```
