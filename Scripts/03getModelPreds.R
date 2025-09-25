#################################################### 
###### Collider - get model predictions  #####
####################################################
# Script to set up probability vectors of each variable, then run a series of 3 source files to implement the cesm
# and save the model predictions for each run

library(here)
library(tidyverse)
source(here('Scripts', 'cesmUtils.R')) # Functions for running the cesm

# Other values set outside for now 
N_cf <- 100000L # How many counterfactual samples to draw
modelruns <- 10
s <- 0.7

causes1 <- c('A', 'Au', 'B', 'Bu')

load(here('Data', 'modelData', 'params.rda'))
# defined in script `setParams.r`

set.seed(12)

# -------------- Full cesm  ----------

# Empty df to put everything in
all <- data.frame(matrix(ncol=27, nrow = 0)) # needs to be 10 longer than df

# For each setting of possible probability parameters we want to: 
# 1) generate worlds, 2) get conditional probabilities and 3) get model predictions
for (i in 1:length(poss_params)) { 
  # 1) Get possible world combos of two observed variables in both dis and conj structures
  dfd <- world_combos(params = poss_params[[i]], structure = 'disjunctive')
  dfd$pgroup <- i
  dfc <- world_combos(params = poss_params[[i]], structure = 'conjunctive')
  dfc$pgroup <- i
  mp1 <- data.frame(matrix(ncol = 27, nrow = 0)) # was 27
  # 3) Get predictions of the counterfactual effect size model for these worlds 
      # We also want to calculate like 10 versions to get the variance of model predictions 
  for (m in 1:modelruns) {
    mpd <- get_cfs(params = poss_params[[i]], structure = 'disjunctive', df = dfd) # 16 obs of 6
    mpd$run <- m
    mpc <- get_cfs(params = poss_params[[i]], structure = 'conjunctive', df = dfc)
    mpc$run <- m
    mp1 <- rbind(mp1, mpd, mpc)
  }
  #mp1$pgroup <- i
  all <- rbind(all, mp1)  # 1440 of 26
} 
# It takes a minute or two but not terrible.

save(all, file = here("Data", "modelData", "all.rda"))

