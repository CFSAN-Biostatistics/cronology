process MASH_SKETCH {
    tag "${meta.id}"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}mash${params.fs}2.3" : null)
    conda (params.enable_conda ? "conda-forge::capnproto conda-forge::gsl bioconda::mash=2.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mash:2.3--he348c14_1':
        'quay.io/biocontainers/mash:2.3--he348c14_1' }"

    input:
        tuple val(meta), path(query)

    output:
        tuple val(meta), path("*.msh")               , emit: sketch
        tuple val(meta), path("*_mash_sketch.status"), emit: stats
        path "versions.yml"                          , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def queries = (query ? query.collect().join('\\n') : null)
        sleep(Math.round(params.genomes_chunk.toInteger()) as int * 100)
        """
        echo -e "$queries" > sketch_these.txt

        mash \\
            sketch \\
            -p $task.cpus \\
            -o "msh.${task.index}.k${params.mashsketch_k}.${params.mashsketch_s}h.${prefix}" \\
            $args \\
            -l sketch_these.txt \\
            2> ${prefix}_${task.index}_mash_sketch.status

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mash: \$( mash --version )
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}