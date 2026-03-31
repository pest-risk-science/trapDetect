test_that("calc_escape_prob returns mean_prob of length Time + 1", {
  Time <- 3
  set.seed(6622)
  result <- calc_escape_prob(
    init_dat = test_init_dat,
    surv_locs = test_surv_locs,
    sdm = make_sdm(),
    Time = Time, num_replications = 5,
    rand.walk = TRUE, step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  expect_equal(length(result$mean_prob), Time + 1)
})

test_that("calc_escape_prob mean_prob values are in [0, 1]", {
  set.seed(7733)
  result <- calc_escape_prob(
    init_dat = test_init_dat,
    surv_locs = test_surv_locs,
    sdm = make_sdm(),
    Time = 3, num_replications = 5,
    rand.walk = TRUE, step_size_ad = 10, offspr_mu = 0,
    PLOT.IT = FALSE
  )
  expect_true(all(result$mean_prob >= 0 & result$mean_prob <= 1))
})

test_that("calc_escape_prob runs sequentially by default (parallel = FALSE)", {
  # Should complete without needing furrr or a future plan
  set.seed(4488)
  expect_no_error(
    calc_escape_prob(
      init_dat = test_init_dat,
      surv_locs = test_surv_locs,
      sdm = make_sdm(),
      Time = 2, num_replications = 3,
      rand.walk = FALSE, offspr_mu = 0,
      PLOT.IT = FALSE
    )
  )
})

test_that("calc_escape_prob probs matrix has correct dimensions when return_all_prob = TRUE", {
  Time <- 3
  n_rep <- 4
  set.seed(1122)
  result <- calc_escape_prob(
    init_dat = test_init_dat,
    surv_locs = test_surv_locs,
    sdm = make_sdm(),
    Time = Time, num_replications = n_rep,
    rand.walk = FALSE, offspr_mu = 0,
    PLOT.IT = FALSE,
    return_all_prob = TRUE
  )
  expect_equal(nrow(result$probs), n_rep)
  expect_equal(ncol(result$probs), Time + 1)
})

test_that("calc_escape_prob returns sim list when return_sim = TRUE", {
  set.seed(9955)
  result <- calc_escape_prob(
    init_dat = test_init_dat,
    surv_locs = test_surv_locs,
    sdm = make_sdm(),
    Time = 2, num_replications = 2,
    rand.walk = FALSE, offspr_mu = 0,
    PLOT.IT = FALSE,
    return_sim = TRUE
  )
  expect_true("sim" %in% names(result))
  expect_equal(length(result$sim), 2)
  expect_named(result$sim[[1]], c("dat", "sdm"), ignore.order = TRUE)
})

test_that("calc_escape_prob get_first_detect returns integer vector", {
  set.seed(3377)
  result <- calc_escape_prob(
    init_dat = test_init_dat,
    surv_locs = test_surv_locs,
    sdm = make_sdm(),
    Time = 3, num_replications = 5,
    rand.walk = FALSE, offspr_mu = 0,
    PLOT.IT = FALSE,
    get_first_detect = TRUE
  )
  expect_true("first_detect" %in% names(result))
  expect_equal(length(result$first_detect), 5)
  expect_true(all(result$first_detect >= 0))
})

test_that("calc_escape_prob parallel = TRUE errors without furrr (if not installed)", {
  # Only check the error message path; skip if furrr is available
  skip_if(requireNamespace("furrr", quietly = TRUE),
          "furrr is installed; skipping 'missing package' error test")
  expect_error(
    calc_escape_prob(
      init_dat = test_init_dat,
      surv_locs = test_surv_locs,
      sdm = make_sdm(),
      Time = 2, num_replications = 2,
      PLOT.IT = FALSE, parallel = TRUE
    ),
    regexp = "furrr"
  )
})
