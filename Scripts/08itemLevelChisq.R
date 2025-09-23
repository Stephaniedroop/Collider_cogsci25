## ----setup, include=FALSE---------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(ggnewscale)
library(tidyverse)


## ----include=FALSE----------------------------------------------------------------------------------------------
df <- read.csv('modelAndDataUnfit.csv') # 288 obs of 14



## ---------------------------------------------------------------------------------------------------------------
results <- df %>%
  group_by(pg_tt) %>%
  summarise(
    chi_sq_stat = chisq.test(n, p = rep(1/n(), n()))$statistic,
    p_value     = chisq.test(n, p = rep(1/n(), n()))$p.value
  ) %>%
  mutate(
    p_adj = p.adjust(p_value, method = "bonferroni")
  )

print(results)



## ----include=FALSE----------------------------------------------------------------------------------------------
observed <- df$n
expected <- rep((sum(df$n)/length(df$n))/sum(df$n), length(df$n))

chi_sq_result <- chisq.test(x=df$n, p = expected)
print(chi_sq_result)


