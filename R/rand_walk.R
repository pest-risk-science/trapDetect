#' Random Walk
#'
#' @description
#' Function to determine new location of an individual based on a random walk
#' process.
#'
#' @details
#' This function takes in a location of an individual and generates a vector
#' for the new location of an individual based on a random walk.
#'
#' @param x,y the location (x,y) of the init
#' @param step_size step size for dispersal distances of individual.
#' @param sigma variance of random walk if specified. Defalut `NULL`.
#' @param theta angle of random walk if specified.  Default `NULL`.
#' @param random_length logical. If `TRUE`, random walk allows random length up
#'   to `step_size`. Default `FALSE`.
#' @param sdm a raster of an sdm with cells between 0 and 1.  Default is `NULL`.
#' @param attractive_areas logical. If `TRUE`, specify areas in sdm to be more
#'   attractive and prevent individuals leaving once they enter area as defined
#'   by raster values.
#'
#' @return
#' A vector of length 2, the first element corresponding to the location in the
#' x direction, the second in the y directoin.
#'
#' @export
rand_walk <- function(x=0,y=0,step_size=1,sigma=NULL,theta=NULL,
                      random_length=FALSE, sdm=NULL,
                      attractive_areas=TRUE) {

  # Check to see if original point in raster
  if(!is.null(sdm)) {
    org_loc <- c(x,y)
    if(is.na(sum(extract(sdm,matrix(org_loc,1,2))))) {
      stop("Error: Individual not in raster")
    }
  }

  # If angle not specified
  if(is.null(sigma)) {
    theta_new <- 2*pi*runif(1)
  } else {
    theta_new <- theta + rnorm(1, theta, sigma)
  }
  if(random_length) {
    this_step <- runif(1,max=step_size)
  } else {
    this_step <- step_size
  }
  x_new <- x + this_step*cos(theta_new)
  y_new <- y + this_step*sin(theta_new)
  new_loc <- c(x_new,y_new)

  if(is.null(sdm)) {
    return(new_loc)
  } else {
    outside_raster <- is.na(sum(extract(sdm,matrix(new_loc,1,2))))
    worse_loc <- FALSE
    if(attractive_areas) {
      old_loc_value <- sum(extract(sdm,matrix(org_loc,1,2)),na.rm=TRUE)
      new_loc_value <- sum(extract(sdm,matrix(new_loc,1,2)),na.rm=TRUE)
      worse_loc <- old_loc_value > new_loc_value
    }
    if(outside_raster | worse_loc) {
      return(rand_walk(x,y,step_size,sigma,theta,random_length,sdm,
                       attractive_areas))
    } else {
      return(new_loc)
    }


  }
}

