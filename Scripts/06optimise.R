##############################################################
########### Fit models, NLL, optimise parameters ##########
##############################################################

library(here)
library(tidyverse)
source(here('Scripts', 'optimUtils.R')) # Functions for optimising the model fits

# read in the rda
load(here::here('Data', 'modelData', 'modelAndDataUnfit.rda')) # df: 288 obs of 14

df <- modelAndData

# Let's create variables coding the actual observation
df.map<-data.frame(condition=c('c1','c2','c3','c4','c5','d1','d2','d3','d4','d5','d6','d7'),
                   A=c(0,0,1,1,1, 0,0,0,1,1,1,1),
                   B=c(0,1,0,1,1, 0,1,1,0,0,1,1),
                   E=c(0,0,0,0,1, 0,0,1,0,1,0,1))

for (i in 1:nrow(df))
{
  df$A[i]<-df.map$A[df.map$condition==df$trialtype[i]]
  df$B[i]<-df.map$B[df.map$condition==df$trialtype[i]]
  df$E[i]<-df.map$E[df.map$condition==df$trialtype[i]]
}

# Allocate Boolean status for Include: F for noisy or nonsense answers (e.g. answering A=0 when they can see A=1). 
# This is only for the cogsci paper, to handle 1.4% of data. later we handle it with a noise parameter epsilon
# It also has the advantage of any var being NA (e.g. if a ppt never answered A=0) being excluded
df <- df |> 
  mutate(include = !( (node3=='B=0' & B==1) | (node3=='B=1' & B==0) | (node3=='A=0' & A==1) | (node3=='A=1' & A==0)))


# This time there is only one parameter, tau
par <- 1
mod_name <- 'full'
i <- 1


# Usage:
model_names <- c('full', 
                 'noAct', 
                 'noInf', 
                 'noSelect', 
                 'noActnoInf', 
                 'noActnoSelect', 
                 'noInfnoSelect', 
                 'noActnoInfnoSelect')  

results <- optimize_models(model_names, df)

print(results)
newdf <- results$predictions # 1728 obs of 4


df_wide <- newdf |>
  pivot_wider(
    id_cols = c(trial_id, node3),
    names_from = model,
    values_from = predicted_prob
  )


justppt <- df |> 
  select(trial_id, node3, n, prop, pgroup, Actual, A, B, E, include)

fitforplot <- merge(df_wide, justppt, by = c('trial_id', 'node3'))

#save as rda
save(fitforplot, file = here::here('Data', 'modelData', 'fitforplot.rda'))