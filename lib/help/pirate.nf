// Help text for pirate within CPIPES.

def pirateHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'pirate_run': [
            clihelp: 'Run pirate tool. Default: ' +
                (params.pirate_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'pirate_steps': [
            clihelp: '% identity thresholds to use for pangenome construction. ' +
                "Default: ${params.pirate_steps}",
            cliflag: '-s',
            clivalue: (params.pirate_steps ?: '')
        ],
        'pirate_features': [
            clihelp: 'Choose features to use for pangenome construction. ' +
                'Multiple may be entered, seperated by a comma' +
                "Default: ${params.pirate_features}",
            cliflag: '-f',
            clivalue: (params.pirate_features ?: '')
        ],
        'pirate_nucl': [
            clihelp: 'CDS are not translated to AA sequence. ' +
                "Default: ${params.pirate_nucl}",
            cliflag: '-n',
            clivalue: (params.pirate_nucl ? ' ' : '')
        ],
        'pirate_pan_opt': [
            clihelp: 'Additional arguments to pass to pangenome_contruction. ' +
                "Default: ${params.pirate_pan_opt}",
            cliflag: '--pan-opt',
            clivalue: (params.pirate_pan_opt ?: '')
        ],
        'pirate_pan_off': [
            clihelp: "Don't run pangenome tool. " +
                "Default: ${params.pirate_pan_off}",
            cliflag: '--pan-off',
            clivalue: (params.pirate_pan_off ? ' ' : '')
        ],
        'pirate_min_len': [
            clihelp: 'Minimum length for feature extraction. ' +
                "Default: ${params.pirate_min_len}",
            cliflag: '--min-len',
            clivalue: (params.pirate_min_len ?: '')
        ],
        'pirate_para_off': [
            clihelp: 'Switch off paralog identification. ' +
                "Default: ${params.pirate_para_off}",
            cliflag: '--para-off',
            clivalue: (params.pirate_para_off ?: '')
        ],
        'pirate_para_args': [
            clihelp: 'Options to pass to paralog splitting algorithm. ' +
                "Default: ${params.pirate_para_args}",
            cliflag: '--para-args',
            clivalue: (params.pirate_para_args ?: '')
        ],
        'pirate_classify_off': [
            clihelp: 'Do not classify paralogs, assumes this has been ' +
                'run previously. ' +
                "Default: ${params.pirate_classify_off}",
            cliflag: '--classify-off',
            clivalue: (params.pirate_classify_off ? ' ' : '')
        ],
        'pirate_align': [
            clihelp: 'align all genes and produce core/pangenome alignments. ' +
                "Default: ${params.pirate_align}",
            cliflag: '--align',
            clivalue: (params.pirate_align ? ' ' : '')
        ],
        'pirate_rplots': [
            clihelp: 'Plot summaries using R. ' +
                "Default: ${params.pirate_rplots}",
            cliflag: '--rplots',
            clivalue: (params.pirate_rplots ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}