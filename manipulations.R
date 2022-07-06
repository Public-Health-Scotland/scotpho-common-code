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

## Convert variables to cases and viceversa ----
#bind all cld deaths and cld by type deaths
cld_deaths <- rbind(all_cld, cld_deaths) %>% 
  pivot_wider(names_from = cld_type, values_from = deaths)

## Pivot longer (keeping columns year and decile)
pop <-dz01_pop %>%
  pivot_longer(cols = -c(year, decile), names_to = "age_grp", values_to = "pop")

###############################################
## case_when with substr condition ----
dataset <- dataset
  mutate(sex_grp=case_when(substr(age_grp,1,1)=="m" ~ "1", 
                           substr(age_grp,1,1)=="f" ~ "2",
                           TRUE ~ "x")) # true works as else
  
###############################################
## binding rows (aka adding datasets) ----
  #bind rows will execute even if the datasets don't have the same variables
  population <- bind_rows(scot_pop,hb_pop) 
  #rbind will only execute if the datasets have the same variables
  population <- rbind(scot_pop,hb_pop) 
  
  # cbind joins two datasets by column (e.g. same rows, but different measures as variables)
  # merge, left_join, inner_join, full_join match two datasets together linking variables
  
###############################################.
## Dealing with dates ----
###############################################.
# Creating a fake data frame with different types of date variables. 
# The date variables are all of type character.
library(dplyr)
library(ggplot2)
library(zoo)
library(lubridate)

test <- data.frame(value = 1:8,
                   date_string = rep(c("2018-01", "2018-02", "2018-03", "2019-04"), 2),
                   date_string2 = rep(c("01-01-2018", "01-02-2018", "01-03-2018", "01-04-2019"), 2),
                   date_string3 = rep(c("01-2018", "02-2018", "03-2018", "04-2019"), 2),
                   spec = c(rep("G1", 4), rep("G2", 4))) %>% 
  # Transforming the character variables into date variables
  mutate(date = as.yearmon(date_string), #using a zoo package function
         date2 = as.Date(date_string2, "%d-%m-%Y"),
         date3 = parse_date_time(date_string3, "my"), # lubridate function
         date4 = as.yearmon(date_string2, "%d-%m-%Y")) #using a zoo package function 

#Plotting the different date variables.
ggplot(test, aes(x = date, y = value, color = spec)) +
  geom_line()

ggplot(test, aes(x = date2, y = value, color = spec)) +
  geom_line()

ggplot(test, aes(x = date3, y = value, color = spec)) +
  geom_line()

ggplot(test, aes(x = date4, y = value, color = spec)) +
  geom_line() 

##################################.
##### Checking if a vector/variable is all NULL or NA ---- 
all(is.na(c(NA, NaN)))
all(is.null(c(NULL, 4)))

##################################.
##### Removing starting or ending white spaces in string ---- 
trimws("Does it work?       ", "right")

##################################.
##### Testing speed of a command ---- 
system.time(read.csv("./data/all_OPTdata.csv", na.strings=c(""," ","NA")))

###############################################.
## Listing files and details ----
hsmr_folder <- "/conf/quality_indicators/hsmr/projects"

hsmr_files <- list.files(hsmr_folder, full.names = T, recursive= T)

View(file.info(hsmr_files, extra_cols  = T))

##################################.
#####Rounding ---- 
#R has a particular way of rounding. R inferno book for more details 
x <- 1.44647478
y <- 1.44447478
round(x, 2)
round(y, 2)

##################################.
#####Selecting cases ---- 
subset() 
filter() #many packages have filter function, make sure you are using dplyr one

##################################.
#####Dropping non-existant factors levels after subsetting/filtering ---- 
droplevels()


