process SPADES_ASSEMBLE {
    tag "$meta.id"
    label 'process_higher'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}spades${params.fs}3.15.3" : null)
    conda (params.enable_conda ? 'bioconda::spades=3.15.3' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.3--h95f258a_0' :
        'quay.io/biocontainers/spades:3.15.3--h95f258a_0' }"

    input:
    tuple val(meta), path(illumina), path(pacbio), path(nanopore)

    output:
    path "${meta.id}${params.fs}*"
    tuple val(meta), path("${meta.id}${params.fs}scaffolds.fasta"), emit: assembly, optional: true
    tuple val(meta), path("${meta.id}${params.fs}spades.log")     , emit: log
    path  "versions.yml"                                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def maxmem = task.memory ? "--memory ${task.memory.toGiga()}" : ""
    def illumina_reads = illumina ? ( meta.single_end ? "-s $illumina" : "-1 ${illumina[0]} -2 ${illumina[1]}" ) : ""
    def pacbio_reads = !(pacbio.simpleName ==~ 'dummy_file.*') ? "--pacbio $pacbio" : ""
    def nanopore_reads = !(nanopore.simpleName ==~ 'dummy_file.*') ? "--nanopore $nanopore" : ""
    def custom_hmms = params.spades_hmm ? "--custom-hmms ${params.spades_hmm}" : ""
    """
    spades.py \\
        $args \\
        --threads $task.cpus \\
        $maxmem \\
        $custom_hmms \\
        $illumina_reads \\
        $pacbio_reads \\
        $nanopore_reads \\
        -o ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: \$(spades.py --version 2>&1 | sed 's/^.*SPAdes genome assembler v//; s/ .*\$//')
    END_VERSIONS
    """
}