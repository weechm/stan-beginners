data {
  int<lower=1> N;
  int<lower=0> complaints[N];
  vector<lower=0>[N] employees;
}
parameters {
  real alpha;
  real beta;
}
model {
  // poisson_log(x) is more efficient and stable alternative to poisson(exp(x))
  // complaints ~ poisson(exp(alpha + beta * traps));
  complaints ~ poisson_log(alpha + beta * employees);
  
  // weakly informative priors:
  // we expect negative slope on traps and a positive intercept,
  // but we will allow ourselves to be wrong
  alpha ~ normal(log(7), 1);
  beta ~ normal(-0.25, 0.5);
} 

