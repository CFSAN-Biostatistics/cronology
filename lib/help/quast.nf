// Help text for quast within CPIPES.

def quastHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'quast_run': [
            clihelp: 'Run quast tool. Default: ' +
                (params.quast_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'quast_min_contig': [
            clihelp: 'Lower threshold for contig length. ' +
                "Default: ${params.quast_min_contig}",
            cliflag: '-m',
            clivalue: (params.quast_min_contig ?: '')
        ],
        'quast_split_scaffolds': [
            clihelp: "Split assemblies by continuous fragments of N's" +
                'and add such "contigs" to the comparison' +
                "Default: ${params.quast_split_scaffolds}",
            cliflag: '-s',
            clivalue: (params.quast_split_scaffolds ? ' ' : '')
        ],
        'quast_euk': [
            clihelp: 'Genome is eukaryotic (primarily affects gene prediction). ' +
                "Default: ${params.quast_euk}",
            cliflag: '-e',
            clivalue: (params.quast_euk ? ' ' : '')
        ],
        'quast_fungal': [
            clihelp: 'Genome is fungal (primarily affects gene prediction). ' +
                "Default: ${params.quast_fungal}",
            cliflag: '--fungal',
            clivalue: (params.quast_fungal ? ' ' : '')
        ],
        'quast_large': [
            clihelp: 'Use optimal parameters for evaluation of large genomes' +
                "In particular, imposes '-e -m 3000 -i 500 -x 7000'." +
                "Default: ${params.quast_large}",
            cliflag: '--large',
            clivalue: (params.quast_large ? ' ' : '')
        ],
        'quast_k': [
            clihelp: 'Compute k-mer-based quality metrics (recommended for large genomes). ' +
                "Default: ${params.quast_k}",
            cliflag: '-k',
            clivalue: (params.quast_k ? ' ' : '')
        ],
        'quast_kmer_size': [
            clihelp: 'Size of k used in --quast_k. ' +
                "Default: ${params.quast_kmer_size}",
            cliflag: '--k-mer-size',
            clivalue: (params.quast_kmer_size ?: 101)
        ],
        'quast_circos': [
            clihelp: 'Draw circos plot. ' +
                "Default: ${params.quast_circos}",
            cliflag: '--circos',
            clivalue: (params.quast_circos ? ' ' : '')
        ],
        'quast_glimmer': [
            clihelp: 'Use GlimmerHMM for gene prediction. ' +
                "Default: ${params.quast_glimmer}",
            cliflag: '--glimmer',
            clivalue: (params.quast_glimmer ? ' ' : '')
        ],
        'quast_gene_thr': [
            clihelp: 'Comma-separated list of threshold lengths of genes to ' +
                'search with Gene Finding module. ' +
                "Default: ${params.quast_gene_thr}",
            cliflag: '--gene-thresholds',
            clivalue: (params.quast_gene_thr ?: '')
        ],
        'quast_rna_finding': [
            clihelp: 'Predict ribosomal RNA genes using Barrnap. ' +
                "Default: ${params.quast_rna_finding}",
            cliflag: '--rna-finding',
            clivalue: (params.quast_rna_finding ? ' ' : '')
        ],
        'quast_ref_size': [
            clihelp: 'Estimated reference size in-case the reference genome is not supplied. ' +
                "Default: ${params.quast_ref_size}",
            cliflag: '--est-ref-size',
            clivalue: (params.quast_ref_size ?: '')
        ],
        'quast_ctg_thr': [
            clihelp: 'Comma-separated list of contig length thresholds. ' +
                "Default: ${params.quast_ctg_thr}",
            cliflag: '--contig-thresholds',
            clivalue: (params.quast_ctg_thr ?: '')
        ],
        'quast_x_for_nx': [
            clihelp: "Value of 'x' for Nx, Lx, etc metrics reported in addition to N50, L50, etc. " +
                "Default: ${params.quast_x_for_nx}",
            cliflag: '--x-for-Nx',
            clivalue: (params.quast_x_for_nx ?: '')
        ],
        'quast_use_all_alns': [
            clihelp: 'Compute genome fraction, # genes, # operons in QUAST v1.* style. ' +
                "By default, QUAST filters Minimap's alignments to keep only best ones. " +
                "Default: ${params.quast_glimmer}",
            cliflag: '--use-all-alignments',
            clivalue: (params.quast_use_all_alns ? ' ' : '')
        ],
        'quast_min_alignment': [
            clihelp: 'The minimum alignment length. ' +
                "Default: ${params.quast_min_alignment}",
            cliflag: '-i',
            clivalue: (params.quast_min_alignment ?: '')
        ],
        'quast_min_identity': [
            clihelp: 'The minimum alignment identity (80.0, 100.0). ' +
                "Default: ${params.quast_min_identity}",
            cliflag: '--min-identity',
            clivalue: (params.quast_min_identity ?: '')
        ],
        'quast_ambig_usage': [
            clihelp: 'Use none, one, or all alignments of a contig when all of them. ' +
                'are almost equally good (see --quast_ambig_score). ' +
                "Default: ${params.quast_ambig_usage}",
            cliflag: '-a',
            clivalue: (params.quast_ambig_usage ?: '')
        ],
        'quast_ambig_score': [
            clihelp: 'Score S for defining equally good alignments of a single contig. ' +
                'All alignments are sorted by decreasing LEN * IDY% value. ' +
                'All alignments with LEN * IDY% < S * best(LEN * IDY%) are ' +
                'discarded. S should be between 0.8 and 1.0. ' +
                "Default: ${params.quast_ambig_score}",
            cliflag: '--ambiguity-score',
            clivalue: (params.quast_ambig_score ?: '')
        ],
        'quast_strict_na': [
            clihelp: 'Break contigs in any misassembly event when compute NAx and NGAx. '+
                'By default, QUAST breaks contigs only by extensive misassemblies (not local ones). ' +
                "Default: ${params.quast_strict_na}",
            cliflag: '--strict-NA',
            clivalue: (params.quast_strict_na ?: '')
        ],
        'quast_x': [
            clihelp: 'Lower threshold for extensive misassembly size. All relocations with inconsistency ' +
                'less than extensive-mis-size are counted as local misassemblies. ' +
                "Default: ${params.quast_x}",
            cliflag: '-x',
            clivalue: (params.quast_x ?: '')
        ],
        'quast_local_mis_size': [
            clihelp: 'Lower threshold on local misassembly size. Local misassemblies with inconsistency ' +
                'less than local-mis-size are counted as (long) indels. ' +
                "Default: ${params.quast_local_mis_size}",
            cliflag: '--local-mis-size',
            clivalue: (params.quast_local_mis_size ?: '')
        ],
        'quast_sca_gap_size': [
            clihelp: 'Max allowed scaffold gap length difference. All relocations with inconsistency ' +
                'less than scaffold-gap-size are counted as scaffold gap misassemblies. ' +
                "Default: ${params.quast_sca_gap_size}",
            cliflag: '--scaffold-gap-max-size',
            clivalue: (params.quast_sca_gap_size ?: '')
        ],
        'quast_unaln_part_size': [
            clihelp: 'Lower threshold for detecting partially unaligned contigs. Such contig should have ' +
                'at least one unaligned fragment >= the threshold. ' +
                "Default: ${params.quast_unaln_part_size}",
            cliflag: '--unaligned-part-size',
            clivalue: (params.quast_unaln_part_size ?: '')
        ],
        'quast_skip_unaln_mis_ctgs': [
            clihelp: 'Do not distinguish contigs with >= 50% unaligned bases as a separate group ' +
                'By default, QUAST does not count misassemblies in them. ' +
                "Default: ${params.quast_skip_unaln_mis_ctgs}",
            cliflag: '--skip-unaligned-mis-contigs',
            clivalue: (params.quast_skip_unaln_mis_ctgs ?: '')
        ],
        'quast_fragmented': [
            clihelp: 'Reference genome may be fragmented into small pieces (e.g. scaffolded reference). ' +
                "Default: ${params.quast_fragmented}",
            cliflag: '--fragmented',
            clivalue: (params.quast_fragmented ? ' ' : '')
        ],
        'quast_frag_max_ident': [
            clihelp: 'Mark translocation as fake if both alignments are located no further than N bases ' +
                'from the ends of the reference fragments. ' +
                "Default: ${params.quast_frag_max_ident}",
            cliflag: '--fragmented-max-indent',
            clivalue: (params.quast_frag_max_ident ?: '')
        ],
        'quast_plots_format': [
            clihelp: 'Save plots in specified format [default: pdf]. ' +
                'Supported formats: emf, eps, pdf, png, ps, raw, rgba, svg, svgz' +
                "Default: ${params.quast_plots_format}",
            cliflag: '--plots-format',
            clivalue: (params.quast_plots_format ?: '')
        ],
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}