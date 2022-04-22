####################################################################################.
## Code to generate a deprivation lookup file that will permit matching on Postcode &
## assign correct deprivation decile for that year

## first create deprivation postcode or IZ to quintil/decile/rank lookup ----
## you could use the deprivation lookup directly from cl-out but remember that decile/quintile order is reversed from SIMD 2004 & 2006 


dep_lookup <- readRDS('/conf/linkage/output/lookups/Unicode/Deprivation/postcode_2021_2_all_simd_carstairs.rds') %>% 
  setNames(tolower(names(.))) %>%  #variables to lower case
  select (pc7, simd2004_sc_decile, simd2006_sc_decile, simd2009v2_sc_decile, simd2012_sc_decile, simd2016_sc_decile, simd2020v2_sc_decile)


# For variable SIMD 2004 & 2006 SIMD deciles were 1 = least deprived, 10 = most deprived.
# Reverse the decile for consistency with the latest SIMD values.

dep_lookup <- dep_lookup %>%
  mutate(simd2004_sc_decile = case_when(simd2004_sc_decile==10 ~ 1, simd2004_sc_decile==9 ~ 2,
                                        simd2004_sc_decile==8 ~ 3, simd2004_sc_decile==7 ~ 4,
                                        simd2004_sc_decile==6 ~ 5, simd2004_sc_decile==5 ~ 6,
                                        simd2004_sc_decile==4 ~ 7, simd2004_sc_decile==3 ~ 8,
                                        simd2004_sc_decile==2 ~ 9, simd2004_sc_decile==1 ~ 10, TRUE ~ 0),
         simd2006_sc_decile = case_when(simd2006_sc_decile==10 ~ 1, simd2006_sc_decile==9 ~ 2,
                                        simd2006_sc_decile==8 ~ 3, simd2006_sc_decile==7 ~ 4,
                                        simd2006_sc_decile==6 ~ 5, simd2006_sc_decile==5 ~ 6,
                                        simd2006_sc_decile==4 ~ 7, simd2006_sc_decile==3 ~ 8,
                                        simd2006_sc_decile==2 ~ 9, simd2006_sc_decile==1 ~ 10, TRUE ~ 0))


##Matching deprivation on to your dataset & selecting correct decile/quintile for the year
# requires a column identifying the year the data comes from

#matches postcode to deprivation deprivation deciles
dataset  <- left_join(dataset , dep_lookup, "pc7") 

#SIMD deciles not suitable for data prior to 1996
#1996-2003 use SIMD 2004
#2004-2006 use SIMD 2006
#2007-2009 use SIMD 2009
#2010-2011 use SIMD 2012
#2012-2018 use SIMD 2016
#2019- use SIMD 2020

# select correct SIMD decile for each time period
dataset <- dataset %>%
  mutate(decile=ifelse(year<1996,NA,
                       ifelse((year>=1996 & year<=2003), simd2004_sc_decile,
                              ifelse((year>=2004 & year<=2006),simd2006_sc_decile,
                                     ifelse((year>=2007 & year<=2009),simd2009v2_sc_decile,
                                            ifelse((year>=2010 & year<=2011),simd2012_sc_decile,    
                                                   ifelse((year>=2012 & year<=2018),simd2016_sc_decile,simd2020v2_sc_decile))))))) %>%
  select(-simd2004_sc_decile,-simd2006_sc_decile,-simd2009v2_sc_decile,-simd2012_sc_decile,-simd2016_sc_decile,-simd2020v2_sc_decile) # removes additional column once they are no longer required

