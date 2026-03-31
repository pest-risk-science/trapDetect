
#' Generating Offspring
#'
#' @description
#' Takes a given given data frame with locations of a population of individuals
#' and generates offspring based on a random walk.
#'
#' @details
#' The function `gen_offspring` is used to generate offspring from individuals
#' (e.g. pests) in a population using a Poisson distribution, based on user
#' specified mean of the offspring per individual, and then using a random walk
#' process, generates the new locations of the offspring.  In general, this
#' function is called from the `sim_spread()` function.
#'
#' @param dat data frame of population that will generate offspring containing
#'   the initial locations of the individual ("x", "y"), the survival ("Fate"),
#'   age ("Age"), and density ("dens") of a given cell.
#' @param step_size_os step size for dispersal distances of offspring.
#' @param offspr_mu parameter indicating the mean number of offspring generated
#'   per individual per time step using a Poisson distribution.
#' @param K number for the carrying capacity of cells in the raster.
#' @param sigma variance of random walk if specified. Default `NULL`
#' @param theta angle of random walk if specified.  Default `NULL`
#' @param random_length logical. If `TRUE`, random walk allows random length up
#'   to `step_size_os`. Default `FALSE`.
#' @param sdm a SpatRaster (terra) of an sdm with cells between 0 and 1.
#'   Default is `NULL`.
#' @param sdm_vec optional pre-extracted numeric vector of SDM cell values
#'   passed through to `rand_walk()` for fast boundary checks.
#' @param ... additional arguments to be passed to other functions.
#'
#' @return
#' A data frame with columns indicating the location (x, y), survival (Fate),
#' and age (Age) of the generated offspring.
#'
#' @importFrom stats rpois
#' @export
gen_offspring <- function(dat = NULL,
                          step_size_os = 5,
                          offspr_mu = 2,
                          K = 10,
                          sigma = NULL,
                          theta = NULL,
                          random_length = FALSE,
                          sdm = NULL,
                          sdm_vec = NULL, ...) {

  if (nrow(dat) > 0) {

    # Calculate effective per capita reproduction rate assuming logistic growth
    eff_mu <- offspr_mu * (1 - dat$dens / K)
    eff_mu[eff_mu < 0] <- 0

    # Generate offspring counts per individual
    new_offspring <- rpois(nrow(dat), eff_mu)

    # All possible recruits (locations of parents)
    recruits <- cbind(dat[, c("x", "y")],
                      Fate = rep(1, nrow(dat)),
                      Age  = rep(0, nrow(dat)))

    # Duplicate appropriate number of times
    recruits <- recruits[rep(seq_len(nrow(recruits)), new_offspring), ]

    # Disperse recruits by vectorized random walk
    if (nrow(recruits) > 0) {
      new_locs <- rand_walk(x = recruits$x,
                            y = recruits$y,
                            step_size = step_size_os,
                            sigma = sigma,
                            theta = theta,
                            random_length = random_length,
                            sdm = sdm,
                            sdm_vec = sdm_vec)
      recruits$x <- new_locs[, 1]
      recruits$y <- new_locs[, 2]
    }
  }
  row.names(recruits) <- NULL
  return(recruits)
}
