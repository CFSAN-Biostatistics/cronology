# NextFlow DSL2 Module

```bash
MULTIQC
```

## Description

Generate an aggregated [**MultiQC**](https://multiqc.info/) report. This particular module **will only work** within the framework of `cpipes` as in, it uses many `cpipes` related UNIX absolute paths to store and retrieve **MultiQC** related configration files and `cpipes` context aware metadata. It also uses a custom logo with filename `FDa-Logo-Blue---medium-01.png` which should be located inside an `assets` folder from where the NextFlow script including this module will be executed.

\
&nbsp;

### `input:`

___

Type: `path`

Takes in NextFlow input type of `path` which points to many log files that **MultiQC** should parse.

Ex:

```groovy
[ '/data/sample1/centrifuge/cent_output.txt', '/data/sample1/kraken/kraken_output.txt'] ]
```

\
&nbsp;

### `output:`

___

#### `report`

Type: `path`

Outputs a NextFlow output type of `path` pointing to the location of **MultiQC** final HTML report.

\
&nbsp;

#### `data`

Type: `path`

NextFlow output type of `path` pointing to the data files folder generated by **MultiQC** which were used to generate plots and HTML report.

\
&nbsp;

#### `plots`

Type: `path`
Optional: `true`

NextFlow output type of `path` pointing to the plots folder generated by **MultiQC**.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.