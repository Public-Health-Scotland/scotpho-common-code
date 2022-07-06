##################################.
#####Install a package ---- 
install.packages()

#it only works for versions published after September 2014
library(versions)
install.versions("ggplot2", "2.0.0")

#This function can be used for GitHub packages.
remotes::install_github("Public-Health-Scotland/qifunctions", upgrade = "never")


##################################.
#####Load a package ---- 
library()
require() #inside functions

#One liner for multiple packages
lapply(c("dplyr", "readr", "odbc"), library, character.only = TRUE)

##################################.
##### Unloading all packages loaded in environment ---- 
lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
       detach, character.only=TRUE, unload=TRUE)