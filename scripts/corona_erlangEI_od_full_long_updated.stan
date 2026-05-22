/* Corona evidence synthesis for Portuguese Hospitalization and Seroprevalence data
 * This Stan script is adapted from scripts developed for the publication
 * 
 * Ganna Rozhnova, Christiaan H. van Dorp, Patricia Bruijning-Verhagen et al. 
 * Model-based evaluation of school- and non-school-related measures to control the COVID-19 pandemic. 
 * Nature Communications 12, 1614 (2021). https://doi.org/10.1038/s41467-021-21899-6
 *
 * This model uses some features from Stan 2.4 to make life easier.
 * Use a negative-binomial distribution for hospitalizations
 * The infectious period and the exposed period are Erlang-distributed.
 *
 * update: use new array notation, and implement the adjoint solver.
 * some aspects are simplified: for instance the sero time point has to be
 * one of the hosp time points, and no sorting is required.
 */

functions {
  /* ODE model */
  vector corona_model(real t, vector y, real epsilon, real alpha, real gamma,
                      real zeta, real k0, real x0, real k1, real x1, real k2,
                      real x2, real k3, real x3, real k4, real x4, real u1,
                      real u2, real u3, real u4, vector beta_short,
                      vector nu_short, data matrix Cunp, data matrix Cdis,
                      data matrix Csch, array[] int susc_classes,
                      array[] int hosp_classes, int A, int J, int F) {
    vector[(1 + F + J) * A] dydt; // S, E, I
    // preparations
    vector[A] Itot = to_matrix(y[(F + 1) * A + 1 : (F + J + 1) * A], A, J)
                     * rep_vector(1.0, J);
    // pre-compute matrix vector products
    vector[A] CunpItot = Cunp * Itot;
    vector[A] CdisItot = Cdis * Itot;
    
    real q0 = inv_logit(k0 * (t - x0));
    real q1 = inv_logit(k1 * (t - x1));
    real q2 = inv_logit(k2 * (t - x2));
    real q3 = inv_logit(k3 * (t - x3));
    real q4 = inv_logit(k4 * (t - x4));
    
    vector[A] CItot = CunpItot * (1 - q0) + q0 * zeta * CdisItot * (1 - q1)
                      + q1 * (u1 * CunpItot + (1 - u1) * zeta * CdisItot)
                        * (1 - q2)
                      + q2 * (u2 * CunpItot + (1 - u2) * zeta * CdisItot)
                        * (1 - q3)
                      + q3 * (u3 * CunpItot + (1 - u3) * zeta * CdisItot)
                        * (1 - q4)
                      + q4 * (u4 * CunpItot + (1 - u4) * zeta * CdisItot); // 2nd relaxed lockdown                  
    
    vector[A] incidence = (CItot * epsilon) .* beta_short[susc_classes]
                          .* y[1 : A];
    // now build dydt
    dydt[1 : A] = -incidence; // Susceptible
    // first exposed phase
    dydt[A + 1 : 2 * A] = incidence - alpha * F * y[A + 1 : 2 * A]; // Exposed
    // other E-stages (if F > 1)
    for (j in 2 : F) {
      dydt[j * A + 1 : (j + 1) * A] = alpha * F
                                      * (y[(j - 1) * A + 1 : j * A]
                                         - y[j * A + 1 : (j + 1) * A]);
    }
    // first infectious stage
    dydt[(1 + F) * A + 1 : (2 + F) * A] = alpha * F
                                          * y[F * A + 1 : (1 + F) * A]
                                          - (gamma * J
                                             + nu_short[hosp_classes])
                                            .* y[(1 + F) * A + 1 : (2 + F)
                                                                   * A];
    // other infectous stages (if J > 1)
    for (j in 2 : J) {
      dydt[(F + j) * A + 1 : (1 + F + j) * A] = gamma * J
                                                * y[(F + j - 1) * A + 1 : 
                                                (F + j) * A]
                                                - (gamma * J
                                                   + nu_short[hosp_classes])
                                                  .* y[(F + j) * A + 1 : 
                                                  (1 + F + j) * A];
    }
    // Hospitalized class
    //    dydt[A*(J+F+1)+1:A*(J+F+2)] = nu_short[hosp_classes] .* Itot;
    // and return the result...
    return dydt;
  }
}
data {
  /* preliminaries  */
  real t0; // start integration at t0=0
  int<lower=1> A;
  int<lower=1> numdayshosp;
  
  /* for grouping of classes wrt reporting in the hospital */
  int<lower=1> Ahosp;
  array[A] int<lower=1, upper=Ahosp> hosp_classes;
  
  /* for grouping of susceptibility classes */
  int<lower=1> Asusc;
  array[A] int<lower=1, upper=Asusc> susc_classes;
  int<lower=1, upper=Asusc> ref_class; // has OR of 1
  
  /* contact matrices in the pre-lockdown and lockdown */
  matrix[A, A] Cunp; // unperturbed contact matrix
  matrix[A, A] Cdis; // distancing contact matrix
  matrix[A, A] Csch; // school contact matrix
  
  /* demography */
  array[A] real demography; // demographic composition
  array[A] real demo_sero_eligible; // allows for smaller age classes for sero samplng
  
  /* observation times */
  array[numdayshosp] real ts;
  
  int<lower=1> F; // number of compartments for Erlang-distributed exposed period
  int<lower=1> J; // number of compartments for Erlang-distributed infectious period
  
  /* fix latent period for faster sampling */
  //real <lower = 0> alpha;                                    
  
  /* sampling temperature */
  int<lower=0, upper=1> mode; // 0 = estimation, 1 = WBIC calculation
  
  /* hospitalisation data by admission date */
  array[numdayshosp, A] int<lower=0> hospitalisations;
  
  /* serological data */
  int<lower=0> numdayssero;
  int<lower=0> Asero; // number of sero data age classes
  array[A] int<lower=1, upper=Asero> sero_classes; // assign to every age class a sero class
  array[numdayssero] int tidx_sero; // time indices of sero measurements
  array[numdayssero, Asero] int<lower=0> sero_num_sampled;
  array[numdayssero, Asero] int<lower=0> sero_num_pos;
  
  /* ODE integrator settings */
  real<lower=0> rel_tol;
  real<lower=0> abs_tol;
  int max_num_steps;
  
  /* Hyper parameters */
  array[Asusc] real<lower=0> beta_short_hyp; // typical ORs
  real<lower=0> log_beta_sd; // sd for log-normal prior for ORs
  
  real<lower=0> a_gamma; // shape parameter for prior of gamma
  real<lower=0> b_gamma; // scale parameter for prior of gamma
  
  real<lower=0> a_alpha; // shape parameter for prior of alpha
  real<lower=0> b_alpha; // scale parameter for prior of alpha
  
  //real<lower=0> alpha;                                             //!! rate of becoming infectious
  //real<lower=0> gamma;                                             //!! recovery rate
  
  real<lower=0> m_zeta; // location parameter for prior of zeta
  real<lower=0> s_zeta; // scale parameter for prior of zeta
  
  real m_tld; // mean lockdown time
  real m_tlx; // mean lockdown relaxation time
  real m_tls; // mean school opening time
  
  real<lower=0, upper=1> AlphaTrans; // ...
  
  // some settings
  int<lower=0, upper=1> adjoint; // use adjoint ODE integrator
}

transformed data {
  /* sampling temperature */
  real<lower=0, upper=1> watanabe_beta; // 0 = normal; 1 = WBIC
  array[Asero] real<lower=0> demography_sero = rep_array(0.0, Asero); // sizes of sero age classes
  array[A] real<lower=0, upper=1> demography_sero_frac; // fraction of sub-populations of sero_classes
  int numobs_all = A * numdayshosp + Asero * numdayssero;
  
  /* sampling mode. 0 = normal; 1 = WBIC */
  if (mode == 0) {
    watanabe_beta = 1.0;
  }
  else {
    // mode == 1
    /* NB: if any of the age classes for the sero data has a 0 sample
     * size, this should be exluded from the number of observations 
     */
    watanabe_beta = 1.0 / log(numobs_all);
  }
  
  // sum sub-age-classes for each sero class
  for (a in 1 : A) {
    // demography_sero was initialized at 0.0
    demography_sero[sero_classes[a]] += demo_sero_eligible[a];
  }
  // and compute the relative size of each sub class
  for (a in 1 : A) {
    demography_sero_frac[a] = demo_sero_eligible[a]
                              / demography_sero[sero_classes[a]];
  }
}

parameters {
  real<lower=0> alpha; // rate of becoming infectious
  real<lower=0> gamma; // recovery rate
  real<lower=0, upper=1> epsilon; // probability of transmission per contact 
  real<lower=0> zeta; // proportionality parameter for the lockdown contact matrix
  real<lower=0> x0; // x0 of logist from pre-lockdown to lockdown
  real<lower=0.25> k0; // k0 of logist from pre-lockdown to lockdown
  real<lower=50, upper=141> x1; // x1 of logist from lockdown to relaxed lockdown
  real<lower=0.25> k1; // k1 of logist from lockdown to relaxedlockdown 
  real<lower=141, upper=223> x2; // x2 of logist from relaxed lockdown to 2nd pre-lockdown
  real<lower=0.25> k2; // k2 of logist from relaxed lockdown to 2nd pre-lockdown
  real<lower=223, upper=287> x3; // x3 of logist from 2nd pre-lockdown to 2nd lockdown
  real<lower=0.25> k3; // k3 of logist from 2nd pre-lockdown to 2nd lockdown
  real<lower=287> x4; // x4 of logist from 2nd lockdown to 2nd relaxed lockdown
  real<lower=0.25> k4; // k4 of logist from 2nd lockdown to 2nd relaxed lockdown
  real<lower=0, upper=1> u1; // relaxed lockdown parameter
  real<lower=0, upper=1> u2; // 2nd pre-lockdown parameter
  real<lower=0, upper=1> u3; // 2nd lockdown parameter
  real<lower=0, upper=1> u4; // 2nd relaxed lockdown parameter
  real<lower=0> nu_scale; // average hosp rate
  simplex[Ahosp] nu_simplex; // relative hosp rates
  vector<lower=0, upper=1>[Asusc - 1] beta_short_raw; // age-dependent susceptibility 
  real<lower=1e-7, upper=5e-4> inoculum; // approx 1-10k initial infections
  real<lower=0> r; // over-dispersion parameter for hosp incidence
}

transformed parameters {
  vector<lower=0, upper=1>[(1 + F + J) * A] y0; // initial conditions 
  array[numdayshosp] vector[(1 + F + J) * A] y_hat; // prevalences at time t of age a (3 classes)
  vector<lower=0>[Ahosp] p_short; // prob of hospitalisation
  vector<lower=0>[A] nu; // hospitalisation rates              
  vector<lower=0>[Asusc] beta_short = ones_vector(Asusc); // age-dependent susceptibility ORs
  vector<lower=0>[A] beta; // susceptibilities for all age classes
  
  real x1_alpha = x1 + logit(AlphaTrans) / k1;
  
  /* for easy reference */
  matrix[numdayshosp, A] Susceptible;
  matrix[numdayshosp, A] Exposed = rep_matrix(0.0, numdayshosp, A);
  matrix[numdayshosp, A] Infected = rep_matrix(0.0, numdayshosp, A);
  matrix[numdayshosp, A] log_likes_hosp; // log-likelihood contributions of hospitalisations  
  matrix[numdayssero, Asero] log_likes_sero; // log-likelihood contributions of serological data 
  
  vector[Ahosp] nu_short = nu_scale * nu_simplex;
  /* reduced number age-specific parameters for severe disease */
  nu = nu_short[hosp_classes]; // elongate nu_short
  
  // add a OR of 1 to the beta_short_raw vector at the reference class
  if (ref_class > 1) beta_short[:ref_class-1] = beta_short_raw[:ref_class-1];
  if (ref_class < Asusc) beta_short[ref_class+1:] = beta_short_raw[ref_class:];
  
  beta = beta_short[susc_classes]; // full vector of age-dependent susc
  
  /* initial conditions */
  for (a in 1 : A) {
    y0[a] = 1.0 - inoculum; // Susceptible
    for (j in 1 : F) {
      y0[j * A + a] = 0.5 / F * inoculum; // Exposed 
    }
    for (j in 1 : J) {
      y0[(F + j) * A + a] = 0.5 / J * inoculum; // Infected
    }
  }
  
  /* integrate ODEs and take result */
  if ( adjoint == 0 ) {
    y_hat = ode_adams_tol(corona_model, y0, t0, ts, rel_tol,
                          abs_tol, max_num_steps, epsilon, alpha, gamma, zeta,
                          k0, x0, k1, x1, k2, x2, k3, x3, k4, x4, u1, u2, u3,
                          u4, beta_short, nu_short, Cunp, Cdis, Csch,
                          susc_classes, hosp_classes, A, J, F);
  } else { // adjoint == 1
      int n = (1 + F + J) * A; // dim of system
      y_hat = ode_adjoint_tol_ctl(corona_model, y0, t0, ts,
                          rel_tol/9.0,                // forward tolerance
                          rep_vector(abs_tol/9.0, n), // forward tolerance
                          rel_tol/3.0,                // backward tolerance
                          rep_vector(abs_tol/3.0, n), // backward tolerance
                          rel_tol,                    // quadrature tolerance
                          abs_tol,                    // quadrature tolerance
                          max_num_steps,
                          150,                       // number of steps between checkpoints
                          1,                         // interpolation polynomial: 1=Hermite, 2=polynomial
                          1,                         // solver for forward phase: 1=Adams, 2=BDF
                          1,                         // solver for backward phase: 1=Adams, 2=BDF
                          epsilon, alpha, gamma, zeta, // params
                          k0, x0, k1, x1, k2, x2, k3, x3, k4, x4, u1, u2, u3,
                          u4, beta_short, nu_short, Cunp, Cdis, Csch,
                          susc_classes, hosp_classes, A, J, F);
  }
  
  /* extract trajectories */
  for (i in 1 : numdayshosp) {
    Susceptible[i,  : ] = y_hat[i][1 : A]';
    for (j in 1 : F) {
      Exposed[i,  : ] += y_hat[i][j * A + 1 : (j + 1) * A]';
    }
    for (j in 1 : J) {
      Infected[i,  : ] += y_hat[i][(F + j) * A + 1 : (F + j + 1) * A]';
    }
  }
  
  /* probability of hospitalisation for rate-based reporting model */
  p_short = nu_short ./ (nu_short + gamma);
  
  /* likelihood contributions */
  for (i in 1 : numdayshosp) {
    for (a in 1 : A) {
      /* prevalence-based reporting */
      real x = nu[a] * Infected[i, a] * demography[a];
      log_likes_hosp[i, a] = neg_binomial_2_lpmf(hospitalisations[i, a] | x, r);
    }
  }
  
  /* likelihood of sero data */
  for (i in 1 : numdayssero) {
    int idx = tidx_sero[i];
    // compute weighted sum of age classes
    array[Asero] real pred_frac_sero = rep_array(0.0, Asero);
    for (a in 1 : A) {
      pred_frac_sero[sero_classes[a]] += (1 - Susceptible[idx, a])
                                         * demography_sero_frac[a];
    }
    // now use the fraction sero positives to compute the likelihood of the sero data
    for (a in 1 : Asero) {
      log_likes_sero[i, a] = binomial_lpmf(sero_num_pos[i, a] | sero_num_sampled[i, a], pred_frac_sero[a]);
    }
  }
}
model {
  /* prior distributions */
  alpha ~ inv_gamma(a_alpha, b_alpha); // 1/latent period; 95% prior coverage 2.2-4.4 days
  gamma ~ inv_gamma(a_gamma, b_gamma); // 1/infectious period; 95% prior coverage 4.2-15 days
  
  nu_short ~ normal(0, 5);
  // manual jacobian correction: log|dnu_short/dnu_simplex| = Ahosp * nu_scale
  target += Ahosp * nu_scale;
  
  for (a in 1 : Asusc) {
    beta_short[a] ~ lognormal(log(beta_short_hyp[a]), log_beta_sd); // the log-OR has a normal distribution
  }
  
  r ~ lognormal(5, 2);
  
  zeta ~ normal(m_zeta, s_zeta); // a priori expect no additional reduction, max 2se=0.5 at most
  
  k0 ~ exponential(1); // k of logistic transition from pre-lockdown to lockdown
  k1 ~ exponential(1);
  k2 ~ exponential(1);
  k3 ~ exponential(1);
  k4 ~ exponential(1);
  
  x0 ~ normal(m_tld, 7); // x0 of logistic transition from pre-lockdown to lockdown
  x1_alpha ~ normal(m_tlx, 7);
  x2 ~ normal(m_tls, 7);
  x3 ~ normal(254, 7);
  x4 ~ normal(304, 7);
  
  u1 ~ uniform(0, 1); // redundant
  u2 ~ uniform(0, 1); // redundant
  u3 ~ uniform(0, 1); // redundant
  u4 ~ uniform(0, 1); // redundant
  
  /* likelihood of the data */
  target += watanabe_beta * sum(log_likes_hosp);
  target += watanabe_beta * sum(log_likes_sero);
}

generated quantities {
  real log_lik = sum(log_likes_hosp) + sum(log_likes_sero); // estimates WBIC when mode = 1
  array[numobs_all] real log_lik_vec = append_array(to_array_1d(log_likes_hosp),
                                                      to_array_1d(log_likes_sero));
  array[numdayshosp, A] real expected_hospitalisations; // for credible intervals
  array[numdayshosp, A] int simulated_hospitalisations; // for prediction intervals of hospitalisations
  array[numdayssero, Asero] real expected_serodata; // for credible intervals of serological data
  array[numdayssero, Asero] int simulated_serodata; // for prediction intervals of serological data
  
  /* sample from priors to compare marginal posteriors with priors on parameters */
  real prior_sample_gamma = inv_gamma_rng(a_gamma, b_gamma); // samples from the prior of gamma
  real prior_sample_alpha = inv_gamma_rng(a_alpha, b_alpha); // samples from the prior of alpha
  real prior_sample_zeta = normal_rng(m_zeta, s_zeta); // samples from the prior of zeta
  
  /* hospitalisations */
  for (i in 1 : numdayshosp) {
    for (a in 1 : A) {
      real x = nu[a] * Infected[i, a] * demography[a];
      expected_hospitalisations[i, a] = x;
      simulated_hospitalisations[i, a] = neg_binomial_2_rng(x, r);
    }
  }
  
  /* serological data */
  for (i in 1 : numdayssero) {
    int idx = tidx_sero[i];
    // compute weighted sum of age classes
    array[Asero] real pred_frac_sero = rep_array(0.0, Asero);
    for (a in 1 : A) {
      pred_frac_sero[sero_classes[a]] += (1 - Susceptible[idx, a])
                                         * demography_sero_frac[a];
    }
    for (a in 1 : Asero) {
      int num_sam = sero_num_sampled[i, a];
      real prob_pos = pred_frac_sero[a];
      expected_serodata[i, a] = num_sam * prob_pos;
      simulated_serodata[i, a] = binomial_rng(num_sam, prob_pos);
    }
  }
}


