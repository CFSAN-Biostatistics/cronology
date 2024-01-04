process MASURCA_POLISH {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}masurca${params.fs}4.1.0" : null)
    conda (params.enable_conda ? "bioconda::masurca=4.1.0 conda-forge::libgcc-ng" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/masurca:4.1.0--pl5321hb5bd705_1' :
        'quay.io/biocontainers/masurca:4.1.0--pl5321hb5bd705_1' }"

    input:
        tuple val(meta), path(contigs), path(reads)

    output:
        tuple val(meta), path("${prefix}_contigs.fa"), emit: polished
        path "versions.yml"                          , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args           = task.ext.args ?: ''
        def memory         = (task.memory ? task.memory.toGiga() : 16)
        def mem_per_thread = memory.toGiga().toInteger().div(task.cpus.toInteger()).round(0)
        def all_reads      = "${reads.join(' ')}"
        prefix             = (task.ext.prefix ?: meta.id)
        """
        polca.sh \\
            -a $contigs \\
            -r '${all_reads}' \\
            -t $task.cpus \\
            -m $mem_per_thread \\
            $args \\
        
        mv 'contigs.fa' "${prefix}.contigs.fa"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            masurca: \$(echo \$(masurca --version 2>&1) | sed 's/^.*version //')
        END_VERSIONS
    """
}