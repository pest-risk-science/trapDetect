################################################################################
## Random Walk Function
## Author: Peter Caley
## Edited by: Dan Gladish
## Last updated:  Last updated: 25 Nov 2021
#### changelog:
#### 25 Nov 2021
#### -added random length measure
#### -outputs error if initial location not in raster (if supplied)
#### -if raster supplied, made so random walk stays in raster
################################################################################

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

