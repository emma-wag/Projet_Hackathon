#On charge la librairie DESeq2 (pas besoin d'installer avant car on utilise un conteneur Docker dans le workflow snakefile)
library( "DESeq2" )

#On récupère le chemin, pour indiquer où sont les fichiers dont on va avoir besoin (snakemake@input dans notre cas)
dir = getwd()
setwd(dir)

# On crée la variable file_names qui contient 8 chaines de charactères qui correspondent aux 8 noms des gènes
file_names <- paste0("SRR62858",seq(2,9))

#On récupère la première et septième colonne du premier input du snakemake. 
#Dans notre cas, le script est utilisé dans notre dernier "rule" du snakefile, les input sont les fichiers ".counts" de chaque gène
#list_test va donc contenir le Gene id et le nombre de reads du premier gène, c'est-à-dire SRR62858 (on initialise)
list_test <- read.table(snakemake@input[[1]],header=T)[,c(1,7)]
#On rajoute à list_test la septième colonne (nombre de reads) de tous les autres gènes
for(k in 2:length(file_names)){
  list_test <- cbind(list_test,read.table(snakemake@input[[k]],header=T)[,7])
}

#On renomme la première colonne Geneid et toutes les autres prennent les noms des gènes 
colnames(list_test) <- c("Geneid",file_names)
#On renomme les lignes avec tous les Geneid
rownames(list_test) <- list_test[,1]
#list_test a donc 2 fois les Geneid (une fois en titre de lignes, une fois dans la première colonne) donc essai est une copie de list_test sans cette première colonne
essai <- list_test[,-1]

#head(essai) - pour nous aider à visualiser essai

#La fonction DESeqDataSetFromMatrix a besoin du nom des colonnes en format data.frame. On veut séparer selon le type de mutations. 
#On crée donc coldata qui associe à chaque gène soit M pour indiqué qu'il est muté ou WT pour Wild-Type (= sauvage). 
mutations = c("M", "M", "WT", "WT", "WT", "WT", "WT", "M")
coldata = as.matrix(data.frame(labels = file_names, mutations))

#Utilisatin des fonctions de DESeq2
dds = DESeqDataSetFromMatrix(countData = essai, colData = coldata, ~mutations)
dds2 = DESeq(dds)
resultats = results(dds2)

#On sauvegarde toutes les informations dont on aura besoin pour réaliser les graphes dans l'output du snakemake, soit "stats.Rdata" pour nous
save(dds, dds2, resultats, essai, mutations, file=snakemake@output[[1]])
