library(tidyverse)
library(lubridate)
library(janitor)
library(mgcv)
library(zoo)
library(jsonlite) 
library(httr)

source("lib/pullTXData.R")
source("lib/pullData.R")

#### input arg
defaultArgs <- list (
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
if (!is.null(args$beginDate)) {
   args$beginDate <- as.Date(args$beginDate)
}
if (!is.null(args$endDate)) {
   args$endDate <- as.Date(args$endDate)
}

if (args$state == "NY") {
    df <- formatNYData(raw,
                       args$beginDate,
                       args$endDate
                       )
} else if (args$state == "WI") {
    df <- formatWIData(raw,
                       args$beginDate,
                       args$endDate
                       )

} else if (args$state == "TX") {
    df <- formatTXData(raw,
                       args$beginDate,
                       args$endDate
                       )

}

write.csv(df, args$outFile, row.names = FALSE, quote = FALSE)
q()
