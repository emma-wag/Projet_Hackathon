gene_names = list(range(8,9))


rule all:
	input:
		directory(expand("/mnt/mydatalocal/genes/SRR62858{sample}/", sample = gene_names))

rule download_gene: 
	output: directory("/mnt/mydatalocal/genes/SRR62858{sample}/")
	shell:
		"""
			mkdir {output}
			wget -P {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_1.fastq.gz"
			wget -P {output} "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/SRR62858{wildcards.sample}/SRR62858{wildcards.sample}_2.fastq.gz"
		"""
