process PRODIGAL {
    tag "$meta.id"
    label 'process_nano'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}prodigal${params.fs}2.6.3" : null)
    conda (params.enable_conda ? "bioconda::prodigal=2.6.3 conda-forge::pigz=2.6" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-2e442ba7b07bfa102b9cf8fac6221263cd746ab8:57f05cfa73f769d6ed6d54144cb3aa2a6a6b17e0-0' :
        'quay.io/biocontainers/mulled-v2-2e442ba7b07bfa102b9cf8fac6221263cd746ab8:57f05cfa73f769d6ed6d54144cb3aa2a6a6b17e0-0' }"

    input:
        tuple val(meta), path(genome)
        val(output_format)

    output:
        tuple val(meta), path("*.${output_format}"), emit: gene_annotations
        tuple val(meta), path("*.fna")             , emit: cds
        tuple val(meta), path("*.faa")             , emit: proteins
        tuple val(meta), path("*_all.txt")         , emit: all_gene_annotations
        tuple val(meta), path("*trn")              , emit: trained, optional: true
        path "versions.yml"                        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args          = task.ext.args   ?: ''
        def prefix        = task.ext.prefix ?: "${meta.id}"
        def training      = args.toString().matches(/.*-t/) ? "-t ${prefix}.trn" : ''
        args              = args.toString().replace(/-t/, '')
        """
        if [ "$training" = "-t ${prefix}.trn" ]; then
            touch "${prefix}.fna"
            touch "${prefix}.faa"
            touch "${prefix}_all.txt"
            touch "${prefix}.${output_format}"

            prodigal \\
                $training \\
                -i $genome
        fi

        prodigal \\
            $args \\
            -d "${prefix}.fna" \\
            -o "${prefix}.${output_format}" \\
            -a "${prefix}.faa" \\
            -s "${prefix}_all.txt" \\
            -i $genome

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            prodigal: \$(prodigal -v 2>&1 | sed -n 's/Prodigal V\\(.*\\):.*/\\1/p')
        END_VERSIONS
        """
}