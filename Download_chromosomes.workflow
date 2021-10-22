#!/usr/bin/env python
import wget

CHROMOSOMES=["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","Mt"]

rule all:
    input:expand("chromosome/{chromosome}.fa.gz", chromosome=CHROMOSOMES)

rule count:
    input:"README.md"
    output:"chromosome/{chromosome}.fa.gz"
    run:
        url="https://ftp.ensembl.org/pub/release-101/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.!{chromosome}.fa.gz"
        print(url)
        Fasta=wget.download(url,"chromosome/{chromosome}.fa.gz")
