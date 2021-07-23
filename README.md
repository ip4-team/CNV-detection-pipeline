# Snakemake workflow for CNV detection on exome and custom target panel sequencing data
This repository provides a [Snakemake](https://snakemake.readthedocs.io/en/stable/) workflow to call CNVs on exome 
and custom target panel data by integrating multiple tools that employ read-depth during CNV detection:
* [CNVkit](https://cnvkit.readthedocs.io/en/stable/index.html)
* [CNVpytor](https://github.com/abyzovlab/CNVpytor)
* [ExomeDepth](https://github.com/vplagnol/ExomeDepth)

## Getting started
### 1. Dependencies
The workflow itself has multiple dependencies, but they're all installed using [conda](https://docs.conda.io/en/latest/).
Thus, **you'll need to have anaconda/conda installed on your computer**. We favor the usage of [miniconda](https://docs.conda.io/en/latest/miniconda.html) 
as it is small, and it's very useful to create virtual environments and to isolate the installation of tools.
You can learn more about managing environments with conda in their [user guide](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-with-commands).

### 2. Choose and download a workflow version from the [releases page]()
Even though you could just clone or download this repository, we strongly encourage you to get **the latest version** from the 
release page to allow for better reproducibility. That's because we make changes over time to the main branch to
improve the workflow and update the integrated tools when there are new releases.

### 3. Create and activate the conda virtual environment
With the workflow folder as the working directory, create the virtual environment by running:
```shell
conda env create --file workflow/envs/environment.yml
```
Installing all dependencies may take a while. After completion, activate the virtual environment with:
```shell
conda activate CNV-detection-pipeline
```

### 4. Test workflow installation
To check if the installation was successful, and that the workflow is working on your end, you can make a snakemake dry-run 
using the `-n` flag:
```shell
snakemake -n
```
This command builds and prints the jobs that should be executed, but don't actually run them. Note that
currently we're providing mock empty files to the workflow (resources/mocks). Thus, if you forget the `-n`, 
you'll encounter an execution error because the files are empty.

### 5. Configure the workflow
#### General settings
To configure this workflow, you need to modify `config/config.yaml` according to your needs.
There explanations on the file itself, but here are some considerations as well:

Actual data such as exomes, reference genomes are expected to be placed on the `resources` folder.
However, you don't need to copy or move them there, you can simply create a symbolic link on the `resources` folder
to the actual data.  For instance, considering that the exome files are on the directory `/home/valengo/data/exomes`,
we can create a symlink to them on `resources` directory with:
```shell
ln -s /home/valengo/data/exomes resources/exomes
```
In case you want to learn more about symbolic links, check out this [tutorial](https://www.freecodecamp.org/news/symlink-tutorial-in-linux-how-to-create-and-remove-a-symbolic-link/)
on *freeCodeCamp*.

#### Test and baseline samples
Add test samples to `config/test-samples.tsv` and baseline samples to `config/baseline-samples.tsv`.
Both are tab-delimited files. For each sample, define in the first column the sample name,
and the respective sex in the second column.

#### Sample regex: wildcards
We use wildcards to generalize the jobs, so they work in multiple datasets.
Hopefully, your exome files (baseline and test) follow some pattern, for example: NA12878, NA24385, NA24631.
Basically, you need to set the regular expression (regex) parameter named `common:sample-regex` in the `config/config.yaml` file.
A *regex* represents a search pattern, but they can be tricky.
Thus, we recommend reading about it on [Wikipedia](https://en.wikipedia.org/wiki/Regular_expression).
In addition, check out the Snakemake's docs on [wildcards](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#wildcards).
To easily test your  *regex*, you can use an online validator, such as [regex101](https://regex101.com).


#### Reference genome
It is best practice using the same reference build (if possible, even the same fasta file) that was used to align/map the reads.
In case the sequencer's workflow provides you with an aligned BAM,
it's probably possible to obtain the corresponding fasta file in the sequencer's server.
However, you can obtain reference genome fasta files on Genome Browsers, such as [Ensembl](https://www.ensembl.org/index.html) or [UCSC Genome Browser](https://genome.ucsc.edu).


### 6. Run workflow
After deploying and configuring the workflow, it can be executed as:
```shell
snakemake --cores all
```

# Limitations
* This pipeline is a work in progress and the current version is for amplicon based targets defined in a very specific BED file.
* The pipeline works in Linux distributions and macOS.


# Issues and suggestions
Having issues or suggestions using the workflow? You can contact us by creating an issue here on GitHub. We’ll be very happy in helping you.