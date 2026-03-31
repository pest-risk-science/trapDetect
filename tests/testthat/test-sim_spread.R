test_that("sim_spread returns list with 'dat' and 'sdm' elements", {
  set.seed(5050)
  result <- sim_spread(
    init_dat = test_init_dat, Time = 3,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  expect_named(result, c("dat", "sdm"), ignore.order = TRUE)
})

test_that("sim_spread dat list has length Time + 1", {
  Time <- 4
  set.seed(7733)
  result <- sim_spread(
    init_dat = test_init_dat, Time = Time,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  expect_equal(length(result$dat), Time + 1)
})

test_that("sim_spread dat frames have required columns", {
  set.seed(3388)
  result <- sim_spread(
    init_dat = test_init_dat, Time = 2,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  required_cols <- c("x", "y", "Fate", "Age", "sdm", "dens")
  for (i in seq_along(result$dat)) {
    expect_true(
      all(required_cols %in% names(result$dat[[i]])),
      label = paste("dat[[", i, "]] missing columns")
    )
  }
})

test_that("sim_spread dat[[1]] preserves init_dat coordinates", {
  set.seed(4411)
  result <- sim_spread(
    init_dat = test_init_dat, Time = 2,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  expect_equal(result$dat[[1]]$x, test_init_dat$x)
  expect_equal(result$dat[[1]]$y, test_init_dat$y)
})

test_that("sim_spread sdm column values are in [0, 1]", {
  set.seed(9977)
  result <- sim_spread(
    init_dat = test_init_dat, Time = 3,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 5, offspr_mu = 1,
    PLOT.IT = FALSE
  )
  for (df in result$dat) {
    if (nrow(df) > 0) {
      expect_true(all(df$sdm >= 0 & df$sdm <= 1),
                  label = "SDM values out of [0, 1]")
    }
  }
})

test_that("sim_spread returns a SpatRaster as sdm element", {
  set.seed(6622)
  result <- sim_spread(
    init_dat = test_init_dat, Time = 2,
    sdm = make_sdm(), rand.walk = FALSE,
    offspr_mu = 0, PLOT.IT = FALSE
  )
  expect_s4_class(result$sdm, "SpatRaster")
})

test_that("sim_spread Age increases by 1 each time step", {
  init <- data.frame(x = 0, y = 0, Fate = 1, Age = 5, sdm = 0.8, dens = 1)
  set.seed(2200)
  result <- sim_spread(
    init_dat = init, Time = 3,
    sdm = make_sdm(), rand.walk = FALSE,
    offspr_mu = 0, PLOT.IT = FALSE
  )
  # The original individual's age should increment at each step
  expect_equal(result$dat[[1]]$Age, 5)
  expect_equal(result$dat[[2]]$Age[1], 6)
  expect_equal(result$dat[[3]]$Age[1], 7)
})
