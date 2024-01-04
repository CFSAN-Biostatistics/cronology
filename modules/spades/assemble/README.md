# NextFlow DSL2 Module

```bash
SPADES_ASSEMBLE
```

## Description

Run `spades` assembler tool on a list of read files in FASTQ format.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of FASTQ files from various platforms of input type `path` (`illumina`, `pacbio`, `nanopore`).

Ex:

```groovy
[ [id: 'sample1', single_end: true], '/data/sample1/f_merged.fq.gz' ]
[ [id: 'sample1', single_end: false], ['/data/sample1/f1_merged.fq.gz', '/data/sample2/f2_merged.fq.gz'], ['/data/sample1/nanopore.fastq'], ['/data/sample1/pacbio.fastq'] ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTQ file.

Ex:

```groovy
[ id: 'FAL00870', strandedness: 'unstranded', single_end: true ]
```

\
&nbsp;

#### `illumina`

Type: `path`

NextFlow input type of `path` pointing to Illumina read files in FASTQ format that need to be *de novo* assembled along with reads from any other sequencing platforms, if any.

\
&nbsp;

#### `nanopore`

Type: `path`

NextFlow input type of `path` pointing to Oxford Nanopore read files in FASTQ format that need to be *de novo* assembled along with reads from any other sequencing platforms, if any.

\
&nbsp;

#### `pacbio`

Type: `path`

NextFlow input type of `path` pointing to PacBio read files in FASTQ format that need to be *de novo* assembled along with reads from any other sequencing platforms, if any.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'SPADES_ASSEMBLE' {
    ext.args = '--rna'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `spades` assembled scaffolds file in FASTA format.

\
&nbsp;

#### `assembly`

Type: `path`

NextFlow output type of `path` pointing to the `spades` assembler results file (`scaffolds.fasta`) per sample (`id:`) i.e., the final assembled scaffolds file in FASTA format.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
