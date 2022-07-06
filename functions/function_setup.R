#code to show a potential setup with functions
source("functions/function_source.R") #calling the function contents

dummy_data <- data.frame(age = floor(runif(1000,0,100)), 
                         area = c("A", "B", "C", "D"),
                         sex = c("F", "M"))

dummy_data_grouped <- dummy_data %>% create_agegroups()

## END