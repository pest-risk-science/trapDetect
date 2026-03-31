library(raster)
library(trapDetect)

bound_box <- c(-800,-800,800,800)
surv_pts <- expand.grid(seq(-800,800,800),seq(-800,800,800))
names(surv_pts) <- c("x","y")
sdm <- raster(xmn=bound_box[1], xmx=bound_box[3],
              ymn=bound_box[2],ymx=bound_box[4],
              resolution=c(10,10))
sdm[] <- .2

sdm[1:50,1:50] <- 0.0
sdm[1:50,100:160] <- 1
#sdm[120:160,1:50] <- 0
sdm[120:160,120:160] <- 0
sdm[50:120,50:120] <- .5


# Testing individual functions
sim_test <- sim_spread(init_dat = NULL, N_seed = 2, rand.walk = TRUE,
                       step_size_os=10, step_size_ad=150, T = 100, K = 1000,
                       age_mu = 1, offspr_mu = 0, bbox=bound_box,
                       cell_res = 10, sdm = sdm, sdm_og = 0, PLOT.IT =TRUE,
                       allow_leave=FALSE, attractive_areas = TRUE,
                       survive_prob = FALSE)

init_dat = NULL
N_seed = 1
rand.walk = TRUE
step_size_os=10
step_size_ad=150
T = 20
K = 1000
age_mu = 1
offspr_mu = 0
bbox=bound_box
cell_res = 10
sdm_og = 0
PLOT.IT =TRUE
allow_leave=TRUE
attractive_areas = TRUE

tmp <- calc_escape_prob(sdm = sdm,
                 surv_locs = surv_pts,
                 init_dat = data.frame(x=-700,y=700,
                                       Fate=1,
                                       Age=1,
                                       sdm=0.0,
                                       dens=1),
                 T = 2,
                 num_replications = 2,PLOT.IT=F,
                 return_sim = TRUE,
                 return_all_prob = TRUE)
