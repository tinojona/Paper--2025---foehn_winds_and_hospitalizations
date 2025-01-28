################################################################################
# GNM Model 4:
# temperature modified by foehn winds


### PACKAGES ####
library(dlnm);library(splines);library(ggplot2);library(viridis);library(gnm);library(mgcv);library(dplyr)

######


### DATA ####

data = read.csv()

# index to include only stratum that have hospitalization counts
data$stratum_dow = as.factor(data$stratum_dow)
ind_dow = tapply(data$all, data$stratum_dow, sum)

#####


### CROSSBASIS TEMPERATURE ######
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


### INTERACTION WITH FOEHN WINDS  ####

# binary foehn_threshold
foehn_bin      <- ifelse(data$foehn_wind >= 72, 0, 1)
foehn_bin_rev  <- ifelse(foehn_bin == 1, 0, 1)

# modifier functions
modif     <- cb.temp * foehn_bin
modif_rev <- cb.temp * foehn_bin_rev

#####


### MODEL 4 ####

# on foehn wind days
model_4 <- gnm("all ~ cb.temp + modif",
               data = data,
               family=quasipoisson(),
               eliminate=stratum_dow,
               subset=ind_dow>0)

# on non-foehn wind days
model_4_rev <- gnm("all ~ cb.temp + modif_rev",
                  data = data,
                  family=quasipoisson(),
                  eliminate=stratum_dow,
                  subset=ind_dow>0)

####
