process PIRATE {
    tag "$meta.id"
    label 'process_medium'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}pirate${params.fs}5.2.0" : null)
    conda (params.enable_conda ? "bioconda::pirate=1.0.5 bioconda::mcl=14.137 conda-forge::r-dplyr" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pirate:1.0.5--hdfd78af_0' :
        'quay.io/biocontainers/pirate:1.0.5--hdfd78af_0' }"

    input:
        tuple val(meta), path(gff)

    output:
        tuple val(meta), path("results/*")                   , emit: results
        tuple val(meta), path("results/core_alignment.fasta"), emit: aln, optional: true
        path "versions.yml"                                  , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def rplots = (params.enable_conda ? '--rplots' : '')
        """
        PIRATE \\
            $args \\
            $rplots \\
            --threads $task.cpus \\
            --input ".${params.fs}" \\
            --output results/

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            pirate: \$( echo \$( PIRATE --version 2>&1) | sed 's/PIRATE //' )
        END_VERSIONS
        """
}