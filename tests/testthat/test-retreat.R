test_that("a dislodged unit retreats to an open province", {
  g <- dp_example_game("retreat")
  expect_equal(nrow(g$dislodged), 1L)
  res <- dp_retreat(g, "Austria: F Tri R Alb")
  expect_equal(res$phase, "retreat")
  expect_true("alb" %in% res$units$loc)
  expect_equal(nrow(res$disbanded), 0L)
})

test_that("a retreat to the attacker's province is refused", {
  g <- dp_example_game("retreat")
  res <- dp_retreat(g, "Austria: F Tri R Ven")
  expect_false(res$orders$success)
  expect_match(res$orders$note, "illegal retreat")
  expect_equal(nrow(res$disbanded), 1L)
})

test_that("a unit with no order disbands", {
  g <- dp_example_game("retreat")
  res <- dp_retreat(g, NULL)
  expect_false(res$orders$success)
  expect_equal(nrow(res$disbanded), 1L)
  expect_equal(res$disbanded$loc, "tri")
})

test_that("an explicit disband is honoured", {
  g <- dp_example_game("retreat")
  res <- dp_retreat(g, "Austria: Remove F Tri")
  expect_equal(res$orders$note, "disband ordered")
  expect_equal(nrow(res$disbanded), 1L)
})

test_that("colliding retreats disband both units", {
  units <- data.frame(
    power = c("Italy", "Italy"), type = c("army", "army"),
    loc = c("vie", "boh"), stringsAsFactors = FALSE
  )
  dislodged <- data.frame(
    power = c("Austria", "Austria"), type = c("army", "army"),
    loc = c("vie", "boh"), from = c("tri", "sil"),
    by_convoy = c(FALSE, FALSE), stringsAsFactors = FALSE
  )
  g <- dp_game_from_units(units, phase = "retreat", dislodged = dislodged)
  res <- dp_retreat(g, c("Austria: A Vie R Tyr", "Austria: A Boh R Tyr"))
  expect_equal(nrow(res$disbanded), 2L)
  expect_true(all(grepl("collide", res$orders$note)))
})

test_that("a contested province is closed to retreats", {
  units <- data.frame(power = "Italy", type = "army", loc = "vie",
                      stringsAsFactors = FALSE)
  dislodged <- data.frame(
    power = "Austria", type = "army", loc = "vie", from = "tri",
    by_convoy = FALSE, stringsAsFactors = FALSE
  )
  g <- dp_game_from_units(units, phase = "retreat", dislodged = dislodged,
                          contested = "tyr")
  expect_false("tyr" %in% .retreat_options(g, g$dislodged[1, ]))
  res <- dp_retreat(g, "Austria: A Vie R Tyr")
  expect_equal(nrow(res$disbanded), 1L)
})

test_that("dp_retreat refuses other phases", {
  expect_error(dp_retreat(dp_new_game(), NULL), "retreat phases")
})
