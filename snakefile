gene_names = list(range(2,10))
chromosome_nb = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "MT"]

rule all:
	input: "stats.Rdata"

rule download_gene1:
        output: "genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz"
        shell:
                """
                        wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_1.fastq.gz"
                """

rule download_gene2:
        output: "genes/SRR62858{sample}/SRR62858{sample}_2.fastq.gz"
        shell:
                """
                        wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_2.fastq.gz"
                """

rule download_chr:
        output: "chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa.gz"
        shell:
                """
                    wget -O {output} "ftp://ftp.ensembl.org/pub/release-101/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.{wildcards.chr_list}.fa.gz"
                """

rule unzip_genes_1:
        input: "genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz"
        output: "genes/SRR62858{sample}/SRR62858{sample}_1.fastq"
        shell:
                """
                        gunzip -c {input} > {output}
                """

rule unzip_genes_2:
        input: "genes/SRR62858{sample}/SRR62858{sample}_2.fastq.gz"
        output: "genes/SRR62858{sample}/SRR62858{sample}_2.fastq"
        shell:
                """
                        gunzip -c {input} > {output}
                """

rule unzip_chr:
        input: "chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa.gz"
        output: "chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa"
        shell:
                """
                        gunzip -c {input} > {output}
                """

rule concatenate_genome:
        input: expand("chromosome/Chr{chr_list}/Homo_sapiens.GRCh38.dna.chromosome.{chr_list}.fa", chr_list = chromosome_nb)
        output: "genome/genome.fa"
        shell:
                """
                        cat {input} > {output}
                """

rule index_genome:
        input: "genome/genome.fa"
        output: "genome_index/SAindex"
        singularity: "docker://evolbioinfo/star:v2.7.6a"
        threads: 8
        shell:
                """
                        STAR --runThreadN {threads} --runMode genomeGenerate --genomeDir genome_index/ --genomeFastaFiles {input}
                """

rule annotation:
	output: "genome_annot/Homo_sapiens.GRCh38.101.chr.gtf"
        shell:
                """
                        wget -O "genome_annot/Homo_sapiens.GRCh38.101.chr.gtf.gz" ftp://ftp.ensembl.org/pub/release-101/gtf/homo_sapiens/Homo_sapiens.GRCh38.101.chr.gtf.gz
			gunzip -c "genome_annot/Homo_sapiens.GRCh38.101.chr.gtf.gz" > {output}
                """

rule mapping:
        input:
                g1 = "genes/SRR62858{sample}/SRR62858{sample}_1.fastq",
                g2 = "genes/SRR62858{sample}/SRR62858{sample}_2.fastq",
                genome = "genome_index/SAindex"
        output: "mapping_files/SRR62858{sample}.bam"
        singularity: "docker://evolbioinfo/star:v2.7.6a"
        threads: 12
        shell:
                """
                        STAR --outSAMstrandField intronMotif --outFilterMismatchNmax 4 --outFilterMultimapNmax 10 --genomeDir genome_index/ --readFilesIn {input.g1} {input.g2} --runThreadN {threads} --outSAMunmapped None --outSAMtype BAM SortedByCoordinate --outStd BAM_SortedByCoordinate --genomeLoad NoSharedMemory --limitBAMsortRAM 60000000000  > {output}
                """

rule count:
        input:
                map = "mapping_files/SRR62858{sample}.bam",
                gtf = "genome_annot/Homo_sapiens.GRCh38.101.chr.gtf"
        output: "counting_files/SRR62858{sample}.counts"
        singularity: "docker://evolbioinfo/subread:v2.0.1"
        threads: 4
        shell:
                """
                        featureCounts -T {threads} -t gene -g gene_id -s 0 -a {input.gtf} -o {output} {input.map}
                """

rule stat:
	input: expand("counting_files/SRR62858{sample}.counts", sample = gene_names)
	output: "stats.Rdata"
	singularity: "docker://evolbioinfo/deseq2:v1.28.1"
	script: "/home/ubuntu/Projet_Hackaton/Script_Hackathon.R"
