process PROKKA {
    tag "$meta.id"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}prokka${params.fs}1.14.6" : null)
    conda (params.enable_conda ? "bioconda::prokka=1.14.6 conda-forge::perl" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/prokka:1.14.6--pl5321hdfd78af_4' :
        'quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_4' }"

    input:
        tuple val(meta), path(fasta), path(proteins), path(prodigal_tf)

    output:
        tuple val(meta), path("${prefix}/*.gff"), emit: gff
        tuple val(meta), path("${prefix}/*.gbk"), emit: gbk
        tuple val(meta), path("${prefix}/*.fna"), emit: fna
        tuple val(meta), path("${prefix}/*.faa"), emit: faa
        tuple val(meta), path("${prefix}/*.ffn"), emit: ffn
        tuple val(meta), path("${prefix}/*.sqn"), emit: sqn
        tuple val(meta), path("${prefix}/*.fsa"), emit: fsa
        tuple val(meta), path("${prefix}/*.tbl"), emit: tbl
        tuple val(meta), path("${prefix}/*.err"), emit: err
        tuple val(meta), path("${prefix}/*.log"), emit: log
        tuple val(meta), path("${prefix}/*.txt"), emit: txt
        tuple val(meta), path("${prefix}/*.tsv"), emit: tsv
        path "versions.yml" , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args         = task.ext.args   ?: ''
        def proteins_opt = proteins ? "--proteins ${proteins[0]}" : ""
        def prodigal_tf  = prodigal_tf ? "--prodigaltf ${prodigal_tf[0]}" : ""
        def prefix_l     = "${meta.id}" ?: ''
        prefix           = task.ext.prefix ?: "${meta.id}"
        def strain       = !params.prokka_strain && prefix_l ? "--strain '${prefix_l}'" : ''

        """
        prokka \\
            $strain \\
            $args \\
            --cpus $task.cpus \\
            --prefix $prefix \\
            $proteins_opt \\
            $prodigal_tf \\
            $fasta

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
        END_VERSIONS
        """
}