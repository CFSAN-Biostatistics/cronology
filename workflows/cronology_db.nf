// Define any required imports for this specific workflow
import java.nio.file.Paths
import nextflow.file.FileHelper

// Include any necessary methods
include { \
    summaryOfParams; stopNow; fastqEntryPointHelp; sendMail; \
    addPadding; wrapUpHelp   } from "${params.routines}"
include { dpubmlstpyHelp     } from "${params.toolshelp}${params.fs}dpubmlstpy"
include { checkm2predictHelp } from "${params.toolshelp}${params.fs}checkm2predict"
include { guncrunHelp        } from "${params.toolshelp}${params.fs}guncrun"
include { mlstHelp           } from "${params.toolshelp}${params.fs}mlst"

// Exit if help requested before any subworkflows
if (params.help) {
    log.info help()
    exit 0
}

// Include any necessary modules and subworkflows
include { DOWNLOAD_PDG_METADATA    } from "${params.modules}${params.fs}download_pdg_metadata${params.fs}main"
include { DOWNLOAD_PUBMLST_SCHEME  } from "${params.modules}${params.fs}download_pubmlst_scheme${params.fs}main"
include { FILTER_PDG_METADATA      } from "${params.modules}${params.fs}filter_pdg_metadata${params.fs}main"
include { GUNC_RUN                 } from "${params.modules}${params.fs}gunc${params.fs}run${params.fs}main"
include { CHECKM2_PREDICT          } from "${params.modules}${params.fs}checkm2${params.fs}predict${params.fs}main"
include { QUAL_PASSED_GENOMES      } from "${params.modules}${params.fs}custom${params.fs}qual_passed_genomes${params.fs}main"
include { SCAFFOLD_GENOMES         } from "${params.modules}${params.fs}scaffold_genomes${params.fs}main"
include { MLST                     } from "${params.modules}${params.fs}mlst${params.fs}main"
include { INDEX_PDG_METADATA       } from "${params.modules}${params.fs}index_pdg_metadata${params.fs}main"
include { MASH_SKETCH              } from "${params.modules}${params.fs}mash${params.fs}sketch${params.fs}main"
include { MASH_PASTE               } from "${params.modules}${params.fs}mash${params.fs}paste${params.fs}main"
include { DUMP_SOFTWARE_VERSIONS   } from "${params.modules}${params.fs}custom${params.fs}dump_software_versions${params.fs}main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS AND ANY CHECKS FOR THE CRONOLOGY_DB WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (!params.output) {
    stopNow("Please mention the absolute UNIX path to store the DB flat files\n" +
            "using the --output option.\n" +
        "Ex: --output /path/to/cronology/db_files")
}

checkDBPathExists(params.guncrun_dbpath, 'GUNC')
checkDBPathExists(params.checkm2predict_dbpath, 'CheckM2')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN THE CRONOLOGY_DB WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CRONOLOGY_DB {
    main:
        log.info summaryOfParams()

        DOWNLOAD_PDG_METADATA ( params.pdg_release ?: null )

        DOWNLOAD_PDG_METADATA.out.versions
            .set { software_versions }

        DOWNLOAD_PUBMLST_SCHEME ( params.dpubmlstpy_org ?: null )

        FILTER_PDG_METADATA (
            DOWNLOAD_PDG_METADATA.out.accs
                .splitText(by: params.genomes_chunk, file: true)
        )

        FILTER_PDG_METADATA.out.accs_chunk_tbl
            .collectFile(sort: { acc_f -> acc_f.simpleName })
            .multiMap { acc_chunk_file ->
                def meta = [:]
                meta.id = 'AssemblyQC'
                meta.phone_ncbi = true
                gunc: [ meta, params.guncrun_dbpath, acc_chunk_file ]
                checkm2: [ meta, params.checkm2predict_dbpath, acc_chunk_file ]
            }
            .set { ch_run_qual_on_these_accs }

        CHECKM2_PREDICT ( ch_run_qual_on_these_accs.checkm2 )

        GUNC_RUN ( ch_run_qual_on_these_accs.gunc )

        QUAL_PASSED_GENOMES (
            CHECKM2_PREDICT.out.quality_report_passed
                .map { meta, qual ->
                    [ qual ]
                }
                .collect()
                .flatten()
                .collectFile(name: 'checkm2_quality_passed.txt'),
            GUNC_RUN.out.quality_report_passed
                .map { meta, qual ->
                    [ qual ]
                }
                .collect()
                .flatten()
                .collectFile(name: 'gunc_quality_passed.txt')
        )

        SCAFFOLD_GENOMES (
            QUAL_PASSED_GENOMES.out.accs
                .splitText(by: params.genomes_chunk, file: true)
        )

        SCAFFOLD_GENOMES.out.scaffolded
            .multiMap { scaffolded ->
                def meta = [:]
                meta.id = (params.pdg_release ?: 'NCBI Pathogen Genomes')
                mlst: [ meta, scaffolded ]
                mash: [ meta, scaffolded ]
            }
            .set { ch_scaffolded_genomes }

        MLST (
            ch_scaffolded_genomes.mlst
                .combine( DOWNLOAD_PUBMLST_SCHEME.out.pubmlst_dir )
        )

        MLST.out.tsv
            .map { meta, tsv -> 
                tsv
            }
            .collectFile(
                name: 'mlst_results.tsv',
                keepHeader: true,
                skip: 1
            )
            .set { ch_mlst_results }

        INDEX_PDG_METADATA (
            DOWNLOAD_PDG_METADATA.out.pdg_metadata,
            DOWNLOAD_PDG_METADATA.out.snp_cluster_metadata,
            DOWNLOAD_PDG_METADATA.out.accs,
            ch_mlst_results
        )

        MASH_SKETCH ( 
            ch_scaffolded_genomes.mash
                .map { it -> tuple ( it[0], it[1].flatten() ) }
        )

        MASH_PASTE (
            MASH_SKETCH.out.sketch
                .map { meta, sketch ->
                    [ [id: (params.pdg_release ?: 'NCBI Pathogen Genomes')], sketch ]
                }
                .groupTuple(by: [0])
        )

        DUMP_SOFTWARE_VERSIONS (
            software_versions
                .mix (
                    DOWNLOAD_PDG_METADATA.out.versions,
                    DOWNLOAD_PUBMLST_SCHEME.out.versions,
                    FILTER_PDG_METADATA.out.versions,
                    CHECKM2_PREDICT.out.versions,
                    GUNC_RUN.out.versions,
                    QUAL_PASSED_GENOMES.out.versions,
                    SCAFFOLD_GENOMES.out.versions,
                    MLST.out.versions,
                    INDEX_PDG_METADATA.out.versions,
                    MASH_SKETCH.out.versions,
                    MASH_PASTE.out.versions
                )
                .unique()
                .collectFile(name: 'collected_versions.yml')
        )
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
    METHOD TO CHECK IF DB PATHS EXIST
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def checkDBPathExists(db_path, msg) {
    db_path_obj = file( db_path )

    if (!db_path_obj.exists()) {
        stopNow("Please check if the database path for ${msg}\n" +
            "[ ${db_path} ]\nexists.")
    }
}/*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP TEXT METHODS FOR CRONOLOGY WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def help() {

    Map helptext = [:]

    helptext.putAll (
        fastqEntryPointHelp().findAll {
            it.key =~ /Required|output|Other|Workflow|Author|Version/
        } +
        dpubmlstpyHelp(params).text +
        checkm2predictHelp(params).text +
        guncrunHelp(params).text +
        wrapUpHelp()
    )

    return addPadding(helptext)
}