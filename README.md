
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
#>  [1] 0.002926277 0.003769782 0.005147319 0.005538568 0.005798644 0.006002994
#>  [7] 0.006288245 0.006570003 0.006991934 0.007791871 0.008355333
#> 
#> $probs
#>             [,1]        [,2]        [,3]        [,4]        [,5]        [,6]
#> [1,] 0.003126708 0.003726724 0.005827882 0.006221361 0.006345291 0.006575967
#> [2,] 0.002725847 0.003812839 0.004466755 0.004855776 0.005251998 0.005430020
#>             [,7]        [,8]        [,9]       [,10]       [,11]
#> [1,] 0.007041844 0.007254207 0.007885233 0.008941978 0.009518606
#> [2,] 0.005534646 0.005885799 0.006098636 0.006641765 0.007192059
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
