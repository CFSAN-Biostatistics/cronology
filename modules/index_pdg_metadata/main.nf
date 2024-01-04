process INDEX_PDG_METADATA {
    tag "index_pdg_metadata.py"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        path pdg_metadata
        path pdg_ref_snp_metadata
        path accs_all
        path mlst_results

    output:
        path "*.pickle"    , emit: index
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def mlst_results = (mlst_results ? "-mlst ${mlst_results}" : '')
        """
        index_pdg_metadata.py \\
            $mlst_results \\
            -pdg_dir "."

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """

}