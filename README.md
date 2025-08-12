
<!-- README.md is generated from README.Rmd. Please edit that file -->

# trapDetect

<!-- badges: start -->

[![R-CMD-check](https://github.com/dangladish/trapDetect/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dangladish/trapDetect/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of trapDetect is to provide the functionality to simulate the
spread of individuals over a given area (such as an orchard or block),
and provide the tools to determine the probability of detecting a pest
using various detection functions.

## Installation

You can install trapDetect from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("pest-risk-science/trapDetect")
```

Please note that `trapDetect` is in development.

## The main function: `calc_escape_prob()`

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
#>  [1] 0.001932758 0.004664519 0.006353742 0.008456654 0.021667613 0.084583072
#>  [7] 0.191896071 0.203347758 0.207298822 0.208489238 0.209082170
#> 
#> $probs
#>             [,1]        [,2]        [,3]        [,4]       [,5]       [,6]
#> [1,] 0.001098439 0.001298568 0.002178413 0.005765786 0.03155261 0.15690633
#> [2,] 0.002767077 0.008030471 0.010529072 0.011147522 0.01178262 0.01225981
#>            [,7]       [,8]       [,9]      [,10]      [,11]
#> [1,] 0.37139647 0.39397773 0.40177719 0.40383641 0.40459982
#> [2,] 0.01239567 0.01271779 0.01282045 0.01314207 0.01356452
```

## Simulate Capture: `sim_capture()`

The `sim_capture()` focuses on trap catch counts rather than probability
of capture. This function acts in a similar manner as `sim_spread()` but
needs information about detection devices. This can be in the form of
trap locations or number of traps in the space. If number of traps is
specified, traps are arranged in a grid covering the block as much as
possible. It is recommended to run `sim_capture()` multiple times for
uncertainty estimates.

## Contact

For all inquires regarding the `trapDetect` R package, please contact:
Dan Gladish (<Dan.Gladish@data61.csiro.au>).
