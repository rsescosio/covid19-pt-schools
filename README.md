# COVID19-PT-Retrospective

## Overview 
GitHub repository for the paper "MRetrospective evaluation of school-related measures on pre-vaccination dynamics of SARS-CoV-2". All details are described in the manuscript:
> Canfora, B., Escosio, R. A., Boldea, O., van Dorp, C. H., Nunes, A., and Rozhnova, G.. (2025). Retrospective evaluation of school-related measures on pre-vaccination dynamics of SARS-CoV-2. 

## Data
The folder [DATA/EPIDEMIOLOGICAL]("DATA/EPIDEMIOLOGICAL") contains epidemiological data and PrEP data.
The folder [DATA/SURVEY_BEHAVIOR]("DATA/SURVEY_BEHAVIOR") contains aggregated survey data on sexual contact rates. There are 3 files with 529 rows containing the individual values of the variable $c$ (contact rate adjusted by condom use and steady partners, as described in Section 2.1 of the Supplementary Material).
- `total_curr.xlsx` refers to the scenario with no cure
- `total_sc1.xlsx` refers to the scenario with remission cure
- `total_sc2.xlsx` refers to the scenario with eradication cure

## Running the code
### Fitting 
To fit the model, run the following scripts in the suggested order:

1)	fit_contactrates.nb to fit Weibulls to pre-processed aggregated survey data for all scenarios
2)	diagnostic_delays.R to calibrate diagnostic delays as described in Section 2.2 of the Supplementary Material
3)	ABC.R to fit the baseline model before cure with Approximate Bayesian Computation. ABC_noimp.R and ABC_fixed_imp.R to fit the models for the sensitivity analyses without immigration and fixed proportion of undiagnosed to diagnosed imported individuals, respectively (see the paper for a detailed explanation of various assumptions on importation)
Initial conditions for the model variables in the fitting process are defined in lines 423 - 448 of ABC.R.

The results from steps 1) and 2) are already included in the DATA/SURVEY_BEHAVIOR and DATA/EPIDEMIOLOGICAL subfolders, respectively.

To avoid high computational costs of ABC procedures, we have provided pre-saved workspaces, that are "fit_threshold15.Rdata" (baseline), "fit_threshold15_noimp.Rdata" and "fit_threshold15_fixedimp.Rdata" (sensitivity analyses) that can be dowloaded from Zenodo, DOI: 10.5281/zenodo.14851476 (link: https://doi.org/10.5281/zenodo.14851476). After downloading, fit_threshold15.Rdata (or similarly the other two sensitivity analyses workspaces), place it in the RESULTS folder. This file contains the output from the Approximate Bayesian Computation (ABC) fit.
You can skip step 3) and proceed directly to simulating scenarios using the provided workspace (see instructions below).

### Simulating
To generate scenarios output files, run the following scripts:

-	scenario1.R to simulate remission
-	scenario1_noimp.R to simulate remission with no importation
-	scenario1_fixedimp.R to simulate remission with fixed proportion of undiagnosed to diagnosed imported individuals
-	scenario1_behav.R to simulate remission with behavioral changes
-	scenario1_erlang.R to simulate remission with Erlang distributed rebound times
-	scenario_mix.R to simulate remission with possibility of re-infection
-	scenario2.R to simulate eradication
-	scenario2_noimp.R to simulate eradication with no importation
-	scenario2_fixedimp.R to simulate eradication with fixed proportion of undiagnosed to diagnosed imported individuals
-	scenario2_behav.R to simulate eradication with behavioral changes
-	incr_lambda_1.R to simulate remission with HIV incidence increasing after 2022
-	incr_lambda_2.R to simulate eradication with HIV incidence increasing after 2022
-	check_proportions_groups.R to simulate the model without cure and check if prevalence by risk group remains constant

Computation for the ABC requires about 3-4 hours on a MacBook Pro (Apple M1 Pro).
Computation for each cure scenarios requires 1-2 hours.

### Plotting 
To produce final figures, run the following scripts:

-	plot_CDFcontactrates.R to plot CDF
-	plot_ABC.R to plot the fit results
-	plot_ABC_noimp.R to plot the fit results relative to ABC_noimp.R
-	plot_ABC_fixed.R to plot the fit results relative to ABC_fixedimp.R
-	plot_proportions_groups.R to plot the check results relative to check_proportions_groups.R
-	plot_scenario1.R to plot remission dynamics
-	plot_scenario1_noimp.R to plot remission dynamics simulated with scenario1_noimp.R
-	plot_scenario1_fixedimp.R.R to plot remission dynamics simulated with scenario1_fixedimp.R
-	plot_scenario1_behav.R to plot remission with behavioral changes dynamics
-	plot_scenarioerlang.R.R to plot remission dynamics with Erlang distributed rebound times
-	plot_scenariomix.R.R to plot remission dynamics simulated with scenario_mix.R
-	plot_scenario2.R to plot eradication dynamics
-	plot_scenario1_noimp.R to plot eradication dynamics simulated with scenario2_noimp.R
-	plot_scenario1_fixedimp.R.R to plot eradication dynamics simulated with scenario2_fixedimp.R
-	plot_scenario2_behav.R to plot eradication with behavioral changes dynamics
-	plot_SA_scenario1.R to plot sensitivity analyses for remission
-	plot_SA_scenario2.R to plot sensitivity analyses for eradication (after "plot_SA_scenario1.R")
-	plot_incr_1.R to plot sensitivity analyses of increasing incidence for remission
-	plot_incr_2.R to plot sensitivity analyses of increasing incidence for eradication

## Dependencies and hardware requirements 
This code was developed on a MacBook Pro (13-inch, 2020), macOS: Sequoia 15.3.1, chip: Apple M1 Pro, memory: 8GB. 
Our study requires only a standard computer with enough RAM to support the in-memory operations.

- [Mathematica 14.2.0.0](https://www.wolfram.com/mathematica/)
- [R version 3.6.0](https://www.r-project.org/) with the following packages:
  - [rstan](https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html) Version 2.21.1
  - [cmdstanr](https://mc-stan.org/cmdstanr/) Version 0.1.3

No non-standard hardware is required.
Other than installation of these required software and packages, no installation is needed.

## Funding  
The authors gratefully acknowledge funding from the Fundação para a Ciência e a Tecnologia, I.P., through national funds, under the project 2022.01448.PTDC “Controlo dirigido da COVID-19 após a vacinação em massa”, DOI 10.54499/ 2022.01448.PTDC. This work was also supported by UID/04046/2025 Centre grant from the Fundação para a Ciência e a Tecnologia, Portugal (to BioISI). Benedetta Canfora was supported by the Swaantje Mondt travel fund from the Center for Complex Systems Studies at Utrecht University. Ganna Rozhnova was supported by the VERDI project (101045989), funded by the European Union. Views and opinions expressed in this article are however those of the author(s) only and do not necessarily reflect those of the European Union or the Health and Digital Executive Agency. Neither the European Union nor the granting authority can be held responsible for them. We also appreciate the valuable discussions with Infectious Disease Modeling Group members at the University Medical Center Utrecht.