% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_data.R
\name{process_all_surgery_files}
\alias{process_all_surgery_files}
\title{Process all surgery files in a folder and generate qc reports}
\usage{
process_all_surgery_files(
  data_folder,
  services,
  report_folder = file.path(dirname(data_folder), paste0(basename(data_folder),
    "_Reports")),
  pattern = "LAB-BB-CSRP-Surgery*"
)
}
\arguments{
\item{data_folder}{the folder containing the raw data}

\item{services}{the operating room services (surgery types) to analyze}

\item{report_folder}{the folder to write reports to, default is
data_folder with "_Reports" appended. Must exist.}

\item{pattern}{the pattern to distinguish surgery files, default
"LAB-BB-CSRP-Surgery*" appearing anywhere}
}
\value{
a combined dataset
}
\description{
Process all surgery files in a folder and generate qc reports
}
