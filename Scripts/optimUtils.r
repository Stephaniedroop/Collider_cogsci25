##############################################################
########### Functions for optimising parameters and fitting  ##########
##############################################################




model_likelihood <- function(par, df, mod_name)
{
  
  tau <- exp(par) 
  tt <- unique(df$trial_id) # unique trial ids
  # Empty place for NLLs
  nlls <- rep(NA, length(tt)) 
  for (i in 1:length(tt))
  {
    n <- df$n[df$trial_id==tt[i] & df$include==T] #get counts
    mod_raw <- df[[mod_name]][df$trial_id==tt[i] & df$include==T] #get model predictions
    mod_raw[is.na(mod_raw)] <- 0 
    # Softmax with tau only
    mod_pred2 <- exp(mod_raw/tau)/sum(exp(mod_raw/tau)) 
    # Get likelihood for this trial
    nlls[i] <-  -sum(log(mod_pred2)*n) 
  }
  sum(nlls)#return the total likelihood
}


## ----include=FALSE----------------------------------------------------------------------------------------------
generate_predictions <- function(mod_name, tau, df) {
  tt <- unique(df$trial_id)
  do.call(rbind, lapply(tt, function(t_id) {
    trial_rows <- df$trial_id == t_id & df$include == TRUE
    mod_raw <- df[[mod_name]][trial_rows]
    mod_raw[is.na(mod_raw)] <- 0
    
    mod_pred2 <- exp(mod_raw/tau)/sum(exp(mod_raw/tau))
    
    data.frame(
      model = mod_name,
      trial_id = t_id,
      node3 = df$node3[trial_rows],
      predicted_prob = mod_pred2
    )
  }))
}


## ----include=FALSE----------------------------------------------------------------------------------------------

optimize_models <- function(model_names, df, initial_values = 1) { 
  optimize_single <- function(mod_name) {
    result <- tryCatch({
      optim(par = initial_values, 
            fn = model_likelihood, 
            method = 'Brent', 
            lower=-10, upper=100,
            df = df, 
            mod_name = mod_name)
    }, error = function(e) {
      message("Error in optimization for model ", mod_name, ": ", e$message)
      return(list(par = NA, value = NA))
    })
    return(result)
  }
  
  out <- lapply(model_names, optimize_single)
  names(out) <- model_names
  
  mfs <- data.frame(
    model = names(out),
    tau = exp(sapply(out, function(x) x$par)),
    logl = -sapply(out, function(x) x$value)
  ) |>
    mutate(BIC = -2 * logl + 1 * log(sum(df$n[df$include == TRUE]))) 
  
  # Generate predictions 
  predictions <- do.call(rbind, lapply(names(out), function(mod_name) {
    if(!any(is.na(out[[mod_name]]$par))) {
      generate_predictions(
        mod_name = mod_name,
        tau = exp(out[[mod_name]]$par),
        df = df
      )
    }
  }))
  
  list(
    model_fits = mfs |> mutate(tau = format(tau, digits=3)),
    predictions = predictions
  )
}