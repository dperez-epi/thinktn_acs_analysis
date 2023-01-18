## This script calculates	the ratio of median household income at the 80th percentile to median household income at the 20th percentile.

hhincomes <- acs_household %>% 
  summarise(med_hhincome = median(hhincome, na.rm=TRUE),
            avg_hhincome = weighted.mean(hhincome, w=hhwt, na.rm=TRUE))

hhincome_8020_ratios <- acs_household %>% 
  #Calculate 80th and 20th quantiles by state
  group_by(state) %>% 
  #create percentiles based on household income for each state
  summarize(hhincome_ptile80 = weighted_quantile(hhincome, w = hhwt, probs = 0.80, na.rm=TRUE),
            hhincome_ptile20 = weighted_quantile(hhincome, w=hhwt, probs = 0.20, na.rm=TRUE)) %>% 
  #create 80-20 ratio for each state
  mutate(ratio_80_20 =  hhincome_ptile80/hhincome_ptile20) %>% 
  arrange(desc(ratio_80_20)) %>% 
  mutate(rank = dense_rank(desc(ratio_80_20)))


