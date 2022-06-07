################################################################################
## Functions to estimate probability of detecting at least one pest
## Author: Peter Caley
## Edited by: Dan Gladish
## Last updated:  Last updated: 25 Nov 2021
#### changelog:
#### 26 Nov 2021
#### -- added run_surveil flag to combine with run_surv()
################################################################################


#' Probability to detect one individual
#'
#' @description
#'
#' @details
#'
#' @param sim
#'
#' @param surv_locs
#' @param g0
#' @param lam
#' @param sig
#' @param det_func
#' @param use_manouk_error
#' @param run_surveil
#'
#' @export
p_detect_one <- function(sim=NULL, surv_locs=NULL,
                         g0=1.0, lam=1/10, sig=1,
                         det_func="Manouk", use_manouk_error=FALSE,
                         run_surveil=FALSE) {
  # Args:
  ### sim -- simulation object with (x,y) locations of pests
  ### surv_locs -- data.frame of survey points (e.g. traps)
  ### g0 -- detection probabity at distance zero
  ### lam -- trap attractiveness
  ### sig --  standard deviation of detection
  ### det_func -- detection function with "Manouk" or "HalfNorm". Default is "Manouk"
  ### run_surveil -- return surveillance?
  # Returns:
  ### p_cum_out -- the probability of detecting at least one

  # Return Errors
  if(is.null(sim)) {
    stop("Error: Please supply pest simulation")
  }
  if(is.null(surv_locs)) {
    stop("Error: Please supply surveylance locations")
  }

  dat=sim[["dat"]]
  p_non_detect <- numeric()

  if(run_surveil) {
    surv_out <- list()
  }

  for (i in 1:length(dat)) {	#i=1	i= i+1

    # Grab point data for pest
    pest_locs <- dat[[i]][,c('x','y')]

    # Pairwise distances (pwd) between critters and surveillance devices
    pwd_pest_surv <- rdist(pest_locs, surv_locs[,c('x','y')])

    # Calculate probabilities of detection for all pairwise distances
    if(det_func=="HalfNorm") {
      pwd_probs <- apply(pwd_pest_surv, c(1,2),
                         function(x) p_halfnorm(d=x, g0=g0, sig=sig))
    }
    if(det_func=="Manouk") {
      pwd_probs <- apply(pwd_pest_surv, c(1,2),
                         function(x) p_manouk(d=x, g0=g0, lam=lam))
    }

    # Calculate probabilities of non-detection in all traps
    pwd_probs_bar <- apply(pwd_probs, c(1,2), function(x) {1-x})

    # Calculate probabilities of non-detection for individual pests
    p_indiv_non_detect <- apply(pwd_probs_bar, 1, prod)

    # Calculate probability of non-detection of all pests
    p_non_detect[i] <- prod(p_indiv_non_detect)

    if(use_manouk_error) {
      p_non_detect[i] <- mean(p_indiv_non_detect)
    }

    # Run surveillance?
    if(run_surveil) {
      surv_detect <- apply(pwd_probs,c(1,2), function(x) rbinom(1,1,x))
      trap_detect <- apply(surv_detect,2,sum)
      pos_trap_nos <- surv_locs[which(trap_detect>0),]
      surv_out[[i]] <- list(pos_trap_nos=pos_trap_nos,dat=dat[[i]])
    }
  }

  # Calculate cumulative p ...
  p_cum_out <- 1 - sapply(1:length(p_non_detect), function(i) prod(p_non_detect[1:i]))

  # Returning
  if(run_surveil) {
    return(
      list(p_cum_out=p_cum_out,
           surv_res=surv_out,
           surv_pts=surv_locs,
           sdm=sim$sdm
      ))
  } else {
    return(p_cum_out)
  }
}
