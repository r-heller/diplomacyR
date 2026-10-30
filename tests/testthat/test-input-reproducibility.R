test_that("counts reject non-finite and out-of-range values before coercion", {
  for (bad in list(Inf, -Inf, NaN, 2^31, 1.5, numeric(), NA_real_)) {
    expect_error(dp_simulate(n = bad, verbose = FALSE), class = "rlang_error")
    expect_error(dp_play(max_years = bad), class = "rlang_error")
    expect_error(dp_play(seed = bad), class = "rlang_error")
  }
})

test_that("seeded play and batches preserve the caller's RNG on success and failure", {
  set.seed(4321); before <- .Random.seed
  a <- dp_play(bots = "random", max_years = 1, seed = 77)
  expect_identical(.Random.seed, before)
  expect_identical(a, dp_play(bots = "random", max_years = 1, seed = 77))
  b <- dp_simulate(n = 2, bots = "random", max_years = 1, seed = 77, verbose = FALSE)
  expect_identical(.Random.seed, before)
  expect_identical(b, dp_simulate(n = 2, bots = "random", max_years = 1, seed = 77, verbose = FALSE))
  expect_error(dp_play(bots = "not-a-bot", seed = 77))
  expect_identical(.Random.seed, before)
  withr::local_preserve_seed()
  rm(".Random.seed", envir = .GlobalEnv)
  dp_play(bots = "hold", max_years = 1, seed = 77)
  expect_false(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
})
