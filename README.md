# `cronology`

`cronology` is an automated workflow for **_Cronobacter_** whole genome sequence assembly, subtyping and traceback based on [NCBI Pathogen Detection](https://www.ncbi.nlm.nih.gov/pathogens) Project for [Cronobacter](https://www.ncbi.nlm.nih.gov/pathogens/isolates/#taxgroup_name:%22Cronobacter%22). At present, only short-read data is supported with long-read support and hybrid assembly planned in future versions. Future roadmap also includes support for Metagenomics.

It is written in **Nextflow** and is part of the modular data analysis pipelines (**CFSAN PIPELINES** or **CPIPES** for short) at **CFSAN**.

\
&nbsp;

## Workflows

`cronology`: [README](./readme/cronology.md).

\
&nbsp;

### Citing `cronology`

---
This work is currently unpublished. Please cite our **GitHub** page.

>
>**cronology: An automated bioinformatics workflow for _Cronobacter_ whole genome sequence assembly, subtyping and traceback.**
>
>Kranti Konganti, Padmini Ramachandran, Monica Pava-Ripoll, Karen Jarvis, Maria Balkey, Ruth Timme, Gopal Gopinathrao, Yi Chen, and Chris Grim. _**CFSAN, FDA**_. [https://github.com/CFSAN-Biostatistics/cronology](https://github.com/CFSAN-Biostatistics/cronology).
>

\
&nbsp;

### Caveats

---

- The main workflow has been used for **research purposes** only.
- Analysis results should be interpreted with caution and should be treated as suspect, as the pipeline is dependent on the precision of metadata from the **NCBI Pathogen Detection** project.
- Internet access is required for succesful completion since the pipeline uses **Ribosomal MLST** (**RMLST**) for **_Cronobacter_** species identification using **PubMLST** API calls.

\
&nbsp;

### Acknowledgements

---
**NCBI Pathogen Detection**:

We gratefully acknowledge all data contributors, i.e., the Authors and their Originating laboratories responsible for obtaining the specimens, and their Submitting laboratories for generating the sequence and metadata and sharing it via the **NCBI Pathogen Detection** site, some of which this research utilizes.

\
&nbsp;

### Disclaimer

---
**CFSAN, FDA** assumes no responsibility whatsoever for use by other parties of the Software, its source code, documentation or compiled or uncompiled executables, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. Further, **CFSAN, FDA** makes no representations that the use of the Software will not infringe any patent or proprietary rights of third parties. The use of this code in no way implies endorsement by the **CFSAN, FDA** or confers any advantage in regulatory decisions.
