
#find new extracts at
#https://usa.ipums.org/usa-action/data_requests/download
#Accuracy of data: https://usa.ipums.org/usa/resources/codebooks/AccuracyACS_2021.pdf
#Data tables: https://data.census.gov/table?q=DP04
#Group quarter defn: https://www2.census.gov/programs-surveys/acs/tech_docs/group_definitions/2021GQ_Definitions.pdf

#Import premade geographic labels
geo_labels <- read_csv(here('input/geographic_labels.csv')) %>% 
  select(statefip=statefips, state)

# import ACS extract using haven library
acs_raw <- read_dta(here('input/usa_00012.dta.gz'))

acs <- acs_raw %>% 
  #merge geographic labels
  left_join(geo_labels) %>% 
  #Replace missing income values codes as 999... to NA
  mutate(across(hhincome|inctot|ftotinc, ~replace(.x, .x==9999999, NA)),
         incwage = replace(incwage, incwage==999999, NA),
         owncost = replace(owncost, owncost==99999, NA))

acs_household <- acs %>% 
  #Keep head of household and households that are not group quarters
  filter(pernum==1, gq %in% c(1,2,5)) %>% 
  mutate(across(ownershp, ~ifelse(!is.na(.x), yes=replace(.x, .x==0, NA), no=0))) %>% 
  #If utilities are not missing values, then convert to monthly cost, otherwise convert to 0
  mutate(across(costelec|costgas|costwatr|costfuel, ~replace(.x,.x>=9992 | .x==0, 0)),
         m12_costelec = ifelse(!is.na(costelec), yes=costelec/12, no=0),
         m12_costwatr = ifelse(!is.na(costwatr), yes=costwatr/12, no=0),
         m12_costfuel = ifelse(!is.na(costfuel), yes=costfuel/12, no=0),
         m12_costgas = ifelse(!is.na(costgas), yes=costgas/12, no=0),
         #Create util variable, sum of monthly utilities
         utils = (m12_costelec + m12_costgas + m12_costwatr + m12_costfuel)) %>%
  #monthly household income variable
  mutate(month_hhinc = ifelse(!is.na(hhincome), yes=hhincome/12, no=NA)) %>% 
  #Create binned household income for occupied housing units (Used for benchmarking purposes)
  mutate(hhinc_bins = cut(hhincome,
                          breaks = c(-Inf, 4999, 9999, 14999, 19999, 24999, 34999, 49999, 74999, 99999, 149999, 9999998),
                          labels = c('Less than 5k', '$5,000 to $9,999','$10,000 to $14,999','$15,000 to $19,999',
                                     '$20,000 to $24,999','$25,000 to $34,999', '$35,000 to $49,999', '$50,000 to $74,999',
                                     '$75,000 to $99,999', '$100,000 to $149,999', 'Greater than 150k'))) %>% 
  #create binned housing cost variable for renters
  mutate(rentgrs_bins = cut(rentgrs,
                           breaks = c(-Inf, 299, 499, 799, 999, 1499,1999, 2499, 2999, Inf),
                           labels = c('Less than $300','$300 to $499','$500 to $799','$800 to $999','$1k to $1,499',
                                      '$1,500 to $1,999', '$2,000 to $2,499','$2,500 to $2,999','$3,000 or more'))) %>%
  #create binned housing cost var for homeowners
         mutate(owncost_bins = cut(owncost,
                                 breaks = c(-Inf, 299, 499, 799, 999, 1499,1999, 2499, 2999, Inf),
                                 labels = c('Less than $300','$300 to $499','$500 to $799','$800 to $999','$1k to $1,499',
                                            '$1,500 to $1,999', '$2,000 to $2,499','$2,500 to $2,999','$3,000 or more'))) %>% 
  #Create variables calculating rent/ownership costs as a share of monthly household income
  mutate(rentcost_share = rentgrs/month_hhinc) %>%
  mutate(owncost_share = owncost/month_hhinc) %>% 
  #Create variables calculating rent burden. Defined as costs in excess of 30% of hhincome
  mutate(owncost_burdened = ifelse(owncost_share>=.30, yes=1, no=0),
         rent_burdened = ifelse(rentcost_share>=.30, yes=1, no=0),
         housing_burdened = ifelse(rent_burdened==1 | owncost_burdened==1, yes=1, no=0)) %>% 
  #set labels
  set_value_labels(owncost_burdened = c("Not cost burdened"=0, 'Cost burdened >=30%'=1),
                   rent_burdened = c("Not rent burdened"=0, 'Rent burdened >=30%'=1),
                   housing_burdened = c("Not housing burdened (<30%)" = 0, 'Housing burdened (>=30%)' = 1))
         
  
