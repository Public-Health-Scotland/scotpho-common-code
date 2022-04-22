
## speak to Jaime : what is adm_table? where does it come from, whats in it?




############################################################################################################.
## CIS level extraction  ----

## Points to consider: 
## Should the timeframe for your CIS be based on the hospital date of admission or discharge
## Do you want age/sex/postcode from the first/last episode in a CIS

############################################################################################################.


## Example 1 - fye ----
# Extracts CIS where main condition is alcoholic liver disease (K70)
# returns one row per cis with field for financial year of hospital discharge

# MAX(discharge_date) OVER (PARTITION BY link_no, cis_marker) end_cis : 
# creates field called end_cis which is the max discharge date for a particular cis/linkno


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
