pos <- function(...) {
  rows <- list(...)
  dp_game_from_units(do.call(rbind, lapply(rows, function(r) {
    data.frame(power = r[1], type = r[2], loc = r[3],
               stringsAsFactors = FALSE)
  })))
}

test_that("support turns a bounce into a dislodgement", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "sil"),
           c("Russia", "army", "pru"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Sil S A Ber - Pru", "Russia: A Pru H"
  ))
  expect_true(res$orders$success[res$orders$loc == "ber"])
  expect_equal(res$dislodged$loc, "pru")
  expect_equal(res$dislodged$from, "ber")
})

test_that("support is cut by an attack from a third province", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "sil"),
           c("Russia", "army", "pru"), c("Russia", "army", "boh"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Sil S A Ber - Pru",
    "Russia: A Pru H", "Russia: A Boh - Sil"
  ))
  expect_false(res$orders$success[res$orders$loc == "sil"])
  expect_false(res$orders$success[res$orders$loc == "ber"])
  expect_equal(nrow(res$dislodged), 0L)
})

test_that("support is not cut from the province it is directed into", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "sil"),
           c("Russia", "army", "pru"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Sil S A Ber - Pru",
    "Russia: A Pru - Sil"
  ))
  expect_true(res$orders$success[res$orders$loc == "sil"])
  expect_true(res$orders$success[res$orders$loc == "ber"])
})

test_that("an attack by the same power does not cut support", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "sil"),
           c("Germany", "army", "boh"), c("Russia", "army", "pru"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Sil S A Ber - Pru",
    "Germany: A Boh - Sil", "Russia: A Pru H"
  ))
  expect_true(res$orders$success[res$orders$loc == "sil"])
  expect_equal(res$dislodged$loc, "pru")
})

test_that("support cannot help dislodge a unit of the supporter's power", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "pru"),
           c("Russia", "army", "sil"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Pru H", "Russia: A Sil S A Ber - Pru"
  ))
  expect_false(res$orders$success[res$orders$loc == "ber"])
  expect_equal(nrow(res$dislodged), 0L)
})

test_that("support to an unreachable province is void", {
  g <- pos(c("Austria", "fleet", "tri"), c("Austria", "army", "bud"),
           c("Russia", "army", "gal"), c("Russia", "army", "rum"))
  res <- dp_adjudicate(g, c(
    "Austria: F Tri S A Bud", "Austria: A Bud H",
    "Russia: A Gal - Bud", "Russia: A Rum S A Gal - Bud"
  ))
  expect_equal(res$orders$type[res$orders$loc == "tri"], "hold")
  expect_equal(res$dislodged$loc, "bud")
})

test_that("support of a hold is void once the unit is ordered to move", {
  g <- pos(c("Austria", "army", "bud"), c("Austria", "army", "vie"),
           c("Russia", "army", "gal"), c("Russia", "army", "rum"))
  res <- dp_adjudicate(g, c(
    "Austria: A Bud - Ser", "Austria: A Vie S A Bud",
    "Russia: A Gal - Bud", "Russia: A Rum S A Gal - Bud"
  ))
  expect_true(res$orders$success[res$orders$loc == "gal"])
})

test_that("a beleaguered garrison survives two equal attacks", {
  g <- pos(c("England", "fleet", "nth"), c("England", "fleet", "yor"),
           c("Germany", "fleet", "hol"), c("Germany", "fleet", "hel"),
           c("Russia", "fleet", "ska"), c("Russia", "fleet", "nwy"))
  res <- dp_adjudicate(g, c(
    "England: F Nth H", "England: F Yor S F Nth",
    "Germany: F Hol - Nth", "Germany: F Hel S F Hol - Nth",
    "Russia: F Ska - Nth", "Russia: F Nwy S F Ska - Nth"
  ))
  expect_equal(nrow(res$dislodged), 0L)
  expect_true("nth" %in% res$units$loc)
})
