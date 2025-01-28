################################################################################
# GNM Model 1:
# the direct effect of foehn winds intensity
# on hospitalizations without adjusting for temperature


### PACKAGES ####
library(dlnm);library(splines);library(ggplot2);library(viridis);library(gnm)

######


### DATA ####

data = read.csv()

# index to include only stratum that have hospitalization counts
data$stratum_dow = as.factor(data$stratum_dow)
ind_dow = tapply(data$all, data$stratum_dow, sum)

#####


### FUNCTION qAIC ####

QAIC <- function(model) {
  phi <- summary(model)$dispersion
  loglik <- sum(dpois(model$y, model$fitted.values, log=TRUE))
  return(-2*loglik + 2*summary(model)$df[3]*phi)
}

######


### ARGVAR ARGLAG DEFINITION ####
# two lists of argvar and arglag arguments
# many have been tried out, visualized and then repeatedly compared
# the listed ones are here as an example

v_var <- list(list(fun="ns", knots = quantile(data$f_id, c(.8, .9), na.rm=TRUE),Boundary=range(data$f_id)),
              list(fun="ns", knots = quantile(data$f_id, c(.8, .9, .95), na.rm=TRUE),Boundary=range(data$f_id)),
              list(fun="strata", breaks = equalknots(data$f_id, nk = 3)),
              list(fun="strata", breaks = equalknots(data$f_id, nk = 4)),
              list(fun="strata", breaks = equalknots(data$f_id, nk = 5)),
              list(fun="ns", knots = equalknots(data$f_id, nk=2) ,Boundary=range(data$f_id)),
              list(fun="ns", knots = equalknots(data$f_id, nk=3) ,Boundary=range(data$f_id)),
              list(fun="ns", knots = equalknots(data$f_id, nk=4) ,Boundary=range(data$f_id)),
              list(fun="lin")
)

v_lag <- list(list(fun="integer"),
              list(fun="strata", breaks = 1),
              list(fun="ns", knots = 1),
              list(fun="ns", knots = c(1,2))
)

#####


### METHOD OF DETERMINATION OF OPTIMAL PARAMETERS ####

# define the maximum lag distance we account for
maxlago <- 3

# create an empty matrix to store the qAIC
qaic_tab <- matrix(NA,
                   nrow = length(v_var),
                   ncol=length(v_lag),
                   dimnames = list(c(v_var), c(v_lag)))

## Run the model for each combination
for (i in 1:length(v_var)){

  # extract variable function
  argvar = v_var[[i]]

  for (j in 1:length(v_lag)) {

    #  extract lag function
    arglag = v_lag[[j]]

    # crossbasis
    cb.f_id <- crossbasis(data$f_id,
                          lag=maxlago,
                          argvar=argvar,
                          arglag=arglag,
                          group=data$station)

    # model
    mod <- gnm(all ~ cb.f_id,
               data=data,
               eliminate=stratum,
               subset=ind_dow>0,
               family=quasipoisson())

    # save qAIC in qaic_tab
    qaic_tab[i,j] <- QAIC(mod)
  }
}


# Check model with lowest Q-AIC score
min_qaic = min(qaic_tab, na.rm = TRUE)

# extract location of minimum value
min_position <- which(qaic_tab == min_qaic, arr.ind = TRUE)

# extract name of col and row and save them for plotting (the functions)
opt_var <- rownames(qaic_tab)[min_position[1]]
opt_lag <- colnames(qaic_tab)[min_position[2]]

# print results
print(paste0("Minimum value: ", round(min_qaic, 1), digits = 1))
cat("Var function:", opt_var, "\n")
cat("Lag function:", opt_lag, "\n")

#####


### MODEL 1 ####

cb.foehn <- crossbasis(data$foehn_wind,
                       lag = 3,
                       argvar = list(fun="lin"),
                       arglag = list(fun="integer"),
                       group = data$station)

model_1 <- gnm("all ~ cb.foehn",
               data = data,
               family=quasipoisson(),
               eliminate=stratum_dow,
               subset=ind_dow>0)

####
