###############################################.
##Function to perform standardisation ----

## allows for options to include/exclude sex or addditional categories e.g age groups/NHS boards
## allows for option to declare different columns as the numerator

# requires a column in your dataset containing population and european population


## Parameters

# dataset - the name of the dataframe to apply standardisation to (depending on how the function is called you may not need to supply this parameter)
# measure - the name of the column you wish to use as the numerator
# epop_total - insert number for the sum of the epop for your given data e.g. epop_total for all ages and both sexes 200000, for single sex all ages 100000, for <15 years both sexes 32500
# sex - (TRUE/FALSE) - select if your standardisation should be split by a column called sex (TRUE) or not (FALSE)
# cats - an optional parameter that can be used to declare any other columns to split the standardisation by (can be mu)



###############################################.

# Function to calculate age sex standardized rates
create_rates <- function(dataset, measure, epop_total, sex, cats = NULL ) {
  
  dataset <- dataset %>%
    mutate(easr_first = {{measure}} *epop/pop) # easr population
  
  if (sex == TRUE) {
    # aggregating by year, code and time
    dataset <- dataset %>% select(-age_grp) %>%
      group_by_at(c(cats, "year", "sex_grp")) %>%
      summarize(across(c({{measure}}, easr_first), sum, na.rm = T)) %>% ungroup()
  } else if (sex == FALSE) {
    # aggregating by year, code and time
    dataset <- dataset %>% select(-age_grp, -sex_grp) %>%
      group_by_at(c(cats, "year")) %>%
      summarize(across(c({{measure}}, easr_first), sum, na.rm = T)) %>% ungroup()
  }
  
  # Calculating rates
  dataset <- dataset %>%
    mutate(epop_total = epop_total,  # Total EPOP population
           easr = easr_first/epop_total, # easr calculation
           rate = easr*100000) %>%   # rate calculation
    select(-c(easr_first, epop_total, easr))
}




## Example calls to function ----
## below an example of how you might call the function above and supply parameters


# standardised rates by NHS board, for all ages and not split by sex
dataset_name <- dataset_name %>% 
  create_rates(measure=deaths, epop_total=200000, cats = c("hb2019","hb2019name"), sex=FALSE)



# standardised rates for Scotland only, for males and females and all sexes.  All ages.
rates_by_gender <- rbind(
  dataset_name %>% filter(hb2019name=="Scotland") %>%
    create_rates(measure=all_cld, epop_total=100000, cats = c("hb2019","hb2019name"), sex=TRUE),
  dataset_name %>% filter(hb2019name=="Scotland") %>%
    create_rates(measure=all_cld, epop_total=200000, cats = c("hb2019","hb2019name"), sex=FALSE) %>%
    mutate(sex_grp="All"))


# standardised rates for Scotland only, by bespoke age groups and all ages - for all sexes
rates_by_agegroup <- rbind(
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "<15")%>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 32000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "15-24") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 23000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "25-34") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 25000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "35-44") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 28000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "45-54") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 28000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "55-64") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 25000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland" & age_grp2 == "65+") %>%
    create_rates(measure=all_cld, cats = "age_grp2", epop_total = 39000, sex = FALSE),
  dataset_name %>% filter(hb2019name=="Scotland") %>%
    create_rates(measure=all_cld, epop_total = 200000, sex = FALSE) %>%
    mutate(age_grp2="All"))