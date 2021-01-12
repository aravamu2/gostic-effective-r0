library(tidyverse)
library(lubridate)
library(openxlsx)
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
    outFile = "data/raw/WI_2020-11-17.rds"
)

args <- R.utils::commandArgs(trailingOnly = TRUE,
                             asValues = TRUE ,
                             defaults = defaultArgs)

## fetch the data and format it
df <- fetchData(
    state = args$state,
    rawData = args$outFile
    )

q()
