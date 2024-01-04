process RMLST_POST {
    tag "${meta.id}"
    label "process_pico"
    maxForks 3

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10 conda-forge::requests" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/requests:2.26.0' :
        'quay.io/biocontainers/requests:2.26.0' }"

    input:
        tuple val(meta), path(genome)

    output:
        tuple val(meta), path('*.tsv')     , emit: tsv, optional: true
        tuple val(meta), path('*.log.json'), emit: log, optional: true
        path 'versions.yml'                , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def prefix = (task.ext.prefix ?: meta.id)

        """
        rmlst_post.py \\
            -fasta $genome \\
            -prefix $prefix \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
            requests: \$( python -c "import requests; print (requests.__version__)" )
        END_VERSIONS
        """
}