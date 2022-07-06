# Example of how to calculate mortality within a certain period of admission/discharge
# and also on how to calculate readmissions within a certain period of admission/discharge

###############################################.
## Functions/packages/filepaths ----
###############################################.
library(dplyr) #data manipulation
library(odbc) #odbc connections
library(readr)
library(tidyr) #for wide to long changes
library(lubridate) #for dates
library(janitor) #for clean-up functions

###############################################.
## Part 1 - Extraction from SMRA ----
###############################################.
channel <- dbConnect(odbc(), 
                     dsn="SMRA",
                     uid=.rs.askForPassword("SMRA Username:"), 
                     pwd=.rs.askForPassword("SMRA Password:"))

# WITH creates a table that you can query in the second part of the query
# This query extracts all episodes from admissions in which one of their episodes
# had a specific diagnosis during a particular time period (exists), 
# then brings one row per admission with the start and end dates of their 
# admission, apart from selecting their first relevant hb (WITH subquery) and in 
# the last part it selects only the ones with a final discharge date in the period required.
# You could run the three subqueries separately to understand what each one pulls.
# Here using diagnosis but could be tweaked for a procedure or other variable
smr_data <- tbl_df(dbGetQuery(channel, statement=
  "WITH adm_table AS (
       SELECT distinct link_no || '-' || cis_marker admission_id, 
              MIN(admission_date) OVER (PARTITION BY link_no, cis_marker) start_cis,
              MAX(discharge_date) OVER (PARTITION BY link_no, cis_marker) end_cis
       FROM ANALYSIS.SMR01_PI  z
       WHERE exists(
                    SELECT * 
                    FROM ANALYSIS.SMR01_PI  
                    WHERE link_no=z.link_no and cis_marker=z.cis_marker
                          AND regexp_like(main_condition, 'C')
                          AND discharge_date between '1 June 2021' and '31 December 2021' 
                   )
    )
                   SELECT admission_id, start_cis, end_cis,  hb
                   FROM adm_table 
                   WHERE end_cis between '1 June 2021' and '31 December 2021' ")) %>% 
  clean_names() #variables to lower case

###############################################.
## Part 2 - Mortality within 90 days of discharge ----
###############################################.
# Extracting all deaths, as some link_nos might be repeated, selecting one with
# the last one, as this is methodology used in Discovery
# Not using dicharge_type to identify people dying as it seems there are 
# data quality issues with this variable
# This could be easily changed to within 30 days for example, or using admission
# or operation dates instead
# Extracting a bit of a longer time period than for the other dataset
deaths_data <- tbl_df(
  dbGetQuery(channel, statement=
               "SELECT max(date_of_registration) death_date, link_no  
             FROM ANALYSIS.GRO_DEATHS_C 
             WHERE date_of_registration between '1 June 2021' and '31 January 2022'
             GROUP BY link_no")) %>%
  clean_names()  #variables to lower case

# Joining with main dataset
smr_data <- left_join(smr_data, deaths_data, by = "link_no") %>%
  mutate(time_to_death = (death_date - end_cis), # in days
         # If present on deaths catalogue or discharge as dead then count
         death_90 = case_when(time_to_death<91 ~ 1, TRUE ~0)) 

###############################################.
## Part 3 - Readmissions within 30 days of surgery ----
###############################################.
# Standard approach is counting only emergency readmissions
# Extracting a bit of a longer time period than for the other dataset
readm_data <- tbl_df(dbGetQuery(channel, statement=
                                  "SELECT distinct link_no, cis_marker, max(admission_type) adm_type,
                                min(admission_date) adm_date, max(discharge_date) disch_date
                                FROM ANALYSIS.SMR01_PI 
                                WHERE discharge_date between '1 January 2021' and '31 January 2022'
                                GROUP BY link_no, cis_marker")) %>% 
  setNames(tolower(names(.)))  #variables to lower case

# list of admissions with one of the diagnosis of interest
list_adm <- unique(paste0(smr_data$link_no, "-", smr_data$cis_marker))

readm_data <- readm_data %>% 
  #keeping only those patients found in the smr_data dataset
  filter(link_no %in% unique(smr_data$link_no)) %>%  
  # Flagging the original admissions from the smr data
  mutate(adm_orig = case_when(unique(paste0(link_no, "-", cis_marker)) %in% list_adm ~ 1,
                              TRUE ~ 0)) %>% 
  # Keeping original admissions and emergency readmissions
  filter(adm_type %in% c(20,21,22,30,31,32,33,34,35,36,37,38,39) | adm_orig ==1) %>% 
  arrange(link_no, cis_marker, disch_date) %>% 
  # If the patient is the same, the substract the end date of that admission from
  # admission date for the following one.
  mutate(readmission_period = case_when(link_no == lead(link_no) ~ (lead(adm_date) - disch_date)/(3600*24))) %>%
  # filtering those cases with one of the diagnosis and readmitted within 30 days
  filter(adm_orig == 1 & readmission_period <31) %>% 
  mutate(emerg_readm30 = 1) %>% # Flagging admission with a readmission within 30 days
  select(link_no, cis_marker, emerg_readm30)

# Joining with main dataset and substituing NAs for 0s
smr_data <- left_join(smr_data, readm_data, by = c("link_no", "cis_marker")) %>% 
  mutate_at(c("emerg_readm30"), ~replace(., is.na(.), 0))

## END
