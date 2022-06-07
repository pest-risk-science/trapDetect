################################################################################
## Generate Offspring function
## Author: Peter Caley
## Edited by: Dan Gladish
## Last updated:  Last updated: 25 Nov 2021
#### changelog:
#### 25 Nov 2021
#### - updated rand_walk() call to incorporate changes to that function
################################################################################


#' Generating Offspring
#'
#' @description
#'
#' @details
#'
#' @param dat
#' @param step_size_os
#' @param offspr_mu
#' @param K
#' @param sigma
#' @param theta
#' @param random_length
#' @param sdm
#' @param ...
#'
#' @export
gen_offspring <- function(dat=NULL,
                          step_size_os=5,
                          offspr_mu=2,
                          K=10,
                          sigma=NULL,
                          theta=NULL,
                          random_length=FALSE,
                          sdm=NULL, ...) {
  # Args:
  ### dat -- data frame containing
  ##### - initial locations of individuals ("x","y"),
  ##### - survival "Fate",
  ##### - age "Age",
  ##### - density "dens"
  ###	step_size_os -- step size for for dispersal distances of offspring
  ###	offspr_mu -- mean number of offspring generated per individual per time step (Poisson)
  ###	K -- carrying capacity of cells
  # Returns:
  ###	dat - data frame containing the locations of individuals

  if(nrow(dat)>0) {

    # Calculate effective per capita reproduction rate assuming logistic growth
    eff_mu <- offspr_mu*(1 - dat$dens/K)
    eff_mu[eff_mu<0] <- 0

    # Generate offspring
    new_offspring <- rpois(nrow(dat),eff_mu)

    # All possible recruits (locations of parents)
    recruits <- cbind(dat[,c("x","y")],Fate=rep(1,nrow(dat)),Age=rep(0,nrow(dat)))

    # Duplicate appropriate number of times
    recruits <- recruits[rep(1:nrow(recruits),new_offspring),]

    # Disperse recruits by random walk
    if(nrow(recruits)>0) {
      recruits[,c("x","y")] <- t(apply(recruits[,c("x","y")], 1,
                                       function(x) rand_walk(x=x[1],
                                                             y=x[2],
                                                             step_size=step_size_os,
                                                             sigma=sigma,
                                                             theta=theta,
                                                             random_length=random_length,
                                                             sdm=sdm)))
    }
  }
  row.names(recruits) <- NULL
  return(recruits)
}


