################################################################################
# GNM Model 2:
# the direct effect of foehn winds intensity
# on hospitalizations with adjusting for temperature


### PACKAGES ####
library(dlnm);library(splines);library(ggplot2);library(viridis);library(gnm);library(dplyr)

######


### DATA ####

data = read.csv()

# index to include only stratum that have hospitalization counts
data$stratum_dow = as.factor(data$stratum_dow)
ind_dow = tapply(data$all, data$stratum_dow, sum)

#####


### CROSSBASIS TEMPERATURE ####
# adjusted from:
# Gasparrini A, et al. Mortality risk attributable to high
# and low ambient temperature: a multicountry observational study.
# Lancet (London, England). 2015;386.9991:369–375.

cb.temp <- crossbasis(data$temperature,
                      lag=21,
                      argvar=list(fun="ns", knots = quantile(data$temperature, c(.5,.9), na.rm=TRUE)),
                      arglag=list(fun="ns", knots = logknots(21,3)),
                      group = data$station)

#####


### MODEL 2 ####

cb.foehn <- crossbasis(data$foehn_wind,
                       lag = 3,
                       argvar = list(fun="lin"),
                       arglag = list(fun="integer"),
                       group = data$station)

model_2 <- gnm("all ~ cb.foehn + cb.temp",
               data = data,
               family=quasipoisson(),
               eliminate=stratum_dow,
               subset=ind_dow>0)

####
