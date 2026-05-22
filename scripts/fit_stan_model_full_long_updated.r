## Corona evidence synthesis for Portuguese Hospitalization and Seroprevalence data
##
## This R script is adapted from scripts developed for the publication
##
## Ganna Rozhnova, Christiaan H. van Dorp, Patricia Bruijning-Verhagen et al. 
## Model-based evaluation of school- and non-school-related measures to control the COVID-19 pandemic. 
## Nature Communications 12, 1614 (2021). https://doi.org/10.1038/s41467-021-21899-6
##
## updates: use the posterior package to handle posterior draws
## update 2 (by Rey Escosio): code adjusted for the paper
##
## Benedetta Canfora, Rey Audie Escosio, et al.
## Retrospective evaluation of school-related measures on pre-vaccination transmission dynamics of SARS-CoV-2
## medRxiv (2025). https://doi.org/10.1101/2025.04.14.25325720


# set directory
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)


# load packages
library(tidyverse)
library(cowplot)
library(lubridate)
options(mc.cores = parallel::detectCores())
library(readxl)
library(ggplot2)
library(loo) ## model comparison
library(posterior)
library(bayesplot)

## install cmdstanr to get access to newer version of Stan
#install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

library(cmdstanr)
## manually set the path to the cmdstan install
set_cmdstan_path("~/.cmdstan/cmdstan-2.37.0") ## change this to your cmdstan path
## or install cmdstan
#install_cmdstan()

# some preliminaries
numberofageclasses <- 10
t0 <- 0

## Hospitalisation data for Portugal
## This hospitalisation data file can be found in the 'data' directory
hospitalisations_all <- read.csv("../data/PT_HOSPITALIZATION_DATA.csv")
numberofdays <- dim(hospitalisations_all)[1]
hospitalisations_selected <- hospitalisations_all[1:numberofdays,]

## Demographic data for Portugal
## This demography data file can be found in the 'data' directory
demography <- pull(read_excel("../data/PT_DEMOGRAPHY_DATA_10.xlsx", skip = 0, sheet = "Population", 
                              col_names = FALSE, col_types = "numeric"), var = 1)
sum(demography)

## Contact matrices for Portugal
## These contact matrices can be found in the 'outputs' directory
## These contact matrices were obtained from data in the 'data/contact_matrix_demography/PT/' directory
contactmatrix_unperturbed <- as.matrix(read.csv("../data/RES_PT_CONTACT_MATRIX_BEFORE_10.csv", sep = "", header = FALSE))
contactmatrix_distancing <- as.matrix(read.csv("../data/RES_PT_CONTACT_MATRIX_AFTER_10.csv",sep = "", header = FALSE))
contactmatrix_schools <- as.matrix(read.csv("../data/RES_PT_CONTACT_MATRIX_SCHOOL_10.csv",sep = "", header = FALSE))

## Import serological data for Portugal
## The serological data file can be found in the 'data' directory
SeroData <- read_tsv("../data/PT_SEROPREVALENCE_DATA_TSV.tsv")


# what sampling time should we take for the seroprevalence data?
# The data has been collected between May 21 and July 8, 2020.
# Time t0 is at February 26, 2020. 

# compute the average sampling time for the sero data

date0 <- as.Date('2020-02-26') # t0 = 0
date1 <- as.Date('2020-05-21') # first sero sample
date2 <- as.Date('2020-07-08') # last sero sample

day1 <- as.numeric(difftime(date1, date0, units = "days"))
day2 <- as.numeric(difftime(date2, date0, units = "days"))

avg_day <- (day1 + day2) / 2
avg_date <- date0 + avg_day

print(paste("average sampling day:", avg_day, "which is", avg_date))

# correct for seroconversion delay

sero_delay <- 16 ## days between infection and seroconversion

# some sources:
## https://pmc.ncbi.nlm.nih.gov/articles/PMC7401320/

avg_day_inf <- avg_day - sero_delay
avg_date_inf <- date0 + avg_day_inf
print(paste("average sampling day corrected for seroconversion delay:", 
            avg_day_inf, "which is", avg_date_inf))


# instead of the average day, we also take the last day as a sensitivity analysis

last_day <- day2
last_date <- date0 + last_day
print(paste("last sampling day:", last_day, "which is", last_date))

# also correct this for seroconversion delay

last_day_inf <- last_day - sero_delay
last_date_inf <- date0 + last_day_inf
print(paste("last sampling day corrected for seroconversion delay:", 
            last_day_inf, "which is", last_date_inf))


## hyper parameters (for the priors)

## use 3 susceptability classes
#<20 : OR=0.23 (0.11,0.46)
#20-59 : OR=0.64 (0.43,0.97)
#60+ : OR=1 (reference class)

beta_short_hyp <- c(0.23, 0.64, 1.0)

susc_classes = c(1, 1, 1, 2, 2, 2, 2, 3, 3, 3)  # 3 classes

hosp_classes <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)  # 10 classes

sero_classes <- c(1, 1, 2, 3, 3, 4, 4, 5, 5, 5)  # 5 classes

## Reduce the size of age groups used for sero sampling,
## For instance, in the age class [0,5) the 0-1 year olds
## are not included in sero sampling.
demo_sero_eligible <- demography
demo_sero_eligible[1] <- (demo_sero_eligible[1] - 86579) ## this subtracts population size of 0-1 y.o.

## Compare the population sizes used for hospitalization and sero data:
dem <- as.matrix(data.frame(all=demography, sero=demo_sero_eligible))
barplot(t(dem), beside=TRUE, legend.text = c("all", "sero"))

## hyper parameters for gamma and alpha

## 95% T_I between 5.3 and 8.2 days
a_gamma <- 80; b_gamma <- 20

## 99% T_E between 2 and 5 days
a_alpha <- 32.25; b_alpha <- 9.75


stride <- 1
subset <- seq(1, numberofdays, stride)
ts <- 1:numberofdays

datalist <- list(
  t0 = t0, ## should be smaller than the smallest integration time
  ts = ts[subset], 
  numdayshosp = length(subset),
  A = numberofageclasses,
  J = 1, ## Erlang shape parameter for infectious phase
  F = 1, ## Erlang shape parameter for exposed phase
  demography = demography,
  demo_sero_eligible = demo_sero_eligible,
  Cunp = contactmatrix_unperturbed, 
  Cdis = contactmatrix_distancing,
  Csch = contactmatrix_schools,
  hospitalisations = as.matrix(hospitalisations_selected[subset,]),
  Ahosp = 10,
  hosp_classes = hosp_classes,
  Asusc = 3,
  ref_class = 3,
  susc_classes = susc_classes,
  numdayssero = 1,
#  tidx_sero = as.array(93 %/% stride), ## 93 is the average day of serological samples (corrected for seroconversion??)
  tidx_sero = as.array(last_day_inf %/% stride), ## use last day, corrected for seroconversion
  sero_num_sampled = matrix(SeroData$SampleSize, nrow=1),
  sero_num_pos = matrix(SeroData$Positive, nrow=1),
  Asero = 5, ## 5 serological classes
  sero_classes = sero_classes,
  beta_short_hyp = beta_short_hyp,
  log_beta_sd = 0.5,
  a_gamma = a_gamma,
  b_gamma = b_gamma,
  a_alpha = a_alpha,
  b_alpha = b_alpha,
  m_zeta = 1.0, ## we think zeta should be around 1
  s_zeta = 0.1,
  m_tld = 22,
  m_tlx = 69,
  m_tls = 203,
  rel_tol = 1e-5,
  abs_tol = 1e-7, 
  max_num_steps = 1e5,
  mode = 0,
  adjoint = 1,
  AlphaTrans = 0.05#,
  #alpha = 0.4, # FIXED PARAMETERS...
  #gamma = 0.25
)


nu_short_scale_guess <- 0.08
nu_short_simplex_guess <- c(0.001, 0.001, 0.001, 0.001, 0.002, 0.005, 0.01, 0.02, 0.03, 0.04) ## 8 classes

## make sure that sum(nu_short_simplex_guess) = 1
nu_short_simplex_guess <- nu_short_simplex_guess / sum(nu_short_simplex_guess)

beta_short_raw_guess <- c(0.23, 0.64) ## 3 age classes (one reference class)

## check if the initial parameter guess leads to an R0 that is reasonable
## as an approximation for R0, take rho(diag(S) * C) * epsilon/gamma
## where rho is the spectral radius

calc_R0 <- function(epsilon, beta, gamma, alpha, C) {
  ## FIXME: compute R0 properly!!
  SC <- diag(beta) %*% as.matrix(C)
  eval <- eigen(SC)$values[1]
  R0 <- eval * epsilon / gamma
  return(R0)
}

beta_short_guess <- c(beta_short_raw_guess, 1)
beta_guess <- beta_short_guess[susc_classes]
epsilon_guess <- 0.0709
gamma_guess <- 1/4.0
alpha_guess <- 0.4
R0_guess <- calc_R0(epsilon_guess, beta_guess, gamma_guess, 
                    alpha_guess, contactmatrix_unperturbed)
print("approx R0 for initial values:")
print(R0_guess)

# initial values 
initials <- function(){
  return(list(
    epsilon = epsilon_guess,
    gamma = gamma_guess,
    zeta = 0.7703,
    alpha = alpha_guess,
    inoculum = 0.00012,
    x0 = 28.4379,
    k0 = 1.4911,
    x1 = 68.0929, 
    k1 = 1.4676,
    x2 = 203.2779,
    k2 = 1.2642,
    x3 = 254.0224,
    k3 = 1.3639,
    x4 = 303.7147,
    k4 = 1.3787,
    u1 = 0.2397,
    u2 = 0.4298,
    u3 = 0.2441,
    u4 = 0.4637,
    r = 22.5975,
    nu_scale = nu_short_scale_guess,
    nu_simplex = nu_short_simplex_guess,
    beta_short_raw = beta_short_raw_guess
  ) 
  )
}

stan_model_file <- "corona_erlangEI_od_full_long_updated.stan"


# run Stan model

iter <- 3
warmup <- 2
thin <- 1



output_basename <- "PT-fit_2026-05-20_tsero93"
output_files <- file.path("outputs", paste0(output_basename, "-", 1:4, ".csv"))

# specific_output_files <- c(
#   "outputs/PT-fit_2025-09-01_tsero117-202509011147-1-8820f8.csv",
#   "outputs/PT-fit_2025-09-01_tsero117-202509011147-2-8820f8.csv",
#   "outputs/PT-fit_2025-09-01_tsero117-202509011147-3-8820f8.csv",
#   "outputs/PT-fit_2025-09-01_tsero117-202509011147-4-8820f8.csv"
# )
specific_output_files <- c(
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-1-40d0fb.csv",
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-2-40d0fb.csv",
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-3-40d0fb.csv",
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-4-40d0fb.csv",
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-5-40d0fb.csv",
  "outputs/PT-fit_2025-09-01_tsero93-202509061826-6-40d0fb.csv"
)

if (all(file.exists(specific_output_files))) {
  # csv_files <- list.files("outputs", pattern = "PT-fit_2025-09-01_tsero117.*csv$", full.names = TRUE)
  fit <- cmdstanr::as_cmdstan_fit(specific_output_files)
  
  # fit <- cmdstanr::as_cmdstan_fit(csv_files)
} else {
  
  sm <- cmdstan_model(stan_model_file)
  
  fit <- sm$sample(
    data = datalist,
    init = initials,
    chains = 4,
    iter_sampling = iter,
    iter_warmup = warmup,
  #  save_warmup = TRUE, ## have a look at traces during warmup
    thin = thin,
    refresh = 1,
    adapt_delta = 0.95,
  #  fixed_param = TRUE,
    max_treedepth = 12,
    output_dir = "cmdstan-cache", ## make sure this directory exists
    step_size = 1e-2
  )
  
  ## diagnose!
  # https://mc-stan.org/misc/warnings.html
  
  ## show summary for a subset of the params
  source("aux_functions.R")
  subfit <- subset_cmdstanr(fit, c("epsilon", "zeta", "nu_scale", "inoculum", "r", "alpha", "gamma",
                               "x0", "k0", "x1", "k1", "x2", "k2", "x3", "k3", "x4", "k4", 
                               "u1", "u2", "u3", "u4",
                               "lp__",
                               "beta_short_raw",
                               "nu_simplex"
  ))
  
  sm <- subfit$summary()
  sm[sm$rhat > 1.01,]
  
  
  # save the cmdstan csv files
  
  fit$save_output_files(dir = "outputs", basename = "PT-fit_2025-09-01_tsero117")
}


# extract with posterior

draws <- posterior::as_draws_rvars(fit$draws())

draws_df_object <- posterior::as_draws_df(draws)
base_params <- c("epsilon", "zeta", paste0("nu_short[", 1:10, "]"), "inoculum", 
                 paste0("beta_short[", 1:3, "]"), "r", "alpha", "gamma",
                 "x0", "k0", "x1", "k1", "x2", "k2", "x3", "k3", "x4", "k4",
                 "u1", "u2", "u3", "u4")
all_params_to_select <- c(base_params)
selected_df <- draws_df_object[, all_params_to_select]
# write.csv(selected_df, file = "../data/PARAMETER_ESTIMATES_SENS4SERO.csv", row.names = FALSE)





# traces (including warmup)

plot_trace_params <- c("epsilon", "zeta", "nu_scale", "inoculum", "r", "alpha", "gamma",
                       "x0", "k0", "x1", "k1", "x2", "k2", "x3", "k3", "x4", "k4", "u1", "u2", "u3", "u4")

mcmc_trace(
    draws, 
    pars = plot_trace_params,
    facet_args = list(ncol = 3), 
    size = 0.5
) + labs(title = "Traces of parameters")


# pair plots

plot_pairs_params <- c("epsilon", "zeta", "nu_scale", "inoculum")
mcmc_pairs(draws, pars=plot_pairs_params)



# select sample closest to MAP
lp <- posterior::draws_of(draws$lp_)
hist(lp, nclass = 30)
max(lp)
posmax <- as.numeric(which(lp == max(lp)))




# color-blind friendly scheme
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7",
               "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7",
               "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") 

# make a figure of hospitalisations and model fit
df_Hospitalizations <- draws$simulated_hospitalisations
yHosp_sim025 <- posterior::quantile2(df_Hospitalizations, probs=0.025)
yHosp_sim50 <- posterior::quantile2(df_Hospitalizations, probs=0.5)
yHosp_sim975 <- posterior::quantile2(df_Hospitalizations, probs=0.975)

df_Expect_Hosps <- draws$expected_hospitalisations
yHosp_hat025 <- posterior::quantile2(df_Expect_Hosps, probs=0.025)
yHosp_hat50 <- posterior::quantile2(df_Expect_Hosps, probs=0.5)
yHosp_hat975 <- posterior::quantile2(df_Expect_Hosps, probs=0.975)

ts = 1:numberofdays

dfHosp <- list()

for (j in 1:numberofageclasses) {
  dfHosp[[j]] = data.frame(list(ts = ts,
                                ## simulated values
                                y_sim50=yHosp_sim50[,j],
                                y_sim025=yHosp_sim025[,j],
                                y_sim975=yHosp_sim975[,j],
                                ## expected values
                                y_hat50=yHosp_hat50[,j],
                                y_hat025=yHosp_hat025[,j],
                                y_hat975=yHosp_hat975[,j],
                                ## data
                                hospitalizations = hospitalisations_selected[,j]
  ))
}

## Manually combine age classes

dfHosp[[numberofageclasses+1]] = data.frame(list(ts = ts, 
                                                 ## simulations
                                                 y_sim50=yHosp_sim50[,1]+yHosp_sim50[,2]+yHosp_sim50[,3],
                                                 y_sim025=yHosp_sim025[,1]+yHosp_sim025[,2]+yHosp_sim025[,3],
                                                 y_sim975=yHosp_sim975[,1]+yHosp_sim975[,2]+yHosp_sim975[,3],
                                                 ## expected values
                                                 y_hat50=yHosp_hat50[,1]+yHosp_hat50[,2]+yHosp_hat50[,3],
                                                 y_hat025=yHosp_hat025[,1]+yHosp_hat025[,2]+yHosp_hat025[,3],
                                                 y_hat975=yHosp_hat975[,1]+yHosp_hat975[,2]+yHosp_hat975[,3],
                                                 ## data
                                                 hospitalizations = hospitalisations_selected[,1]+hospitalisations_selected[,2]+
                                                   hospitalisations_selected[,3]
))


# some plot preliminaries
plothosp <- list()
margs <- c(b=1,l=0,t=0,r=0)
size <- 12
maxy <- 250
date.start <- as.Date('2020-02-26')

for (j in 1 : (numberofageclasses+1)) {
  plothosp[[j]] <- ggplot(data = dfHosp[[j]], fill=cbPalette[[j]], mapping = aes(x = ts+date.start)) +
    geom_ribbon(aes(ymin = y_hat025, ymax = y_hat975),  alpha = 0.3) +
    geom_ribbon(aes(ymin = y_sim025, ymax = y_sim975),  alpha = 0.2) +
    geom_line(aes(y=y_hat50),colour = cbPalette[[j]]) +
    geom_point(aes(y = hospitalizations), colour = cbPalette[[j]]) +  
    labs(x="Day", y = "Hospitalisations") + 
    #coord_cartesian(xlim = c(0, numberofdaysunperturbed), ylim = c(0, 100)) +
    theme_bw(base_size = size) + 
    theme(plot.margin = unit(margs, "pt"), 
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank())  
}


plot_hosp <- 
  plot_grid(
    plothosp[[1]] + ggtitle("0-4 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[2]] + ggtitle("5-9 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[3]] + ggtitle("10-19 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[4]] + ggtitle("20-29 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[5]] + ggtitle("30-39 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[6]] + ggtitle("40-49 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[7]] + ggtitle("50-59 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[8]] + ggtitle("60-69 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[9]] + ggtitle("70-79 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[10]] + ggtitle("80+ yr") + theme(plot.title = element_text(hjust = 0.5)),
    nrow = 2, 
    ncol= 5
  )

## look at all individual age classes (is pclasses OK?)
plot_hosp

plot_hosp_comb <- 
  plot_grid(
    plothosp[[11]] + ggtitle("0-19 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[4]] + ggtitle("20-29 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[5]] + ggtitle("30-39 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[6]] + ggtitle("40-49 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[7]] + ggtitle("50-59 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[8]] + ggtitle("60-69 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[9]] + ggtitle("70-79 yr") + theme(plot.title = element_text(hjust = 0.5)),
    plothosp[[10]] + ggtitle("80+ yr") + theme(plot.title = element_text(hjust = 0.5)),
    nrow = 2, 
    ncol= 4
  )

plot_hosp_comb

#png(filename = "x.png",
#    width = 1100, height = 1620, units = "px", pointsize = 12,
#    bg = "white",  res = NA, type = c("cairo"))
#plot_hosp
#dev.off()

###

# logistic function for probability of infection

probinfection <- function(t, xi, ki){
  return(1 / (1 + exp((-ki) * (t - xi))))
} 

make_logistic_plot <- function(ki, xi, tmin, tmax, tguess, color="#D55E00", p=NULL) {
  # tibble for plotting
  n_samples <- length(ki)
  
  probinfection_curves <- tibble(
    sample = 1:n_samples,
    xi = xi,
    ki = ki
  )
  
  plot_data <-
    pmap_df(probinfection_curves,
            function(sample, xi, ki) {
              tibble(sample = sample,
                     x = seq(tmin, tmax, by = 1),
                     y = probinfection(x, xi, ki))
            }) 

  # if p is NULL, we want to create a new ggplot object. Otherwise add to an existing ggplot object
  if (is.null(p)) {
    p <- ggplot()
  }
  
  # plot estimated curves of prob(infection)
  prob_infection_plot <- p +
    geom_line(mapping=aes(group = sample, x = x, y = y), data=plot_data, alpha = .2, color = color) +
    geom_vline(xintercept=tguess, linetype="dashed", color = "black", alpha = 1.0) +
    labs(x = "Date", y = "Lockdown weight") + 
    scale_x_continuous(limits = c(tmin, tmax), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    theme_bw(base_size = 20) +
    theme(legend.position = "none")
  
  return(prob_infection_plot)
}


x0_guess <- 28.4379
x1_guess <- 68.0929
x2_guess <- 203.2779
x3_guess <- 254.0224
x4_guess <- 303.7147

## logistic function lockdown
p <- make_logistic_plot(posterior::draws_of(draws$k0), posterior::draws_of(draws$x0), 0, 350, x0_guess)  ## choose good values

## logistic function relaxation
p <- make_logistic_plot(posterior::draws_of(draws$k1), posterior::draws_of(draws$x1), 0, 350, x1_guess, p=p, color='#ccccff')
p <- make_logistic_plot(posterior::draws_of(draws$k2), posterior::draws_of(draws$x2), 0, 350, x2_guess, p=p, color='#ffccff')
p <- make_logistic_plot(posterior::draws_of(draws$k3), posterior::draws_of(draws$x3), 0, 350, x3_guess, p=p, color='#ffffcc')
p <- make_logistic_plot(posterior::draws_of(draws$k4), posterior::draws_of(draws$x4), 0, 350, x4_guess, p=p, color='#ccffcc')

# show the plot...
p

## Make a violin plot of the serological data and model predictions

age.class.names.sero <- SeroData$AgeClass ## [0,5), [5,10), ...

df_sero <- as.data.frame(posterior::draws_of(draws$expected_serodata))
names(df_sero) <- age.class.names.sero
df_sero_long <- gather(df_sero, age.class)

sero_plot <- 
  ggplot() +
  geom_point(data=SeroData, aes(x=AgeClass, y=Positive), size=3) +
  geom_violin(data=df_sero_long, aes(x=age.class, y=value)) +
  scale_x_discrete(limits=age.class.names.sero) ## avoid sorting strings

sero_plot

## Are the simulations of the sero data from Stan compatible with our data?
## We can compute confidence intervals for the fractions of non-susceptible
## individuals based on the sero data alone (using Jeffreys method).
## This will be displayed as age-specific error bars.
## Then, we can compare this with the point estimates from each simulated 
## value. These are shown as a violin plot.

df_sero_frac <- as.data.frame(sweep(as.matrix(df_sero), 2, SeroData$SampleSize, "/"))
df_sero_frac_long <- gather(df_sero_frac, age.class)

SeroData$Frac <- SeroData$Positive / SeroData$SampleSize
SeroData$Lower <-qbeta(0.025, SeroData$Positive + 0.5, SeroData$SampleSize - SeroData$Positive + 0.5)
SeroData$Upper <-qbeta(0.975, SeroData$Positive + 0.5, SeroData$SampleSize - SeroData$Positive + 0.5)

sero_plot2 <- 
  ggplot(SeroData) +
  geom_point(aes(x=AgeClass, y=Frac)) +
  geom_errorbar(aes(x=AgeClass, ymin=Lower, ymax=Upper), width=0.3) +
  geom_violin(data=df_sero_frac_long, aes(x=age.class, y=value), color='red', alpha=0.5) +
  scale_x_discrete(limits=age.class.names.sero) ## avoid sorting strings

sero_plot2

## plot the estimated susc ORs

age.class.names <- c("[0.5)", "[5,10)", "[10,20)", "[20,30)", 
                     "[30,40)", "[40,50)", "[50,60)", "[60,70)",
                     "[70,80)", "80+")

df_susc <- as.data.frame(posterior::draws_of(draws$beta))
names(df_susc) <- age.class.names
df_susc_long <- gather(df_susc, age.class)

susc_plot <- 
  ggplot() +
  geom_violin(data=df_susc_long, aes(x=age.class, y=value)) +
  scale_x_discrete(limits=age.class.names) ## avoid sorting strings

susc_plot

## look at hospitalization rates 

df_hosp <- as.data.frame(log10(posterior::draws_of(draws$nu)))
names(df_hosp) <- age.class.names
df_hosp_long <- gather(df_hosp, age.class)

hosp_rate_plot <- ggplot() +
  geom_violin(data=df_hosp_long, aes(x=age.class, y=value)) +
  scale_x_discrete(limits=age.class.names) ## avoid sorting strings

hosp_rate_plot
## compute posterior density of R0

beta_est <- posterior::draws_of(draws$beta)
gamma_est <- posterior::draws_of(draws$gamma)
alpha_est <- posterior::draws_of(draws$alpha)
epsilon_est <- posterior::draws_of(draws$epsilon)

R0_est <- c()

for ( i in 1:length(epsilon_est) ) {
  R0 <- calc_R0(epsilon_est[i], beta_est[i,], gamma_est[i], alpha_est[i], 
                contactmatrix_unperturbed)
  R0_est <- c(R0_est, R0)
}

hist(R0_est)


## plot prior distributions vs marginal posteriors

## 1/gamma
df.prior.posterior <- gather(data.frame(posterior=1/posterior::draws_of(draws$gamma), 
                                        prior=1/posterior::draws_of(draws$prior_sample_gamma)))
pp.plot.gamma <- ggplot(data=df.prior.posterior) +
  geom_density(aes(x=value, fill=key), alpha=0.3)

## 1/alpha
df.prior.posterior <- gather(data.frame(posterior=1/posterior::draws_of(draws$alpha), 
                                        prior=1/posterior::draws_of(draws$prior_sample_alpha)))
pp.plot.alpha <- ggplot(data=df.prior.posterior) +
  geom_density(aes(x=value, fill=key), alpha=0.3)

## zeta 
df.prior.posterior <- gather(data.frame(posterior=posterior::draws_of(draws$zeta), 
                                        prior=posterior::draws_of(draws$prior_sample_zeta)))
pp.plot.zeta <- ggplot(data=df.prior.posterior) +
  geom_density(aes(x=value, fill=key), alpha=0.3)


pp.plots <- plot_grid(
  pp.plot.gamma + ggtitle("1/gamma"),
  pp.plot.alpha + ggtitle("1/alpha"), 
  pp.plot.zeta + ggtitle("zeta"), 
  nrow=1,
  ncol=3
)

pp.plots

################### COMPARE MODELS ##################

# compute WAIC 

log_lik <- posterior::as_draws_matrix(fit$draws(variables = "log_lik_vec"))
waic <- loo::waic(log_lik)
print(waic)

# compute LOO-CV

## FIXME: reff should be computed properly

loo <- loo::loo(log_lik)
print(loo)


