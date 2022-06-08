
<!-- README.md is generated from README.Rmd. Please edit that file -->

# trapDetect

<!-- badges: start -->

[![R-CMD-check.yaml](https://github.com/dangladish/trapDetect/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dangladish/trapDetect/actions)
<!-- badges: end -->

The goal of trapDetect is to provide the functionality to simulate the
spread of individuals over a given area (such as an orchard or block),
and provide the tools to determine the probability of detecting a pest
using various detection functions.

## Installation

You can install trapDetect from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dangladish/trapDetect")
```

Please note that trapDetect is in early development and likely will
change significantly.

## The main function: calc\_escape\_prob()

The main function is `calc_escape_prob()` which simulates the spread of
a population of individuals using the `sim_spread()` function if not
provided, and then determines the probability of detecting an individual
for a given trap configuration using `p_detect_one()`. There are a
number of optional arguments in `calc_escape_prob()` which the user can
set for their own purposes. A basic example can be run using the
following code:

``` r
library(trapDetect)
calc_escape_prob()
#> [1] "Warning: generating survey and raster..."
#> [1] "No initial data detected, generating random simulations"
#> $mean_prob
#>  [1] 0.001980833 0.007407997 0.012929112 0.016822192 0.026363889 0.066494047
#>  [7] 0.140832344 0.191965537 0.303142293 0.355364417 0.366404143
```
