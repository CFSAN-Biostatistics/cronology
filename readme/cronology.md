# cronology

`cronology` is an automated workflow for **_Cronobacter_** whole genome sequence assembly, subtyping and traceback based on [NCBI Pathogen Detection](https://www.ncbi.nlm.nih.gov/pathogens) Project for [Cronobacter](https://www.ncbi.nlm.nih.gov/pathogens/isolates/#taxgroup_name:%22Cronobacter%22). It uses `fastp` for read quality control, `shovill` and `polypolish` for **_de novo_** assembly and genome polishing, `prokka` for gene prediction and annotation, and `quast.py` for assembly quality metrics. User(s) can choose a gold standard reference genome as a model during gene prediction step with `prokka`. By default, `GCF_003516125` (**_Cronobacter sakazakii_**) is used.

In parallel, for each isolate, whole genome based (genome distances) traceback analysis is performed using `mash` and `mashtree` and the results are saved as a phylogenetic tree in `newick` format. Accompanying metadata generated can be uploaded to [iTOL](https://itol.embl.de/) for tree visualization.

User(s) can also run pangenome analysis using `pirate` but this will considerably increase the run time of the pipeline if the input has more than ~50 samples.

\
&nbsp;

<!-- TOC -->

- [Minimum Requirements](#minimum-requirements)
- [CFSAN GalaxyTrakr](#cfsan-galaxytrakr)
- [Usage and Examples](#usage-and-examples)
  - [Database](#database)
  - [Input](#input)
  - [Output](#output)
  - [Computational resources](#computational-resources)
  - [Runtime profiles](#runtime-profiles)
  - [your_institution.config](#your_institutionconfig)
  - [Cloud computing](#cloud-computing)
  - [Example data](#example-data)
- [cronology CLI Help](#cronology-cli-help)

<!-- /TOC -->

\
&nbsp;

## Minimum Requirements

1. [Nextflow version 23.04.3](https://github.com/nextflow-io/nextflow/releases/download/v23.04.3/nextflow).
    - Make the `nextflow` binary executable (`chmod 755 nextflow`) and also make sure that it is made available in your `$PATH`.
    - If your existing `JAVA` install does not support the newest **Nextflow** version, you can try **Amazon**'s `JAVA` (OpenJDK):  [Corretto](https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz).
2. Either of `micromamba` (version `1.0.0`) or `docker` or `singularity` installed and made available in your `$PATH`.
    - Running the workflow via `micromamba` software provisioning is **preferred** as it does not require any `sudo` or `admin` privileges or any other configurations with respect to the various container providers.
    - To install `micromamba` for your system type, please follow these [installation steps](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#linux-and-macos) and make sure that the `micromamba` binary is made available in your `$PATH`.
    - Just the `curl` step is sufficient to download the binary as far as running the workflows are concerned.
    - Once you have finished the installation, **it is important that you downgrade `micromamba` to version `1.0.0`**.

        ```bash
        micromamba self-update --version 1.0.0
        ```

3. Minimum of 10 CPU cores and about 60 GBs for main workflow steps. More memory may be required if your **FASTQ** files are big.

\
&nbsp;

## CFSAN GalaxyTrakr

The `cronology` pipeline is also available for use on the [Galaxy instance supported by CFSAN, FDA](https://galaxytrakr.org/). If you wish to run the analysis using **Galaxy**, please register for an account, after which you can run the workflow by selecting `cronology` under [`Metagenomics:CPIPES`](../assets/cronology_on_galaxytrakr.PNG) tool section.

Please note that the pipeline on [CFSAN GalaxyTrakr](https://galaxytrakr.org) in most cases may be a version older than the one on **GitHub** due to testing prioritization.

\
&nbsp;

## Usage and Examples

Clone or download this repository and then call `cpipes`.

```bash
cpipes --pipeline cronology [options]
```

Alternatively, you can use `nextflow` to directly pull and run the pipeline.

```bash
nextflow pull CFSAN-Biostatistics/cronology
nextflow list
nextflow info CFSAN-Biostatistics/cronology
nextflow run CFSAN-Biostatistics/cronology --pipeline cronology_db --help
nextflow run CFSAN-Biostatistics/cronology --pipeline cronology --help
```

\
&nbsp;

**Example**: Run the default `cronology` pipeline in single-end mode.

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes
      --pipeline cronology \
      --input /path/to/illumina/fastq/dir \
      --output /path/to/output \
      --cronology_root_dbdir /data/Kranti_Konganti/cronology_db/PDG000000043.213 \
      --fq_single_end true
```

\
&nbsp;

**Example**: Run the `cronology` pipeline in paired-end mode.

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes \
      --pipeline cronology \
      --input /path/to/illumina/fastq/dir \
      --output /path/to/output \
      --cronology_root_dbdir /data/Kranti_Konganti/cronology_db/PDG000000043.213 \
      --fq_single_end false
```

\
&nbsp;

### Database

---

Although users can choose to run the `cronology_db` pipeline, it requires access to HPC Cluster or a similar cloud setting. Since `GUNC` and `CheckM2` tools are used to filter out low quality assemblies, which require its own databases, the runtime is longer than usual. Therefore, the pre-formatted databases will be provided for download.

- Download the `PDG000000043.213` version of **NCBI Pathogens release** for **_Cronobacter_**: <https://research.foodsafetyrisk.org/cronology/PDG000000043.213.tar.bz2>.

\
&nbsp;

### Input

---

The input to the workflow is a folder containing compressed (`.gz`) FASTQ files. Please note that the sample grouping happens automatically by the file name of the FASTQ file. If for example, a single sample is sequenced across multiple sequencing lanes, you can choose to group those FASTQ files into one sample by using the `--fq_filename_delim` and `--fq_filename_delim_idx` options. By default, `--fq_filename_delim` is set to `_` (underscore) and `--fq_filename_delim_idx` is set to 1.

For example, if the directory contains FASTQ files as shown below:

- KB-01_apple_L001_R1.fastq.gz
- KB-01_apple_L001_R2.fastq.gz
- KB-01_apple_L002_R1.fastq.gz
- KB-01_apple_L002_R2.fastq.gz
- KB-02_mango_L001_R1.fastq.gz
- KB-02_mango_L001_R2.fastq.gz
- KB-02_mango_L002_R1.fastq.gz
- KB-02_mango_L002_R2.fastq.gz

Then, to create 2 sample groups, `apple` and `mango`, we split the file name by the delimitor (underscore in the case, which is default) and group by the first 2 words (`--fq_filename_delim_idx 2`).

This goes without saying that all the FASTQ files should have uniform naming patterns so that `--fq_filename_delim` and `--fq_filename_delim_idx` options do not have any adverse effect in collecting and creating a sample metadata sheet.

\
&nbsp;

### Output

---

All the outputs for each step are stored inside the folder mentioned with the `--output` option. A `multiqc_report.html` file inside the `cronology-multiqc` folder can be opened in any browser on your local workstation which contains a consolidated brief report. The tree metadata which can be uploaded to [iTOL](https://itol.embl.de/) for visualization will be located in the `cat_unique` folder.

\
&nbsp;

### Computational resources

---

The workflow `cronology` requires at least a minimum of 60 GBs of memory to successfully finish the workflow. By default, `cronology` uses 10 CPU cores where possible. You can change this behavior and adjust the CPU cores with `--max_cpus` option.

\
&nbsp;

Example:

```bash
cpipes \
    --pipeline cronology \
    --input /path/to/cronology_sim_reads \
    --output /path/to/cronology_sim_reads_output \
    --cronology_root_dbdir /path/to/PDG000000043.213
    --max_cpus 5 \
    -profile stdkondagac \
    -resume
```

\
&nbsp;

### Runtime profiles

---

You can use different run time profiles that suit your specific compute environments i.e., you can run the workflow locally on your machine or in a grid computing infrastructure.

\
&nbsp;

Example:

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes \
    --pipeline cronology \
    --input /path/to/fastq_pass_dir \
    --output /path/to/where/output/should/go \
    -profile your_institution
```

The above command would run the pipeline and store the output at the location per the `--output` flag and the **NEXTFLOW** reports are always stored in the current working directory from where `cpipes` is run. For example, for the above command, a directory called `CPIPES-cronology` would hold all the **NEXTFLOW** related logs, reports and trace files.

\
&nbsp;

### `your_institution.config`

---

In the above example, we can see that we have mentioned the run time profile as `your_institution`. For this to work, add the following lines at the end of [`computeinfra.config`](../conf/computeinfra.config) file which should be located inside the `conf` folder. For example, if your institution uses **SGE** or **UNIVA** for grid computing instead of **SLURM** and has a job queue named `normal.q`, then add these lines:

\
&nbsp;

```groovy
your_institution {
    process.executor = 'sge'
    process.queue = 'normal.q'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = false
    params.enable_conda = true
    conda.enabled = true
    conda.useMicromamba = true
    params.enable_module = false
}
```

In the above example, by default, all the software provisioning choices are disabled except `conda`. You can also choose to remove the `process.queue` line altogether and the `cronology` workflow will request the appropriate memory and number of CPU cores automatically, which ranges from 1 CPU, 1 GB and 1 hour for job completion up to 10 CPU cores, 1 TB and 120 hours for job completion.

\
&nbsp;

### Cloud computing

---

You can run the workflow in the cloud (works only with proper set up of AWS resources). Add new run time profiles with required parameters per [Nextflow docs](https://www.nextflow.io/docs/latest/executor.html):

\
&nbsp;

Example:

```groovy
my_aws_batch {
    executor = 'awsbatch'
    queue = 'my-batch-queue'
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    aws.batch.region = 'us-east-1'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = true
    params.conda_enabled = false
    params.enable_module = false
}
```

\
&nbsp;

### Example data

---

`cronology` was tested on multiple internal sequencing runs and also on publicly available WGS run data. Please make sure that you have all the [minimum requirements](#minimum-requirements) to run the workflow.

- Download public SRA data for **_Cronobacter_**: [SRR List](../assets/runs_public_cronobacter.txt). You can download a minimized set of sequencing runs for testing purposes.
- Download pre-formatted full database for **NCBI Pathogens release**: [PDG000000043.213](https://research.foodsafetyrisk.org/cronology/PDG000000043.213.tar.bz2) (~500 MB).
- After succesful run of the workflow, your **MultiQC** report should look something like [this](https://research.foodsafetyrisk.org/cronology/627_crono_multiqc_report.html).
- It is always a best practice to use absolute UNIX paths and real destinations of symbolic links during pipeline execution. For example, find out the real path(s) of your absolute UNIX path(s) and use that for the `--input` and `--output` options of the pipeline.

  ```bash
  realpath /hpc/scratch/user/input
  ```

Now, run the workflow:

\
&nbsp;

```bash
cpipes \
    --pipeline cronology \
    --input /path/to/sra_reads \
    --output /path/to/sra_reads_output \
    --cronology_root_dbdir /path/to/PDG000000043.213 \
    --fq_single_end false \
    --fq_suffix '_1.fastq.gz' --fq2_suffix '_2.fastq.gz' \
    -profile stdkondagac \
    -resume
```

Please note that the run time profile `stdkondagac` will run jobs locally using `micromamba` for software provisioning. The first time you run the command, a new folder called `kondagac_cache` will be created and subsequent runs should use this `conda` cache.

\
&nbsp;

## `cronology` CLI Help

```text
[Kranti_Konganti@my-unix-box ]$ cpipes --pipeline cronology --help
N E X T F L O W  ~  version 23.04.3
Launching `./cronology/cpipes` [jovial_colden] DSL2 - revision: 79ea031fad
================================================================================
             (o)                  
  ___  _ __   _  _ __    ___  ___ 
 / __|| '_ \ | || '_ \  / _ \/ __|
| (__ | |_) || || |_) ||  __/\__ \
 \___|| .__/ |_|| .__/  \___||___/
      | |       | |               
      |_|       |_|
--------------------------------------------------------------------------------
A collection of modular pipelines at CFSAN, FDA.
--------------------------------------------------------------------------------
Name                            : CPIPES
Author                          : Kranti.Konganti@fda.hhs.gov
Version                         : 0.7.0
Center                          : CFSAN, FDA.
================================================================================


--------------------------------------------------------------------------------
Show configurable CLI options for each tool within cronology
--------------------------------------------------------------------------------
Ex: cpipes --pipeline cronology --help
Ex: cpipes --pipeline cronology --help fastp
Ex: cpipes --pipeline cronology --help fastp,polypolish
--------------------------------------------------------------------------------
--help dpubmlstpy               : Show dl_pubmlst_profiles_and_schemes.py CLI
                                  options CLI options
--help fastp                    : Show fastp CLI options
--help spades                   : Show spades CLI options
--help shovill                  : Show shovill CLI options
--help polypolish               : Show polypolish CLI options
--help quast                    : Show quast.py CLI options
--help prodigal                 : Show prodigal CLI options
--help prokka                   : Show prokka CLI options
--help pirate                   : Show priate CLI options
--help mlst                     : Show mlst CLI options
--help mash                     : Show mash `screen` CLI options
--help tree                     : Show mashtree CLI options
--help abricate                 : Show abricate CLI options

```
