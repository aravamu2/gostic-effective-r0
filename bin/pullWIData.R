library(tidyverse)
library(lubridate)
library(janitor)
library(mgcv)
library(zoo)

outFile <- "data/processed/WI_2020-11-17.csv"

df <- read.csv("https://opendata.arcgis.com/datasets/5374188992374b318d3e2305216ee413_12.csv", fileEncoding="UTF-8-BOM", stringsAsFactors = FALSE) %>% 
  clean_names() %>% 
  select(name:test_new) %>% 
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

write.csv(df, outFile, row.names = FALSE, quote = FALSE)
