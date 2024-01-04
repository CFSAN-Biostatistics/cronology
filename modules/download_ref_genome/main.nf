process DOWNLOAD_REF_GENOME {
    tag "${meta.id}"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        val meta

    output:
        path "*.fna"       , emit: fasta
        path "*.gff"       , emit: gff
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        prefix   = task.ext.prefix ?: "${meta.id}"
        """
        datasets download genome accession --assembly-version latest --include genome,gff3 ${meta.id}

        unzip ncbi_dataset.zip

        stage_ncbi_dataset_genomes.py -in ncbi_dataset -suffix '_genomic.fna' -out "."

        stage_ncbi_dataset_genomes.py -in ncbi_dataset -suffix '.gff' -out "."

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            datasets: \$( datasets --version | sed 's/datasets version: //g' )
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS

        zcmd=""
        zver=""

        if type pigz > /dev/null 2>&1; then
            zcmd="pigz"
            zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed -e '1!d' | sed "s/\$zcmd //" )
        elif type gzip > /dev/null 2>&1; then
            zcmd="gzip"
        
            if [ "${workflow.containerEngine}" != "null" ]; then
                zver=\$( echo \$( \$zcmd --help 2>&1 ) | sed -e '1!d; s/ (.*\$//' )
            else
                zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed "s/^.*(\$zcmd) //; s/\$zcmd //; s/ Copyright.*\$//" )
            fi
        fi

        cat <<-END_VERSIONS >> versions.yml
            \$zcmd: \$zver
        END_VERSIONS
        """

}