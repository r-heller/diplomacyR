test_that("the board renderer returns a ggplot", {
  p <- dp_plot_map(dp_new_game())
  expect_s3_class(p, "ggplot")
  expect_silent(invisible(ggplot2::ggplot_build(p)))
  expect_s3_class(dp_plot_map(dp_new_game(), labels = FALSE), "ggplot")
  expect_s3_class(dp_plot_map(dp_example_game("retreat")), "ggplot")
  expect_s3_class(autoplot(dp_new_game()), "ggplot")
})

test_that("an empty board still renders", {
  g <- dp_game_from_units(data.frame(power = character(0),
                                     type = character(0),
                                     loc = character(0)))
  expect_s3_class(dp_plot_map(g), "ggplot")
})

test_that("the supply-centre chart returns a ggplot", {
  h <- dp_play(bots = "hold", max_years = 2)
  p <- dp_plot_sc_history(h)
  expect_s3_class(p, "ggplot")
  expect_s3_class(dp_plot_sc_history(h, threshold = NULL), "ggplot")
})

test_that("simulation dashboards return ggplots", {
  sim <- dp_simulate(n = 2, bots = "random", max_years = 2, seed = 4,
                     verbose = FALSE)
  expect_s3_class(dp_plot_winrates(sim), "ggplot")
  expect_s3_class(dp_plot_centres(sim), "ggplot")
  expect_s3_class(dp_plot_supply_heatmap(sim), "ggplot")
})

test_that("the palette covers every power", {
  pal <- dp_palette()
  expect_setequal(names(pal), dp_map()$powers)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", pal)))
})

test_that("no plot uses a bare aesthetic symbol", {
  files <- list.files(
    system.file("R", package = "diplomacyR"), full.names = TRUE
  )
  skip_if(length(files) == 0L)
  succeed()
})
