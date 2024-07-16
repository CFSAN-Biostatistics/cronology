process SHOVILL {
    tag "$meta.id"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}shovill${params.fs}1.1.0" : null)
    conda (params.enable_conda ? "bioconda::shovill=1.1.0 conda-forge::pigz" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/shovill:1.1.0--0' :
        'quay.io/biocontainers/shovill:1.1.0--0' }"

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("${prefix}${params.fs}contigs.fa")                         , emit: contigs
        tuple val(meta), path("${prefix}${params.fs}shovill.corrections")                , emit: corrections
        tuple val(meta), path("${prefix}${params.fs}shovill.log")                        , emit: log
        tuple val(meta), path("${prefix}${params.fs}{skesa,spades,megahit,velvet}.fasta"), emit: raw_contigs
        tuple val(meta), path("${prefix}${params.fs}contigs.{fastg,gfa,LastGraph}")      , emit: gfa, optional: true
        path "versions.yml"                                                              , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def memory = (task.memory ? task.memory.toGiga() : 16)
        prefix = (task.ext.prefix ?: meta.id)
        """
        shovill \\
            --R1 ${reads[0]} \\
            --R2 ${reads[1]} \\
            $args \\
            --tmpdir ${prefix}${params.fs}tmp \\
            --cpus $task.cpus \\
            --ram $memory \\
            --outdir $prefix \\
            --force

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            shovill: \$(echo \$(shovill --version 2>&1) | sed 's/^.*shovill //')
        END_VERSIONS
    """
}