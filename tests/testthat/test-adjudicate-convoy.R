pos <- function(...) {
  rows <- list(...)
  dp_game_from_units(do.call(rbind, lapply(rows, function(r) {
    data.frame(power = r[1], type = r[2], loc = r[3],
               stringsAsFactors = FALSE)
  })))
}

test_that("a simple convoy carries an army across a sea", {
  g <- pos(c("England", "fleet", "nth"), c("England", "army", "lon"))
  res <- dp_adjudicate(g, c(
    "England: F Nth C A Lon - Nwy", "England: A Lon - Nwy"
  ))
  expect_true(all(res$orders$success))
  expect_setequal(res$units$loc, c("nth", "nwy"))
})

test_that("a chain of fleets carries an army further", {
  g <- pos(c("England", "fleet", "eng"), c("England", "fleet", "mao"),
           c("England", "army", "lon"))
  res <- dp_adjudicate(g, c(
    "England: F Eng C A Lon - Por", "England: F Mao C A Lon - Por",
    "England: A Lon - Por"
  ))
  expect_true(all(res$orders$success))
  expect_true("por" %in% res$units$loc)
})

test_that("dislodging a convoying fleet disrupts the convoy", {
  g <- pos(c("England", "fleet", "nth"), c("England", "army", "lon"),
           c("Germany", "fleet", "ska"), c("Germany", "fleet", "den"))
  res <- dp_adjudicate(g, c(
    "England: F Nth C A Lon - Nwy", "England: A Lon - Nwy",
    "Germany: F Ska - Nth", "Germany: F Den S F Ska - Nth"
  ))
  expect_false(res$orders$success[res$orders$loc == "lon"])
  expect_equal(res$dislodged$loc, "nth")
  expect_true("lon" %in% res$units$loc)
})

test_that("an army ordered a convoy it cannot get is not helped by a hold support", {
  # There is a fleet at sea, so the order counts as an attempted convoy and
  # the army is not treated as holding.
  g <- pos(c("Austria", "fleet", "ion"), c("Austria", "army", "ser"),
           c("Austria", "army", "alb"), c("Turkey", "army", "gre"),
           c("Turkey", "army", "bul"))
  res <- dp_adjudicate(g, c(
    "Austria: F Ion H", "Austria: A Ser S A Alb - Gre", "Austria: A Alb - Gre",
    "Turkey: A Gre - Nap", "Turkey: A Bul S A Gre"
  ))
  expect_true(res$orders$success[res$orders$loc == "alb"])
  expect_equal(res$dislodged$loc, "gre")
})

test_that("with no fleet at sea the same order is simply impossible", {
  g <- pos(c("England", "fleet", "edi"), c("England", "army", "lvp"),
           c("France", "fleet", "lon"), c("Germany", "army", "yor"))
  res <- dp_adjudicate(g, c(
    "England: F Edi S A Lvp - Yor", "England: A Lvp - Yor",
    "France: F Lon S A Yor", "Germany: A Yor - Hol"
  ))
  expect_false(res$orders$success[res$orders$loc == "lvp"])
  expect_equal(nrow(res$dislodged), 0L)
})

test_that("two armies swap places when their own fleet convoys one of them", {
  g <- pos(c("England", "fleet", "ska"), c("England", "army", "nwy"),
           c("England", "army", "swe"))
  res <- dp_adjudicate(g, c(
    "England: F Ska C A Nwy - Swe", "England: A Nwy - Swe",
    "England: A Swe - Nwy"
  ))
  expect_true(res$orders$success[res$orders$loc == "nwy"])
  expect_true(res$orders$success[res$orders$loc == "swe"])
  expect_setequal(res$units$loc, c("ska", "swe", "nwy"))
})

test_that("a foreign convoy cannot commandeer an adjacent move", {
  g <- pos(c("England", "army", "nwy"), c("Russia", "fleet", "swe"),
           c("Germany", "fleet", "ska"))
  res <- dp_adjudicate(g, c(
    "England: A Nwy - Swe", "Russia: F Swe - Nwy",
    "Germany: F Ska C A Nwy - Swe"
  ))
  expect_false(res$orders$success[res$orders$loc == "nwy"])
  expect_false(res$orders$success[res$orders$loc == "swe"])
})

test_that("the convoy paradox leaves the convoying fleet in place", {
  g <- pos(c("England", "fleet", "lon"), c("England", "fleet", "wal"),
           c("France", "army", "bre"), c("France", "fleet", "eng"),
           c("Germany", "fleet", "nth"), c("Germany", "fleet", "bel"))
  res <- dp_adjudicate(g, c(
    "England: F Lon S F Wal - Eng", "England: F Wal - Eng",
    "France: A Bre - Lon", "France: F Eng C A Bre - Lon",
    "Germany: F Nth S F Bel - Eng", "Germany: F Bel - Eng"
  ))
  expect_equal(nrow(res$dislodged), 0L)
  expect_true("eng" %in% res$units$loc)
  expect_equal(res$units$power[res$units$loc == "eng"], "France")
})
