import argparse
import sys

import pandas as pd
from bedhandler.handler import BedFileLoader


def parse_args(args) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Create a bed file with intervals and gene names only')
    parser.add_argument('-i', '--input', type=str, required=True, help='AmpliSeq Exome designed bed file')
    parser.add_argument('-o', '--output', type=str, required=True, help='output filename')

    return parser.parse_args(args)


def create_column_map(columns) -> dict:
    return {column: c for c, column in enumerate(columns)}


def get_type_map() -> dict:
    text_fields = ['chrom', 'region_id', 'gene']
    number_fields = ['chrom_start', 'chrom_end',
                     'gc_count', 'overlaps',
                     'fwd_e2e', 'rev_e2e',
                     'total_reads', 'fwd_reads', 'rev_reads',
                     'cov20x', 'cov100x', 'cov500x']
    self_fields = ['pools']
    text_dict = {field: str for field in text_fields}
    number_dict = {field: int for field in number_fields}
    self_dict = {field: lambda obj: obj for field in self_fields}
    return {**text_dict, **number_dict, **self_dict}


def build_dataframe(lines: list, columns: list, column_map: dict, type_map: dict):
    targets = [[type_map[column](line[column_map[column]]) for column in columns] for line in lines]
    return pd.DataFrame(targets, columns=columns)


if __name__ == '__main__':
    parsed_args = parse_args(sys.argv[1:])
    intervals = BedFileLoader(parsed_args.input)
    df = build_dataframe(intervals.expand_columns(), ['chrom', 'chrom_start', 'chrom_end', 'gene'],
                         create_column_map(intervals.columns), get_type_map())
    df.to_csv(parsed_args.output, sep='\t', index=False, header=False)
