
#' @description Simulates spread of
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
#' @param K number for the carrying capacity of cells in the raster.
#' @param age_mu parameter to randomly assign initial ages.
#' @param offspr_mu parameter passed to `gen_offpring()` indicating the mean
#'   number of offspring generated per individual per time step using a Poisson
#'   distribution.
#' @param bbox a vector of length 4 of the extent if `sdm` is not given.
#' @param cell_res resolution of the raster if `sdm` not given.
#' @param sdm a raster of an sdm with cells between 0 and 1.  Default is NULL.
#' @param sdm_og value of sdm off the grid.  If zero, then individuals die off
#'   grid.
#' @param p_alpha alpha parameter for Beta distribution for survival probability
#'   (currently not implemented).
#' @param p_beta beta parameter for Beta distribution for survival probability
#'   (currently not implemented).
#' @param allow_leave logical indicating if individuals can leave the grid.
#' @param crw logical indicating a correlated random walk.
#' @param sigma variance of random walk if specified. Defalut `NULL`
#' @param theta angle of random walk if specified.  Default `NULL`
#' @param random_length logical. If `TRUE`, random walk allows random length up
#'   to `step_size_os`. Default `FALSE`.
#' @param attractive_areas logical. Passed to `rand_walk()`. If `TRUE`, specify
#'   areas in sdm to be more attractive and prevent individuals leaving once they
#'   enter area as defined by raster values.
#' @param survive_prob logical. If `TRUE` allow for survival/mortality based on
#'   sdm values.
#' @param PLOT.IT logical. If `TRUE` plot an amm
#' @param ... additional arguments to be passed to helper functions.
#'
#' @export
sim_spread <- function(init_dat=NULL, N_seed=2, rand.walk=FALSE,
                      step_size_os=100, step_size_ad=50, T=10, K=1000,
                      age_mu=1, offspr_mu=1, bbox=c(0,0,1608,1608),
                      cell_res=10, sdm=NULL, sdm_og=0, p_alpha=1,
                      p_beta=1, allow_leave=FALSE, crw=FALSE,
                      sigma=NULL, theta=NULL, random_length=FALSE,
                      attractive_areas=FALSE, survive_prob=FALSE,
                      PLOT.IT=TRUE, ...) {

  ###	PLOT.IT -- do you want to plot

  # Args:
  ###	init_dat -- data.frame contain x, y, Fate and Age of population to be updated
  ###	N_seed -- number of individuals to start with if init_dat not given
  ### rand.walk -- are individuals fixed, or do they move each time step
  ###	step_size_os -- step size for dispersal distances of offspring
  ###	step_size_ad -- step size for dispersal distances of adults
  ###	T -- number of time steps to run simulation for
  ###	K -- carrying capacity for cells
  ###	age_mu -- parameter for randomly assigning initial ages
  ### offspr_mu - parameter for offspring mean
  ###	bbox -- extent (used for plotting)
  ###	cell_res -- resolution of raster (for calculating K etc.)
  ###	sdm -- a sdm on a raster (values need to on [0,1])
  ###	sdm_og -- values to use for sdm off the grid (if zero, all die)
  ###	p_alpha, p_beta -- beta parameters governing survival probability (THESE ARE NOT IN)
  ### allow_leave -- are individuals allowed to leave the raster?
  ### crw -- use correlated random walk or no?
  ### sigma, theta, random_length -- parameters to pass to rand_walk()
  ###	PLOT.IT -- do you want to plot

  # Returns:
  ###	dat_all -- list of data.frames for the spread at each time point
  ### sdm -- raster layer


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
  if(PLOT.IT) {
    plot(sdm)
    with(dat,points(x, y, pch=16,
                    xlim=c(bbox[1],bbox[3]),
                    ylim=c(bbox[2],bbox[4]),
                    col='red'))
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
  while (t <= T & nrow(dat)>0) {

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

    #if(sum(is.na(dat$sdm))==length(dat$sdm)) {break}

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
    # Update plot
    if(PLOT.IT) {
      plot(sdm)
      with(dat,points(x, y, pch=16,
                      xlim=c(bbox[1],bbox[3]),
                      ylim=c(bbox[2],bbox[4]),
                      col='blue'))
      ani.pause(0.1)
    }
    # Save details to list
    dat_all[[t+1]] <- dat
    t <- t + 1
  }
  return(list(
    dat=dat_all,
    sdm=sdm
  ))
}
