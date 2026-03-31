test_that("gen_offspring returns a data frame with required columns", {
  dat <- data.frame(
    x = c(0, 10), y = c(0, 10),
    Fate = c(1, 1), Age = c(2, 3),
    sdm = c(0.5, 0.5), dens = c(1, 1)
  )
  set.seed(4422)
  result <- gen_offspring(dat, step_size_os = 5, offspr_mu = 2, K = 100)
  expect_true(is.data.frame(result))
  expect_true(all(c("x", "y", "Fate", "Age") %in% names(result)))
})

test_that("gen_offspring returns zero rows when offspr_mu = 0", {
  dat <- data.frame(
    x = c(0, 10), y = c(0, 10),
    Fate = c(1, 1), Age = c(1, 1),
    sdm = c(0.5, 0.5), dens = c(1, 1)
  )
  set.seed(8811)
  result <- gen_offspring(dat, step_size_os = 5, offspr_mu = 0, K = 100)
  expect_equal(nrow(result), 0)
})

test_that("gen_offspring respects carrying capacity (K)", {
  # When dens >= K, effective mu = 0, so no offspring
  dat <- data.frame(
    x = 0, y = 0,
    Fate = 1, Age = 1,
    sdm = 0.5, dens = 50
  )
  set.seed(2255)
  result <- gen_offspring(dat, step_size_os = 5, offspr_mu = 3, K = 50)
  expect_equal(nrow(result), 0)
})

test_that("gen_offspring offspring all have Age = 0 and Fate = 1", {
  dat <- data.frame(
    x = rep(0, 5), y = rep(0, 5),
    Fate = rep(1, 5), Age = rep(3, 5),
    sdm = rep(0.5, 5), dens = rep(0, 5)
  )
  set.seed(6633)
  result <- gen_offspring(dat, step_size_os = 5, offspr_mu = 2, K = 1000)
  if (nrow(result) > 0) {
    expect_true(all(result$Age == 0))
    expect_true(all(result$Fate == 1))
  }
})

test_that("gen_offspring disperses offspring within SDM when sdm supplied", {
  sdm <- make_sdm()
  sdm_vec <- terra::values(sdm)[, 1]
  ext_r <- terra::ext(sdm)
  dat <- data.frame(
    x = 0, y = 0,
    Fate = 1, Age = 1,
    sdm = 0.8, dens = 0
  )
  set.seed(1199)
  result <- gen_offspring(dat, step_size_os = 10, offspr_mu = 5, K = 1000,
                          sdm = sdm, sdm_vec = sdm_vec)
  if (nrow(result) > 0) {
    expect_true(all(result$x >= ext_r[1] & result$x <= ext_r[2]))
    expect_true(all(result$y >= ext_r[3] & result$y <= ext_r[4]))
  }
})
