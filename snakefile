gene_names = list(range(2,9))
chromosome_nb = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "MT"]

rule all:
	input: expand("/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_2.fastq", sample = gene_names), expand("/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq", sample = gene_names), "genome/genome.fa", "genome_index/genomeParameters.txt"

rule download_gene1:
        output: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz"
        shell:
                """
                        wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_1.fastq.gz"
                """

rule download_gene2:
        output: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_2.fastq.gz"
        shell:
                """
                        wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_2.fastq.gz"
                """

rule download_chr:
        output: "/mnt/mydatalocal/chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa.gz"
        shell:
                """
                    wget -O {output} "ftp://ftp.ensembl.org/pub/release-101/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.{wildcards.chr_list}.fa.gz"
                """

rule unzip_genes_1:
	input: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz"
	output: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq"
        shell:
                """
			gunzip -c {input} > {output}
                """

rule unzip_genes_2:
        input: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_2.fastq.gz"
        output: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_2.fastq"
        shell:
                """
                        gunzip -c {input} > {output}
                """

rule unzip_chr:
	input: "/mnt/mydatalocal/chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa.gz"
	output: "/mnt/mydatalocal/chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa"
        shell:
                """
			gunzip -c {input} > {output}
                """

rule concatenate_genome:
        input: expand("/mnt/mydatalocal/chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa", chr_list = chromosome_nb)
        output: "genome/genome.fa"
        shell:
                """
                        cat {input} > {output}
                """

rule index_genome:
        input: "genome/genome.fa"
        output: "genome_index/genomeParameters.txt"
        singularity: "docker://evolbioinfo/star:v2.7.6a"
        threads: 4
        shell:
                """
                        STAR --runThreadN {threads} --runMode genomeGenerate --genomeDir genome_index/ --genomeFastaFiles {input}
                """
