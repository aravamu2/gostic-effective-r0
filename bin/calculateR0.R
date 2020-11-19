##  check if I need these here or in pullWIData.R
library(tidyverse)
library(lubridate)
library(janitor)
library(mgcv)
library(zoo)
library(EpiNow2)
library(future)

defaultArgs <- list (
    inFile = "data/processed/WI_2020-11-17.csv",
    countyIndex = 1,
    countyName = NULL,

    ## knobs for optimizing execution
    samples = 1000,
    warmup = 200, 
    cores = 2,
    chains = 2,

    outFile = "results/2020-11-17/out.csv"  
)

args <- R.utils::commandArgs(trailingOnly = TRUE,
                             asValues = TRUE ,
                             defaults = defaultArgs)

## read data   -----------
df <- read.csv(args$inFile, fileEncoding="UTF-8-BOM", stringsAsFactors = FALSE) 

## select county of interest  ---------
counties <- unique(df$name)
if (!is.null(args$countyName)) {
   county <- args$countyName
} else {
  county <- counties[as.numeric(args$countyIndex)]
}

df <- df %>%
  filter(name == county)

## priors for EpiNow2 -----------------
future::plan("multiprocess", gc = TRUE, earlySignal = TRUE, workers = 7)

reporting_delay <- EpiNow2::bootstrapped_dist_fit(rlnorm(100, log(6), 1))
reporting_delay$max <- 30
generation_time <- list(mean = EpiNow2::covid_generation_times[1, ]$mean,
                        mean_sd = EpiNow2::covid_generation_times[1, ]$mean_sd,
                        sd = EpiNow2::covid_generation_times[1, ]$sd,
                        sd_sd = EpiNow2::covid_generation_times[1, ]$sd_sd,
                        max = 30)
  
incubation_period <- list(mean = EpiNow2::covid_incubation_period[1, ]$mean,
                          mean_sd = EpiNow2::covid_incubation_period[1, ]$mean_sd,
                          sd = EpiNow2::covid_incubation_period[1, ]$sd,
                          sd_sd = EpiNow2::covid_incubation_period[1, ]$sd_sd,
                          max = 30)

## estimate R_eff  -------------------
df.master <- df %>% 
  group_by(name) %>% 
  select(date, case) %>%
  transmute(date = as.Date(date),
            confirm = round(case)) %>% 
  nest() %>% 
  mutate(
    estimate = list(
      EpiNow2::epinow(
        reported_cases = as.data.frame(data),
        generation_time = generation_time,
        delays = list(incubation_period, reporting_delay),
        horizon = 7,
        samples = as.numeric(args$samples),
        warmup = as.numeric(args$warmup),
        cores = as.numeric(args$cores),
        chains = as.numeric(args$chain),
        verbose = TRUE, 
        adapt_delta = 0.95
      )$plots$summary$data
    )
  ) %>% 
  select(-data) %>% 
  unnest(estimate)

write.csv(df.master, args$outFile, row.names = FALSE, quote = FALSE)
q()
