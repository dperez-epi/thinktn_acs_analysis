
### Housing burdened by state (including renters and owners) ###

housing_burdened_children <- acs_household %>% 
  #keep households with children present
  filter(nchild>0) %>% 
  left_join(geo_labels) %>% 
  group_by(state) %>% 
  summarize(total_owner_renters = sum(hhwt),
            burdened_n = sum(hhwt*housing_burdened, na.rm=TRUE),
            burdened_share = weighted.mean(housing_burdened, w = hhwt, na.rm=TRUE)) %>% 
  arrange(desc(burdened_share)) %>% 
  mutate(rank = dense_rank(desc(burdened_share)))

state_housing_burdened <- acs_household %>% 
  mutate(statefip = to_factor(statefip)) %>% 
  group_by(statefip) %>% 
  summarize(all_n = sum(hhwt*housing_burdened, na.rm=TRUE),
            all_burdened = weighted.mean(housing_burdened, w = hhwt, na.rm=TRUE))



state_rent_burden <- acs_household %>% 
  filter(ownershpd %in% c(22)) %>%
  mutate(statefip = to_factor(statefip)) %>% 
  group_by(statefip) %>% 
  summarize(wgt_n = sum(hhwt),
            rent_burden_share = weighted.mean(rent_burdened, wt=hhwt, na.rm=TRUE)) %>% 
  pivot_wider(id_cols = statefip, names_from = rent_burdened, values_from = c(wgt_n))


#Rental / ownership cost as a share of monthly household income


own_burden <- acs_household %>% 
  filter(ownershpd %in% c(12,13)) %>%
  group_by(owncost_burdened_30) %>% 
  summarize(wgt_n = sum(hhwt))

state_own_burden <- acs_household %>% 
  filter(ownershpd %in% c(12, 13)) %>%
  mutate(statefip = to_factor(statefip)) %>% 
  group_by(statefip) %>% 
  summarize(wgt_n = sum(hhwt),
            share_burdened = weighted.mean(owncost_burdened, wt=hhwt, na.rm=TRUE))# %>% 
  pivot_wider(id_cols = statefip, names_from = owncost_burdened_30, values_from = c(wgt_n))
            


#benchmarks

rent_burden_count <- acs_household %>% 
  filter(ownershpd==22) %>%
  mutate(rentshare = rentgrs/month_hhinc) %>% 
  mutate(rent_burdened_bins = cut(rentshare, 
                                  breaks = c(-Inf, .149, .199, .249, .299, .349, Inf),
                                  labels = c('Less than 15%','15% to 19.9%', '20% to 24.9%',
                                             '25% to 29.9%', '30% to 34.9%', '35% or more'))) %>% 
  mutate(rent_burdened_30 = cut(rentshare,
                                breaks = c(-Inf, .299, Inf),
                                rent_burdened_binslabels = c("Not rent burdened", 'Rent burdened >=30%'))) %>% 
  group_by(rent_burdened_bins) %>% 
  summarize(wgt_n = sum(hhwt))



# This portion is dedicated to household level analysis. 
# I will benchmark results to housing tenure tables https://data.census.gov/table?q=DP04

own_status <- acs_household %>% 
  group_by(to_factor(ownershpd)) %>% 
  summarize(n=n(),
            wgt_n = format(sum(hhwt), scientific=FALSE))

# Financial characteristics benchmark
# https://data.census.gov/table?q=Income+(Households,+Families,+Individuals)&t=Families+and+Household+Characteristics&y=2021&tid=ACSST1Y2021.S2503&moe=false

### Household incomes ###

#all households
hhincomes <- acs_household %>% 
  summarise(med_hhincome = median(hhincome, na.rm=TRUE),
            avg_hhincome = weighted.mean(hhincome, w=hhwt, na.rm=TRUE))

#all owner occupied households
owner_hhincomes <- acs_household %>% 
  filter(ownershpd %in% c(12,13)) %>%
  group_by(hhinc_bins) %>% 
  summarise(wgt_n = sum(hhwt))

#all renter occupied households
renter_hhincomes <- acs_household %>% 
  filter(ownershpd %in% c(21, 22)) %>%
  group_by(hhinc_bins) %>% 
  summarise(wgt_n = sum(hhwt))


### Housing costs ###

## See https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2021_ACSSubjectDefinitions.pdf 
## Page 35, Selected Monthly Owner Costs for Census methodology
# including rent, rent+utilities, mortgage, and mortgage+utilities

monthly_owner_cost_bins <- acs_household %>% 
  filter(ownershpd %in%  c(12,13)) %>%
  group_by(owncost_bins) %>% 
  summarize(wgt_n=sum(hhwt))

monthly_renter_cost_bins <- acs_household %>% 
  filter(ownershpd==22) %>%
  group_by(rentgrs_bins) %>% 
  summarize(wgt_n=sum(hhwt))

median_rent_cost <-  acs_household %>% 
  filter(ownershpd %in% c(22)) %>%
  summarize(wgt_n=sum(hhwt),
            med_rentcost = median(rentgrs))


median_own_cost <- acs_household %>% 
  filter(ownershp %in% c(12, 13)) %>%
  summarize(wgt_n=sum(hhwt),
            med_owncost = median(owncost))

