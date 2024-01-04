// Help text for prodigal within CPIPES.

def prodigalHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'prodigal_run': [
            clihelp: 'Run prodigal tool. Default: ' +
                (params.prodigal_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'prodigal_c': [
            clihelp: 'Closed ends. Do not allow genes to run off edges. ' +
                "Default: ${params.prodigal_c}",
            cliflag: '--c',
            clivalue: (params.prodigal_c ? ' ' : '')
        ],
        'prodigal_f': [
            clihelp: "Select output format (gbk, gff, or sco). " +
                "Default: ${params.prodigal_f}",
            cliflag: '-f',
            clivalue: (params.prodigal_f ?: '')
        ],
        'prodigal_g': [
            clihelp: "Specify translation table to use." +
                "Default: ${params.prodigal_g}",
            cliflag: '-g',
            clivalue: (params.prodigal_g ?: '')
        ],
        'prodigal_m': [
            clihelp: "Treat runs of N as masked sequence; don't build genes " +
                'across them. ' +
                "Default: ${params.prodigal_m}",
            cliflag: '-m',
            clivalue: (params.prodigal_m ? ' ' : '')
        ],
        'prodigal_n': [
            clihelp: 'Bypass Shine-Dalgarno trainer and force a full motif scan. ' +
                "Default: ${params.prodigal_n}",
            cliflag: '-n',
            clivalue: (params.prodigal_n ? ' ' : '')
        ],
        'prodigal_p': [
            clihelp: "Select procedure (single or meta). " +
                "Default: ${params.prodigal_p}",
            cliflag: '-p',
            clivalue: (params.prodigal_p ?: '')
        ],
        'prodigal_t': [
            clihelp: 'Write a training file (if none exists) ending in suffix `.trnd`; ' +
                'otherwise, read and use the specified training file. ' +
                "Default: ${params.prodigal_t}",
            cliflag: '-t',
            clivalue: (params.prodigal_t ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}