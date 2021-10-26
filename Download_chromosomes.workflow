#!/usr/bin/env python
import wget

CHROMOSOMES=["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","Mt"]

rule all:
    input:expand("chromosome/{chromosome}.fa.gz", chromosome=CHROMOSOMES)

#Télécharger les chromosomes
rule download_chromosomes:
    output:"chromosome/{wildcards.chromosome}.fa.gz"
    shell:
        """
        wget -0 chromosome/{chromosome}.fa.gz ftp://ftp.ensembl.org/pub/release-101/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.{wildcards.chromosome}.fa.gz
        gunzip -c *.fa.gz > ref.fa
        """

#Indexer le génome
rule genome_index:
    input:
        "{chromosome}.fa" 
    output:
        "{chromosome}/IndexChromosome.txt"
    threads: 1
    singularity: 
		"docker://evolbioinfo/star:v2.7.6a"
    shell: 
        """
        STAR --runThreadN {threads} --runMode genomeGenerate --genomeDir {chromosome}/ --genomeFastaFiles {chromosome}.fa
        """

#Annoter le génome
rule genome_annot:
    output:
        "Annotation.gtf"
    threads: 1
    shell: 
        """
        wget ftp://ftp.ensembl.org/pub/release-101/gtf/homo_sapiens/Homo_sapiens.GRCh38.101.chr.gtf.gz
        """

#Mapping FastQ
rule mapping_FastQ:
    input:
        "{chromosome}.fastq" #?
    output:
        #?
    threads: 1
    singularity: 
        "docker://evolbioinfo/star:v2.7.6a"
        "docker://evolbioinfo/samtools:v1.11"
    shell: 
        """
        STAR --outSAMstrandField intronMotif \
        --outFilterMismatchNmax 4 \
        --outFilterMultimapNmax 10 \
        --genomeDir ref \
        --readFilesIn <(gunzip -c <fastq1>) <(gunzip -c <fastq2>) \
        --runThreadN {threads} \
        --outSAMunmapped None \
        --outSAMtype BAM SortedByCoordinate \
        --outStd BAM_SortedByCoordinate \
        --genomeLoad NoSharedMemory \
        --limitBAMsortRAM <Memory in Bytes> \
        > <sample id>.bam
        samtools index *.bamwget ftp://ftp.ensembl.org/pub/release-101/gtf/homo_sapiens/Homo_sapiens.GRCh38.101.chr.gtf.gz
        """
#Analyse statistique
rule analyse_statistique:
    input:
        "path/to/inputfile",
        "path/to/other/inputfile"
    output:
        "path/to/outputfile",
        "path/to/another/outputfile"
    script:
        "scripts/script.R"