##  check if I need these here or in pullWIData.R
library(tidyverse)
library(lubridate)
library(janitor)
library(mgcv)
library(zoo)
library(EpiNow2)
library(future)

defaultArgs <- list (
    inFile = "data/WI_2020-11-12.csv",
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
df <- read.csv(args$inFile, fileEncoding="UTF-8-BOM", stringsAsFactors = FALSE) %>% 
  clean_names() %>% 
    select(name:test_new)

## select county of interest  ---------
counties <- unique(df$name)
if (!is.null(args$countyName)) {
   county <- args$countyName
} else {
  county <- counties[as.numeric(args$countyIndex)]
}

## transform case counts ----------
##   using smoothed positivity 
df <- df %>%
  filter(name == county) %>%
  mutate(date = ymd_hms(date)) %>% 
  group_by(name) %>% 
  arrange(desc(date)) %>% 
  mutate(positive = cummin(positive),
         negative = cummin(negative),
         deaths = cummin(deaths)) %>% 
  arrange(date) %>% 
  mutate(pos_new = positive - lag(positive, 1, 0),
         neg_new = negative - lag(negative, 1, 0),
         dth_new = deaths - lag(deaths, 1, 0)) %>% 
  mutate(tests = positive + negative,
         test_new = pos_new + neg_new,
         test_new = na.fill(test_new, "extend"),
         pos_rate = pos_new / test_new,
         pos_rate = na.fill(pos_rate, "extend")) %>% 
  nest() %>% 
  mutate(pos_rate_gam = map(data, function(df) fitted(gam(pos_rate ~ s(as.numeric(date)), data = df, family = "quasibinomial", weights = test_new)))) %>%
  unnest(cols = c(data, pos_rate_gam)) %>% 
  group_by(date) %>% 
  mutate(case = pos_new * (pos_rate_gam/quantile(pos_rate_gam, probs = 0.025, na.rm = TRUE))^0.1) %>% 
  ungroup()

## set up for EpiNow2 -----------------
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
## estimate R_eff


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
