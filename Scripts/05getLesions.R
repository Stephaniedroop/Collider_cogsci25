##############################################################
########### Get the other model modules and lesions ##########
##############################################################

# Script takes the processed data from the ppt expt (`DATA.RDATA`)
# and combines it with the preprocessed model predictions from `04modelProcessing.R` (`tidiedPreds.csv`)

#
load(here::here('Data', 'Data.Rdata')) # This is one big df, 'data', 3348 obs of 18 ie. 284 ppts (without the 5 very first pilot - they were in paper but not here)
load(here::here('Data', 'ModelData', 'tidiedPreds.rda')) # 576 of 26 - 576 rows because: 3 pgroups x 12 trialtypes x 4 nodes x 4 prior possible settings of unobserved variables  

mp <- all # For legacy reasons it is renamed in the wholescript, maybe tidy later

mp$pgroup <- as.factor(mp$pgroup)
mp$node3 <- as.factor(mp$node3)
mp$trialtype <- as.factor(mp$trialtype)
mp$structure <- as.factor(mp$structure)
mp$E.x <- as.factor(mp$E.x)
mp$E.y <- as.factor(mp$E.y)

# Models with the Actual causation module 
# Allocate a cause as Actual when it fulfils either of two conditions:
#  1) it equals the Effect
#  2) unobserved variable can only follow main variable

# Condition 1
mp <- mp |> # 
  mutate(Actual = case_when(
    node2 == 'A' ~ A==E.x,
    node2 == 'B' ~ B==E.x,
    node2 == 'Au' ~ Au==E.x,
    node2 == 'Bu' ~ Bu==E.x
  ))


# Condition 2 - many of these are already caught but just to catch the extras 
mp$Actual[mp$A=='0' & mp$node3=='Au=1'] <- FALSE
mp$Actual[mp$B=='0' & mp$node3=='Bu=1'] <- FALSE


mp <- mp |> 
  mutate(cesmActual = cesm*Actual)

# FULL 
full <- mp |>  
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(full = sum(cesmActual*posterior)) 


#-------  NEXT GROUP OF LESIONS ---------

# Uses plain cesm before treatment for Actual
noAct <- mp |>  #2
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(noAct = sum(cesm*posterior)) 

# Uses the cesm after treatment for Actuality, but then uses prior of unobserved variables rather than posterior
noInf <- mp |>  #3
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(noInf = sum(cesmActual*PrUn)) 

# Uses plain cesm before treatment for Actual, and prior of unobserved variables rather than posterior
noActnoInf <- mp |>  #6
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(noActnoInf = sum(cesm*PrUn)) 


#--------- Lesioning causal selection - noSelect -------------

# Get the individual posterior, for example:
# For Au, keep Au fixed and sum the joint posterior for each possible value of Bu.

getpost <- mp |> # 120 obs of 4
  filter(!node2 %in% c('A','B')) |> 
  group_by(pgroup, trialtype, node) |> 
  summarise(post = sum(posterior),
            prior = sum(PrUn))
            
# Merge this back in to the main model predictions
postmp <- merge(mp, getpost, by = c('pgroup', 'trialtype', 'node'), all.x = TRUE)

# For A and B, gives 1 when E matches, 0 if not. This sets B to 1 for actual cause, eg. if B=0 when E=0
postmp <- postmp |> # 
  mutate(Act1 = case_when(
    node2 == 'A' ~ Actual,
    node2 == 'B' ~ Actual,
    node2 == 'Au' ~ post,
    node2 == 'Bu' ~ post
  ))

# We decided (with Quillien) we have to give only the Actual causal score for the observed variables
postmp <- postmp |> #
  mutate(noSelect = case_when(
    node2 == 'A' ~ Actual,
    node2 == 'B' ~ Actual,
    node2 == 'Au' ~ post*Actual,
    node2 == 'Bu' ~ post*Actual
  ))


noSelect <- postmp |> 
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(noSelect = mean(noSelect)) 

noActnoSelect <- postmp |> 
  group_by(pgroup, trialtype, node3, .drop=F) |> 
  summarise(noActnoSelect = mean(Act1)) 

#------- Lesion both inference and selection ---------
# As before, but it's the prior instead of posterior
mp <- mp |> # 
  mutate(Act3 = case_when(
    node2 == 'A' ~ Actual,
    node2 == 'B' ~ Actual,
    node2 == 'Au' ~ peA*Actual,
    node2 == 'Bu' ~ peB*Actual
  ))

noInfnoSelect <- mp |> 
  group_by(pgroup, trialtype, node3, .drop = F) |> 
  summarise(noInfnoSelect = mean(Act3))


#-------- Lesion everything ----------
# Assign causal score of C=1 to observed variables, and prior to unobserved variables.

mp <- mp |> # 
  mutate(Act2 = case_when(
    node2 == 'A' ~ Actual,
    node2 == 'B' ~ Actual,
    node2 == 'Au' ~ peA,
    node2 == 'Bu' ~ peB
  ))

noActnoInfnoSelect <- mp |> 
  group_by(pgroup, trialtype, node3, .drop = F) |> 
  summarise(noActnoInfnoSelect = mean(Act2))


# ---------- Merge models back together --------------------
df_list <- list(full, 
                noAct, 
                noInf, 
                noSelect, 
                noActnoInf, 
                noActnoSelect, 
                noInfnoSelect, 
                noActnoInfnoSelect) 

models <- df_list |> 
  reduce(full_join, by = c('pgroup', 'trialtype', 'node3')) |> 
  ungroup()

# Get values of Actual for each combination of pgroup, trialtype, node3
Actual <- mp |>
  group_by(pgroup, trialtype, node3) |>
  summarise(Actual = first(Actual), .groups = "drop")

# And merge back in
models2 <- merge(models, Actual, all.x = TRUE)

# --------------- Bring in participant data ----------------
# Get it in same structure 
# First set factors so we can use tally
data$pgroup <- as.factor(data$pgroup)
data$node3 <- as.factor(data$node3)
data$trialtype <- as.factor(data$trialtype)
data$isPerm <- as.factor(data$isPerm)

dataNorm <- data |> # 289
  group_by(pgroup, trialtype, node3, .drop=FALSE) |> # Here we need the .drop to get all the combinations, otherwise it doesn't give e.g. A=1 when A=0
  tally() |> 
  mutate(prop=n/sum(n))

# --------------- The actual merge! ------------------
modelAndData <- merge(x=dataNorm, y=models2) 

modelAndData <- modelAndData |> 
  unite('trial_id', pgroup, trialtype, sep = "_", remove = FALSE)

# save as rda
save(modelAndData, file = here::here('Data', 'modelData', 'modelAndDataUnfit.Rda'))