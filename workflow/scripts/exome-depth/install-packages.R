# Title     : Install packages
# Objective : To install R packages
# Created by: valengo
# Created on: 16/06/21

args <- commandArgs(trailingOnly=TRUE)
repos <- args[1]

install.packages("BiocManager", repos = repos)

packages <- c("Biostrings",
              "IRanges",
              "Rsamtools",
              "GenomicRanges",
              "GenomicAlignments")
BiocManager::install(packages, update = TRUE, ask = FALSE)

packages <- c("optparse",
              "ExomeDepth")
install.packages(packages, repos = repos)


