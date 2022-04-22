###########################################################################################
## Creating a ODBC connection to SMRA and exploring objects available via the connection.
###########################################################################################

library(odbc) #load first to avoid masking of certain functions within dplyr
library(dplyr)
library(readr)



# SMRA login information
# SMRA login information
channel <- suppressWarnings(dbConnect(odbc(),  dsn="SMRA",
                                      uid=.rs.askForPassword("SMRA Username:"),
                                      pwd=.rs.askForPassword("SMRA Password:")))


#LIST tables available through channel connection
dbListTables(channel)[1:100]

#List objects available from "Analysis" schema (smr01, gro deaths, smr00 are all views within this schema)
odbcListObjects(channel,  schema="ANALYSIS") 

#List headers for a table/view
odbcPreviewObject(channel,  table="ANALYSIS.SMR01_PI",  rowLimit=0)
