## Flagging diagnosis codes using R ----
## Consider including diagnostic criteria filters in SQL extraction to reduce the size of the extract (see examples from data extractions folder)

#required packages
library(dplyr)


## Examples of scan through main condition or all diagnosis fields to flag rows which contain one or more diagnosis codes.

# create a string that lists all the diagnosis codes you want flaged.
# The string length can vary, the '|' symbol means OR.

conditions <- "5710|5711|5712|5713|K70"

# adds a column called condition_flag where the values match the strings featured in the list 'conditions'
# grepl = global regular expression print logical : built in R function used for identifying regular expressions
# function will search across any column with header that contain the word "condition" e.g. main condition/other_condition_1 etc
# the '*1' part ensures the result is a flag with a value of 1 or 0 (rather than TRUE or FALSE)

df <- df %>% 
  rowwise() %>% # searches through each row in dataframe
  mutate(condition_flag=any(grepl(conditions,c_across(contains("condition"))))*1) %>% # adds a column called condition flag
  ungroup()



## Alternative: if you are only looking a main condition or main cause of death
## but still want to search using a number of diagnositc codes
## the method below requires string lengths to be the same for each clause

#list of ICD9 codes for alcoholic or non alcoholic liver disease
alc_list4 <- list("5710", "5711", "5712", "5713")

cld_deaths <- cld_deaths %>%
  mutate(cld_type=case_when((substr(cod,1,4) %in% alc_list4) ~ "alc_liver", 
                            (substr(cod,1,3)=="K70") ~ "alc_liver", 
                            TRUE ~ "other_liver")) # add CLD type field
