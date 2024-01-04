// Help text for ktImportText (krona) within CPIPES.

def kronaktimporttextHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'krona_ktIT_run': [
            clihelp: 'Run the ktImportText (ktIT) from krona. Default: ' +
                (params.krona_ktIT_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'krona_ktIT_n': [
            clihelp: 'Name of the highest level. ' +
                "Default: ${params.krona_ktIT_n}",
            cliflag: '-n',
            clivalue: (params.krona_ktIT_n ?: '')
        ],
        'krona_ktIT_q': [
            clihelp: 'Input file(s) do not have a field for quantity. ' +
                "Default: ${params.krona_ktIT_q}",
            cliflag: '-q',
            clivalue: (params.krona_ktIT_q ? ' ' : '')
        ],
        'krona_ktIT_c': [
            clihelp: 'Combine data from each file, rather than creating separate datasets '
                + 'within the chart. ' +
                "Default: ${params.krona_ktIT_c}",
            cliflag: '-c',
            clivalue: (params.krona_ktIT_c ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}