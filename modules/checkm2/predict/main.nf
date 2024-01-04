process CHECKM2_PREDICT {
    tag "$meta.id"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}checkm2${params.fs}1.0.1" : null)
    conda (params.enable_conda ? "conda-forge::scipy bioconda::checkm2=1.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/checkm2:1.0.1--pyh7cba7a3_0' :
        'quay.io/biocontainers/checkm2:1.0.1--pyh7cba7a3_0+' }"

    input:
        tuple val(meta), path(database_path), path(acc_chunk_file, stageAs: 'acc_chunk_file.txt')

    output:
        tuple val(meta), path("**${params.fs}*quality_report.tsv")       , emit: quality_report
        tuple val(meta), path("**${params.fs}*quality_report.passed.tsv"), emit: quality_report_passed
        path "versions.yml"                                              , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args          = task.ext.args ?: ''
        def prefix        = task.ext.prefix ?: "${meta.id}"
        def outdir        = prefix + (task.index ?: '')
        def fgq_py_args   = []
        fgq_py_args.addAll([
            ("${params.fgq_py_cm2_extract}" ? "-extract ${params.fgq_py_cm2_extract}" : "-extract Name"),
            ("${params.fgq_py_cm2_fcn}" ? "-fcn ${params.fgq_py_cm2_fcn}" : "-fcn 'Completeness_General,Contamination,Completeness_Specific'"),
            ("${params.fgq_py_cm2_fcv}" ? "-fcv ${params.fgq_py_cm2_fcv}" : "-fcv '97.5,1,99'"),
            ("${params.fgq_py_cm2_conds}" ? "-conds ${params.fgq_py_cm2_conds}" : "-conds '>=,<=,>='")
        ]) 
        """
        datasets download genome accession \\
            --dehydrated \\
            --inputfile $acc_chunk_file

        unzip ncbi_dataset.zip

        datasets rehydrate \\
            --gzip \\
            --max-workers $task.cpus \\
            --directory "."

        stage_ncbi_dataset_genomes.py -in ncbi_dataset

        checkm2 \\
            predict \\
            --threads ${task.cpus} \\
            --database_path $database_path \\
            --input unscaffolded \\
            --output_directory $outdir \\
            $args

        filter_genomes_by_qual.py \\
            -tsv $outdir${params.fs}quality_report.tsv \\
            -outprefix "${outdir}_" \\
            ${fgq_py_args.join(' ')}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            datasets: \$( datasets --version | sed 's/datasets version: //g' )
            python: \$( python --version | sed 's/Python //g' )
            checkm2: \$( checkm2 --version )
        END_VERSIONS
        """
}