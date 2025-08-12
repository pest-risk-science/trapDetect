
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
#' \item{sdm}{A raster containing the sdm of the simulation.}
#' \item{surv_loc}{A data frame containing the locations of the traps.}
#' \item{captured}{A vector of length Time+1 of the number of captured pests
#'                   during that time step. First element is time point 0 and
#'                   always 0.}
#' \item{total_captured}{A vector of length Time+1 of the cumulative total
#'                   caught pests up to that point.First element is time point 0
#'                   and always 0.}
#'
#' @export

sim_capture <- function(init_dat=NULL, N_seed=2, rand.walk=TRUE, surv_loc = NULL,
                        ntraps = NULL, prop_inside = 0.05, det_func = "Manouk",
                        g0=1.0, lam=1/10, sig=1, use_manouk_error=FALSE,
                        step_size_os=100, step_size_ad=50, Time=10, K=1000,
                        age_mu=1, offspr_mu=0, bbox=c(0,0,1608,1608),
                        cell_res=10, sdm=NULL, sdm_og=0, p_alpha=1,
                        p_beta=1, allow_leave=FALSE, crw=FALSE,
                        sigma=NULL, theta=NULL, random_length=FALSE,
                        attractive_areas=FALSE, survive_prob=FALSE,
                        ...) {

  if(is.null(sdm)) {
    # Create sdm assuming all suitable if unknown
    sdm <- raster(xmn=bbox[1], xmx=bbox[3], ymn=bbox[2],ymx=bbox[4],
                  resolution=c(cell_res,cell_res))
    sdm[] <- 1
  } else {
    # Redefine bounding box on the basis of sdm supplied
    sdm_ext <- extent(sdm)
    bbox <- c(sdm_ext[1],sdm_ext[3],sdm_ext[2],sdm_ext[4])
  }

  # Survey locs
  if(is.null(surv_loc)) {
    if(is.null(ntraps)) {
      stop("Error: Please supply surveillance locations or number of traps")
    } else {
      surv_loc <- expand.grid(seq(bbox[1] + (bbox[3]-bbox[1])*prop_inside,
                                  bbox[3] - (bbox[3]-bbox[1])*prop_inside,
                                  length=sqrt(ntraps)),
                              seq(bbox[2] + (bbox[4]-bbox[2])*prop_inside,
                                  bbox[4] - (bbox[4]-bbox[2])*prop_inside,
                                  length=sqrt(ntraps)))

      start_ind <- ceiling((nrow(surv_loc)-ntraps)/2)+1
      end_ind <- start_ind + ntraps - 1
      surv_loc <- surv_loc[start_ind:end_ind,]
    }
  }
  names(surv_loc) <- c("x","y")

  # Initialize population if initial population unknown
  if(is.null(init_dat)) {
    dat <- data.frame(x=runif(N_seed,bbox[1],bbox[3]),
                      y=runif(N_seed,bbox[2],bbox[4]),
                      Fate=rep(1,N_seed),
                      Age=rpois(N_seed,age_mu))
    row.names(dat) <- NULL
  } else {
    dat <- init_dat
  }

  # Extract sdm values at introduction locations
  dat$sdm <- raster::extract(sdm,dat[,c("x","y")])

  # Choose off-grid sdm values
  dat$sdm[is.na(dat$sdm)] <- sdm_og

  # Sum populations by raster cell
  dens <- rasterize(dat[,c('x','y')], sdm, fun=function(x,...) length(x))

  # Calculate density where critter lives and add to data.frame
  dat$dens <- raster::extract(dens,dat[,c("x","y")])

  # Apply survival/mortality based on sdm values
  if(survive_prob) {
    dat[,"Fate"] <- rbinom(nrow(dat),1,dat$sdm)
    # Choose survivors
    dat <- dat[dat$Fate==1,]
  }

  # List for populating
  dat_all <- list()
  dat_all[[1]] <- dat
  captured <- c()
  captured[1] <- 0

  # Additional things outside loop
  if(crw) {
    sigma0 <- sigma
    theta0 <- theta
  } else {
    sigma0 <- NULL
    theta0 <- NULL
  }
  if(allow_leave) {
    sdm0 <- NULL
  } else {
    sdm0 <- sdm
  }

  # Iterate
  t <- 1
  while (t <= Time & nrow(dat)>0) {

    # Generate offspring from survivors
    offspring <- gen_offspring(dat, step_size_os, offspr_mu, K=K,
                               sigma = sigma0, theta=theta0,
                               random_length = random_length,
                               sdm=sdm0)
    if(nrow(offspring)>0) {
      # Add sdm & dens to enable binding
      offspring$sdm <- NA
      offspring$dens <- NA
      dat <- rbind(dat,offspring)
    }

    # Extract sdm values
    dat$sdm <- raster::extract(sdm,dat[,c("x","y")])

    # Replaces NAs with 1 (u survive outside of the grid)
    dat$sdm[is.na(dat$sdm)] <- 1

    # Calculate density
    dens <- rasterize(dat[,c('x','y')], sdm, fun=function(x,...) length(x))
    dat$dens <- raster::extract(dens,dat[,c("x","y")])

    # Assume no density-dependence outside of the grid
    dat$dens[is.na(dat$dens)] <- 0

    # Apply mortality based on sdm
    if(survive_prob) {
      dat[,"Fate"] <- rbinom(nrow(dat),1,dat$sdm)

      # Choose survivors
      dat <- dat[dat$Fate==1,]
    }

    # Update survivor age
    dat$Age <- dat$Age+1

    # Undertake random walk if required
    if(rand.walk) {
      dat[,c("x","y")] <- t(apply(dat[,c("x","y")], 1,
                                  function(x) rand_walk(x=x[1],
                                                        y=x[2],
                                                        step_size_ad,
                                                        sigma=sigma0,
                                                        theta=theta0,
                                                        random_length=random_length,
                                                        sdm=sdm0,
                                                        attractive_areas=attractive_areas)))
    }
    row.names(dat) <- NULL

    # Get Pest dist to detection devices
    pest_locs <- dat[,c('x','y')]
    pwd_pest_surv <- rdist(pest_locs, surv_loc[,c('x','y')])

    # Calculate probabilities of detection for all pairwise distances
    if(det_func=="HalfNorm") {
      pwd_probs <- apply(pwd_pest_surv, c(1,2),
                         function(x) p_halfnorm(d=x, g0=g0, sig=sig))
    }
    if(det_func=="Manouk") {
      pwd_probs <- apply(pwd_pest_surv, c(1,2),
                         function(x) p_manouk(d=x, g0=g0, lam=lam))
    }

    # Traps detect?
    surv_detect <- apply(pwd_probs,c(1,2), function(x) rbinom(1,1,x))
    pest_detect <- apply(surv_detect,1,sum)

    if(sum(pest_detect>0)) {
      detected_ind <- which(pest_detect>0)
      nondetected_ind <- c(1:nrow(dat))[!(c(1:nrow(dat)%in%detected_ind))]
      dat <- dat[nondetected_ind,]
      captured <- c(captured,sum(length(detected_ind)))
    } else {
      captured <- c(captured,0)
    }

    # Save details to list
    dat_all[[t+1]] <- dat
    t <- t + 1
  }
  total_captured <- cumsum(captured)

  return(list(
    dat=dat_all,
    sdm=sdm,
    surv_loc=surv_loc,
    captured=captured,
    total_captured=total_captured
  ))
}
