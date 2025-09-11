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
source('set_params.R')

source('get_model_preds.R') # 
# Takes the probability vectors of settings of the variables from `set_params.R`. 
# Also loads source file `functionsN2.R` for 2 static functions which 1) generate world settings then 
# model predictions for those and normalise/condition for unobserved variables

# Process model predictions to be more user friendly: 
# Takes average of 10 model runs
# Wrangles and renames variables, splits out node values 0 and 1
source('modpred_processing2.R')  

# -------------3. Results: fit model, compare predictions, plot etc

source(knitr::purl('modelCombLesions.Rmd')) # puts the processed model predictions together with lesions to get a df called 'modelAndDataUnfit.csv'
# That is then sent to a few different scripts, following structure of paper:

source(knitr::purl('optimise_noK.Rmd')) # Get predictions and optimise: Get nll and tau for each model
source(knitr::purl('reportingFigsnoK.Rmd')) 

# A continuation of this project from spring 2025 onwards had a parameter, 'K'.
# If you want that version, go to repo `collider_cognition`.

source(knitr::purl('itemLevelChisq.Rmd')) # Check ppt n against a uniform distribution
source(knitr::purl('abnormalInflation.Rmd')) # Is the phenomenon found in our results?


