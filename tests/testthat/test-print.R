test_that("S3 print methods run and return their input invisibly", {
  m <- dp_map()
  g <- dp_new_game()
  o <- dp_example_orders()
  res <- dp_adjudicate(g, o)
  h <- dp_play(bots = "hold", max_years = 2)
  sim <- dp_simulate(n = 1, bots = "hold", max_years = 2, seed = 1,
                     verbose = FALSE)

  for (x in list(m, g, o, res, h, sim)) {
    expect_invisible(print(x))
    expect_type(format(x), "character")
  }
})

test_that("summary methods return tibbles", {
  g <- dp_new_game()
  expect_s3_class(summary(g), "tbl_df")
  expect_s3_class(summary(dp_example_orders()), "tbl_df")
  expect_s3_class(summary(dp_adjudicate(g, dp_example_orders())), "tbl_df")
  h <- dp_play(bots = "hold", max_years = 2)
  expect_s3_class(summary(h), "tbl_df")
  sim <- dp_simulate(n = 1, bots = "hold", max_years = 2, seed = 1,
                     verbose = FALSE)
  expect_s3_class(summary(sim), "tbl_df")
})

test_that("empty orders print without error", {
  expect_invisible(print(dp_bind_orders()))
  expect_equal(format(dp_bind_orders()), character(0))
})

test_that("predicates identify their classes", {
  expect_true(is_dp_map(dp_map()))
  expect_true(is_dp_game(dp_new_game()))
  expect_true(is_dp_orders(dp_example_orders()))
  expect_true(is_dp_history(dp_history()))
  expect_false(is_dp_game(dp_map()))
  expect_false(is_dp_sim(dp_map()))
})

test_that("coercers produce plain tibbles", {
  o <- dp_example_orders()
  tb <- as_tibble(o)
  expect_s3_class(tb, "tbl_df")
  expect_false(inherits(tb, "dp_orders"))
  expect_equal(nrow(tb), nrow(o))
})

test_that("game construction validates its input", {
  expect_error(
    dp_game_from_units(data.frame(power = c("France", "Germany"),
                                  type = c("army", "army"),
                                  loc = c("par", "par"))),
    "More than one unit"
  )
  expect_error(
    dp_game_from_units(data.frame(power = "France", type = "army",
                                  loc = "nth")),
    "cannot occupy the sea"
  )
  expect_error(
    dp_game_from_units(data.frame(power = "France", type = "fleet",
                                  loc = "par")),
    "cannot occupy the inland"
  )
  expect_error(
    dp_game_from_units(data.frame(power = "Russia", type = "fleet",
                                  loc = "stp")),
    "must name a coast"
  )
  expect_error(dp_game_from_units(data.frame(x = 1)), "missing column")
})

test_that("dp_unit normalises locations", {
  u <- dp_unit("Russia", "fleet", "stp/sc")
  expect_equal(u$loc, "stp/sc")
  expect_equal(dp_unit("France", "army", "PAR")$loc, "par")
  expect_equal(dp_unit("Italy", "fleet", "nap")$loc, "nap")
  expect_error(dp_unit("France", "army", "zzz"), "Unknown province")
})

test_that("example data is coherent", {
  for (state in c("opening", "midgame", "retreat", "build", "solo")) {
    g <- dp_example_game(state)
    expect_s3_class(g, "dp_game")
  }
  for (phase in c("spring_1901", "fall_1901", "retreat", "build")) {
    o <- dp_example_orders(phase)
    expect_s3_class(o, "dp_orders")
    expect_gt(nrow(o), 0L)
  }
  expect_equal(nrow(dp_example_orders("spring_1901")), 22L)
})

test_that("the app launcher is documented and guarded", {
  expect_true(is.function(dp_run_app))
  expect_true(nzchar(system.file("shiny", "diplomacyR", "app.R",
                                 package = "diplomacyR")))
})
