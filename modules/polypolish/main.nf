process POLYPOLISH {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}polypolish${params.fs}0.5.0" : null)
    conda (params.enable_conda ? "bioconda::polypolish=0.5.0 conda-forge::libgcc-ng" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/polypolish:0.5.0--hdbdd923_4' :
        'quay.io/biocontainers/polypolish:0.5.0--hdbdd923_4' }"

    input:
        tuple val(meta), path(genome), path(sam)

    output:
        tuple val(meta), path("*.polished.fa"), emit: polished
        path  "versions.yml"                  , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args   = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        """

        polypolish \\
            $args \\
            $genome \\
            ${sam.join(' ')} > ${prefix}.polished.fa

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            polypolish: \$(echo \$(polypolish -V 2>&1) | sed 's/^Polypolish v//')
        END_VERSIONS
        """
}