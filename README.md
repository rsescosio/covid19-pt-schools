# COVID19-PT-Retrospective

## Overview 
This is a GitHub repository for the paper "Retrospective evaluation of school-related measures on pre-vaccination dynamics of SARS-CoV-2".
In this project, we retrospectively assessed the role of school-related interventions in SARS-CoV-2 transmission in Portugal during the pre-vaccination period, providing quantitative evidence on their impact on hospital admissions and time-varying reproduction number.
We compared the real-world baseline case to two simulated scenarios: letting the schools open throughout the first lockdown of 2020 (Scenario 1), and forcing school closures right after the summer holidays of 2020 (Scenario 2).

All details are described in the manuscript:
> Canfora, B., Escosio, R. A., Boldea, O., van Dorp, C. H., Nunes, A., and Rozhnova, G.. (2025). Retrospective evaluation of school-related measures on pre-vaccination dynamics of SARS-CoV-2. 


## Data
The folder [data]("data") contains contact matrices, demographic data, hospitalization data, and obtained results from contact matrix construction and parameter estimation.
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
The scripts can be found in the [script]("scripts") directory. The R and Stan scripts are based on scripts used for the following publications

> van Boven M, Teirlinck AC, Meijer A, Hooiveld M, van Dorp CH, Reeves RM, Campbell H, van der Hoek W; RESCEU Investigators. Estimating Transmission Parameters for Respiratory Syncytial Virus and Predicting the Impact of Maternal and Pediatric Vaccination. *J Infect Dis.* 2020 Oct 7;222(Supplement_7):S688-S694. doi: https://doi.org/10.1093/infdis/jiaa424

> Viana J, van Dorp CH, Nunes A, Gomes MC, van Boven M, Kretzschmar ME, Veldhoen M, Rozhnova G. Controlling the pandemic during the SARS-CoV-2 vaccination rollout. Nature communications. 2021 Jun 16;12(1):3674. doi: https://doi.org/10.1038/s41467-021-23938-8.


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
