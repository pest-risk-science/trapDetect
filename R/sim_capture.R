
#' Simulation of spread and capture of pests
#'
#' @description
#' This function simulates spread and captures of an outbreak.
#'
#' @details
#' Takes in an sdm, initial data, and potential survey locations.  If no sdm,
#' data, or survey locations are specified, generates a grid of monitoring
#' devices in a square uniform block.  User must specify the number of traps
#' if no survey locations given. It is recommended to run this function multiple
#' times.
#'
#' @inherit sim_spread
#' @inherit calc_escape_prob
#' @param surv_loc a data frame containing the locations of the traps. Default
#'   `NULL`.
#' @param ntraps Must be specified if `surv_loc` is `NULL`, the number of traps
#'   to be generated in a grid.
#' @param prop_inside If `surv_loc` is `NULL`, specifies the distance from the
#'   border of the raster the grid starts, as a proportion of the length of
#'   the edge of the bounding box.
#' @return
#' \item{dat}{A list of data frames, where each element of the list
#'              corresponds to a time step in the simulated spread.  Each data
#'              frame contains columns for the location of individuals (x, y),
#'              the survival (Fate), age at specified time step (Age), sdm
#'              value (sdm), and density (dens).}
#' \item{sdm}{A SpatRaster containing the sdm of the simulation.}
#' \item{surv_loc}{A data frame containing the locations of the traps.}
#' \item{captured}{A vector of length Time+1 of the number of captured pests
#'                   during that time step. First element is time point 0 and
#'                   always 0.}
#' \item{total_captured}{A vector of length Time+1 of the cumulative total
#'                   caught pests up to that point.First element is time point 0
#'                   and always 0.}
#'
#' @importFrom terra rast ext extract cellFromXY ncell values
#' @importFrom fields rdist
#' @importFrom stats rbinom rpois runif
#' @export

sim_capture <- function(init_dat = NULL, N_seed = 2, rand.walk = TRUE,
                        surv_loc = NULL, ntraps = NULL, prop_inside = 0.05,
                        det_func = "Manouk", g0 = 1.0, lam = 1/10, sig = 1,
                        use_manouk_error = FALSE,
                        step_size_os = 100, step_size_ad = 50, Time = 10,
                        K = 1000, age_mu = 1, offspr_mu = 0,
                        bbox = c(0, 0, 1608, 1608), cell_res = 10,
                        sdm = NULL, sdm_og = 0, p_alpha = 1, p_beta = 1,
                        allow_leave = FALSE, crw = FALSE,
                        sigma = NULL, theta = NULL, random_length = FALSE,
                        attractive_areas = FALSE, survive_prob = FALSE, ...) {

  if (is.null(sdm)) {
    sdm <- terra::rast(xmin = bbox[1], xmax = bbox[3],
                       ymin = bbox[2], ymax = bbox[4],
                       resolution = c(cell_res, cell_res))
    terra::values(sdm) <- 1
  } else {
    sdm_ext <- terra::ext(sdm)
    bbox <- c(sdm_ext[1], sdm_ext[3], sdm_ext[2], sdm_ext[4])
  }

  # Survey locations
  if (is.null(surv_loc)) {
    if (is.null(ntraps)) {
      stop("Error: Please supply surveillance locations or number of traps")
    } else {
      surv_loc <- expand.grid(
        seq(bbox[1] + (bbox[3] - bbox[1]) * prop_inside,
            bbox[3] - (bbox[3] - bbox[1]) * prop_inside,
            length = sqrt(ntraps)),
        seq(bbox[2] + (bbox[4] - bbox[2]) * prop_inside,
            bbox[4] - (bbox[4] - bbox[2]) * prop_inside,
            length = sqrt(ntraps)))
      start_ind <- ceiling((nrow(surv_loc) - ntraps) / 2) + 1
      end_ind   <- start_ind + ntraps - 1
      surv_loc  <- surv_loc[start_ind:end_ind, ]
    }
  }
  names(surv_loc) <- c("x", "y")

  # Initialize population
  if (is.null(init_dat)) {
    dat <- data.frame(x    = runif(N_seed, bbox[1], bbox[3]),
                      y    = runif(N_seed, bbox[2], bbox[4]),
                      Fate = rep(1, N_seed),
                      Age  = rpois(N_seed, age_mu))
    row.names(dat) <- NULL
  } else {
    dat <- init_dat
  }

  dat$sdm  <- terra::extract(sdm, as.matrix(dat[, c("x", "y")]))[, 1]
  dat$sdm[is.na(dat$sdm)] <- sdm_og

  dat$dens <- .cell_density(dat[, c("x", "y")], sdm)

  if (survive_prob) {
    dat[, "Fate"] <- rbinom(nrow(dat), 1, dat$sdm)
    dat <- dat[dat$Fate == 1, ]
  }

  dat_all  <- list()
  dat_all[[1]] <- dat
  captured    <- numeric(Time + 1)

  sigma0 <- if (crw) sigma else NULL
  theta0 <- if (crw) theta else NULL
  sdm0   <- if (allow_leave) NULL else sdm

  # Pre-compute trap location matrix once
  surv_mat <- as.matrix(surv_loc[, c("x", "y")])

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

    dat$sdm <- terra::extract(sdm, as.matrix(dat[, c("x", "y")]))[, 1]
    dat$sdm[is.na(dat$sdm)] <- 1

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

    # Pairwise distances and detection probabilities (fully vectorized)
    pwd_pest_surv <- rdist(as.matrix(dat[, c("x", "y")]), surv_mat)

    if (det_func == "HalfNorm") {
      pwd_probs <- p_halfnorm(d = pwd_pest_surv, g0 = g0, sig = sig)
    } else {
      pwd_probs <- p_manouk(d = pwd_pest_surv, g0 = g0, lam = lam)
    }

    # Vectorized Bernoulli draws across the entire probability matrix
    surv_detect <- matrix(rbinom(length(pwd_probs), 1L, pwd_probs),
                          nrow = nrow(pwd_probs))
    pest_detect <- rowSums(surv_detect)

    if (any(pest_detect > 0)) {
      detected_ind    <- which(pest_detect > 0)
      dat             <- dat[-detected_ind, ]
      captured[t + 1] <- length(detected_ind)
    }

    dat_all[[t + 1]] <- dat
    t <- t + 1
  }

  total_captured <- cumsum(captured)

  return(list(
    dat           = dat_all,
    sdm           = sdm,
    surv_loc      = surv_loc,
    captured      = captured,
    total_captured = total_captured
  ))
}
