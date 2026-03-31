test_that("rand_walk returns a two-column matrix", {
  result <- rand_walk(x = 0, y = 0, step_size = 10)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), 2)
})

test_that("rand_walk handles multiple individuals (vectorised)", {
  n <- 50
  set.seed(7421)
  result <- rand_walk(
    x = runif(n, -50, 50),
    y = runif(n, -50, 50),
    step_size = 5
  )
  expect_true(is.matrix(result))
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 2)
})

test_that("rand_walk moves exactly step_size without random_length or SDM", {
  n <- 200
  x <- rep(0, n); y <- rep(0, n)
  set.seed(3301)
  result <- rand_walk(x = x, y = y, step_size = 25)
  dists <- sqrt(result[, 1]^2 + result[, 2]^2)
  # All distances should be exactly 25 (constant step, no rejection)
  expect_equal(unique(round(dists, 10)), 25)
})

test_that("rand_walk with random_length produces distances <= step_size", {
  n <- 500
  set.seed(9812)
  result <- rand_walk(
    x = rep(0, n), y = rep(0, n),
    step_size = 20, random_length = TRUE
  )
  dists <- sqrt(result[, 1]^2 + result[, 2]^2)
  expect_true(all(dists <= 20 + 1e-9))
})

test_that("rand_walk keeps individuals inside SDM extent (allow_leave = FALSE)", {
  sdm <- make_sdm()
  sdm_vec <- terra::values(sdm)[, 1]
  ext_r <- terra::ext(sdm)

  set.seed(5544)
  # Start near boundary so step_size could push outside without constraint
  n <- 100
  result <- rand_walk(
    x = runif(n, 60, 70), y = runif(n, 60, 70),
    step_size = 30,
    sdm = sdm, sdm_vec = sdm_vec
  )
  expect_true(all(result[, 1] >= ext_r[1] & result[, 1] <= ext_r[2]))
  expect_true(all(result[, 2] >= ext_r[3] & result[, 2] <= ext_r[4]))
})

test_that("rand_walk with CRW (sigma) produces movement at every step", {
  n <- 20
  set.seed(1177)
  result <- rand_walk(
    x = rep(0, n), y = rep(0, n),
    step_size = 10, sigma = 0.5, theta = 0
  )
  expect_equal(nrow(result), n)
  dists <- sqrt(result[, 1]^2 + result[, 2]^2)
  expect_true(all(dists > 0))
})
