// Help text for gunc run within CPIPES.

def guncrunHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'guncrun_run': [
            clihelp: 'Run `gunc run` tool. Default: ' +
                (params.guncrun_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'guncrun_in_is_fasta': [
            clihelp: 'Is input a file in FASTA format. ' +
                "Default: ${params.guncrun_in_is_fasta}",
            cliflag: null,
            clivalue: null
        ],
        'guncrun_in_is_fofn': [
            clihelp: 'Is input a file of file names. ' +
                "Default: ${params.guncrun_in_is_fofn}",
            cliflag: null,
            clivalue: null
        ],
        'guncrun_in_is_dir': [
            clihelp: 'Is input a directory of FASTA files. ' +
                "Default: ${params.guncrun_in_is_dir}",
            cliflag: null,
            clivalue: null
        ],
        'guncrun_file_suffix': [
            clihelp: "Suffix of files if input is a directory. " +
                "Default: ${params.guncrun_file_suffix}",
            cliflag: '--file_suffix',
            clivalue: (params.guncrun_file_suffix ?: '')
        ],
        'guncrun_gene_calls': [
            clihelp: 'Input files are in FASTA faa format. ' +
                "Default: ${params.guncrun_gene_calls}",
            cliflag: '--gene_calls',
            clivalue: (params.guncrun_gene_calls ? ' ' : '')
        ],
        'guncrun_temp_dir': [
            clihelp: 'Path to directory to store temp files. ' +
                "Default: ${params.guncrun_temp_dir}",
            cliflag: '--temp_dir',
            clivalue: (params.guncrun_temp_dir ?: '')
        ],
        'guncrun_sensitive': [
            clihelp: 'Run with high sensitivity. ' +
                "Default: ${params.guncrun_sensitive}",
            cliflag: '--sensitive',
            clivalue: (params.guncrun_sensitive ? ' ' : '')
        ],
        'guncrun_detailed_output': [
            clihelp: 'Output scores for every taxa level. ' +
                "Default: ${params.guncrun_detailed_output}",
            cliflag: '--detailed_output',
            clivalue: (params.guncrun_detailed_output ? ' ' : '')
        ],
        'guncrun_ctg_tax_output': [
            clihelp: 'Output assignments for each contig. ' +
                "Default: ${params.guncrun_ctg_tax_output}",
            cliflag: '--contig_taxonomy_output',
            clivalue: (params.guncrun_ctg_tax_output ? ' ' : '')
        ],
        'guncrun_use_species_lvl': [
            clihelp: 'Allow species level to be picked as maxCSS. ' +
                "Default: ${params.guncrun_use_species_lvl}",
            cliflag: '--use_species_level',
            clivalue: (params.guncrun_use_species_lvl ? ' ' : '')
        ],
        'guncrun_min_mapped_genes': [
            clihelp: 'Do not calculate GUNC score if number of mapped ' +
                'genes is below this value. ' +
                "Default: ${params.guncrun_min_mapped_genes}",
            cliflag: '--min_mapped_genes',
            clivalue: (params.guncrun_min_mapped_genes ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}