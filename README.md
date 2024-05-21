
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

Please note that trapDetect is in early development and likely will
change significantly.

## The main function: calc_escape_prob()

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
#>  [1] 0.005717749 0.011657990 0.014240821 0.019920444 0.042614483 0.057565287
#>  [7] 0.060593001 0.065987531 0.067438542 0.067927372 0.068921897
#> 
#> $probs
#>             [,1]       [,2]       [,3]       [,4]       [,5]       [,6]
#> [1,] 0.009603779 0.01100987 0.01159542 0.01438694 0.01581731 0.01727015
#> [2,] 0.001831718 0.01230611 0.01688623 0.02545395 0.06941166 0.09786043
#>            [,7]       [,8]       [,9]      [,10]      [,11]
#> [1,] 0.01827983 0.02049427 0.02099458 0.02160694 0.02187893
#> [2,] 0.10290617 0.11148080 0.11388251 0.11424780 0.11596486
```

## Contact

For all inquires regarding the `trapDetect` R package, please contact:
Dan Gladish (<Dan.Gladish@data61.csiro.au>).
