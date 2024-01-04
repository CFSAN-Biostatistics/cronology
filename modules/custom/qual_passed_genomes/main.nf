process QUAL_PASSED_GENOMES {
    tag "Consolidate"
    label "process_micro"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        path acc_passed_tool1
        path acc_passed_tool2

    output:
        path 'accs_passed.txt', emit: accs
        path 'versions.yml'   , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.index ?: ''
        def output = 'accs_passed.txt'

        """
        qual_confirm.py \\
            -f1 $acc_passed_tool1  \\
            -f2 $acc_passed_tool2

        cat <<-END_VERSIONS >> versions.yml
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}