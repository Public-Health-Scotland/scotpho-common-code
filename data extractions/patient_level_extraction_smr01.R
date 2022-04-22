############################################################################################################.
## Patient level extraction  ----

# Points to consider:
# Timeframe for your patient selection - based on date of admission/discharge date
# Do you want to count patients once in a fye or calendar year?
# patient details such age (and occasionally sex) might change during a hospital stay - does this matter to your extraction - do you want age on admission/discharge or age during a stay

############################################################################################################.


# Creates one record per CIS and selects only one case per patient/year.
# Looking to admissions with a main diagnosis of CHD (ICD-10: I20-I25), 
# excluding unknown sex
# by financial year. 
# min(age_in_years) should return age on admission
# min(DR_POSTCODE) will return minimum postcode - which isn't necessarily first or last PC within a cis
# min(sex) will mean in rare cases where sex might change you will return the lowest value 


patient_extract <- tbl_df(dbGetQuery(channel, statement=
    "SELECT distinct link_no linkno, min(AGE_IN_YEARS) age, min(SEX) sex_grp, min(DR_POSTCODE) pc7,
    CASE WHEN extract(month from admission_date) > 3 
        THEN extract(year from admission_date) 
        ELSE extract(year from admission_date) -1 END as year
    FROM ANALYSIS.SMR01_PI z 
      WHERE admission_date between  '1 April 2020' and '31 March 2021'
      AND sex <> 0 
      AND regexp_like(main_condition, 'I2[0-5]')
    GROUP BY link_no,
      CASE WHEN extract(month from admission_date) > 3 
          THEN extract(year from admission_date) 
          ELSE extract(year from admission_date) -1 END" )) %>% 
  setNames(tolower(names(.)))  #variables to lower case