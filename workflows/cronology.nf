// Define any required imports for this specific workflow
import java.nio.file.Paths
import nextflow.file.FileHelper

// Include any necessary methods
include { \
    summaryOfParams; stopNow; fastqEntryPointHelp; sendMail; conciseHelp; \
    addPadding; wrapUpHelp   } from "${params.routines}"
include { dpubmlstpyHelp     } from "${params.toolshelp}${params.fs}dpubmlstpy"
include { fastpHelp          } from "${params.toolshelp}${params.fs}fastp"
include { mashscreenHelp     } from "${params.toolshelp}${params.fs}mashscreen"
include { tuspyHelp          } from "${params.toolshelp}${params.fs}tuspy"
include { spadesHelp         } from "${params.toolshelp}${params.fs}spades"
include { shovillHelp        } from "${params.toolshelp}${params.fs}shovill"
include { polypolishHelp     } from "${params.toolshelp}${params.fs}polypolish"
include { mashtreeHelp       } from "${params.toolshelp}${params.fs}mashtree"
include { quastHelp          } from "${params.toolshelp}${params.fs}quast"
include { prodigalHelp       } from "${params.toolshelp}${params.fs}prodigal"
include { prokkaHelp         } from "${params.toolshelp}${params.fs}prokka"
include { pirateHelp         } from "${params.toolshelp}${params.fs}pirate"
include { mlstHelp           } from "${params.toolshelp}${params.fs}mlst"
include { abricateHelp       } from "${params.toolshelp}${params.fs}abricate"

// Exit if help requested before any subworkflows
if (params.help) {
    log.info help()
    exit 0
}

// Include any necessary modules and subworkflows
include { PROCESS_FASTQ            } from "${params.subworkflows}${params.fs}process_fastq"
include { PRODKA                   } from "${params.subworkflows}${params.fs}prodka"
include { DOWNLOAD_PUBMLST_SCHEME  } from "${params.modules}${params.fs}download_pubmlst_scheme${params.fs}main"
include { DOWNLOAD_REF_GENOME      } from "${params.modules}${params.fs}download_ref_genome${params.fs}main"
include { FASTP                    } from "${params.modules}${params.fs}fastp${params.fs}main"
include { MASH_SCREEN              } from "${params.modules}${params.fs}mash${params.fs}screen${params.fs}main"
include { TOP_UNIQUE_SEROVARS      } from "${params.modules}${params.fs}top_unique_serovars${params.fs}main"
include { CAT_UNIQUE               } from "${params.modules}${params.fs}cat${params.fs}unique${params.fs}main"
include { SPADES_ASSEMBLE          } from "${params.modules}${params.fs}spades${params.fs}assemble${params.fs}main"
include { SHOVILL                  } from "${params.modules}${params.fs}shovill${params.fs}main"
include { BWA_IDX_MEM              } from "${params.modules}${params.fs}custom${params.fs}bwa_idx_mem${params.fs}main"
include { POLYPOLISH               } from "${params.modules}${params.fs}polypolish${params.fs}main"
include { QUAST                    } from "${params.modules}${params.fs}quast${params.fs}main"
include { RMLST_POST               } from "${params.modules}${params.fs}rmlst${params.fs}main"
include { PIRATE                   } from "${params.modules}${params.fs}pirate${params.fs}main"
include { MASHTREE                 } from "${params.modules}${params.fs}mashtree${params.fs}main"
include { MLST                     } from "${params.modules}${params.fs}mlst${params.fs}main"
include { ABRICATE_RUN             } from "${params.modules}${params.fs}abricate${params.fs}run${params.fs}main"
include { ABRICATE_SUMMARY         } from "${params.modules}${params.fs}abricate${params.fs}summary${params.fs}main"
include { TABLE_SUMMARY            } from "${params.modules}${params.fs}cat${params.fs}tables${params.fs}main"
include { DUMP_SOFTWARE_VERSIONS   } from "${params.modules}${params.fs}custom${params.fs}dump_software_versions${params.fs}main"
include { MULTIQC                  } from "${params.modules}${params.fs}multiqc${params.fs}main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS AND ANY CHECKS FOR THE CRONOLOGY WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
def spades_custom_hmm = (params.spades_hmm ? file ( "${params.spades_hmm}" ) : false)
def reads_platform = 0
def abricate_dbs = [ 'ncbiamrplus', 'resfinder', 'megares', 'argannot' ]

reads_platform += (params.input ? 1 : 0)

if (spades_custom_hmm && !spades_custom_hmm.exists()) {
    stopNow("Please check if the following SPAdes' custom HMM directory\n" +
        "path is valid:\n${params.spades_hmm}\nCannot proceed further!")
}

if (reads_platform < 1 || reads_platform == 0) {
    stopNow("Please mention at least one absolute path to input folder which contains\n" +
            "FASTQ files sequenced using the --input option.\n" +
        "Ex: --input (Illumina or Generic short reads in FASTQ format)")
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN THE CRONOLOGY WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CRONOLOGY {
    main:
        ch_mqc_custom_tbl = Channel.empty()
        ch_dummy = Channel.fromPath("${params.dummyfile}")
        ch_dummy2 = Channel.fromPath("${params.dummyfile2}")

        log.info summaryOfParams()

        PROCESS_FASTQ()

        PROCESS_FASTQ.out.versions
            .set { software_versions }

        PROCESS_FASTQ.out.processed_reads
            .map { meta, fastq ->
                meta.sequence_sketch = (params.mash_sketch ?: null)
                [meta, fastq]              
            }
            .set { ch_processed_reads }

        DOWNLOAD_PUBMLST_SCHEME( params.dpubmlstpy_org ?: null )

        DOWNLOAD_REF_GENOME(
            (params.ref_acc ? ['id': params.ref_acc] : null)
        )

        FASTP( ch_processed_reads )

        FASTP.out.passed_reads
            .set { ch_processed_reads }

        FASTP.out.json
            .map { meta, json -> [ json ] }
            .collect()
            .set { ch_multiqc }

        MASH_SCREEN( ch_processed_reads )

        TOP_UNIQUE_SEROVARS( MASH_SCREEN.out.screened )

        TOP_UNIQUE_SEROVARS.out.tsv
            .map { meta, tsv -> tsv }
            .collectFile(
                name: 'iTOL_metadata_w_dups.txt',
                keepHeader: true,
                skip: 4,
                sort: true
            )
            .map { file ->
                def meta = [:]
                meta.id = 'Unique iTOL Metadata'
                meta.skip_header = 4
                [meta, file] 
            }
            .concat(
                TOP_UNIQUE_SEROVARS.out.popup
                    .map { meta, popup -> popup }
                    .collectFile(
                        name: 'iTOL_2_NCBI_Pathogens_w_dups.txt',
                        keepHeader: true,
                        skip: 3,
                        sort: true
                    )
                    .map { file ->
                        def meta = [:]
                        meta.id = 'Unique iTOL Popup'
                        meta.skip_header = 3
                        [meta, file] 
                    }
            )
            .set { ch_uniq }

        TOP_UNIQUE_SEROVARS.out.accessions
            .map { meta, acc -> acc }
            .splitText()
            .collect()
            .flatten()
            .unique()
            .collectFile(name: 'tree_genomes.txt')
            .map { genomes -> [ [id: 'hitsTree'], genomes ]}
            .set { ch_genomes_fofn }

        CAT_UNIQUE( ch_uniq )

        if (params.fq_single_end) {
            SPADES_ASSEMBLE(
                ch_processed_reads
                    .combine(ch_dummy)
                    .combine(ch_dummy2)
            )

            SPADES_ASSEMBLE.out.assembly
                .set{ ch_assembly }

            software_versions
                .mix( SPADES_ASSEMBLE.out.versions.ifEmpty(null) )
                .set { software_versions }
        } else {
            SHOVILL( ch_processed_reads )

            SHOVILL.out.contigs
                .set { ch_assembly }

            software_versions
                .mix( SHOVILL.out.versions.ifEmpty(null) )
                .set { software_versions }
        }

        if (params.polypolish_run) {
            BWA_IDX_MEM(
                ch_assembly
                    .join( ch_processed_reads )
            )

            POLYPOLISH( 
                ch_assembly
                    .join( BWA_IDX_MEM.out.aligned_sam )
            )

            POLYPOLISH.out.polished
                .set { ch_assembly }

            software_versions
                .mix( 
                    BWA_IDX_MEM.out.versions,
                    POLYPOLISH.out.versions
                )
                .set { software_versions }
        }

        ch_assembly
            .combine( DOWNLOAD_REF_GENOME.out.fasta )
            .combine( DOWNLOAD_REF_GENOME.out.gff )
            .multiMap { meta, consensus, fasta, gff ->
                sample_fa: consensus
                polished: [meta, consensus]
                ref_fasta: [meta, fasta]
                ref_gff: [meta, gff]
            }
            .set { ch_quast }

        MASHTREE(
            ch_genomes_fofn, 
            DOWNLOAD_REF_GENOME.out.fasta
                .concat( ch_quast.sample_fa )
                .collect()
        )

        PRODKA( 
            ch_quast.ref_fasta,
            ch_quast.polished
        )

        RMLST_POST( ch_assembly )

        MLST (
            ch_assembly
                .combine( DOWNLOAD_PUBMLST_SCHEME.out.pubmlst_dir )
        )

        QUAST(
            ch_quast.polished,
            ch_quast.ref_fasta,
            ch_quast.ref_gff
        )

        if (params.pirate_run) {
            PIRATE(
                PRODKA.out.prokka_gff
                    .map { meta, gff ->
                        tuple( [id: 'Predicted Genes'], gff )
                    }
                    .groupTuple(by: [0])
            )

            software_versions
                .mix( PIRATE.out.versions )
                .set { software_versions }
        }

        RMLST_POST.out.tsv
            .map { meta, tsv -> [ 'rmlst', tsv] }
            .groupTuple(by: [0])
            .map { it -> tuple ( it[0], it[1].flatten() ) }
            .set { ch_mqc_rmlst_tbl }

        MLST.out.tsv
            .map { meta, tsv -> [ 'mlst', tsv] }
            .groupTuple(by: [0])
            .map { it -> tuple ( it[0], it[1].flatten() ) }
            .set { ch_mqc_custom_tbl }

        ABRICATE_RUN ( ch_assembly, abricate_dbs )

        ABRICATE_RUN.out.abricated
            .map { meta, abres -> [ abricate_dbs, abres ] }
            .groupTuple(by: [0])
            .map { it -> tuple ( it[0], it[1].flatten() ) }
            .set { ch_abricated }

        ABRICATE_SUMMARY ( ch_abricated )

        ch_mqc_custom_tbl
            .concat (
                ch_mqc_rmlst_tbl,
                ABRICATE_SUMMARY.out.ncbiamrplus.map { it -> tuple ( it[0], it[1] )},
                ABRICATE_SUMMARY.out.resfinder.map { it -> tuple ( it[0], it[1] )},
                ABRICATE_SUMMARY.out.megares.map { it -> tuple ( it[0], it[1] )},
                ABRICATE_SUMMARY.out.argannot.map { it -> tuple ( it[0], it[1] )},
            )
            .groupTuple(by: [0])
            .map { it -> [ it[0], it[1].flatten() ]}
            .set { ch_mqc_custom_tbl }

        TABLE_SUMMARY ( ch_mqc_custom_tbl )

        DUMP_SOFTWARE_VERSIONS (
            software_versions
            .mix(
                    DOWNLOAD_PUBMLST_SCHEME.out.versions,
                    DOWNLOAD_REF_GENOME.out.versions,
                    FASTP.out.versions,
                    MASH_SCREEN.out.versions,
                    TOP_UNIQUE_SEROVARS.out.versions,
                    CAT_UNIQUE.out.versions,
                    MASHTREE.out.versions,
                    POLYPOLISH.out.versions,
                    QUAST.out.versions,
                    PRODKA.out.versions,
                    RMLST_POST.out.versions,
                    MLST.out.versions,
                    ABRICATE_RUN.out.versions,
                    ABRICATE_SUMMARY.out.versions,
                    TABLE_SUMMARY.out.versions
                )
                .unique()
                .collectFile(name: 'collected_versions.yml')
        )

        DUMP_SOFTWARE_VERSIONS.out.mqc_yml
            .concat (
                ch_multiqc,
                TABLE_SUMMARY.out.mqc_yml,
                PRODKA.out.prokka_txt.map { meta, txt -> txt },
                QUAST.out.results.map { meta, res -> res }
            )
            .collect()
            .set { ch_multiqc }

        MULTIQC( ch_multiqc )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ON COMPLETE, SHOW GORY DETAILS OF ALL PARAMS WHICH WILL BE HELPFUL TO DEBUG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (workflow.success) {
        sendMail()
    }
}

workflow.onError {
    sendMail()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP TEXT METHODS FOR CRONOLOGY WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def help() {

    Map helptext = [:]
    Map nH = [:]
    Map fastpAdapterHelp = [:]
    def uHelp = (params.help.getClass().toString() =~ /String/ ? params.help.tokenize(',').join(' ') : '')

    Map defaultHelp = [
        '--help dpubmlstpy' : 'Show dl_pubmlst_profiles_and_schemes.py CLI options CLI options',
        '--help fastp'      : 'Show fastp CLI options',
        '--help spades'     : 'Show mash `screen` CLI options',
        '--help shovill'    : 'Show shovill CLI options',
        '--help polypolish' : 'Show polypolish CLI options',
        '--help quast'      : 'Show quast.py CLI options',
        '--help prodigal'   : 'Show prodigal CLI options',
        '--help prokka'     : 'Show prokka CLI options',
        '--help pirate'     : 'Show priate CLI options',
        '--help mlst'       : 'Show mlst CLI options',
        '--help mash'       : 'Show mash `screen` CLI options',
        '--help tree'       : 'Show mashtree CLI options',
        '--help abricate'   : 'Show abricate CLI options\n'
    ]

    fastpAdapterHelp['--fastp_use_custom_adapaters'] = "Use custom adapter FASTA with fastp on top of " +
        "built-in adapter sequence auto-detection. Enabling this option will attempt to find and remove " +
        "all possible Illumina adapter and primer sequences but will make the workflow run slow. " +
        "Default: ${params.fastp_use_custom_adapters}"

    if (params.help.getClass().toString() =~ /Boolean/ || uHelp.size() == 0) {
        println conciseHelp('fastp,polypolish')
        helptext.putAll(defaultHelp)
    } else {
        params.help.tokenize(',').each { h ->
            if (defaultHelp.keySet().findAll{ it =~ /(?i)\b${h}\b/ }.size() == 0) {
                println conciseHelp('fastp,polypolish')
                stopNow("Tool [ ${h} ] is not a part of ${params.pipeline} pipeline.")
            }
        }

        helptext.putAll(
            fastqEntryPointHelp() +
            (uHelp =~ /(?i)\bdpubmlstpy/ ? dpubmlstpyHelp(params).text : nH) +
            (uHelp =~ /(?i)\bfastp/ ? fastpHelp(params).text + fastpAdapterHelp : nH) +
            (uHelp =~ /(?i)\bmash/ ? mashscreenHelp(params).text : nH) +
            (uHelp =~ /(?i)\btuspy/ ? tuspyHelp(params).text : nH) +
            (uHelp =~ /(?i)\bspades/ ? spadesHelp(params).text : nH) +
            (uHelp =~ /(?i)\bshovill/ ? shovillHelp(params).text : nH) +
            (uHelp =~ /(?i)\bpolypolish/ ? polypolishHelp(params).text : nH) +
            (uHelp =~ /(?i)\bquast/ ? quastHelp(params).text : nH) +
            (uHelp =~ /(?i)\bprodigal/ ? prodigalHelp(params).text : nH) +
            (uHelp =~ /(?i)\bprokka/ ? prokkaHelp(params).text : nH) +
            (uHelp =~ /(?i)\bpirate/ ? pirateHelp(params).text : nH) +
            (uHelp =~ /(?i)\bmlst/ ? mlstHelp(params).text : nH) +
            (uHelp =~ /(?i)\btree/ ? mashtreeHelp(params).text : nH) +
            (uHelp =~ /(?i)\babricate/ ? abricateHelp(params).text : nH) +
            wrapUpHelp()
        )
    }

    return addPadding(helptext)
}