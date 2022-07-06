# Code to explain the basis of functions and how to create your own ones

###############################################.
## Packages ----
###############################################.
library(dplyr)

###############################################.
## Example 1 ----
###############################################.
# Some test data to start with
dummy_data <- data.frame(age = floor(runif(1000,0,100)), 
                         area = c("A", "B", "C", "D"),
                         sex = c("F", "M"))

View(dummy_data)

# Function that creates an age group variable with 5 year age band groups
create_agegroups <- function(dataset) {
 dataset <- dataset %>% mutate(age_grp = case_when( 
    age < 5 ~ 1, age > 4 & age <10 ~ 2, age > 9 & age <15 ~ 3, age > 14 & age <20 ~ 4,
    age > 19 & age <25 ~ 5, age > 24 & age <30 ~ 6, age > 29 & age <35 ~ 7, 
    age > 34 & age <40 ~ 8, age > 39 & age <45 ~ 9, age > 44 & age <50 ~ 10,
    age > 49 & age <55 ~ 11, age > 54 & age <60 ~ 12, age > 59 & age <65 ~ 13, 
    age > 64 & age <70 ~ 14, age > 69 & age <75 ~ 15, age > 74 & age <80 ~ 16,
    age > 79 & age <85 ~ 17, age > 84 & age <90 ~ 18, age > 89 ~ 19, 
    TRUE ~ as.numeric(age)
  ))
}

dummy_data_grouped <- create_agegroups(dataset = dummy_data)

dummy_data_grouped <- dummy_data %>% create_agegroups()

View(dummy_data_grouped) #checking that it worked

###############################################.
## Example 2 ----
###############################################.
dummy_data2 <- data.frame(numerator = floor(runif(1000,50,1000000)), 
                         quintile = 1:5)

View(dummy_data2)

# Function to filter and save the data for each quintile.
create_quintile_data <- function(quint_number) {
  
  dummy_data2 <- dummy_data2 %>% 
    subset(quintile == quint_number) #filtering only quintile of interest

  saveRDS(dummy_data2, file=paste0('dummydata_quintile_', quint_number, '.rds'))
}

create_quintile_data(3) #running the function

did_it_work <- readRDS('dummydata_quintile_3.rds') #checking the file
View(did_it_work)

###############################################.
## What if you want to apply a function to many cases? 
# This will apply the function to each one of the values 
# specified in the quint_number
mapply(create_quintile_data, quint_number = c(1,2,3,4,5))


## END
