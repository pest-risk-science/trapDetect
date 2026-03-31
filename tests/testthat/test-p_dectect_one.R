test_that("p_detect_one errors without sim or surv_locs", {
  expect_error(p_detect_one(sim = NULL, surv_locs = test_surv_locs),
               regexp = "pest simulation")
  fake_sim <- list(dat = list(test_init_dat), sdm = make_sdm())
  expect_error(p_detect_one(sim = fake_sim, surv_locs = NULL),
               regexp = "surveillance")
})

test_that("p_detect_one returns numeric vector of length Time + 1", {
  set.seed(4433)
  sim <- sim_spread(
    init_dat = test_init_dat, Time = 4,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  result <- p_detect_one(sim = sim, surv_locs = test_surv_locs)
  expect_true(is.numeric(result))
  expect_equal(length(result), 4 + 1)
})

test_that("p_detect_one probabilities are in [0, 1]", {
  set.seed(7766)
  sim <- sim_spread(
    init_dat = test_init_dat, Time = 4,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  result <- p_detect_one(sim = sim, surv_locs = test_surv_locs)
  expect_true(all(result >= 0 & result <= 1))
})

test_that("p_detect_one cumulative probabilities are non-decreasing", {
  set.seed(2299)
  sim <- sim_spread(
    init_dat = test_init_dat, Time = 5,
    sdm = make_sdm(), rand.walk = TRUE,
    step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  result <- p_detect_one(sim = sim, surv_locs = test_surv_locs)
  # p_cum_out accumulates: each value should be >= previous
  expect_true(all(diff(result) >= -1e-12))
})

test_that("p_detect_one with run_surveil = TRUE returns full list", {
  set.seed(5544)
  sim <- sim_spread(
    init_dat = test_init_dat, Time = 3,
    sdm = make_sdm(), rand.walk = FALSE,
    offspr_mu = 0, PLOT.IT = FALSE
  )
  result <- p_detect_one(sim = sim, surv_locs = test_surv_locs,
                         run_surveil = TRUE)
  expect_named(result, c("p_cum_out", "surv_res", "surv_pts", "sdm"),
               ignore.order = TRUE)
  expect_equal(length(result$p_cum_out), 3 + 1)
  expect_equal(length(result$surv_res), 3 + 1)
})

test_that("p_detect_one HalfNorm detection function runs without error", {
  set.seed(8811)
  sim <- sim_spread(
    init_dat = test_init_dat, Time = 2,
    sdm = make_sdm(), rand.walk = FALSE,
    offspr_mu = 0, PLOT.IT = FALSE
  )
  result <- p_detect_one(sim = sim, surv_locs = test_surv_locs,
                         det_func = "HalfNorm", sig = 50)
  expect_true(all(result >= 0 & result <= 1))
})
