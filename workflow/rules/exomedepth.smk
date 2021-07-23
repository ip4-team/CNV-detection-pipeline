rule exomedepth_install_packages:
    output:
        "results/exomedepth/r/packages_were_installed.txt"
    params:
        repository=config['exome-depth']['repository']
    log:
        "logs/common/exomedepth_install_packages.log"
    conda:
        "../envs/environment.yml"
    shell:
        """
        Rscript --vanilla workflow/scripts/exome-depth/install-packages.R {params.repository} &&
        echo 'packages were installed!' > {output} 2> {log}
        """


rule exomedepth_create_ampliseq_annotated_targets_file:
    input:
        config['exome']['targets'] if config['exome']['method'] == 'amplicon' else None
    output:
        "results/exomedepth/common/annotated-exome-targets.bed"
    log:
        "logs/exomedepth/create_ampliseq_annotated_targets_file.log"
    conda:
        "../envs/environment.yml"
    shell:
        "python workflow/scripts/create_intervals_with_genes_file.py --input {input} --output {output} 2> {log}"


rule exomedepth_detect_cnvs:
    input:
        baseline=get_baseline_for_sample,
        genome=config['reference']['fasta'],
        targets=rules.exomedepth_create_ampliseq_annotated_targets_file.output,
        test=get_bam_input,
        packages=rules.exomedepth_install_packages.output
    output:
        "results/exomedepth/{sample}/{sample}_cnvs.csv"
    log:
        "logs/exomedepth/{sample}_exomedepth_detect_cnvs.log"
    conda:
        "../envs/environment.yml"
    shell:
        """
        Rscript --vanilla workflow/scripts/exome-depth/exomedepth.R \
        --reference {input.genome} \
        --targets {input.targets} \
        --test-sample-bam {input.test} \
        --output {output} \
        {input.baseline}
        """
