#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install("DESeq2")

#install.packages("tidyverse")
#install.packages("data.table")

#library(tidyverse)
#library(data.table)
library( "DESeq2" )

dir = getwd()
setwd(dir)

# On t?l?charge les donn?es et on ne r?cup?re que la d
file_names <- paste0("SRR62858",seq(2,9))
#file_path <- paste0("counting_files",file_names,".txt")


#list_test <- read.table("counting_files/SRR628582.txt",header=T)[,c(1,7)]
list_test <- read.table(snakemake@input[[1]],header=T)[,c(1,7)]
for(k in 2:length(file_names)){
  list_test <- cbind(list_test,read.table(snakemake@input[[k]],header=T)[,7])
}

colnames(list_test) <- c("Geneid",file_names)
rownames(list_test) <- list_test[,1]
essai <- list_test[,-1]

head(essai)

mutations = c("M", "M", "M", "WT", "WT", "WT", "WT", "M")
coldata = as.matrix(data.frame(labels = file_names, mutations))

dds = DESeqDataSetFromMatrix(countData = essai, colData = coldata, ~mutations)
dds2 = DESeq(dds)
resultats = results(dds2)

save(dds, dds2, resultats, essai, mutations, file=snakemake@output[[1]])
