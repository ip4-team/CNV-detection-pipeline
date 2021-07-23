rule cnvpytor_detect_cnvs:
    input:
        test=get_bam_input
    output:
        root="results/cnvpytor/{sample}/{sample}.pytor",
        calls="results/cnvpytor/{sample}/{sample}_cnvs.csv"
    params:
        bin_size = 1000
    threads:
        1
    log:
        "logs/cnvpytor/{sample}.log"
    conda:
        "../envs/environment.yml"
    shell:
        """
        cnvpytor -root {output.root} -rd {input.test} --max_cores {threads} &&
        cnvpytor -root {output.root} -his {params.bin_size} --max_cores {threads} &&
        cnvpytor -root {output.root} -partition {params.bin_size} --max_cores {threads} &&
        cnvpytor -root {output.root} -call {params.bin_size} --max_cores {threads} > {output.calls} 2> {log}
        """
