process MASH_PASTE {
    tag "${meta.id}"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}mash${params.fs}2.3" : null)
    conda (params.enable_conda ? "conda-forge::capnproto conda-forge::gsl bioconda::mash=2.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mash:2.3--he348c14_1':
        'quay.io/biocontainers/mash:2.3--he348c14_1' }"

    input:
        tuple val(meta), path(sketch)

    output:
        tuple val(meta), path("*.msh")               , emit: sketch
        tuple val(meta), path("*_mash_sketch.status"), emit: stats
        path "versions.yml"                          , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def sketches = (sketch ? sketch.collect().join('\\n') : null)
        """
        echo -e "$sketches" > paste_these.txt

        mash \\
            paste \\
            "msh.k${params.mashsketch_k}.${params.mashsketch_s}h.${prefix}" \\
            -l paste_these.txt \\
            2> ${prefix}_mash_sketch.status

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mash: \$( mash --version )
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}