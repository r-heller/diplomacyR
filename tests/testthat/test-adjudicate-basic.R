pos <- function(...) {
  rows <- list(...)
  dp_game_from_units(do.call(rbind, lapply(rows, function(r) {
    data.frame(power = r[1], type = r[2], loc = r[3],
               stringsAsFactors = FALSE)
  })))
}

test_that("an unopposed move succeeds", {
  g <- pos(c("France", "army", "par"))
  res <- dp_adjudicate(g, "France: A Par - Bur")
  expect_s3_class(res, "dp_result")
  expect_true(is_dp_result(res))
  expect_true(res$orders$success)
  expect_equal(res$units$loc, "bur")
  expect_equal(nrow(res$dislodged), 0L)
})

test_that("equal strength bounces and marks the province contested", {
  g <- pos(c("France", "army", "par"), c("Germany", "army", "mun"))
  res <- dp_adjudicate(g, c("France: A Par - Bur", "Germany: A Mun - Bur"))
  expect_false(any(res$orders$success))
  expect_setequal(res$units$loc, c("par", "mun"))
  expect_equal(res$contested, "bur")
})

test_that("units without orders hold", {
  g <- pos(c("France", "army", "par"))
  res <- dp_adjudicate(g, NULL)
  expect_equal(res$orders$type, "hold")
  expect_equal(res$orders$note, "no order (holds)")
  expect_equal(res$units$loc, "par")
})

test_that("illegal orders are downgraded to a hold", {
  g <- pos(c("Germany", "fleet", "kie"))
  res <- dp_adjudicate(g, "Germany: F Kie - Mun")
  expect_equal(res$orders$type, "hold")
  expect_match(res$orders$note, "illegal move")
  expect_equal(res$units$loc, "kie")
})

test_that("two units may not swap places overland", {
  g <- pos(c("France", "army", "par"), c("Germany", "army", "bur"))
  res <- dp_adjudicate(g, c("France: A Par - Bur", "Germany: A Bur - Par"))
  expect_false(any(res$orders$success))
  expect_setequal(res$units$loc, c("par", "bur"))
})

test_that("a circular movement resolves in favour of every mover", {
  g <- pos(c("Turkey", "fleet", "ank"), c("Turkey", "army", "con"),
           c("Turkey", "army", "smy"))
  res <- dp_adjudicate(g, c(
    "Turkey: F Ank - Con", "Turkey: A Con - Smy", "Turkey: A Smy - Ank"
  ))
  expect_true(all(res$orders$success))
  expect_setequal(res$units$loc, c("con", "smy", "ank"))
})

test_that("a power cannot dislodge its own unit", {
  g <- pos(c("Germany", "army", "ber"), c("Germany", "army", "mun"),
           c("Germany", "army", "sil"))
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Mun", "Germany: A Mun H", "Germany: A Sil S A Ber - Mun"
  ))
  expect_false(res$orders$success[res$orders$loc == "ber"])
  expect_equal(nrow(res$dislodged), 0L)
})

test_that("dp_adjudicate refuses non-movement phases", {
  expect_error(dp_adjudicate(dp_example_game("retreat"), NULL),
               "movement phases")
  expect_error(dp_adjudicate("not a game", NULL), "dp_game")
})

test_that("the result reports the phase it resolved", {
  g <- dp_new_game()
  res <- dp_adjudicate(g, dp_example_orders("spring_1901"))
  expect_equal(res$season, "Spring")
  expect_equal(res$year, 1901L)
  expect_equal(res$phase, "movement")
  expect_equal(nrow(res$orders), 22L)
})
