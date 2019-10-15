Case Study Version 2
================
McKenna Weech
10/8/2019

This case study is largely baised off of a case study made for
StanCon2019 which can be found here
<https://github.com/lauken13/Beginners_Bayes_Workshop>

# Stan Beginners Guide

This guide will introduce first time Stan users to Stan inlcuding what
it does, how it works, what it looks like, and how to begin using it.

-----

#### What is Stan and why do we need it?

Stan is a programming languge that helps us to run larger and more
complex beysian models. Without Stan it would be impossible to run many
of the models that we would like to use.

#### What does Stan do?

Stan works by running complex calculations in the background of our
code. First you complie a stan model, then you send data to stan and it
will run the model and then stan will send back any important
information.

#### What does Stan code look like?

There are three required blocks in Stan code:

`Data`

`Parameter`

`Model`

The **Data** block is used to declare the data that we will use in the
model.

The **Parameter** block is used to specify the parameters.

The **Model** block is used to define the model including the likelihood
and the priors.

#### How do you start using Stan?

Stan runs in the backgroud of r, so you will be working with both an r
markdown or r scrip file as well as a stan file. Start with the r file
where you have your data. You will then have to open an r stan file
which is another file type option in r studio.

When you first open a Stan file it should look like this:

``` {
//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] y;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  y ~ normal(mu, sigma);
}
```

Here you can see the three required stan blocks along with some preset
basic model options and some comments and information about stan.

Now we will look at each block one at a time.

### Data Block

``` {
data {
  int<lower=0> N;
  vector[N] y;
}
```

First, you can see that a block is denoted with { } brackets and that
after everyline of code there is a ; semi-colon. These are necessary for
the code to run.

As we said before, the data block is where you declare your data. Your
actual data will be in your r file but this tells stan what to look for.
For every element, you have to declare what type of data it is. You will
see this in other parts of Stan as well like in the parameters block.

There are two types of data you can declare `int` or `real`.

**int** = count data

**real** = continuious data

Another thing you will notice is `N`. Stan requires you to declare how
my observaions you have as a variable N.

Next you need to declare any variables in your model and their type.
Because each variable catergory has an individual variable for each
observation, every variable is declared as a vector of that variable
with N number of observations in that vector.

`<lower=1>` is just a saftey measure that we can use to make sure that
the data we insert is in the right form. For example, if you were to
specify `<lower=1>` Stan would stop and give a warning message if you
try to pass it any data with N less than 1, but this is not nessecary
and is just a saftey check if you need it.

### Parameter Block

    parameters {
      real mu;
      real<lower=0> sigma;
    }

The parameters block is similar to the data block but here you will
declare your parameters. Just like in the data block you will have to
declare what type of data they are. You can see that here they suggest
using the saftey check `<lower=0>` on sigma becasue you can’t have a
negative sigma.

### Model Block

    model {
      y ~ normal(mu, sigma);
    }

The model block is where you will specify your model and your priors.
This is just an example of a basic regression model.

-----

# Stan Case Study

``` r
# Load libraries. 

library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   0.8.3     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(rstan)
```

    ## Loading required package: StanHeaders

    ## rstan (Version 2.19.2, GitRev: 2e1f913d3ca3)

    ## For execution on a local, multicore CPU with excess RAM we recommend calling
    ## options(mc.cores = parallel::detectCores()).
    ## To avoid recompilation of unchanged Stan programs, we recommend calling
    ## rstan_options(auto_write = TRUE)

    ## 
    ## Attaching package: 'rstan'

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
library(bayesplot)
```

    ## This is bayesplot version 1.7.0

    ## - Online documentation and vignettes at mc-stan.org/bayesplot

    ## - bayesplot theme set to bayesplot::theme_default()

    ##    * Does _not_ affect other ggplot2 plots

    ##    * See ?bayesplot_theme_set for details on theme setting

``` r
# Import data. 

store_data <- read_csv('data/store_data.csv')
```

    ## Parsed with column specification:
    ## cols(
    ##   store_id = col_double(),
    ##   date = col_date(format = ""),
    ##   employees = col_double(),
    ##   floors = col_double(),
    ##   sq_footage_p_floor = col_double(),
    ##   general_manager = col_double(),
    ##   monthly_average_revenue = col_double(),
    ##   average_customer_age = col_double(),
    ##   age_of_store = col_double(),
    ##   total_sq_foot = col_double(),
    ##   month = col_double(),
    ##   complaints = col_double(),
    ##   log_sq_foot_1e4 = col_double()
    ## )

``` r
store <- as.tibble(store_data)
```

    ## Warning: `as.tibble()` is deprecated, use `as_tibble()` (but mind the new semantics).
    ## This warning is displayed once per session.

``` r
store
```

    ## # A tibble: 120 x 13
    ##    store_id date       employees floors sq_footage_p_fl… general_manager
    ##       <dbl> <date>         <dbl>  <dbl>            <dbl>           <dbl>
    ##  1       37 2017-01-15         8      8            5149.               0
    ##  2       37 2017-02-14         8      8            5149.               0
    ##  3       37 2017-03-16         9      8            5149.               0
    ##  4       37 2017-04-15        10      8            5149.               0
    ##  5       37 2017-05-15        11      8            5149.               0
    ##  6       37 2017-06-14        11      8            5149.               0
    ##  7       37 2017-07-14        10      8            5149.               0
    ##  8       37 2017-08-13        10      8            5149.               0
    ##  9       37 2017-09-12         9      8            5149.               0
    ## 10       37 2017-10-12         9      8            5149.               0
    ## # … with 110 more rows, and 7 more variables:
    ## #   monthly_average_revenue <dbl>, average_customer_age <dbl>,
    ## #   age_of_store <dbl>, total_sq_foot <dbl>, month <dbl>,
    ## #   complaints <dbl>, log_sq_foot_1e4 <dbl>

### Background

Imagine that you are a consultant working at a firm in Salt Lake City. A
large retail chain baised in SLC approches you to hire you for a job.
The manager explains to you that they are worried about the number of
complaints they receive from upset customers who feel like they did not
receive enough employees assistance at one of their stores. Their curent
policy is to staff two employees at every store at all times. While this
is the current company policy, the manager believes that two attendents
could be too many for some of their locations and not enough for others
and is an inefficient allocatiton of company resouces.

One alternative to this policy is to vary the number of employees from
store to store depending on the demand of the customers.

### The Goal

The manager wishes to employ your services to help them to find the
optimal number of employees they should place in each of their stores in
order to minimize the number of complaints while also keeping
expenditure on employess affordable.

## Building a Model

Because you are all pros in bayesian statistics you begin by thinking
about you want to model this type of data. A poisson distribution
doesn’t allow for any negative amount of complaints which would make
sense because people can’t call a negative amount of times.

  
![
\\begin{align\*}
\\textrm{complaints}\_{b,t} & \\sim \\textrm{Poisson}(\\lambda\_{b,t})
\\\\
\\lambda\_{b,t} & = \\exp{(\\eta\_{b,t})} \\\\
\\eta\_{b,t} &= \\alpha + \\beta \\, \\textrm{employees}\_{b,t}
\\end{align\*}
](https://latex.codecogs.com/png.latex?%0A%5Cbegin%7Balign%2A%7D%0A%5Ctextrm%7Bcomplaints%7D_%7Bb%2Ct%7D%20%26%20%5Csim%20%5Ctextrm%7BPoisson%7D%28%5Clambda_%7Bb%2Ct%7D%29%20%5C%5C%0A%5Clambda_%7Bb%2Ct%7D%20%26%20%3D%20%5Cexp%7B%28%5Ceta_%7Bb%2Ct%7D%29%7D%20%5C%5C%0A%5Ceta_%7Bb%2Ct%7D%20%26%3D%20%5Calpha%20%2B%20%5Cbeta%20%5C%2C%20%5Ctextrm%7Bemployees%7D_%7Bb%2Ct%7D%0A%5Cend%7Balign%2A%7D%0A
"
\\begin{align*}
\\textrm{complaints}_{b,t} & \\sim \\textrm{Poisson}(\\lambda_{b,t}) \\\\
\\lambda_{b,t} & = \\exp{(\\eta_{b,t})} \\\\
\\eta_{b,t} &= \\alpha + \\beta \\, \\textrm{employees}_{b,t}
\\end{align*}
")  

### Prior Predictive Check

Now we want to run a prior predictive check to see what the priors we
have choosen are saying is possible.

``` r
# using normal distributions for priors on alpha and beta 
prior_predictive <- function(employees, alpha_mean, alpha_sd, beta_mean, beta_sd) {
  N <- length(employees)
  alpha <- rnorm(1, mean = alpha_mean, sd = alpha_sd);
  beta <- rnorm(1, mean = beta_mean, sd = beta_sd);
  complaints <- rpois(N, lambda = exp(alpha + beta * employees))
  return(complaints)
}
```

``` r
# you can run this chunk multiple times to keep generating different datasets
prior_predictive(
  store$employees,
  alpha_mean = 0,
  alpha_sd = 10,
  beta_mean = 0,
  beta_sd = 10
)
```

    ## Warning in rpois(N, lambda = exp(alpha + beta * employees)): NAs produced

    ##   [1]         NA         NA         NA         NA         NA         NA
    ##   [7]         NA         NA         NA         NA         NA         NA
    ##  [13]         NA         NA         NA         NA         NA         NA
    ##  [19]         NA         NA         NA         NA         NA         NA
    ##  [25]         NA         NA         NA         NA         NA         NA
    ##  [31]         NA         NA         NA         NA         NA         NA
    ##  [37]         NA         NA         NA         NA         NA         NA
    ##  [43]         NA         NA         NA         NA         NA         NA
    ##  [49]         NA         NA         NA         NA         NA         NA
    ##  [55]         NA         NA         NA         NA         NA         NA
    ##  [61]         NA         NA         NA         NA         NA         NA
    ##  [67]         NA         NA         NA         NA         NA         NA
    ##  [73]         NA         NA         NA         NA         NA         NA
    ##  [79]         NA         NA         NA         NA         NA         NA
    ##  [85]         NA         NA         NA         NA         NA         NA
    ##  [91]         NA         NA         NA         NA         NA         NA
    ##  [97]         NA         NA         NA         NA         NA         NA
    ## [103]         NA         NA         NA         NA         NA         NA
    ## [109]         NA         NA         NA         NA         NA         NA
    ## [115]         NA         NA         NA         NA         NA 2140552858

### Exploratory Data Analysis (Modeling) (STAN\!)

Now we get to really run the stan code. Try following the steps listed
in the beginning to write stan code. You can also look at my Stan file
titled version\_2\_stan in the stan\_programs folder.

Once we have writen the Stan we need to compile the model.

``` r
comp_model <- stan_model('stan_programs/version_2_stan.stan')
```

The Stan model is now compiled so we need to prepare the data to be
passed to the model. We have already uploaded our data into R but Stan
requires that it is in a specific format.

We input data into stan in a list format. The things in your list need
to match the data you declared in Stan.

``` r
standata_simple <- list(
  N = nrow(store), 
  complaints = store$complaints,
  employees = store$employees
)
str(standata_simple)
```

### Smapling

Here we are going to bring our complied stan model and our data together
and start to look at what we’ve got.

``` r
fit_simple <- sampling(comp_model, data = standata_simple,
                       # these are the defaults but specifying them anyway
                       # so you can see how to use them: 
                       # posterior sample size = chains * (iter-warmup)
                       chains = 4, iter = 2000, warmup = 1000)
```

``` r
print(fit_simple, pars = c('alpha','beta'))
```

``` r
# https://mc-stan.org/bayesplot/reference/MCMC-distributions
#draws <- as.matrix(fit_simple, pars = c('alpha','beta'))
#draws_tibble <- as.tibble(draws)
# ggplot(draws_tibble, aes(alpha)) +    # Marginal posteriors of alpha.
#   geom_histogram()
#
# ggplot(draws_tibble, aes(beta)) +     # Marginal posteriors of beta.
#   geom_histogram()
#
# ggplot(draws_tibble, aes(x = alpha, y = beta)) +  # Posterior of (alpha,beta).
#   geom_jitter()

draws <- as.matrix(fit_simple, pars = c('alpha','beta'))
head(draws)
mcmc_hist(draws) # marginal posteriors of alpha and beta
mcmc_scatter(draws, alpha = 0.2, size = 1) # posterior of (alpha,beta)
```

``` r
alpha_prior_post <- cbind(alpha_prior = rnorm(4000, log(7), 1), 
                          alpha_posterior = draws[, "alpha"])
mcmc_hist(alpha_prior_post, facet_args = list(nrow = 2), binwidth = 0.1) + 
  xlim(range(alpha_prior_post))


beta_prior_post <- cbind(beta_prior = rnorm(4000, -0.25, 0.5), 
                         beta_posterior = draws[, "beta"])
mcmc_hist(beta_prior_post, facet_args = list(nrow = 2), binwidth = 0.05) + 
  xlim(range(beta_prior_post))
```

### Posterior Predictive Check

``` r
fit_summary <- summary(fit_simple)
print(names(fit_summary))

print(fit_summary$summary)
```

``` r
alpha_beta_summary <- summary(fit_simple, pars = c("alpha", "beta"), probs = c(0.1, 0.9))$summary
print(alpha_beta_summary)
```

### Model comparison

If we were really creating a model we would want to iterate through this
a few times and then compare our models using one of the method that we
have talked about in class.

### Decision Analysis
