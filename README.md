
<!-- README.md is generated from README.Rmd. Please edit that file -->

# trapDetect

<!-- badges: start -->
<!-- badges: end -->

The goal of trapDetect is to provide the functionality to simulate the
spread of individuals over a given area (such as an orchard or block),
and provide the tools to determine the probabilty of detecting a pest
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
set for their own purposes. A basic exmaple can be run using the
following code:

``` r
library(trapDetect)
calc_escape_prob()
#> [1] "Warning: generating survey and raster..."
#> [1] "No initial data detected, generating random simulations"
#>  [1] 0.001475055 0.004152568 0.007893457 0.019125796 0.024517261 0.026710217
#>  [7] 0.029412552 0.045169336 0.049119065 0.049925328 0.050334557
```
