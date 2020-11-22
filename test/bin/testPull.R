library(tidyverse)
library(lubridate)
library(janitor)
library(mgcv)
library(zoo)
library(jsonlite) 
library(httr)

source("lib/pullData.R")

#### input arg
defaultArgs <- list (
    rawData = NULL,        ### cache the data after downloading
    state = "WI",
    inFile = "test/input/wiFetch.rds",
    beginDate = NULL,
    endDate   = NULL,
    outFile = "test/output/wiPull.csv"
)

args <- R.utils::commandArgs(trailingOnly = TRUE,
                             asValues = TRUE ,
                             defaults = defaultArgs)

## fetch the data and format it
raw <- readRDS(args$inFile)
if (args$state == "NY") {
    df <- formatNYData(raw,
                       as.Date(args$beginDate),
                       as.Date(args$endDate)
                       )
} else if (args$state == "WI") {
    df <- formatWIData(raw,
                       as.Date(args$beginDate),
                       as.Date(args$endDate)
                       )

}

write.csv(df, args$outFile, row.names = FALSE, quote = FALSE)
q()
