// Help text for sourmash tax metagenome within CPIPES.

def sourmashtaxmetagenomeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sourmashtaxmetagenome_run': [
            clihelp: 'Run `sourmash tax metagenome` tool. Default: ' +
                (params.sourmashtaxmetagenome_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sourmashtaxmetagenome_t': [
            clihelp: "Taxonomy CSV file. "
                + "Default: ${params.sourmashtaxmetagenome_t}",
            cliflag: '-t',
            clivalue: (params.sourmashtaxmetagenome_t ?: '')
        ],
        'sourmashtaxmetagenome_r': [
            clihelp: 'For non-default output formats: Summarize genome'
                + ' taxonomy at this rank and above. Note that the taxonomy CSV must'
                + ' contain lineage information at this rank.'
                + " Default: ${params.sourmashtaxmetagenome_r}",
            cliflag: '-r',
            clivalue: (params.sourmashtaxmetagenome_r ?: '')
        ],
        'sourmashtaxmetagenome_F': [
            clihelp: 'Choose output format. ' +
                "Default: ${params.sourmashtaxmetagenome_F}",
            cliflag: '--output-format',
            clivalue: (params.sourmashtaxmetagenome_F ?: '')
        ],
        'sourmashtaxmetagenome_f': [
            clihelp: 'Continue past errors in taxonomy database loading. ' +
                "Default: ${params.sourmashtaxmetagenome_f}",
            cliflag: '-f',
            clivalue: (params.sourmashtaxmetagenome_f ?: '')
        ],
        'sourmashtaxmetagenome_kfi': [
            clihelp: 'Do not split identifiers on whitespace. ' +
                "Default: ${params.sourmashtaxmetagenome_kfi}",
            cliflag: '--keep-full-identifiers',
            clivalue: (params.sourmashtaxmetagenome_kfi ? ' ' : '')
        ],
        'sourmashtaxmetagenome_kiv': [
            clihelp: 'After splitting identifiers do not remove accession versions. ' +
                "Default: ${params.sourmashtaxmetagenome_kiv}",
            cliflag: '--keep-identifier-versions',
            clivalue: (params.sourmashtaxmetagenome_kiv ?: '')
        ],
        'sourmashtaxmetagenome_fomt': [
            clihelp: 'Fail quickly if taxonomy is not available for an identifier. ' +
                "Default: ${params.sourmashtaxmetagenome_fomt}",
            cliflag: '--fail-on-missing-taxonomy',
            clivalue: (params.sourmashtaxmetagenome_fomt ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}