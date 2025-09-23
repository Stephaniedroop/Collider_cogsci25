##############################################################
########### Master script for collider for cogsci25 ##########
##############################################################

# These scripts assume your working directory is that of the scripts

library(tidyverse)
library(rjson)
library(ggnewscale) # Load these if you don't have them
library(here)
library(RColorBrewer)

source(here::here('Scripts', 'cesmUtils.R')) # Functions for running the cesm
source(here::here('Scripts', 'optimUtils.R')) # Functions for optimising the model fits

#--------------- 1. Get ppt data  -------------------
source(here::here('Scripts', '01preprocessing.R')) # Collates individual data csvs of both main batch and pilot

#------- 2. Create parameters, run cesm, get model predictions and save them ------------
source(here::here('Scripts', '02setParams.R')) # Output: probability vectors for use in getmodelPreds
source(here::here('Scripts', '03getModelPreds.R')) # Loads static `cesmUtils.R` functions and uses it to 1) generate world settings then 2) CESM model predictions for those
source(here::here('Scripts', '04modelProcessing.R')) # Takes average of 10 model runs, wrangles, splits out 0/1 node values and other user friendly

# -------------3. Results: fit model, compare predictions, plot etc
source(here::here('Scripts', '05getLesions.R')) # modules and lesions put with bytrial participant data, to get rda called 'modelAndDataUnfit.csv'
source(here::here('Scripts', '06optimise.R')) # Get predictions and optimise: Get nll and tau for each model
source(here::here('Scripts', '07reportingFigs.R')) 

# A continuation of this project from spring 2025 onwards had a parameter, 'K', fit all the data with a noise parameter
# If you want that version, go to repo `colliderCognition`.

#------------- 4. Supplementary analyses ------------
# These haven't been updated since May 2025 and may not work out of the box
source(here('Scripts', '08itemLevelChisq.R')) # Check ppt n against a uniform distribution
source(here('Scripts', '09abnormalInflation.R')) # Is the phenomenon found in our results?

