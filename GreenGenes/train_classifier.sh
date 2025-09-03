#!/bin/bash
#SBATCH --account=nrsaamr
#SBATCH --nodes=1
#SBATCH --partition=scavenger
#SBATCH --time=0-10:00:00 #days-hours:min:sec
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=davis.benjamin@epa.gov
#SBATCH --output=/work/NRSAAMR/Projects/NRSA-16S/Final_Preparation/slurm/train.%j

source activate qiime2

cd "/work/NRSAAMR/Projects/NRSA-16S/Final_Preparation/GreenGenes"

export TMPDIR="/work/NRSAAMR/Projects/EFLMR-Pilot/work"

#qiime feature-classifier extract-reads --i-sequences 2024.09.backbone.full-length.fna.qza --p-f-primer CCTACGGGAGGCAGCAG --p-r-primer GGACTACHVGGGTWTCTAAT --o-reads greengenes-2024.09-v4v5-ref-seqs.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads greengenes-2024.09-v4v5-ref-seqs.qza --i-reference-taxonomy 2024.09.backbone.tax.qza --o-classifier greengenes-2024.09-v4v5-classifier.qza


