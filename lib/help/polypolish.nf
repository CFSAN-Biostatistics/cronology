// Help text for `polypolish within CPIPES.

def polypolishHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'polypolish_run': [
            clihelp: 'Run polypolish tool. Default: ' +
                (params.polypolish_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'polypolish_d': [
            clihelp: 'A base must occur at least this many times in the pileup to be considered valid. ' +
                "Default: ${params.polypolish_d}",
            cliflag: '-d',
            clivalue: (params.polypolish_d ?: '')
        ],
        'polypolish_i': [
            clihelp: 'A base must make up less than this fraction of the read depth to be considered invalid. ' +
                "Default: ${params.polypolish_i}",
            cliflag: '-i',
            clivalue: (params.polypolish_i ?: '')
        ],
        'polypolish_m': [
            clihelp: 'Ignore alignments with more than this many mismatches and indels. ' +
                "Default: ${params.polypolish_m}",
            cliflag: '-m',
            clivalue: (params.polypolish_m ?: '')
        ],
        'polypolish_v': [
            clihelp: 'A base must make up at least this fraction of the read depth to be considered valid. ' +
                "Default: ${params.polypolish_v}",
            cliflag: '-v',
            clivalue: (params.polypolish_v ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}