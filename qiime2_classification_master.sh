#!/bin/bash
#SBATCH --account=nrsaamr
#SBATCH --nodes=1
#SBATCH --partition=ord
#SBATCH --time=1-00:00:00 #days-hours:min:sec
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=davis.benjamin@epa.gov
#SBATCH --output=/work/NRSAAMR/Projects/NRSA-16S/Final_Preparation/slurm/classification.%j
#SBATCH --exclusive

source activate qiime2

export TMPDIR='/work/NRSAAMR/tmp'

home="/work/NRSAAMR/Projects/NRSA-16S/Final_Preparation"
db="/work/NRSAAMR/Projects/NRSA-16S/Final_Preparation/GreenGenes"

### Step 1: Import data from manifest and generate quality plots
qiime tools import \
	--type 'SampleData[PairedEndSequencesWithQuality]' \
	--input-path  ${home}/nrsa.ncca.manifest.sra.tsv \
	--output-path ${home}/nrsa.ncca-sequences.qza \
	--input-format PairedEndFastqManifestPhred33V2

qiime demux summarize --i-data ${home}/nrsa.ncca-sequences.qza --o-visualization ${home}/nrsa.ncca-sequences-qualityplot.qzv

### Step 2: Generate ASVs using DADA2 (filter, denoise, remove chimeras)
qiime dada2 denoise-paired \
	--i-demultiplexed-seqs ${home}/nrsa.ncca-sequences.qza \
	--p-trunc-len-f 0 \
	--p-trunc-len-r 250 \
	--o-table ${home}/nrsa.ncca-table.qza \
	--o-representative-sequences ${home}/nrsa.ncca-rep-sequences.qza \
	--o-denoising-stats ${home}/nrsa.ncca-denoising-stats.qza

qiime metadata tabulate --m-input-file ${home}/nrsa.ncca-denoising-stats.qza --o-visualization ${home}/nrsa.ncca-denoising-stats.qzv

### Step 3: Generate 97% and 99% OTU tables
qiime vsearch cluster-features-de-novo \
       --i-table ${home}/nrsa.ncca-table.qza \
       --i-sequences ${home}/nrsa.ncca-rep-sequences.qza \
       --p-perc-identity 0.97 \
       --o-clustered-table ${home}/nrsa.ncca-table-97.qza \
       --o-clustered-sequences ${home}/nrsa.ncca-rep-seqs-97.qza

qiime vsearch cluster-features-de-novo \
       --i-table ${home}/nrsa.ncca-table.qza \
       --i-sequences ${home}/nrsa.ncca-rep-sequences.qza \
       --p-perc-identity 0.99 \
       --o-clustered-table ${home}/nrsa.ncca-table-99.qza \
       --o-clustered-sequences ${home}/nrsa.ncca-rep-seqs-99.qza

### Step 4: Taxonomically classify ASV and OTU tables
qiime feature-classifier classify-sklearn \
	--i-reads ${home}/nrsa.ncca-rep-sequences.qza \
	--i-classifier ${db}/greengenes-2024.09-v4v5-classifier.qza \
	--o-classification ${home}/nrsa.ncca-taxonomy-classification-ASV.qza

qiime feature-classifier classify-sklearn \
	--i-reads ${home}/nrsa.ncca-rep-seqs-97.qza \
	--i-classifier ${db}/greengenes-2024.09-v4v5-classifier.qza \
	--o-classification ${home}/nrsa.ncca-taxonomy-classification-97.qza

qiime feature-classifier classify-sklearn \
	--i-reads ${home}/nrsa.ncca-rep-seqs-99.qza \
	--i-classifier ${db}/greengenes-2024.09-v4v5-classifier.qza \
	--o-classification ${home}/nrsa.ncca-taxonomy-classification-99.qza

### Step 5 (optional): Create phylogeny for weighted/unweighted UniFrac
#qiime phylogeny align-to-tree-mafft-fasttree \
#  --i-sequences ${home}/nrsa.ncca-rep-sequences.qza \
#  --output-dir ${home}/mafft-fasttree-output-ASV

#qiime phylogeny align-to-tree-mafft-fasttree \
#  --i-sequences ${home}/nrsa.ncca-rep-sequences-97.qza \
#  --output-dir ${home}/mafft-fasttree-output-97

#qiime phylogeny align-to-tree-mafft-fasttree \
#  --i-sequences ${home}/nrsa.ncca-rep-sequences-99.qza \
#  --output-dir ${home}/mafft-fasttree-output-99

#qiime diversity core-metrics-phylogenetic \
#        --i-table ${home}/nrsa-ncca-table.qza \
#        --i-phylogeny ${home}/mafft-fasttree-output-ASV/rooted_tree.qza \
#        --p-sampling-depth 1000 \
#        --m-metadata-file ${home}/NRSA-NCCA-metadata-qiime2Rclean.tsv \
#        --output-dir ${home}/nrsa-ncca-ASV_phylogenetics_1000
