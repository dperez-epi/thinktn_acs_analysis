#Benchmarks from various analyses

# youth_in_school.R benchmarks
#Presence of children benchmark https://data.census.gov/table?q=&text=presence+of+children&tid=ACSDT1Y2021.B25012  

acs_benchmarking <- acs %>% 
  mutate(age_bins2 = cut(age,
                         breaks = c(-Inf, 4, 9, 15, 19, 24, 34, 44, 54, 59, 64, 74, 84, Inf),
                         labels = c('5 under', '5-9','10-15','16-19','20-24','25-34','35-44','45-54','55-59','60-64',
                                    '65-74','75-84', '85+')))

# Count of population by age
# https://data.census.gov/table?t=Age+and+Sex&y=2021&d=ACS+1-Year+Estimates+Data+Profiles&tid=ACSDP1Y2021.DP05&moe=false
pop_age <- count(acs, age_bins, wt=perwt)
