process CAT_UNIQUE {
    tag "${meta.id}"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}perl${params.fs}5.30.0" : null)
    conda (params.enable_conda ? "conda-forge::perl conda-forge::coreutils bioconda::perl-bioperl=1.7.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl-bioperl:1.7.8--hdfd78af_1' :
        'quay.io/biocontainers/perl-bioperl:1.7.8--hdfd78af_1' }"

    input:
        tuple val(meta), path(file)

    output:
        path '*_uniq.txt'  , emit: txt
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = (task.ext.args ?: '')
        def skip = (meta.skip_header ?: 1)
        prefix = (task.ext.prefix ?: meta.id)
        """
        newfile=\$(echo "$file" | sed -e 's/_w_dups/_uniq/g')

        head -n$skip "$file" > \$newfile
        tail -n+\$(($skip + 1)) "$file" | sort -n | uniq >> \$newfile

        uniqver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            uniqver=\$( uniq --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
            
        else
            uniqver=\$( uniq --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}": 
            head: \$uniqver
            tail: \$uniqver
            sort: \$uniqver
            uniq: \$uniqver
        END_VERSIONS
        """
}