from typing import List, Union

import pandas as pd
import glob
import re


def format(path: str = ''):
    return path.replace('//', '/')


def get_file(sample_id: str, files: List[str]) -> Union[str, None]:
    matching_files = list(filter(re.compile(f'{sample_id}').findall, files))
    if not matching_files:
        return None
    else:
        return matching_files[0]


def load_samples_table(sample_info_tsv: str, data_dir_path: str):
    table =  pd.read_table(sample_info_tsv, usecols=[0, 1], names=['id', 'sex'], header=None).set_index('id')
    bam_files = glob.glob(format(path=f'{data_dir_path}/*.bam'))
    vcf_files = glob.glob(format(path=f'{data_dir_path}/*.vcf.gz'))
    table.loc[:, 'bam_file'] = table.apply(lambda row: get_file(row.name, bam_files), axis=1, result_type='expand')
    table.loc[:, 'vcf_file'] = table.apply(lambda row: get_file(row.name, vcf_files), axis=1, result_type='expand')
    return table


test_samples = load_samples_table(config['test-samples']['table'], config['test-samples']['dir'])
baseline_samples = load_samples_table(config['baseline-samples']['table'], config['baseline-samples']['dir'])


def get_all_sample_ids():
    return list(test_samples.index) + list(baseline_samples.index)


def get_bam_input(wildcards):
    return pd.concat([test_samples, baseline_samples]).loc[wildcards.sample, 'bam_file']


def get_all_bam_files(wildcards):
    return pd.concat([test_samples, baseline_samples]).loc[:, 'bam_file']


def get_baseline_for_sample(wildcards):
    selected = baseline_samples[~baseline_samples.index.isin([wildcards.sample])]
    if config['common']['match-sex']:
        selected = selected[baseline_samples['sex'] == selected.loc[wildcards.sample, 'sex']]
    return selected.loc[:, 'bam_file']

