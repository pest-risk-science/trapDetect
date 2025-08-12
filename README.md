
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
devtools::install_github("dangladish/trapDetect")
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
#>  [1] 0.07278318 0.18362913 0.31703724 0.34558781 0.50491126 0.56712234
#>  [7] 0.80924829 0.81776350 0.83138949 0.83506552 0.83606037
#> 
#> $probs
#>            [,1]       [,2]       [,3]      [,4]      [,5]      [,6]      [,7]
#> [1,] 0.12820562 0.30565717 0.56540698 0.5882247 0.6976356 0.7087125 0.7101887
#> [2,] 0.01736075 0.06160109 0.06866751 0.1029509 0.3121869 0.4255322 0.9083079
#>           [,8]      [,9]    [,10]     [,11]
#> [1,] 0.7105663 0.7113231 0.716181 0.7173269
#> [2,] 0.9249607 0.9514559 0.953950 0.9547938
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
