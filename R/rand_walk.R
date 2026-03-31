#' Random Walk
#'
#' @description
#' Function to determine new locations of individuals based on a random walk
#' process.
#'
#' @details
#' This function takes a matrix of individual locations and generates a matrix
#' of new locations based on a random walk. It accepts either a single (x, y)
#' pair (backward-compatible) or a two-column matrix of locations for fully
#' vectorized operation over many individuals at once.
#'
#' @param x,y the location(s) in x and y. Either scalars (single individual)
#'   or numeric vectors (multiple individuals processed simultaneously).
#' @param step_size step size for dispersal distances of individual.
#' @param sigma variance of random walk if specified. Default `NULL`.
#' @param theta angle(s) of random walk if specified. Default `NULL`.
#' @param random_length logical. If `TRUE`, random walk allows random length up
#'   to `step_size`. Default `FALSE`.
#' @param sdm a SpatRaster (terra) of an sdm with cells between 0 and 1.
#'   Default is `NULL`.
#' @param sdm_vec optional pre-extracted numeric vector of SDM cell values
#'   (i.e. `terra::values(sdm)[, 1]`). When supplied, boundary checks use
#'   fast cell-index lookups instead of `terra::extract()`, saving repeated
#'   raster overhead inside tight loops.
#' @param attractive_areas logical. If `TRUE`, specify areas in sdm to be more
#'   attractive and prevent individuals leaving once they enter area as defined
#'   by raster values.
#'
#' @return
#' A two-column matrix of new (x, y) locations, one row per individual.
#'
#' @importFrom terra extract cellFromXY
#' @importFrom stats rnorm runif
#' @export
rand_walk <- function(x = 0, y = 0, step_size = 1, sigma = NULL, theta = NULL,
                      random_length = FALSE, sdm = NULL, sdm_vec = NULL,
                      attractive_areas = TRUE) {

  n <- length(x)

  # Generate movement angles
  if (is.null(sigma)) {
    theta_new <- 2 * pi * runif(n)
  } else {
    theta_curr <- if (is.null(theta)) runif(n, 0, 2 * pi) else rep_len(theta, n)
    theta_new  <- theta_curr + rnorm(n, 0, sigma)
  }

  # Generate step sizes
  this_step <- if (random_length) runif(n, max = step_size) else step_size

  x_new <- x + this_step * cos(theta_new)
  y_new <- y + this_step * sin(theta_new)

  if (is.null(sdm)) {
    return(cbind(x_new, y_new))
  }

  # Fast SDM lookup: use pre-extracted vector + cellFromXY when available,
  # otherwise fall back to terra::extract (e.g. when called externally).
  .sdm_lookup <- function(xy_mat) {
    if (!is.null(sdm_vec)) {
      sdm_vec[terra::cellFromXY(sdm, xy_mat)]
    } else {
      terra::extract(sdm, xy_mat)[, 1]
    }
  }

  new_mat  <- cbind(x_new, y_new)
  orig_mat <- cbind(x, y)

  new_vals <- .sdm_lookup(new_mat)
  outside  <- is.na(new_vals)

  if (attractive_areas) {
    orig_vals <- .sdm_lookup(orig_mat)
    orig_vals[is.na(orig_vals)] <- 0
    reject <- outside | (orig_vals > ifelse(is.na(new_vals), -Inf, new_vals))
  } else {
    reject <- outside
  }

  # Iteratively re-draw rejected individuals (usually resolves in 1-2 passes)
  max_iter <- 100L
  iter     <- 0L
  while (any(reject) && iter < max_iter) {
    iter <- iter + 1L
    nr   <- sum(reject)

    if (is.null(sigma)) {
      theta_r <- 2 * pi * runif(nr)
    } else {
      theta_c <- if (is.null(theta)) runif(nr, 0, 2 * pi) else rep_len(theta, nr)
      theta_r <- theta_c + rnorm(nr, 0, sigma)
    }
    step_r <- if (random_length) runif(nr, max = step_size) else step_size

    new_mat[reject, 1] <- orig_mat[reject, 1] + step_r * cos(theta_r)
    new_mat[reject, 2] <- orig_mat[reject, 2] + step_r * sin(theta_r)

    new_v  <- .sdm_lookup(new_mat[reject, , drop = FALSE])
    out_r  <- is.na(new_v)

    if (attractive_areas) {
      orig_v <- .sdm_lookup(orig_mat[reject, , drop = FALSE])
      orig_v[is.na(orig_v)] <- 0
      reject[reject] <- out_r | (orig_v > ifelse(is.na(new_v), -Inf, new_v))
    } else {
      reject[reject] <- out_r
    }
  }

  new_mat
}
