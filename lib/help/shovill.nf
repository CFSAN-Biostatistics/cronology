// Help text for shovill within CPIPES.

def shovillHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'shovill_run': [
            clihelp: 'Run shovill tool. Default: ' +
                (params.shovill_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'shovill_depth': [
            clihelp: 'Sub-sample R1/R2 to this depth. Disable with --shovill_depth 0. ' +
                "Default: ${params.shovill_depth}",
            cliflag: '--depth',
            clivalue: (params.shovill_depth ?: 150)
        ],
        'shovill_gsize': [
            clihelp: 'Estimated genome size eg. 3.2M. <false=AUTODETECT>. ' +
                "Default: ${params.shovill_gsize}",
            cliflag: '--gsize',
            clivalue: (params.shovill_gsize ?: '')
        ],
        'shovill_minlen': [
            clihelp: 'Minimum contig length. <false=AUTO>. ' +
                "Default: ${params.shovill_minlen}",
            cliflag: '--minlen',
            clivalue: (params.shovill_minlen ?: '')
        ],
        'shovill_mincov': [
            clihelp: "Minimum contig coverage. <false=AUTO>. " +
                "Default: ${params.shovill_mincov}",
            cliflag: '--mincov',
            clivalue: (params.shovill_mincov ?: '')
        ],
        'shovill_namefmt': [
            clihelp: "Format of contig FASTA IDs in 'printf' style. " +
                "Default: ${params.shovill_namefmt}",
            cliflag: '--namefmt',
            clivalue: (params.shovill_namefmt ?: '')
        ],
        'shovill_keepfiles': [
            clihelp: 'Keep intermediate files. ' +
                "Default: ${params.shovill_keepfiles}",
            cliflag: '--keepfiles',
            clivalue: (params.shovill_keepfiles ? ' ' : '')
        ],
        'shovill_assembler': [
            clihelp: 'Assembler: skesa, megahit, velvet, or spades. ' +
                "Default: ${params.shovill_assembler}",
            cliflag: '--assembler',
            clivalue: (params.shovill_assembler ?: '')
        ],
        'shovill_opts': [
            clihelp: "Extra assembler options in quotes. Ex: '--sc'. " +
                "Default: ${params.shovill_opts}",
            cliflag: '--opts',
            clivalue: (params.shovill_opts ?: '')
        ],
        'shovill_kmers': [
            clihelp: 'K-mers to use. <false=AUTO>. ' +
                "Default: ${params.shovill_kmers}",
            cliflag: '--kmers',
            clivalue: (params.shovill_kmers ?: '')
        ],
        'shovill_trim': [
            clihelp: 'Enable adator trimming. ' +
                "Default: ${params.shovill_trim}",
            cliflag: '--trim',
            clivalue: (params.shovill_trim ? ' ' : '')
        ],
        'shovill_noreadcorr': [
            clihelp: 'Disable read error correction. ' +
                "Default: ${params.shovill_noreadcorr}",
            cliflag: '--noreadcorr',
            clivalue: (params.shovill_noreadcorr ? ' ' : '')
        ],
        'shovill_nostitch': [
            clihelp: 'Disable read stitching. ' +
                "Default: ${params.shovill_nostitch}",
            cliflag: '--nostitch',
            clivalue: (params.shovill_nostitch ? ' ' : '')
        ],
        'shovill_nocorr': [
            clihelp: 'Disable post-assembly correction. ' +
                "Default: ${params.shovill_nocorr}",
            cliflag: '--nocorr',
            clivalue: (params.shovill_nocorr ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}