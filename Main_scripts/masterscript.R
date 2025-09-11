##############################################################
########### Master script for collider for cogsci25 ##########
##############################################################

# These scripts assume your working directory is that of the scripts

library(tidyverse)
library(ggnewscale) # Download these if you don't have them
rm(list=ls())

#--------------- 1. Get ppt data  -------------------
source('preprocessing.R') # Collates individual data csvs of both main batch and pilot

#------- 2. Create parameters, run cesm, get model predictions and save them ------------
source('setParams.R') # Output: probability vectors for use in...
source('getModelPreds.R') # Loads static `functionsN2.R` and uses it to 1) generate world settings then 2) CESM model predictions for those
source('modelProcessing.R') # Takes average of 10 model runs, wrangles, splits out 0/1 node values and other user friendly

# -------------3. Results: fit model, compare predictions, plot etc

source(knitr::purl('modelCombLesions.Rmd')) # modules and lesions put with bytrial participant data, to get a df called 'modelAndDataUnfit.csv'
source(knitr::purl('optimise.Rmd')) # Get predictions and optimise: Get nll and tau for each model
source(knitr::purl('reportingFigs.Rmd')) 

# A continuation of this project from spring 2025 onwards had a parameter, 'K'.
# If you want that version, go to repo `collider_cognition`.

source(knitr::purl('itemLevelChisq.Rmd')) # Check ppt n against a uniform distribution
source(knitr::purl('abnormalInflation.Rmd')) # Is the phenomenon found in our results?


