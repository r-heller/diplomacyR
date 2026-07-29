test_that("a small batch completes and reports stable tables", {
  sim <- dp_simulate(n = 3, bots = "hold", max_years = 2, seed = 1,
                     verbose = FALSE)
  expect_s3_class(sim, "dp_sim")
  expect_true(is_dp_sim(sim))
  expect_equal(nrow(sim$games), 3L)
  expect_equal(sort(unique(sim$centres$game)), 1:3)
  expect_equal(nrow(sim$centres), 21L)
  expect_true(all(sim$games$outcome %in% c("solo", "draw")))
})

test_that("stats tibbles keep their columns for an empty simulation", {
  sim <- dp_simulate(n = 0, verbose = FALSE)
  expect_equal(nrow(sim$games), 0L)
  expect_equal(
    names(dp_stats(sim, "power")),
    c("power", "games", "solos", "win_rate", "survival_rate", "mean_centres",
      "max_centres")
  )
  expect_equal(names(dp_stats(sim, "outcome")), c("outcome", "games", "share"))
  expect_equal(names(dp_stats(sim, "length")), c("years", "games", "share"))
  expect_equal(nrow(dp_stats(sim, "power")), 0L)
  expect_equal(nrow(dp_power_summary(sim)), 0L)
})

test_that("stats tibbles have the same columns when populated", {
  sim <- dp_simulate(n = 2, bots = "random", max_years = 2, seed = 2,
                     verbose = FALSE)
  empty <- dp_simulate(n = 0, verbose = FALSE)
  for (what in c("power", "outcome", "length")) {
    expect_equal(names(dp_stats(sim, what)), names(dp_stats(empty, what)),
                 info = what)
  }
  expect_equal(nrow(dp_stats(sim, "power")), 7L)
  expect_true(all(dp_stats(sim, "power")$win_rate <= 1))
})

test_that("a mixed bot matchup runs", {
  bots <- c(France = "random", Germany = "hold")
  sim <- dp_simulate(n = 1, bots = bots, max_years = 2, seed = 5,
                     verbose = FALSE)
  expect_equal(nrow(sim$games), 1L)
  expect_equal(sim$settings$bots, bots)
})

test_that("simulation is reproducible under a seed", {
  a <- dp_simulate(n = 2, bots = "random", max_years = 2, seed = 99,
                   verbose = FALSE)
  b <- dp_simulate(n = 2, bots = "random", max_years = 2, seed = 99,
                   verbose = FALSE)
  expect_equal(a$centres, b$centres)
})

test_that("power summaries work on games, histories and simulations", {
  expect_s3_class(dp_power_summary(dp_new_game()), "tbl_df")
  h <- dp_play(bots = "hold", max_years = 2)
  ps <- dp_power_summary(h)
  expect_equal(nrow(ps), 7L)
  expect_true(all(c("peak_centres", "final_centres") %in% names(ps)))
  expect_s3_class(dp_sc_trajectory(h), "tbl_df")
  expect_equal(nrow(dp_sc_trajectory(dp_history())), 0L)
})

test_that("bad arguments abort", {
  expect_error(dp_simulate(n = -1, verbose = FALSE), "whole number")
  expect_error(dp_simulate(n = 1, max_years = 0, verbose = FALSE),
               "whole number")
  expect_error(dp_stats("not a sim"), "dp_sim")
})
