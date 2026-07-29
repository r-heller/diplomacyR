test_that("a quiet spring goes straight to autumn", {
  g <- dp_new_game()
  res <- dp_adjudicate(g, NULL)
  nxt <- dp_advance(g, res)
  expect_equal(nxt$season, "Fall")
  expect_equal(nxt$phase, "movement")
  expect_equal(nxt$year, 1901L)
})

test_that("a dislodgement inserts a retreat phase", {
  units <- data.frame(
    power = c("Germany", "Germany", "Russia"),
    type = c("army", "army", "army"),
    loc = c("ber", "sil", "pru"), stringsAsFactors = FALSE
  )
  g <- dp_game_from_units(units)
  res <- dp_adjudicate(g, c(
    "Germany: A Ber - Pru", "Germany: A Sil S A Ber - Pru", "Russia: A Pru H"
  ))
  nxt <- dp_advance(g, res)
  expect_equal(nxt$phase, "retreat")
  expect_equal(nxt$season, "Spring")
  expect_equal(nrow(nxt$dislodged), 1L)
  after <- dp_advance(nxt, dp_retreat(nxt, NULL))
  expect_equal(after$season, "Fall")
  expect_equal(after$phase, "movement")
})

test_that("a full year steps through every phase", {
  g <- dp_new_game()
  seen <- character(0)
  for (i in 1:8) {
    seen <- c(seen, paste(g$season, g$phase))
    g <- dp_step(g, bots = "hold")
    if (g$year > 1901L) break
  }
  expect_true("Spring movement" %in% seen)
  expect_true("Fall movement" %in% seen)
  expect_true("Winter build" %in% seen)
  expect_equal(g$year, 1902L)
  expect_equal(g$season, "Spring")
})

test_that("supply centres change hands only after the autumn", {
  g <- dp_new_game()
  before <- g$sc_owner
  g <- dp_step(g, "Germany: F Kie - Den", bots = "hold")
  expect_equal(g$season, "Fall")
  expect_true("den" %in% g$units$loc)
  expect_equal(g$sc_owner, before)
  g <- dp_step(g, NULL, bots = "hold")
  expect_equal(g$phase, "build")
  expect_equal(unname(g$sc_owner["den"]), "Germany")
})

test_that("dp_step fills missing orders with the chosen bot", {
  g <- dp_new_game()
  out <- dp_step(g, "France: A Par - Bur", bots = "hold")
  # One submitted order plus the nineteen units of the other six powers.
  expect_equal(nrow(out$last_orders), 20L)
  expect_true("bur" %in% out$units$loc)
})

test_that("dp_play records a history and terminates at the cap", {
  h <- dp_play(bots = "hold", max_years = 2)
  expect_s3_class(h, "dp_history")
  expect_true(is_dp_history(h))
  expect_gt(length(h), 0L)
  expect_equal(h$outcome, "draw")
  expect_s3_class(as_tibble(h), "tbl_df")
  expect_true(all(as_tibble(h)$year <= 1903L))
})

test_that("history coercion is type stable when empty", {
  h <- dp_history()
  tb <- as_tibble(h)
  expect_equal(nrow(tb), 0L)
  expect_equal(
    names(tb),
    c("turn", "season", "year", "phase", "power", "centres", "units")
  )
  expect_equal(length(h), 0L)
})
