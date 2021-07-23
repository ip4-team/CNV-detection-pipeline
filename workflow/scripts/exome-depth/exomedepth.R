# Title     : ExomeDepth
# Objective : To call CNVs using ExomeDepth
# Created by: valengo
# Created on: 16/06/21

library(optparse)
library(ExomeDepth)

option_list <- list(make_option(c("-r","--reference"), action = "store",
                                          type="character", help="reference sequence (fasta)"),
                    make_option(c("-t","--targets"), action = "store",
                                          type="character", help="targets file (bed)"),
                    make_option(c("-b", "--test-sample-bam", action = "store",
                                            type="character", help="test sample (bam)")),
                    make_option(c("-o", "--output", action = "store",
                                            type="character", help="output filename (tsv)"))
)
parsed_args <- parse_args(OptionParser(option_list = option_list), positional_arguments = TRUE)
baseline_bams <- unlist(strsplit(parsed_args$args, " "))
reference_fasta <- parsed_args$options$reference
targets_bed <- parsed_args$options$targets
test_sample_bam <- parsed_args$options$`test-sample-bam`
output_filename <- parsed_args$options$output

cat("baseline bams:", baseline_bams, "\n")
cat("fasta reference:", reference_fasta, "\n")
cat("targets bed:", targets_bed, "\n")
cat("test sample bam:", test_sample_bam, "\n")
cat("output filename:", output_filename, "\n")

baseline_counts <- getBamCounts(bed.file = targets_bed,
                                bam.files = baseline_bams,
                                referenceFasta = reference_fasta)

sample_test_counts <- getBamCounts(bed.file = targets_bed,
                                   bam.files = test_sample_bam,
                                   referenceFasta = reference_fasta)

test_sample_id <- unlist(tail(strsplit(test_sample_bam, "/")[[1]], 1))
cat("test sample id:", test_sample_id, "\n")

baseline_sample_ids <- vector("list", length(baseline_bams))
for (i in seq_along(baseline_bams)) {
  baseline_sample_ids[[i]] <- tail(strsplit(baseline_bams[i], "/")[[1]], 1)
}
baseline_sample_ids <- unlist(baseline_sample_ids)
cat("baseline sample ids:", baseline_sample_ids, "\n")

baseline_matrix <- as.matrix(baseline_counts[baseline_sample_ids])

selected_baseline <- select.reference.set(test.counts = as.matrix(sample_test_counts[test_sample_id]),
                                          reference.counts = baseline_matrix,
                                          bin.length = (baseline_counts$end - baseline_counts$start),
                                          n.bins.reduced = 10000)
selected_baseline_matrix <- as.matrix(baseline_counts[selected_baseline$reference.choice])
final_baseline <- apply(X = selected_baseline_matrix, MAR = 1, FUN = sum)

final_test_counts <- apply(sample_test_counts[test_sample_id[1]], MAR = 1, FUN = as.numeric)
all_targets <- new('ExomeDepth',
                   test = final_test_counts,
                   reference = final_baseline,
                   formula = 'cbind(test, reference) ~ 1')
all_targets <- CallCNVs(x = all_targets,
                 transition.probability = 10^-4,
                 chromosome = baseline_counts$chromosome,
                 start = baseline_counts$start,
                 end = baseline_counts$end,
                 name = baseline_counts$exon)

write.csv(file = output_filename,
          x = all_targets@CNV.calls,
          row.names = FALSE)