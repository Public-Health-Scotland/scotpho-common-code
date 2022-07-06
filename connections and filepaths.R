
######################################################################################.
## Flexible filepaths ----
## helps reduce lengths of file paths within scripts and also means script can be easily run on server or desktop without having to rewrite filepaths
## change automatically depending if you are using R server or R desktop

if (sessionInfo()$platform %in% c("x86_64-redhat-linux-gnu (64-bit)", "x86_64-pc-linux-gnu (64-bit)")) {
  output <- "/PHI_conf/ScotPHO/"
  lookups <- "/PHI_conf/ScotPHO/Profiles/Data/Lookups/Population/"
  cl_out <- "/conf/linkage/output/lookups/Unicode/"
  
} else {
  output <- "//stats/ScotPHO/"
  lookups <- "//stats/ScotPHO/Profiles/Data/Lookups/Population/"
  cl_out <- "//Isdsf00d03/cl-out/lookups/Unicode/"
}
######################################################################################.


######################################################################################.
## SMRA Connection ----
channel <- suppressWarnings(dbConnect(odbc(),  dsn="SMRA", 
                                      uid=.rs.askForPassword("SMRA Username:"), 
                                      pwd=.rs.askForPassword("SMRA Password:")))

######################################################################################.


######################################################################################.
## set names to lower ----
# Use postcode lookup to match on HB of residence - hbres from SMRA not currently based on latest scottish postcode directory
postcode_lookup <- readRDS('/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2021_2.rds') %>% 
  setNames(tolower(names(.))) %>%    #variables to lower case
  janitor:clean_names() #this does the same, plus dealing with invalid characters