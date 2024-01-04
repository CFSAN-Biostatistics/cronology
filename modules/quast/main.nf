process QUAST {
    tag "$meta.id"
    label "process_micro"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}quast${params.fs}5.2.0" : null)
    conda (params.enable_conda ? "bioconda::quast=5.2.0 conda-forge::libgcc-ng" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/quast:5.2.0--py39pl5321h2add14b_1' :
        'biocontainers/quast:5.2.0--py39pl5321h2add14b_1' }"

    input:
        tuple val(meta) , path(consensus)
        tuple val(meta2), path(fasta)
        tuple val(meta3), path(gff)

    output:
        tuple val(meta), path("${prefix}")                  , emit: results
        tuple val(meta), path("${prefix}.quastreport.tsv")  , emit: tsv
        tuple val(meta), path("${prefix}_transcriptome.tsv"), emit: transcriptome, optional: true
        tuple val(meta), path("${prefix}_misassemblies.tsv"), emit: misassemblies, optional: true
        tuple val(meta), path("${prefix}_unaligned.tsv")    , emit: unaligned    , optional: true
        path "versions.yml"                                 , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args      = task.ext.args   ?: ''
        prefix        = task.ext.prefix ?: "${meta.id}"
        def reference = fasta ? "-r $fasta" : ''
        def features  = gff ?  "--features $gff" : ''
        """
        quast.py \\
            -l $prefix \\
            --output-dir $prefix \\
            $reference \\
            $features \\
            --threads $task.cpus \\
            $args \\
            ${consensus.join(' ')}

        ln -s ${prefix}/report.tsv ${prefix}.quastreport.tsv
        [ -f  ${prefix}/contigs_reports/all_alignments_transcriptome.tsv ] && ln -s ${prefix}/contigs_reports/all_alignments_transcriptome.tsv ${prefix}_transcriptome.tsv
        [ -f  ${prefix}/contigs_reports/misassemblies_report.tsv         ] && ln -s ${prefix}/contigs_reports/misassemblies_report.tsv ${prefix}_misassemblies.tsv
        [ -f  ${prefix}/contigs_reports/unaligned_report.tsv             ] && ln -s ${prefix}/contigs_reports/unaligned_report.tsv ${prefix}_unaligned.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS

        zcmd=""
        zver=""

        if type pigz > /dev/null 2>&1; then
            zcmd="pigz"
            zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed -e '1!d' | sed "s/\$zcmd //" )
        elif type gzip > /dev/null 2>&1; then
            zcmd="gzip"
        
            if [ "${workflow.containerEngine}" != "null" ]; then
                zver=\$( echo \$( \$zcmd --help 2>&1 ) | sed -e '1!d; s/ (.*\$//' )
            else
                zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed "s/^.*(\$zcmd) //; s/\$zcmd //; s/ Copyright.*\$//" )
            fi
        fi

        cat <<-END_VERSIONS >> versions.yml
            \$zcmd: \$zver
        END_VERSIONS
        """
}