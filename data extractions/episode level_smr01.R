############################################################################################################.
## Episode level extraction  ----

## Note: Direct extraction at episode level data is rarely that useful as you may miss episodes
## within a continuous inpatient stay and you are interested in hospital date of admission/discharge etc.

############################################################################################################.


## Straight episode extraction ----
## selection of episodes diagnosis main condition (asthma J45 and J46)
## selection based on episode date of admission - which *might* not be the same as date of hospital admission

episode_data_condition <- as_tibble (dbGetQuery(channel, statement=
                "SELECT link_no, CIS_marker, AGE_IN_YEARS, SEX, DR_POSTCODE,ADMISSION_DATE,DISCHARGE_DATE,LOCATION,CI_CHI_NUMBER,SIGNIFICANT_FACILITY,MAIN_CONDITION,OTHER_CONDITION_1,OTHER_CONDITION_2,OTHER_CONDITION_3,OTHER_CONDITION_4,OTHER_CONDITION_5 
                                  FROM ANALYSIS.SMR01_PI z
                                  WHERE admission_date between '4 January 2018' and '5 January 2018'
                                  AND sex <> 0
                                  AND regexp_like(main_condition, 'J4[5-6]')"))%>%
  setNames(tolower(names(.)))  #variables to lower case


#selection of episodes with a diagnosis (main condition of asthma J45 and J46)
#selection based on episode date of admission

episode_data_hbt <- tbl_df(dbGetQuery(channel, statement=
                  "SELECT link_no, CIS_marker, HBTREAT_CURRENTDATE,AGE_IN_YEARS, SEX, DR_POSTCODE,ADMISSION_DATE,DISCHARGE_DATE,LOCATION,CI_CHI_NUMBER,SIGNIFICANT_FACILITY,MAIN_CONDITION,OTHER_CONDITION_1,OTHER_CONDITION_2,OTHER_CONDITION_3,OTHER_CONDITION_4,OTHER_CONDITION_5 
                                  FROM ANALYSIS.SMR01_PI z
                                  WHERE admission_date between '4 January 2018' and '5 January 2018'
                                  AND sex <> 0
                                  AND HBTREAT_CURRENTDATE = 'S08000015'
                                  AND location in ('A111H', 'G405H')
                                  AND regexp_like(main_condition, 'J4[5-6]')"))%>%
  setNames(tolower(names(.)))  #variables to lower case



######################################################################################################.

## All episodes within a CIS ----

# selection based on date of discharge
# returns all episode belonging to a cis that featured a main diagnosis of asthma  

all_episodes_within_cis <- as_tibble(dbGetQuery(channel, statement= paste0(
  "SELECT link_no linkno, cis_marker cis, AGE_IN_YEARS age, admission_date, 
      discharge_date, DR_POSTCODE pc7, SEX sex_grp, ADMISSION, DISCHARGE, URI, main_condition
  FROM ANALYSIS.SMR01_PI z
  WHERE discharge_date between  '4 January 2018' and '5 January 2018'
      and exists (
          select * 
          from ANALYSIS.SMR01_PI  
          where link_no=z.link_no and cis_marker=z.cis_marker
            and discharge_date between '4 January 2018' and '5 January 2018'
            AND regexp_like(main_condition, 'J4[5-6]'))"))) %>%
  setNames(tolower(names(.)))  #variables to lower case


# more complicated example: 
# all episodes for a cis with a diagnosis of liver disease in any diagnostic position during a stay

# list of ICD9 and ICD10 diagnositic codes for chronic liver disease
cld_diag <- "5710|5711|5712|5713|5714|5715|5716|K70|K73|K74"

episodes_cld_cis <- as_tibble(dbGetQuery(channel, statement= paste0(
  "SELECT link_no linkno, cis_marker cis, AGE_IN_YEARS age, admission_date, 
      discharge_date, DR_POSTCODE pc7, SEX sex_grp, ADMISSION, DISCHARGE, URI, main_condition, other_condition_1,
other_condition_2,other_condition_3,other_condition_4,other_condition_5
  FROM ANALYSIS.SMR01_PI z
  WHERE discharge_date between  '1 April 2020' and '31 March 2021'
      and exists (
          select * 
          from ANALYSIS.SMR01_PI  
          where link_no=z.link_no and cis_marker=z.cis_marker
            and discharge_date between '1 April 2020' and '31 March 2021'
            and (regexp_like(main_condition, '", cld_diag ,"')
              or regexp_like(other_condition_1,'", cld_diag ,"')
              or regexp_like(other_condition_2,'", cld_diag ,"')
              or regexp_like(other_condition_3,'", cld_diag ,"')
              or regexp_like(other_condition_4,'", cld_diag ,"')
              or regexp_like(other_condition_5,'", cld_diag ,"')))"))) %>%
  setNames(tolower(names(.)))  #variables to lower case
