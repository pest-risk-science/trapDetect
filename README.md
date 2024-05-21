
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
#>  [1] 0.01062590 0.07916914 0.33672593 0.35273204 0.36670331 0.38948848
#>  [7] 0.41201920 0.50599636 0.58316270 0.65313028 0.66167424
#> 
#> $probs
#>              [,1]        [,2]        [,3]        [,4]       [,5]       [,6]
#> [1,] 0.0006887759 0.001340866 0.005473481 0.007041243 0.01612678 0.01991006
#> [2,] 0.0205630170 0.156997419 0.667978386 0.698422842 0.71727983 0.75906689
#>            [,7]      [,8]      [,9]     [,10]     [,11]
#> [1,] 0.04636318 0.2198791 0.3167590 0.4285579 0.4417856
#> [2,] 0.77767523 0.7921136 0.8495664 0.8777026 0.8815629
```

## Contact

For all inquires regarding the `trapDetect` R package, please contact:
Dan Gladish (<Dan.Gladish@data61.csiro.au>).
