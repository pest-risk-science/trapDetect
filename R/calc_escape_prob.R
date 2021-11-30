#' @importFrom stats rbinom rnorm rpois runif
NULL

#' @importFrom animation ani.pause
NULL

#' @importFrom raster extent extract rasterize raster
NULL

#' @importFrom fields rdist

#' @export
calc_escape_prob <- function(init_dat=NULL,
                             surv_locs=NULL,
                             sdm=NULL,
                             N_seed=1,
                             min_surv_locs = 9,
                             num_replications = 2,
                             rand.walk=TRUE,
                             step_size_os=100,
                             step_size_ad=100,
                             T=10,
                             K=1000,
                             age_mu=1,
                             offspr_mu=0,
                             bbox=c(-800,-800,800,800),
                             cell_res=10,
                             sdm_og=0,
                             p_alpha=1,
                             p_beta=1,
                             allow_leave=FALSE,
                             crw=FALSE,
                             sigma=NULL,
                             theta=NULL,
                             random_length=FALSE,
                             PLOT.IT=FALSE,
                             g0 = 1.0,
                             lam=1/50,
                             sig = 1,
                             det_func="Manouk",
                             use_manouk_error=FALSE,
                             run_surveil=FALSE, ...) {
  # Calls:
  ###	p_detect_one()
  # Args:
  ###	sim --- simulation object generated using sim_spread()
  ###	surv_locs --- locations of detection devices
  ### g0 -- detection probability at distance zero
  ### lam -- lambda for Manoukis detection function
  ### sig --  standard deviation of detection
  ###	det_func --- detection function of choice for surveillance
  # Returns:
  ###	mean P(Detect at least one) = 1 - P(Detect none) by day of simulation
  ### Calculate probability of detections daily over list of simulations and bind

  if(is.null(surv_locs)) {
    if(!is.null(sdm)) {
      stop("Error: Please supply survey locations for this raster")
    }
    print("Warning: generating survey and raster...")
    if(is.null(init_dat)) {

      surv_locs <- expand.grid(seq(bbox[1],bbox[3],
                                   length=sqrt(min_surv_locs)),
                               seq(bbox[2],bbox[4],
                                   length=sqrt(min_surv_locs)))
    } else {
      surv_locs <- expand.grid(seq(sim$sdm@extent[1], sim$sdm@extent[2],
                                   length=sqrt(min_surv_locs)),
                               seq(sim$sdm@extent[3], sim$sdm@extent[4],
                                   length=sqrt(min_surv_locs)))
    }
    names(surv_locs) <- c("x","y")
  }

  if(is.null(init_dat)) {
    print("No initial data detected, generating random simulations")
  }
  sim <- replicate(num_replications,
                   sim_spread(init_dat=init_dat,
                              N_seed=N_seed,
                              rand.walk=rand.walk,
                              step_size_os=step_size_os,
                              step_size_ad=step_size_ad,
                              T=T,
                              K=K,
                              age_mu=age_mu,
                              offspr_mu=offspr_mu,
                              bbox=bbox,
                              cell_res=cell_res,
                              sdm=sdm,
                              sdm_og=sdm_og,
                              p_alpha=p_alpha,
                              p_beta=p_beta,
                              allow_leave=allow_leave,
                              crw=crw,
                              sigma=sigma,
                              theta=theta,
                              random_length=random_length,
                              PLOT.IT=PLOT.IT),
                   simplify = FALSE)

  res <- do.call("rbind",lapply(sim,
                                function(x) {
                                  p_detect_one(sim=x,
                                               surv_locs=surv_locs,
                                               g0=g0,
                                               lam=lam,
                                               sig=sig,
                                               det_func=det_func,
                                               use_manouk_error=use_manouk_error,
                                               run_surveil = FALSE)
                                }))

  # Calculate means over simulations
  res_sum <- apply(res,2,mean)
  res_sum
}
