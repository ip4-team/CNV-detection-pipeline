rule cnvkit_create_ampliseq_annotated_targets_file:
    input:
        config['exome']['targets'] if config['exome']['method'] == 'amplicon' else None
    output:
        "results/cnvkit/common/annotated-exome-targets.bed"
    log:
        "logs/cnvkit/create_ampliseq_annotated_targets_file.log"
    conda:
        "../envs/environment.yml"
    shell:
        "python workflow/scripts/create_intervals_with_genes_file.py --input {input} --output {output} 2> {log}"


rule cnvkit_detect_cnvs:
    input:
        baseline=get_baseline_for_sample,
        genome=config['reference']['fasta'],
        targets=rules.cnvkit_create_ampliseq_annotated_targets_file.output,
        test=get_bam_input
    output:
        dir=directory("results/cnvkit/{sample}"),
        reference="results/cnvkit/{sample}/{sample}_reference.cnn"
    params:
        exome_method=config['exome']['method']
    threads:
        4
    log:
        "logs/cnvkit/{sample}_batch.log"
    conda:
        "../envs/environment.yml"
    shell:
        """
        cnvkit.py batch {input.test} --normal {input.baseline} \
        --targets {input.targets} \
        --fasta {input.genome} \
        --output-reference {output.reference} --output-dir {output.dir} \
        --seq-method {params.exome_method} \
        -p {threads} \
        --diagram --scatter 2> {log}
        """
