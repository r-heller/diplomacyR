test_that("a power builds in an open home centre", {
  g <- dp_example_game("build")
  res <- dp_build(g, "Germany: Build A Ber")
  expect_equal(res$phase, "build")
  expect_equal(nrow(res$built), 1L)
  expect_equal(res$built$loc, "ber")
  expect_true("ber" %in% res$units$loc)
})

test_that("builds outside owned, empty home centres fail", {
  g <- dp_example_game("build")
  res <- dp_build(g, c("Germany: Build A Par", "Germany: Build A Mun"))
  expect_false(any(res$orders$success[res$orders$type == "build"]))
  expect_equal(nrow(res$built), 0L)
})

test_that("only as many builds as centres are allowed", {
  g <- dp_example_game("build")
  delta <- .build_delta(g, "Germany")
  sites <- .build_sites(g, "Germany")
  expect_gt(delta, 0L)
  orders <- paste0("Germany: Build A ", toupper(sites))
  res <- dp_build(g, orders)
  expect_lte(nrow(res$built), delta)
})

test_that("a fleet cannot be built in an inland centre", {
  units <- data.frame(power = "Austria", type = "army", loc = "bud",
                      stringsAsFactors = FALSE)
  owner <- c(bud = "Austria", vie = "Austria", tri = "Austria")
  g <- dp_game_from_units(units, season = "Winter", phase = "build",
                          sc_owner = owner)
  res <- dp_build(g, c("Austria: Build F Vie", "Austria: Build A Vie"))
  expect_false(res$orders$success[1])
  expect_true(res$orders$success[2])
  expect_equal(res$built$type, "army")
})

test_that("a shortfall of disbands falls back on civil disorder", {
  g <- dp_example_game("build")
  expect_lt(.build_delta(g, "Russia"), 0L)
  res <- dp_build(g, NULL)
  disband <- res$orders[res$orders$power == "Russia", ]
  expect_true(any(disband$note == "civil disorder"))
  expect_equal(sum(res$units$power == "Russia"), 2L)
})

test_that("civil disorder removes the unit furthest from home", {
  units <- data.frame(
    power = "Russia", type = c("army", "army", "army", "army"),
    loc = c("mos", "stp", "lvn", "swe"), stringsAsFactors = FALSE
  )
  owner <- c(mos = "Russia", stp = "Russia", war = "Russia")
  g <- dp_game_from_units(units, season = "Winter", phase = "build",
                          sc_owner = owner)
  res <- dp_build(g, NULL)
  expect_equal(nrow(res$disbanded), 1L)
  expect_equal(res$disbanded$loc, "swe")
})

test_that("civil disorder prefers fleets at equal distance", {
  units <- data.frame(
    power = "France", type = c("army", "army", "fleet"),
    loc = c("par", "pic", "lyo"), stringsAsFactors = FALSE
  )
  owner <- c(par = "France", bre = "France")
  g <- dp_game_from_units(units, season = "Winter", phase = "build",
                          sc_owner = owner)
  res <- dp_build(g, NULL)
  expect_true("lyo" %in% res$disbanded$loc)
})

test_that("a waived build consumes the entitlement", {
  g <- dp_example_game("build")
  res <- dp_build(g, dp_parse_orders(c("Germany: Waive", "Germany: Waive",
                                       "Germany: Waive"), phase = "build"))
  expect_equal(nrow(res$built), 0L)
})

test_that("dp_build refuses other phases", {
  expect_error(dp_build(dp_new_game(), NULL), "adjustment phases")
})
