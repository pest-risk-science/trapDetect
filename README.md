
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
#>  [1] 0.01409442 0.02040546 0.03504505 0.12153617 0.13691538 0.21566249
#>  [7] 0.29597412 0.39508280 0.40455839 0.40636942 0.41236493
#> 
#> $probs
#>             [,1]        [,2]        [,3]       [,4]       [,5]       [,6]
#> [1,] 0.022180006 0.032962254 0.061367174 0.23228342 0.26212888 0.41752521
#> [2,] 0.006008825 0.007848657 0.008722923 0.01078891 0.01170188 0.01379976
#>            [,7]       [,8]       [,9]      [,10]      [,11]
#> [1,] 0.57714372 0.77499068 0.79336528 0.79680347 0.80868631
#> [2,] 0.01480451 0.01517491 0.01575151 0.01593537 0.01604355
```

## Contact

For all inquires regarding the `trapDetect` R package, please contact:
Dan Gladish (<Dan.Gladish@data61.csiro.au>).
