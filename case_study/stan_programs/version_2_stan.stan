
// The input data is a vector 'y' of length 'N'.
data {
  int<lower=1> N;
  int<lower=0> complaints[N];
  vector<lower=0>[N] employees;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real alpha;
  real beta;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
   complaints ~ poisson_log(alpha + beta * employees);
  
  // weakly informative priors:
  // we expect negative slope on traps and a positive intercept,
  // but we will allow ourselves to be wrong
  beta ~ normal(-0.25, 0.5);
  alpha ~ normal(log(7), 1);
}

