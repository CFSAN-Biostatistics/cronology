// Help text for dl_pubmlst_profiles_and_schemes.py (dpubmlstpy) within CPIPES.

def dpubmlstpyHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'dpubmlstpy_run': [
            clihelp: 'Run the dl_pubmlst_profiles_and_schemes.py ' +
                'script. Default: ' +
                (params.dpubmlstpy_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'dpubmlstpy_org': [
            clihelp: 'The organism name to download the MLST alleles ' +
                'FASTA and profile CSV for. ' +
                " Default: ${params.dpubmlstpy_org}",
            cliflag: '-org',
            clivalue: (params.dpubmlstpy_org ?: '')
        ],
        'dpubmlstpy_mlsts': [
            clihelp: 'The MLST scheme ID to download. ' +
                " Default: ${params.dpubmlstpy_mlsts}",
            cliflag: '-mlsts',
            clivalue: (params.dpubmlstpy_mlsts ?: '')
        ],
        'dpubmlstpy_profile': [
            clihelp: 'The MLST profile name in the scheme. ' +
                " Default: ${params.dpubmlstpy_profile}",
            cliflag: '-profile',
            clivalue: (params.dpubmlstpy_profile ?: '')
        ],
        'dpubmlstpy_loci': [
            clihelp: 'The key name in the JSON response which lists the ' +
                'allele URLs to download. ' +
                " Default: ${params.dpubmlstpy_loci}",
            cliflag: '-loci',
            clivalue: (params.dpubmlstpy_loci ?: '')
        ],
        'dpubmlstpy_suffix': [
            clihelp: 'What should be the suffix of the downloaded allele ' +
                'FASTA. ' +
                " Default: ${params.dpubmlstpy_suffix}",
            cliflag: '-suffix',
            clivalue: (params.dpubmlstpy_suffix ?: '')
        ],
        'dpubmlstpy_akey': [
            clihelp: 'What is the key in the JSON response that contains ' +
                'the URL for allele FASTA. ' +
                " Default: ${params.dpubmlstpy_akey}",
            cliflag: '-akey',
            clivalue: (params.dpubmlstpy_akey ?: '')
        ],
        'dpubmlstpy_id': [
            clihelp: 'What is the key in the JSON response that contains ' +
                'the name of the allele FASTA. ' +
                " Default: ${params.dpubmlstpy_id}",
            cliflag: '-id',
            clivalue: (params.dpubmlstpy_id ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}