## SNIPPETS OF COMMONLY USED R CODE 

######################################################################################.
## Replacing NAs across columns ----
# replace NA with 0s to avoid issues when calculting rate
# mutate across means you can apply the replacing NA to a whole bunch of columns ranging between x and z
df <- df %>%
mutate(across(column_x:column_z ~ replace_na(.x, 0)))
######################################################################################.


######################################################################################.
## Filter when NOT equal to NA ----
## i.e. this command strips out the NAs
df <- df %>% 
subset(!(is.na(datazone2011))) # removes rows when datazone 2011 is na 
######################################################################################.


######################################################################################.  
## Convert to factor ----
## all variables that are character fields into factors  
df <- df %>% 
  mutate_if(is.character, factor) 
######################################################################################.


## Pivot wider ----
#bind all cld deaths and cld by type deaths
cld_deaths <- rbind(all_cld, cld_deaths) %>% 
  pivot_wider(names_from = cld_type, values_from = deaths)



## Pivot longer (keeping columns year and decile)
pop <-dz01_pop %>%
  pivot_longer(cols = -c(year,decile), names_to = "age_grp", values_to = "pop")



## case_when with substr condition
dataset <- dataset
  mutate(sex_grp=case_when(substr(age_grp,1,1)=="m" ~ "1", substr(age_grp,1,1)=="f" ~ "2", TRUE ~ "x"))
  
  
  
## binding rows (aka adding datasets)
  population <- bind_rows(scot_pop,hb_pop)

  
  
