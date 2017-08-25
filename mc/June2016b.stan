// Model modified on 24 June 2016 to tighten up the priors on gamma and beta hoping that it will run faster.

data {
	int N; 			// Number of measurements for all species in dataset
	int Nspp;		// Number of species (including "other")
	int Nplot;		// Number of plots in dataset
	int Nyear;		// Number of years in study
	
	int year[N];		// Year for each measurement
	int plot[N];		// Plot ID for each measurement
	int species[N];		// Species ID for each measurement (1-7 + 8 as unknown)
	real ba[N];			// Basal area (cm2 / 100) for each measurement
	real bainc[N];		// Basal area increment (cm2) for each measurement
	real gdd[N];		// Growing degree days for each measurement
	real precip[N];		// Yearly precipitation for each measurement
	
	vector[Nspp] areaxdist[N];	// Area by squared distance for each neighbor species
	
	real SLA[Nspp];			// SLA and SSD of all species
	real SSD[Nspp];
}

parameters {
	vector<lower=0>[Nplot] alpha[Nspp];					// Plot-level random effect	
	real<lower=0, upper=3> beta_size[Nspp];				// Coefficients of tree size (dbh) for each species
	real<lower=-1, upper=3> beta_temp[Nspp];			// Coefficients of temperature for each species *** lower bound of this parameter changed 07 June 2016
	real<lower=-1, upper=3> beta_prec[Nspp];			// Coefficients of precipitation for each species
	real<lower=-2, upper=2> gamma[2];					// Trait coefficients (gamma1 is SLA, gamma 2 is SSD)
	real<lower=0, upper=0.05> lambda;					// Single parameter on crowding index for the neutral model.
	
	real<lower=0> sigma_g[Nspp];						// Dispersion of growth rate
	real mu_alpha[Nspp];								// Hyperpriors on the plot-level random effect.
	real<lower=0> sigma_alpha[Nspp];

}

model {
	// Likelihood
	for (i in 1:N) {
		bainc[i] ~ normal((alpha[species[i]][plot[i]] * ba[i] ^ beta_size[species[i]] * gdd[i] ^ beta_temp[species[i]] * precip[i] ^ beta_prec[species[i]] * SLA[species[i]] ^ gamma[1] * SSD[species[i]] ^ gamma[2]) / (1 + sum(lambda * areaxdist[i])), sigma_g[species[i]]);
	}
	  
	// Priors
	beta_size ~ normal(1, 3); // Means of these distributions changed 07 June 2016
	beta_temp ~ normal(1, 3);
	beta_prec ~ normal(1, 3);
	lambda ~ normal(0, 0.02);
	gamma[1] ~ normal(0.08, 0.25);
	gamma[2] ~ normal(-0.16, 0.25);
	for (i in 1:Nspp) {
		alpha[i] ~ lognormal(mu_alpha[i], sigma_alpha[i]);
	}
	
	// Hyperpriors
	mu_alpha ~ normal(0, 3);
	// Did not specify priors for the sigmas since Gelman claims that uniform flat priors are better for them in Stan.
	// Betas are constrained to be > 0, following Kunstler et al. 2012 Ecology Letters.
	// Prior means for gamma priors are following results in Kunstler et al. 2015 Nature (Figure 2).
}

generated quantities {
	vector[N] log_lik; // Log-likelihood
	for (i in 1:N) {
		log_lik[i] <- normal_log(bainc[i], (alpha[species[i]][plot[i]] * ba[i] ^ beta_size[species[i]] * gdd[i] ^ beta_temp[species[i]] * precip[i] ^ beta_prec[species[i]] * SLA[species[i]] ^ gamma[1] * SSD[species[i]] ^ gamma[2]) / (1 + sum(lambda * areaxdist[i])), sigma_g[species[i]]);
	}
}