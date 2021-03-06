data {
  int<lower=0> N;
  int<lower=0> N_edges;
  int<lower=1, upper=N> node1[N_edges];  // node1[i] adjacent to node2[i]
  int<lower=1, upper=N> node2[N_edges];  // and node1[i] < node2[i]

  int<lower=0> y[N];              // count outcomes
  vector[N] x;                    // predictor
}
parameters {
  real beta0;                // intercept
  real beta1;                // slope

  real<lower=0> tau_phi;     // precision of spatial effects
  vector[N - 1] phi_std_raw; // raw, standardized spatial effects
}
transformed parameters {
  real<lower=0> sigma_phi = inv(sqrt(tau_phi));      // convert precision to sigma
  vector[N] phi;
  phi[1:(N - 1)] = phi_std_raw;
  phi[N] = -sum(phi_std_raw);
}
model {
  y ~ poisson_log(beta0 + beta1 * x + phi * sigma_phi);

  target += -0.5 * dot_self(phi[node1] - phi[node2]);

  beta0 ~ normal(0, 10);
  beta1 ~ normal(0, 5);
  tau_phi ~ gamma(1, 1);
}
generated quantities {
  vector[N] mu = exp(beta0 + beta1 * x + phi * sigma_phi);
}
