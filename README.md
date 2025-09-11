# Scripts and data for a behavioural experiment and computational models to study how human cognition uses both causal selection and causal inference to generate explanations for observed phenomena

## Authors

- Stephanie Droop (stephanie.droop@ed.ac.uk)
- Neil Bramley
- Tadeg Quillien
- (some consultation from Christopher Lucas)

## Languages

All analysis scripts are in R, v.4.1. (Packages needed: tidyverse, lme4, lmerTest, stringr, [[purrr, ggnewscale, RColorBrewer]] // TO DO check if definitely use these last ones).
Experiment scripts are html, raw JS and JSPsych.

## How to run

- For **analysis** go to the `Main_scripts` folder and run `masterscript.R`, or if you know what script you are looking for you can go straight there and run that only. See list of scripts below.
- To see the behavioural experiment at https://eco.ppls.ed.ac.uk/~s0342840/collidern/collidertop.html. Code for the task interface and structure of running it in JavaScript in in the folder `Experiment`. To click through the experiment: at the comprehension check enter Yes, No, True, 12.

## Files, folders, model

### FOLDER Main_scripts

- `masterscript.R` - top level script to wrangle and process the participant data, run the counterfactual simulations to get model predictions and save them in folder `model_data`, run other model lesions, check model fit, plot all charts, etc. **Go here first**.

The masterscript sources scripts in the following order:

1. Processing behavioural experiment data (see folder `Experiment` for the JS code of experiment):

- `mainbatch_preprocessing.R` - get the participants' behavioural experiment data ready.

2. Setting up Collider worlds and getting model predictions for them:

- `set_params.R` - small script to set the different probabilities we want to manipulate for the model and experiment
- `get_model_preds4.R` - get model predictions
- `functionsN1.R` - static script of functions used to set up the worlds and run the CESM model
- `modpred_processing2.R` - get the model predictions in a user-friendly format: Wrangles and renames variables, splits out node values 0 and 1, saves .rdata for each value of stability parameter s

### FOLDER Experiment

Holds the Javascript and html to run the behavioural experiment, which is an online interface with a task like a game. Participants from Prolific were paid to complete the task in early July 2024.

### FOLDER Data, pilot_data

Participant data from the behavioural experiment.

## Glossary

Some everyday words have a special sense in this project.

- `world` - a setting of observed node variables A and B, and outcome E set by deterministic structural equations. A single iteration of how things started off and turned out. Each node can take 0 or 1. Sometimes represented by the values of A,B,E in order, eg. 110 means A=1, B=1, E=0, ie. that A and B both happened and the effect didn't.
- #TO DO

## What is a Collider and why is it important?

## Glossary

Some everyday words have a special sense in this project.

- `world` - a setting of node variables A and B, and outcome E, a single iteration of how things started off and turned out. Each node can take 0 or 1. Sometimes represented by the values of A,B,E in order, eg. 110 means A=1, B=1, E=0, or that A and B both happened and the effect didn't.
-

When two possible causes, A and B, can both cause effect E. It can be either conjunctive (A _and_ B needed for E) or disjunctive (A _or_ B needed for E). It's a good toy scenario to get a model working. It seems that when several things can potentially cause an outcome, and people want to decide what specifically caused it _this time_, they pick the thing that reliably occurs at the same time as the effect.

But the world is messy and things don't stay the same for long enough to really count everything up. We often have to explain events without having had the luxury of running a proper randomised controlled experiment. Somehow we all do manage to do this, and well enough not to notice how remarkable it is! One theory of how we do this is that our minds simulate `counterfactuals`, (aka other ways things could have turned out), under the hood, under our conscious awareness. Under this theory, we imagine other similar situations, and we decide something is a cause when it robustly correlates with the effect even as everything around shifts and changes. This is elegantly modelled in Quillien's `counterfactual effect size model`, which went a step further than the other existing accounts like Lewis `direct dependency` (where literally everything else has to stay the same to calculate a cause's strength, ie. it only goes 'one layer deep') and Icard/Morris necessity-sufficiency model. Quillien's model 'jiggles', 'flips' or 'resamples' all the variables just like things vary in real life, and then calculates how invariant the cause is across these counterfactuals.

However elegant this model is, it can't be the whole story. The causal score it allocates is only based on base rate or probability, whereas people are more sensitive to the structure they see in the world. It seems we naturally gravitate to causes that are more informative. THat's what this project is about, to model how we do that.
