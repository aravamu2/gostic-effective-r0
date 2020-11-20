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
    outFile = "data/processed/WI_2020-11-17.csv"
)

args <- R.utils::commandArgs(trailingOnly = TRUE,
                             asValues = TRUE ,
                             defaults = defaultArgs)

## fetch the data and format it
df <- pullData(state = args$state,rawData = args$rawData)
write.csv(df, args$outFile, row.names = FALSE, quote = FALSE)
q()
