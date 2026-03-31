# Shared test fixtures --------------------------------------------------------
# Loaded automatically by testthat before all test files.

library(terra)

# Small bounding box (160 x 160 units, 10-unit cells -> 16 x 16 = 256 cells)
test_bbox <- c(-80, -80, 80, 80)

# Uniform SDM (all habitat equally suitable)
make_sdm <- function(val = 0.8) {
  r <- terra::rast(
    xmin = test_bbox[1], xmax = test_bbox[3],
    ymin = test_bbox[2], ymax = test_bbox[4],
    resolution = 10
  )
  terra::values(r) <- val
  r
}

# 3x3 grid of survey locations inside the box
test_surv_locs <- expand.grid(
  x = seq(-60, 60, 60),
  y = seq(-60, 60, 60)
)

# Minimal initial population (one individual, known location)
test_init_dat <- data.frame(
  x    = 0,
  y    = 0,
  Fate = 1,
  Age  = 1,
  sdm  = 0.8,
  dens = 1
)
