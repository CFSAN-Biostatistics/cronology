// Help text for `masurca's polca.sh` within CPIPES.

def masurcapolcaHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'masurcapolca_run': [
            clihelp: 'Run `polca.sh` from masurca. Default: ' +
                (params.masurcapolca_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'masurcapolca_n': [
            clihelp: 'Do not polish, just create vcf file, evaluate the assembly and exit. ' +
                "Default: ${params.masurcapolca_n}",
            cliflag: '-n',
            clivalue: (params.masurcapolca_n ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}