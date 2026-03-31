
#' Simulation of Spread
#'
#' @description
#' This function simulates the spread in an sdm.
#'
#' @details
#' A function that will simulate the spread of a data frame over a given sdm
#'
#' @param init_dat data frame object containing columns named x, y, Fate, and
#'   Age of the initial locations of the population to simulate a spread. If
#'   `NULL` (default), then initial data frame is determined by `N_seed` and
#'   `bbox` parameters.
#' @param N_seed integer of number of individuals to spread if `init_dat` is `NULL`
#' @param rand.walk logical; if `TRUE`, then individuals spread via a random walk
#'   process.
#' @param step_size_os step size for dispersal distances of offspring.
#' @param step_size_ad step size for dispersal distances of adults.
#' @param Time the number of time steps for the simulation.
#' @param K number for the carrying capacity of cells in the raster.
#' @param age_mu parameter to randomly assign initial ages.
#' @param offspr_mu parameter passed to `gen_offpring()` indicating the mean
#'   number of offspring generated per individual per time step using a Poisson
#'   distribution.
#' @param bbox a vector of length 4 of the extent if `sdm` is not given.
#' @param cell_res resolution of the raster if `sdm` not given.
#' @param sdm a SpatRaster (terra) of an sdm with cells between 0 and 1.
#'   Default is `NULL`.
#' @param sdm_og value of sdm off the grid.  If zero, then individuals die off
#'   grid.
#' @param p_alpha alpha parameter for Beta distribution for survival probability
#'   (currently not implemented).
#' @param p_beta beta parameter for Beta distribution for survival probability
#'   (currently not implemented).
#' @param allow_leave logical indicating if individuals can leave the grid.
#' @param crw logical indicating a correlated random walk.
#' @param sigma variance of random walk if specified. Default `NULL`
#' @param theta angle of random walk if specified.  Default `NULL`
#' @param random_length logical. If `TRUE`, random walk allows random length up
#'   to `step_size_os`. Default `FALSE`.
#' @param attractive_areas logical. Passed to `rand_walk()`. If `TRUE`, specify
#'   areas in sdm to be more attractive and prevent individuals leaving once they
#'   enter area as defined by raster values.
#' @param survive_prob logical. If `TRUE` allow for survival/mortality based on
#'   sdm values.
#' @param PLOT.IT logical. If `TRUE` plot an animation of the spread simulation.
#'   Not recommended for large or long simulations.
#' @param ... additional arguments to be passed to helper functions.
#'
#' @return
#' \item{`dat`}{A list of data frames, where each element of the list
#'              corresponds to a time step in the simulated spread.  Each data
#'              frame contains columns for the location of individuals (x, y),
#'              the survival (Fate), age at specified time step (Age), sdm
#'              value (sdm), and density (dens).}
#' \item{`sdm`}{A SpatRaster containing the sdm of the simulation.}
#'
#' @importFrom terra rast ext extract cellFromXY ncell
#' @importFrom animation ani.pause
#' @importFrom stats rbinom rpois runif
#' @export
sim_spread <- function(init_dat = NULL, N_seed = 2, rand.walk = FALSE,
                       step_size_os = 100, step_size_ad = 50, Time = 10, K = 1000,
                       age_mu = 1, offspr_mu = 1, bbox = c(0, 0, 1608, 1608),
                       cell_res = 10, sdm = NULL, sdm_og = 0, p_alpha = 1,
                       p_beta = 1, allow_leave = FALSE, crw = FALSE,
                       sigma = NULL, theta = NULL, random_length = FALSE,
                       attractive_areas = FALSE, survive_prob = FALSE,
                       PLOT.IT = TRUE, ...) {

  if (is.null(sdm)) {
    sdm <- terra::rast(xmin = bbox[1], xmax = bbox[3],
                       ymin = bbox[2], ymax = bbox[4],
                       resolution = c(cell_res, cell_res))
    terra::values(sdm) <- 1
  } else {
    sdm_ext <- terra::ext(sdm)
    bbox <- c(sdm_ext[1], sdm_ext[3], sdm_ext[2], sdm_ext[4])
  }

  # Initialize population if not supplied
  if (is.null(init_dat)) {
    dat <- data.frame(x    = runif(N_seed, bbox[1], bbox[3]),
                      y    = runif(N_seed, bbox[2], bbox[4]),
                      Fate = rep(1, N_seed),
                      Age  = rpois(N_seed, age_mu))
    row.names(dat) <- NULL
  } else {
    dat <- init_dat
  }

  if (PLOT.IT) {
    plot(sdm)
    with(dat, points(x, y, pch = 16,
                     xlim = c(bbox[1], bbox[3]),
                     ylim = c(bbox[2], bbox[4]),
                     col  = "red"))
  }

  # Extract sdm values at introduction locations
  dat$sdm <- terra::extract(sdm, as.matrix(dat[, c("x", "y")]))[, 1]
  dat$sdm[is.na(dat$sdm)] <- sdm_og

  # Fast density: count individuals per raster cell
  dat$dens <- .cell_density(dat[, c("x", "y")], sdm)

  if (survive_prob) {
    dat[, "Fate"] <- rbinom(nrow(dat), 1, dat$sdm)
    dat <- dat[dat$Fate == 1, ]
  }

  dat_all    <- list()
  dat_all[[1]] <- dat

  sigma0 <- if (crw) sigma else NULL
  theta0 <- if (crw) theta else NULL
  sdm0   <- if (allow_leave) NULL else sdm

  t <- 1
  while (t <= Time && nrow(dat) > 0) {

    offspring <- gen_offspring(dat, step_size_os, offspr_mu, K = K,
                               sigma = sigma0, theta = theta0,
                               random_length = random_length,
                               sdm = sdm0)
    if (nrow(offspring) > 0) {
      offspring$sdm  <- NA
      offspring$dens <- NA
      dat <- rbind(dat, offspring)
    }

    # Extract sdm values
    dat$sdm <- terra::extract(sdm, as.matrix(dat[, c("x", "y")]))[, 1]
    dat$sdm[is.na(dat$sdm)] <- 1

    # Fast density via cell index lookup
    dat$dens <- .cell_density(dat[, c("x", "y")], sdm)
    dat$dens[is.na(dat$dens)] <- 0

    if (survive_prob) {
      dat[, "Fate"] <- rbinom(nrow(dat), 1, dat$sdm)
      dat <- dat[dat$Fate == 1, ]
    }

    dat$Age <- dat$Age + 1

    if (rand.walk && nrow(dat) > 0) {
      new_locs <- rand_walk(x = dat$x, y = dat$y,
                            step_size = step_size_ad,
                            sigma = sigma0, theta = theta0,
                            random_length = random_length,
                            sdm = sdm0,
                            attractive_areas = attractive_areas)
      dat$x <- new_locs[, 1]
      dat$y <- new_locs[, 2]
    }

    row.names(dat) <- NULL

    if (PLOT.IT) {
      plot(sdm)
      with(dat, points(x, y, pch = 16,
                       xlim = c(bbox[1], bbox[3]),
                       ylim = c(bbox[2], bbox[4]),
                       col  = "blue"))
      ani.pause(0.1)
    }

    dat_all[[t + 1]] <- dat
    t <- t + 1
  }

  return(list(dat = dat_all, sdm = sdm))
}


# Internal helper: fast per-individual density via cell index counting.
# Replaces the slow rasterize() + extract() pair.
#' @keywords internal
.cell_density <- function(xy, sdm) {
  cells  <- terra::cellFromXY(sdm, as.matrix(xy))
  counts <- tabulate(cells, nbins = terra::ncell(sdm))
  counts[cells]
}
