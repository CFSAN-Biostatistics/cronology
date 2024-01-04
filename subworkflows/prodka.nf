// Include any necessary methods and modules
include { PRODIGAL                } from "${params.modules}${params.fs}prodigal${params.fs}main"
include { PROKKA                  } from "${params.modules}${params.fs}prokka${params.fs}main"

// Start the subworkflow
workflow PRODKA {
    take:
        trained_asm
        predict_asm

    main:
        PRODIGAL(
            trained_asm,
            (params.prodigal_f ?: 'gbk')
        )

        PROKKA( 
            predict_asm
                .join(PRODIGAL.out.proteins)
                .join(PRODIGAL.out.trained)
        )

        PRODIGAL.out.versions
            .mix( PROKKA.out.versions )
            .set{ versions }
    emit:
        prodigal_gene_annots     = PRODIGAL.out.gene_annotations
        prodigal_fna             = PRODIGAL.out.cds
        prodigal_faa             = PRODIGAL.out.proteins
        prodigal_all_gene_annots = PRODIGAL.out.all_gene_annotations
        prodigal_trained         = PRODIGAL.out.trained
        prokka_gff               = PROKKA.out.gff
        prokka_gbk               = PROKKA.out.gbk
        prokka_fna               = PROKKA.out.fna
        prokka_sqn               = PROKKA.out.sqn
        prokka_ffn               = PROKKA.out.ffn
        prokka_fsa               = PROKKA.out.fsa
        prokka_faa               = PROKKA.out.faa
        prokka_tbl               = PROKKA.out.tbl
        prokka_err               = PROKKA.out.err
        prokka_log               = PROKKA.out.log
        prokka_txt               = PROKKA.out.txt
        prokka_tsv               = PROKKA.out.tsv
        versions
}
