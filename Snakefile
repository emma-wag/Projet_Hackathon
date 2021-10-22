gene_names = list(range(2,3))


rule all:
	input:
		expand("/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz", sample = gene_names)

rule download_gene: 
	output: "/mnt/mydatalocal/genes/SRR62858{sample}/SRR62858{sample}_1.fastq.gz"
	shell:
		"""
			wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_1.fastq.gz"
			wget -O {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_2.fastq.gz"
		"""
