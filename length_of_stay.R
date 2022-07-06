# The standard view we use for SMR01 data is at episode level, however quite
# often we need to report on hospital stay length, so we need to aggregate to obtain 
# the right lenght of stay (LOS) figures
# SMR01 does only get to date of admission, not to time of admission.
# Length of stay calculations can vary depend on the request. For example, we could be
# looking at the whole hospital stay length of stay, length of stay at a particular
# specialty or under a consultant, or length of stay after a certain procedure.

###############################################.
## Functions/packages/filepaths ----
###############################################.
library(dplyr) #data manipulation
library(odbc) #odbc connections
library(lubridate) #for dates
library(janitor) #for clean-up functions

###############################################.
## Part 1 - Extraction from SMRA ----
###############################################.
channel <- dbConnect(odbc(), 
                     dsn="SMRA",
                     uid=.rs.askForPassword("SMRA Username:"), 
                     pwd=.rs.askForPassword("SMRA Password:"))

# The length of stay variable refers to episode length
smr1_extract <- as_tibble(dbGetQuery(channel, statement=
 "SELECT link_no, cis_marker, admission_date, discharge_date, length_of_stay
  FROM ANALYSIS.SMR01_PI 
  WHERE discharge_date between '1 September 2021' and '31 December 2021'")) %>%
  setNames(tolower(names(.)))   # variables to lower case

# Two ways of calculating it
smr1_extract2 <- smr1_extract %>% 
  group_by(link_no, cis_marker) %>% 
  summarise(los1 = sum(length_of_stay),
            admission_date = min(admission_date),
            discharge_date = max(discharge_date)) %>% ungroup() %>%  
  mutate(los2 = (discharge_date - admission_date)/(3600*24),
# Average length of stay shouldn't be calculated until you got it to the 
# right level of analysis (e.g. stay not episode)
         mean_los = mean(los1))

# This can be also done in the SQL query, aggregating LOS to stay level
smr_data <- as_tibble(dbGetQuery(channel, statement=
 "SELECT distinct link_no || '-' || cis_marker admission_id, 
        MIN(admission_date) OVER (PARTITION BY link_no, cis_marker) start_cis,
        MAX(discharge_date) OVER (PARTITION BY link_no, cis_marker) end_cis,
        sum(length_of_stay) OVER (PARTITION BY link_no, cis_marker) sum_los
  FROM ANALYSIS.SMR01_PI  
  WHERE discharge_date between '1 September 2021' and '31 December 2021' ")) %>% 
  clean_names() %>%  #variables to lower case
  mutate(mean_los = mean(sum_los))
