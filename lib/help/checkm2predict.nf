// Help text for checkm2 predict within CPIPES.

def checkm2predictHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'checkm2predict_run': [
            clihelp: 'Run `checkm2 predict` tool. Default: ' +
                (params.checkm2predict_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'checkm2predict_quiet': [
            clihelp: 'Only output errors. ' +
                "Default: ${params.checkm2predict_quiet}",
            cliflag: '--quiet',
            clivalue: (params.checkm2predict_quiet ? ' ' : '')
        ],
        'checkm2predict_lowmem': [
            clihelp: 'Low memory mode. Reduces DIAMOND blocksize to ' +
                'significantly reduce RAM usage at the expense of longer runtime. ' +
                "Default: ${params.checkm2predict_lowmem}",
            cliflag: '--lowmem',
            clivalue: (params.checkm2predict_lowmem ? ' ' : '')
        ],
        'checkm2predict_general': [
            clihelp: 'Force the use of the general quality prediction model (gradient boost). ' +
                "Default: ${params.checkm2predict_general}",
            cliflag: '--general',
            clivalue: (params.checkm2predict_general ? ' ' : '')
        ],
        'checkm2predict_specific': [
            clihelp: "Force the use of the specific quality prediction model (neural network) " +
                "Default: ${params.checkm2predict_specific}",
            cliflag: '--specific',
            clivalue: (params.checkm2predict_specific ? ' ' : '')
        ],
        'checkm2predict_allmodels': [
            clihelp: 'Output quality prediction for both models for each genome. ' +
                "Default: ${params.checkm2predict_allmodels}",
            cliflag: '--allmodels',
            clivalue: (params.checkm2predict_allmodels ? ' ' : '')
        ],
        'checkm2predict_genes': [
            clihelp: 'Treat input files as protein files. ' +
                "Default: ${params.checkm2predict_genes}",
            cliflag: '--genes',
            clivalue: (params.checkm2predict_genes ? ' ' : '')
        ],
        'checkm2predict_x': [
            clihelp: 'Extension of input files. ' +
                "Default: ${params.checkm2predict_x}",
            cliflag: '-x',
            clivalue: (params.checkm2predict_x ?: '')
        ],
        'checkm2predict_tmpdir': [
            clihelp: 'Specify an alternate directory for temporary files. ' +
                "Default: ${params.checkm2predict_tmpdir}",
            cliflag: '--tmpdir',
            clivalue: (params.checkm2predict_tmpdir ?: '')
        ],
        'checkm2predict_rminterfiles': [
            clihelp: 'Remove all intermediate files (protein files, diamond output). ' +
                "Default: ${params.checkm2predict_rminterfiles}",
            cliflag: '--remove_intermediates',
            clivalue: (params.checkm2predict_rminterfiles ? ' ' : '')
        ],
        'checkm2predict_ttable': [
            clihelp: 'Provide a specific progidal translation table for bins. The default ' +
                'value of false will automatically determine either 11 or 4. ' +
                "Default: ${params.checkm2predict_ttable}",
            cliflag: '--ttable',
            clivalue: (params.checkm2predict_ttable ? ' ' : '')
        ],
        'checkm2predict_dbg_cos': [
            clihelp: 'DEBUG: Write cosine similarity values to a file. ' +
                "Default: ${params.checkm2predict_dbg_cos}",
            cliflag: '--dbg_cos',
            clivalue: (params.checkm2predict_dbg_cos ? ' ' : '')
        ],
        'checkm2predict_dbg_vectors': [
            clihelp: 'DEBUG: Write Dump pickled feature vectors to a file. ' +
                "Default: ${params.checkm2predict_dbg_vectors}",
            cliflag: '--dbg_vectors',
            clivalue: (params.checkm2predict_dbg_vectors ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}