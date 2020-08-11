## data prep



library(tidyverse)

data_covid <- read_csv("raw_data/covid_us_county.csv.gz", guess_max = 1e5)
data_demo <- read_csv("raw_data/acs2017_county_data.csv")
data_pres <- read_csv("raw_data/pres16results.csv")

data_demo <- data_demo %>%
  rename(fips = CountyId)

data_covid <- data_covid %>%
  filter(!is.na(county)) 

data_pres <- data_pres %>%
  mutate(fips = as.numeric(fips)) %>%
  filter(!is.na(fips)) %>%
  filter(cand == "Donald Trump")

data_covid_latest <- data_covid %>% group_by(fips) %>%
  arrange(desc(date)) %>% slice(1)

data_merged <- 
  data_covid_latest %>%
  inner_join(data_pres %>% select(!c(county, st, cand)), by = "fips") %>%
  inner_join(data_demo %>% select(!c(State, County)) %>%
               select(!ends_with("Err")), by = "fips") %>%
  mutate(cases_per1000 = cases / TotalPop * 1000) %>%
  mutate(deaths_per1000 = deaths / TotalPop * 1000)

write_csv(data_merged, "data/covid-data.csv.gz")



