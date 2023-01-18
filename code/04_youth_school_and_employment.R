# •	Share of youth age 16-24 that are not in school (both full- and part-time) or not employed (both full- and part-time).

acs_youths <- acs %>%
  #Create age bins to benchmark with https://data.census.gov/table?q=unemployment&tid=ACSST1Y2021.S2301&moe=false
  mutate(age_bins1 = cut(age,
                         breaks = c(-Inf, 4, 9, 15, 19, 24, 29, 34, 44, 54, 59, 64, 74, Inf),
                         labels = c('5 under', '5-9','10-15','16-19','20-24','25-29','30-34','35-44','45-54','55-59',
                                    '60-64','65-74', '75+'))) %>% 
  #clean empstat and create unemployment variable
  mutate(empstat = replace(empstat, empstat==0, NA),
         unemp = ifelse(empstat == 2, yes=1, no=0)) %>% 
  set_value_labels(unemp = c('Employed'=0, 'Unemployed'=1)) %>% 
  #clean school variable
  mutate(school = replace(school, school==0, NA),
         no_school = ifelse(school==1, yes=1, no=0)) %>%
  #variable unemployed or unenrolled
  mutate(unemp_or_noschool = ifelse(no_school==1 | unemp==1, yes=1, no=0))
  


youth_enrollment_employment <- acs_youths %>% 
  filter(age %in% c(16:24)) %>% 
  group_by(state) %>% 
  summarize(n=n(),
            total_pop = sum(perwt),
            unemployed = sum(perwt * unemp),
            urate = weighted.mean(unemp, w=perwt, na.rm=TRUE),
            unenrolled = sum(no_school * perwt),
            unenrolled_share = weighted.mean(no_school, w=perwt, na.rm=TRUE),
            unemp_or_unenrolled = sum(unemp_or_noschool * perwt),
            share_unemp_or_unenrolled = weighted.mean(unemp_or_noschool, w=perwt, na.rm=TRUE)) %>% 
  arrange(desc(share_unemp_or_unenrolled)) %>% 
  mutate(rank = dense_rank(desc(share_unemp_or_unenrolled)))


#Benchmarking
youth_school <-  acs_youths %>% 
  group_by(age_bins1) %>% 
  summarize(total_pop = sum(perwt),
            not_enrolled = sum(no_school*perwt, na.rm=TRUE),
            not_enrolled_share = weighted.mean(no_school, w=perwt, na.rm=TRUE))

unemployed_pop <- acs_youths %>% 
  group_by(age_bins1) %>% 
  summarize(labor_force = sum(perwt),
            employed = sum(perwt*unemp),
            urate = weighted.mean(unemp, w=perwt, na.rm=TRUE))
