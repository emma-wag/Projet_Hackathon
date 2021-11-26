#Fait appel aux libraires si les packages sont déjà installés. Si ce n'est pas le cas, il faut faire
#install.packages("...") en fonction de ceux qu'il vous manque
require("FactoMineR")
require("factoextra")
require("data.table")

#On installe le package EnhancedVolano, en verifiant d'abord que BiocManager est déjà installé (sinon le code le fait)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install('EnhancedVolcano')

#Récupère le chemin pour utiliser des fichiers qui sont dans le même dossier
directory = getwd()
setwd(directory)

#Il faut d'abord télécharger ce script et le fichier "stats.Rdata" sur notre Git dans Résultats
#La deuxième étape est de mettre les 2 dans un même dossier sur votre ordinateur. 
#Si le load affiche quand même un message d'erreur avec 'No such file or directory', il faut remplacer la commande
#Pour cela, on va mettre à la place de "stats.Rdata" son chemin entier. 
#On finira donc avec une commande load("path/stats.Rdata")
load("stats.Rdata")

#-----------------------------------------------------------------------------------------------------
#               ACP
#-----------------------------------------------------------------------------------------------------
#Plot d'ACP (Percentage of explained variances pour choisir les dimensions et l'ACP sur Dim1-2)
test_PCA = PCA(t(essai), graph = F)
fviz_eig(test_PCA)
fviz_pca_ind(test_PCA, axes = c(1,2), col.ind = mutations, repel = T, mean.point = F)
# --> on peut changer c(1,3) pour Dim1-Dim3

#-----------------------------------------------------------------------------------------------------
#               Enhanced Volcano Plot
#-----------------------------------------------------------------------------------------------------

#Afin de voir de façon plus lisible, nous avons pris que les 7 derniers charactères de Geneid à afficher dans le VolcanoPlot
library(stringr)
size_name = str_length(rownames(resultats)[1])
names_tronque = substr(rownames(resultats), start = size_name -6 , stop = size_name)

#On remplace les NA
resultats = resultats[complete.cases(resultats[,6]),] 

#Enhanced Volcano plot 
library(EnhancedVolcano)
EnhancedVolcano(resultats,
                lab = names_tronque,
                x = 'log2FoldChange',
                y = 'padj',
                pCutoff = 0.05,
                legendPosition = "bottom",
                legendLabSize = 10,
                legendIconSize = 0.5,
                title = "Enhanced Volcano Plot"
                )


