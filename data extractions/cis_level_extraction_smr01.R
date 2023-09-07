
library(odbc) # for reading oracle databases
library(dplyr) # for data manipulation


# SMRA login information
channel <- suppressWarnings(dbConnect(odbc(),  dsn="SMRA",
                                      uid=.rs.askForPassword("SMRA Username:"), 
                                      pwd=.rs.askForPassword("SMRA Password:")))


############################################################################################################.
## CIS level extraction  ----

## Points to consider: 
## Should the timeframe of your CIS be based on the hospital date of admission or discharge (secondary care team publications based on dates of discharge)
## Do you want age/sex/postcode from the first/last episode in a CIS

############################################################################################################.

## Example 1 - emergency admissions in those aged 65 and over ----
##  Run-time for this extraction may take ~20 minutes 

#ensure that fields are sorted in correct order during SQL extract
sort_var <- "link_no, admission_date, discharge_date, admission, discharge, uri"



# Extract CIS where first episode in CIS has an emergency admission type code
# filtered for only those with age on admission of =>65 years
# excludes those where sex on admission is null/unkonwn
# includes all emergency daycases (differs from secondary care team annual publication figures on emergency admissions)
# includes CIS which start outwith FYE of interest but that have a final discharge date within fye
# takes postcode, sex and age from first episode in CIS

emergency_cis <- as_tibble(dbGetQuery(channel, statement=paste0(
  "SELECT *
  from (
    SELECT
    link_no, cis_marker,
    row_number() OVER (PARTITION BY link_no, cis_marker ORDER BY  ", sort_var, ") rn,
    min(admission_date) OVER (PARTITION BY link_no, cis_marker) dadmit,
    max(discharge_date) OVER (PARTITION BY link_no, cis_marker) ddisch,
    min(AGE_IN_YEARS) OVER (PARTITION BY link_no, cis_marker) age,
    FIRST_VALUE(sex) OVER (PARTITION BY link_no, cis_marker ORDER BY ", sort_var, ") sex_grp,
    FIRST_VALUE(dr_postcode) OVER (PARTITION BY link_no, cis_marker ORDER BY ", sort_var, ") pc7,
    FIRST_VALUE(admission_type) OVER (PARTITION BY link_no, cis_marker ORDER BY ", sort_var, ") adm_type
    FROM ANALYSIS.SMR01_PI z)
WHERE rn = 1
AND age > 64
AND sex_grp not in ('9', '0')
AND ddisch BETWEEN '1 April 2021' and '31 MARCH 2022'
AND (adm_type between '20' and '22' or adm_type between '30' and '39')
ORDER BY link_no, cis_marker"))) %>% 
  setNames(tolower(names(.)))  #variables to lower case



## Example 2 - fye ----
# Extracts CIS where main condition is alcoholic liver disease (K70)
# returns one row per cis with field for financial year of hospital discharge

# MAX(discharge_date) OVER (PARTITION BY link_no, cis_marker) end_cis : 
# creates field called end_cis which is the max discharge date for a particular cis/linkno

# note in this extraction the filters on date of discharge will mean any CIS which span from the year before the filter into the year of the filter may be missed
# e.g. CIS with episodes that are before the year of filter are not considered by the query meaning the CIS might be missed or dates of admissions/initial admission types are missed.
# To avoid this issue you can set the extraction filter to the year before the years you want then filter the resultant dataset after extract created (it is unlike that many CIS have a duration of over 1 year if they are not geriatric long stay).


cis_extract <- tbl_df(dbGetQuery(channel, statement=
  "WITH adm_table AS (
        SELECT distinct link_no || '-' || cis_marker admission_id, 
            MAX(discharge_date) OVER (PARTITION BY link_no, cis_marker) end_cis
        FROM ANALYSIS.SMR01_PI  z
        WHERE exists(
          SELECT * 
          FROM ANALYSIS.SMR01_PI  
          WHERE link_no=z.link_no and cis_marker=z.cis_marker
              AND regexp_like(main_condition, 'K70')
              AND discharge_date between '1 April 1999' and '31 March 2020' 
        )
    )
    SELECT CASE WHEN extract(month from end_cis) > 3 THEN extract(year from end_cis) 
              ELSE extract(year from end_cis) -1 END as year,
          count(distinct admission_id) adm
    FROM adm_table 
    WHERE end_cis between '1 April 1999' and '31 March 2020'
    GROUP BY CASE WHEN extract(month from end_cis) > 3 THEN extract(year from end_cis) 
            ELSE extract(year from end_cis) -1 END")) %>% 
  setNames(tolower(names(.))) %>%   #variables to lower case
  arrange(year) %>% 
  mutate(year = paste0(year, "/", substr(as.numeric(year)+1,3,4)))
