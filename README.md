# covid19-pt-schools

## Overview 
This is a GitHub repository for the paper "Retrospective evaluation of school-related measures on pre-vaccination transmission dynamics of SARS-CoV-2".
In this project, we retrospectively assessed the role of school-related interventions in SARS-CoV-2 transmission in Portugal during the pre-vaccination period, providing quantitative evidence on their impact on hospital admissions and time-varying reproduction number.
We compared the real-world baseline case to two simulated scenarios: letting the schools open throughout the first lockdown of 2020 (Scenario 1), and forcing school closures right after the summer holidays of 2020 (Scenario 2).

All details are described in the manuscript:
> Canfora, B., Escosio, R. A., van Dorp, C. H., Boldea, O., Bonten, M., Nunes, A., and Rozhnova, G.. (2025). Retrospective evaluation of school-related measures on pre-vaccination transmission dynamics of SARS-CoV-2. 


## Data
The folder [data](data) contains contact matrices, demographic data, hospitalization data, and obtained results from contact matrix construction and parameter estimation.
In particular, the seroprevalence data is from:
> Kislaya I, Gonçalves P, Barreto M, Sousa R, Garcia AC, Matos R, Guiomar R, Rodrigues AP; ISNCOVID-19 Group. Seroprevalence of SARS-CoV-2 Infection in Portugal in May-July 2020: Results of the First National Serological Survey (ISNCOVID-19). Acta Med Port. 2021 Feb 1;34(2):87-94. doi: 10.20344/amp.15122. Epub 2021 Feb 1. PMID: 33641702.

The baseline contact matrix for Portugal is from:
> Mistry, D., Litvinova, M., Pastore y Piontti, A. et al. Inferring high-resolution human mixing patterns for disease modeling. Nat Commun 12, 323 (2021). https://doi.org/10.1038/s41467-020-20544-y.

The contact matrices for the Netherlands are from:
> Backer JA, Mollema L, Vos ER, Klinkenberg D, van der Klis FR, deMelker HE, et al. Impact of physical distancing measures against COVID-19 on contacts and mixing patterns: repeated cross-sectional surveys, the Netherlands, 201617, April 2020 and June 2020. Eurosurveillance. 2021;26(8). doi:https://doi.org/10.2807/1560-7917.ES.2021.26.8.2000994.

The demography [data](https://www.pordata.pt/Portugal/Popula%C3%A7%C3%A3o+residente++m%C3%A9dia+anual+total+e+por+grupo+et%C3%A1rio-10) is from the Contemporary Portugal Database (PORDATA): https://www.pordata.pt/ and the hospitalization data is from the Central Administration of the Health System and the Shared Services of the Ministry of Health.


## Model
### Parameter estimation
Parameter estimation was done with R Version 3.6.0 using R Studio Version 1.3.959 (Interface to R) and Stan using rstan R package Version 2.19.3 (R interface to Stan) and cmdstanr R package Version 0.1.3 on Windows 10 Home Version 1903.
The scripts can be found in the [script](scripts) directory. The R and Stan scripts are based on scripts used for the following publications

> van Boven M, Teirlinck AC, Meijer A, Hooiveld M, van Dorp CH, Reeves RM, Campbell H, van der Hoek W; RESCEU Investigators. Estimating Transmission Parameters for Respiratory Syncytial Virus and Predicting the Impact of Maternal and Pediatric Vaccination. *J Infect Dis.* 2020 Oct 7;222(Supplement_7):S688-S694. doi: https://doi.org/10.1093/infdis/jiaa424

> Viana J, van Dorp CH, Nunes A, Gomes MC, van Boven M, Kretzschmar ME, Veldhoen M, Rozhnova G. Controlling the pandemic during the SARS-CoV-2 vaccination rollout. Nature communications. 2021 Jun 16;12(1):3674. doi: https://doi.org/10.1038/s41467-021-23938-8.

### Model solutions and analysis
The model solutions and analysis were done with Wolfram Mathematica 14.2.0.0 on Mac OS Sequioa 15.3.2.
The [main notebook](notebooks/mainTwoScenarios.nb) contains all the codes besides preliminary and plotting functions in the [packages](packages) directory.
It also contains the generated figures in the [figures](figures) directory.
For the local dependencies, the [preliminaries](packages/preliminaries.m) file contain functions on file import and export, and statistical measures.
The [plotting](packages/plotting.m) file contain variables on colors and strings used for labeling and functions on plotting.

## Using the notebook
You should proceed as follows: 1) use the *R* and its packages to fit the model to the data; 2) export the parameter estimates to the [data](data) directory and use the [main notebook](notebooks/mainTwoScenarios.nb) to perform the analyses, run scenarios, and create the figures.

The necessary files in [data](data) directory are:
- Age stratified demography
- Baseline (pre-pandemic) contact matrix
- Contact matrix after the first lockdown
- Age stratified hospitalization data
- Age stratified seroprevalence 

Run the [main notebook](notebooks/mainTwoScenarios.nb) to solve the model for the baseline case, and generate the two scenarios.
To speed up the process, the solution and analysis files are already in the [results](results) directory but the code should run without them.
The codes to generate the results of sensitivity analyses from scratch are not included but follow the same format as that of the three main scenarios.
Their results and figures, alongside all the main text and supplementary plots, are also run in the main notebook.
Other sensitivity analyses such as for fitting seroprevalence to different dates (time indices [117](notebooks/supplementarySeroprevalence117.nb) and [157](notebooks/supplementarySeroprevalence157.nb)) and for varying [partial school mitigation levels](notebooks/supplementaryVaryMultiplier.nb).

## Dependencies and hardware requirements 
This code was developed on a MacBook Pro (13-inch, 2020), macOS: Sequoia 15.3.1, chip: Apple M1 Pro, memory: 8GB. 
Our study requires only a standard computer with enough RAM to support the in-memory operations.

- [Mathematica 14.2.0.0](https://www.wolfram.com/mathematica/)
- [R version 3.6.0](https://www.r-project.org/) with the following packages:
  - [rstan](https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html) Version 2.21.1
  - [cmdstanr](https://mc-stan.org/cmdstanr/) Version 0.1.3

No non-standard hardware is required.
Other than installation of these required software and packages, no installation is needed.

## Acknowledgments
We appreciate the valuable discussions with members of the Infectious Disease Modeling Group at the University Medical Center Utrecht in the Netherlands.

## Funding  
G.R. discloses support for the research of this work from the Fundação para a Ciência e a Tecnologia, I.P. (FCT), Portugal [project 2022.01448.PTDC, DOI: 10.54499/2022.01448.PTDC]. G.R. and A.N. disclose support for the research of this work from UID/04046/2025 (Instituto de Biosistemas \& Ciências Integrativas Centre grant, FCT, Portugal). G.R. acknowledges support from the VERDI project (101045989), funded by the European Union. B.C. acknowledges support from the Swaantje Mondt travel fund from the Center for Complex Systems Studies at Utrecht University. O.B. acknowledges support from the Tilburg University Fund.

## Correspondence
Correspondence and material requests should be addressed to Dr. Ganna Rozhnova, Julius Center for Health Sciences and Primary Care, University Medical Center Utrecht, P.O. Box 85500 Utrecht, The Netherlands; email: [g.rozhnova@umcutrecht.nl](mailto:g.rozhnova@umcutrecht.nl).
