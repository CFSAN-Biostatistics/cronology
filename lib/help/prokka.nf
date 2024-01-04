// Help text for prokka within CPIPES.

def prokkaHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'prokka_run': [
            clihelp: 'Run prokka tool. Default: ' +
                (params.prokka_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'prokka_dbdir': [
            clihelp: 'Path to prokka database root folder. ' +
                "Default: ${params.prokka_dbdir}",
            cliflag: '--dbdir',
            clivalue: (params.prokka_dbdir ?: '')
        ],
        'prokka_addgenes': [
            clihelp: "Add 'gene' features for each 'CDS' feature. " +
                "Default: ${params.prokka_addgenes}",
            cliflag: '--addgenes',
            clivalue: (params.prokka_addgenes ? ' ' : '')
        ],
        'prokka_addmrna': [
            clihelp: "Add 'mRNA' features for each 'CDS' feature. " +
                "Default: ${params.prokka_addmrna}",
            cliflag: '--addmrna',
            clivalue: (params.prokka_addmrna ? ' ' : '')
        ],
        'prokka_locustag': [
            clihelp: "Locus tag prefix. " +
                "Default: ${params.prokka_locustag}",
            cliflag: '--locustag',
            clivalue: (params.prokka_locustag ?: '')
        ],
        'prokka_increment': [
            clihelp: "Locus tag counter increment. " +
                "Default: ${params.prokka_increment}",
            cliflag: '--increment',
            clivalue: (params.prokka_increment ?: '')
        ],
        'prokka_gffver': [
            clihelp: 'GFF version. ' +
                "Default: ${params.prokka_gffver}",
            cliflag: '-gffver',
            clivalue: (params.prokka_gffver ?: '')
        ],
        'prokka_compliant': [
            clihelp: ' Force Genbank/ENA/DDJB compliance i.e. ' +
                '--prokka_addgenes --prokka_mincontiglen 200 --prokka_centre XXX. ' +
                "Default: ${params.prokka_compliant}",
            cliflag: '--compliant',
            clivalue: (params.prokka_compliant ? ' ' : '')
        ],
        'prokka_centre': [
            clihelp: 'Sequencing centre ID. ' +
                "Default: ${params.prokka_centre}",
            cliflag: '--centre',
            clivalue: (params.prokka_centre ?: '')
        ],
        'prokka_accver': [
            clihelp: 'Version to put in GenBank file. ' +
                "Default: ${params.prokka_accver}",
            cliflag: '--accver',
            clivalue: (params.prokka_accver ?: '')
        ],
        'prokka_genus': [
            clihelp: 'Genus name. ' +
                "Default: ${params.prokka_genus}",
            cliflag: '--genus',
            clivalue: (params.prokka_genus ?: '')
        ],
        'prokka_species': [
            clihelp: 'Species name. ' +
                "Default: ${params.prokka_species}",
            cliflag: '--species',
            clivalue: (params.prokka_species ?: '')
        ],
        'prokka_strain': [
            clihelp: 'Strain name. ' +
                "Default: ${params.prokka_strain}",
            cliflag: '--strain',
            clivalue: (params.prokka_strain ?: '')
        ],
        'prokka_plasmid': [
            clihelp: 'Plasmid name or identifier. ' +
                "Default: ${params.prokka_plasmid}",
            cliflag: '--plasmid',
            clivalue: (params.prokka_plasmid ?: '')
        ],
        'prokka_kingdom': [
            clihelp: 'Annotation mode: Archaea|Bacteria|Mitochondria|Viruses. ' +
                "Default: ${params.prokka_kingdom}",
            cliflag: '--kingdom',
            clivalue: (params.prokka_kingdom ?: '')
        ],
        'prokka_gcode': [
            clihelp: 'Genetic code / Translation table (set if --prokka_kingdom is set). ' +
                "Default: ${params.prokka_gcode}",
            cliflag: '--gcode',
            clivalue: (params.prokka_gcode ?: '')
        ],
        'prokka_usegenus': [
            clihelp: 'Use genus-specific BLAST databases (needs --prokka_genus) ' +
                "Default: ${params.prokka_usegenus}",
            cliflag: '--usegenus',
            clivalue: (params.prokka_usegenus ? ' ' : '')
        ],
        'prokka_metagenome': [
            clihelp: 'Improve gene predictions for highly fragmented genomes. ' +
                "Default: ${params.prokka_metagenome}",
            cliflag: '--metagenome',
            clivalue: (params.prokka_metagenome ? ' ' : '')
        ],
        'prokka_rawproduct': [
            clihelp: 'Version to put in GenBank file. ' +
                "Default: ${params.prokka_rawproduct}",
            cliflag: '--rawproduct',
            clivalue: (params.prokka_rawproduct ?: '')
        ],
        'prokka_cdsrnaolap': [
            clihelp: 'Do not clean up /product annotation. ' +
                "Default: ${params.prokka_cdsrnaolap}",
            cliflag: '--cdsrnaolap',
            clivalue: (params.prokka_cdsrnaolap ? ' ' : '')
        ],
        'prokka_evalue': [
            clihelp: 'Similarity e-value cut-off. ' +
                "Default: ${params.prokka_evalue}",
            cliflag: '--evalue',
            clivalue: (params.prokka_evalue ?: '')
        ],
        'prokka_coverage': [
            clihelp: 'Minimum coverage on query protein. ' +
                "Default: ${params.prokka_coverage}",
            cliflag: '--coverage',
            clivalue: (params.prokka_coverage ?: '')
        ],
        'prokka_fast': [
            clihelp: 'Fast mode - only use basic BLASTP databases. ' +
                "Default: ${params.prokka_fast}",
            cliflag: '--fast',
            clivalue: (params.prokka_fast ? ' ' : '')
        ],
        'prokka_noanno': [
            clihelp: 'For CDS just set /product="unannotated protein". ' +
                "Default: ${params.prokka_noanno}",
            cliflag: '--noanno',
            clivalue: (params.prokka_noanno ? ' ' : '')
        ],
        'prokka_mincontiglen': [
            clihelp: 'Minimum contig size [NCBI needs 200]. ' +
                "Default: ${params.prokka_mincontiglen}",
            cliflag: '--mincontiglen',
            clivalue: (params.prokka_mincontiglen ?: '')
        ],
        'prokka_rfam': [
            clihelp: 'Enable searching for ncRNAs with Infernal+Rfam (SLOW!). ' +
                "Default: ${params.prokka_rfam}",
            cliflag: '--rfam',
            clivalue: (params.prokka_rfam ? ' ' : '')
        ],
        'prokka_norrna': [
            clihelp: "Don't run rRNA search. " +
                "Default: ${params.prokka_norrna}",
            cliflag: '--norrna',
            clivalue: (params.prokka_norrna ? ' ' : '')
        ],
        'prokka_notrna': [
            clihelp: "Don't run tRNA search. " +
                "Default: ${params.prokka_notrna}",
            cliflag: '--notrna',
            clivalue: (params.prokka_notrna ? ' ' : '')
        ],
        'prokka_rnammer': [
            clihelp: 'Prefer RNAmmer over Barrnap for rRNA prediction. ' +
                "Default: ${params.prokka_rnammer}",
            cliflag: '--rnammer',
            clivalue: (params.prokka_rnammer ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}