process GUNC_RUN {
    tag "$meta.id"
    label 'process_medium'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}gunc${params.fs}1.0.5" : null)
    conda (params.enable_conda ? "conda-forge::pandas=1.5.1 bioconda::gunc=1.0.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gunc:1.0.5--pyhdfd78af_0' :
        'quay.io/biocontainers/gunc:1.0.5--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(database_path), path(fasta_ford, stageAs: 'fasta_ford.txt')

    output:
        tuple val(meta), path("**${params.fs}*maxCSS_level.tsv")        , emit: maxcss_level_tsv
        tuple val(meta), path("**${params.fs}*all_levels.tsv")          , emit: all_levels_tsv, optional: true
        tuple val(meta), path("**${params.fs}*.maxCSS_level.passed.tsv"), emit: quality_report_passed 
        path "versions.yml"                                             , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args        = task.ext.args ?: ''
        def prefix      = task.ext.prefix ?: "${meta.id}"
        def outdir      = prefix + (task.index ?: '')
        def input       = "${fasta_ford}"
        def fgq_py_args = []
        fgq_py_args.addAll([
            ("${params.fgq_py_gunc_extract}" ? "-extract ${params.fgq_py_gunc_extract}" : "-extract genome"),
            ("${params.fgq_py_gunc_fcn}" ? "-fcn ${params.fgq_py_gunc_fcn}" : "-fcn 'clade_separation_score,contamination_portion'"),
            ("${params.fgq_py_gunc_fcv}" ? "-fcv ${params.fgq_py_gunc_fcv}" : "-fcv '0.05,0.05'"),
            ("${params.fgq_py_gunc_conds}" ? "-conds ${params.fgq_py_gunc_conds}" : "-conds '<=,<='")
        ])
        if (params.guncrun_in_is_dir) {
            input = "--input_dir ${fasta_ford}"
        } else if (params.guncrun_in_is_fofn) {
            input = "--input_file ${fasta_ford}"
        } else if (params.guncrun_in_is_fasta) {
            input = "--input_fasta ${fasta_ford}"
        } else {
            input = "--input_dir unscaffolded"
        }
        """
        mkdir -p $outdir || exit 1

        datasets download genome accession \\
            --dehydrated \\
            --inputfile $fasta_ford

        unzip ncbi_dataset.zip

        datasets rehydrate \\
            --gzip \\
            --max-workers $task.cpus \\
            --directory "."

        stage_ncbi_dataset_genomes.py -in ncbi_dataset

        gunc \\
            run \\
            --db_file $database_path \\
            --threads $task.cpus \\
            --out_dir $outdir \\
            $input \\
            $args

        filter_genomes_by_qual.py \\
            -tsv $outdir${params.fs}GUNC.progenomes_2.1.maxCSS_level.tsv \\
            -outprefix "${outdir}_" \\
            ${fgq_py_args.join(' ')}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            datasets: \$( datasets --version | sed 's/datasets version: //g' )
            python: \$( python --version | sed 's/Python //g' )
            gunc: \$( gunc --version )
        END_VERSIONS
        """
}