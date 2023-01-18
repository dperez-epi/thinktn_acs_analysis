# Analysis of 2021 ACS data for ThinkTennessee TA request
# Daniel Perez, EARN State Economic Analyst
# 2022-12-12

#Libraries
library(tidyverse)
library(labelled)
library(here)
library(data.table)
library(haven)
library(MetricsWeighted)


#Load and clean 2021 ACS extract
source("code/01_acs_cleaning.R", echo = TRUE)

# Calculates share of children in households where more than 30 percent of the monthly income was spent on rent, mortgage payments, taxes, insurance, and/or related expenses.

source('code/02_housing_costs.R', echo = TRUE)

source('code/03_8020_hhincome_ratio.R', echo = TRUE)

source('code/04_youth_school_and_employment.R', echo = TRUE)

source('code/05_family_poverty.R', echo = TRUE)


# Hunter’s Original Request:  
# I have what is maybe a little bit of a different technical assistance request that I was wondering if y’all could help us with. So we have a 
# State of Our State Dashboard that we update every couple of years that ranks Tennessee compared to the rest of the states in the country across
# a long list of different metrics. Some of the sources that we use for that haven’t been updated recently, but I noticed that I think
# they’re originally built off of the ACS micro data. So I was wondering if y’all might be able to put together the following statistics for us 
# (we’d need all 50 states plus DC for each): 

# • share of children in households where more than 30 percent of the monthly income was spent on rent, mortgage payments, taxes, insurance, and/or related expenses.
# •	The ratio of median household income at the 80th percentile to median household income at the 20th percentile.
# •	Share of youth age 16-24 that are not in school (both full- and part-time) or not employed (both full- and part-time).
# •	Share of families where the following three things are true:
#   o	One parent works 50+ weeks in previous year
#   o	Family income < 200% federal poverty level
#   o	There is at least one ‘own child’ under 18 in the family
# 
# More normally, I noticed in the SWX that there was a statistic for the share of workers earning poverty level wages. We were thinking of using this in place of Low-Wage Jobs,
# which Prosperity Now hasn’t updated recently. But we noticed that the most recently available data for it was 2018. Is there a way to get a more recent update? 
#   
#   And Hunter later clarified:  
#   For the last bullet above:  
#   hoping to get the share of families for which all three are true simultaneously. I think it doesn’t matter if they’re full or part-time
#   (for reference, I’m hoping to basically match this from kids count)
# 
# And one thing I just realized is relevant for this TA request. I know the ACS had some issues in 2020, but is there any microdata
# available to put together something more recent than 2019? The current versions we have use 2019 data, so I don’t want to send y’all 
# down a rabbit-hole if there isn’t even a more recent data set available.  
