test_that("sim_capture returns list with required elements", {
  set.seed(1234)
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = 3, rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0
  )
  expected_names <- c("dat", "sdm", "surv_loc", "captured", "total_captured")
  expect_true(all(expected_names %in% names(result)))
})

test_that("sim_capture captured vector has length Time + 1", {
  Time <- 4
  set.seed(8822)
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = Time, rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0
  )
  expect_equal(length(result$captured), Time + 1)
})

test_that("sim_capture first captured element is always 0", {
  set.seed(3311)
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = 3, rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0
  )
  expect_equal(result$captured[1], 0)
})

test_that("sim_capture total_captured equals cumsum of captured", {
  set.seed(5599)
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = 5, rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0
  )
  expect_equal(result$total_captured, cumsum(result$captured))
})

test_that("sim_capture captured values are non-negative integers", {
  set.seed(7744)
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = 4, rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0
  )
  expect_true(all(result$captured >= 0))
  expect_true(all(result$captured == floor(result$captured)))
})

test_that("sim_capture dat list has length Time + 1 when no captures occur", {
  Time <- 3
  set.seed(6688)
  # g0 = 0 means zero detection probability, so the loop always runs to Time
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = Time, rand.walk = FALSE,
    offspr_mu = 0, g0 = 0
  )
  expect_equal(length(result$dat), Time + 1)
})

test_that("sim_capture dat list length is <= Time + 1 (early exit on full capture)", {
  Time <- 3
  set.seed(1155)
  # g0 = 1 makes capture likely; loop may terminate before Time
  result <- sim_capture(
    init_dat = test_init_dat,
    surv_loc = test_surv_locs,
    sdm = make_sdm(),
    Time = Time, rand.walk = FALSE,
    offspr_mu = 0, g0 = 1.0
  )
  expect_lte(length(result$dat), Time + 1)
})

test_that("sim_capture errors without surv_loc or ntraps", {
  expect_error(
    sim_capture(init_dat = test_init_dat, sdm = make_sdm(), Time = 2),
    regexp = "surveillance"
  )
})
