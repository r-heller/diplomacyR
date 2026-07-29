test_that("a fresh game has no winner", {
  vc <- dp_victory_check(dp_new_game())
  expect_true(is.na(vc$winner))
  expect_false(vc$over)
  expect_length(vc$survivors, 7L)
  expect_s3_class(vc$counts, "tbl_df")
})

test_that("eighteen centres is a solo victory", {
  g <- dp_example_game("solo")
  vc <- dp_victory_check(g)
  expect_equal(vc$winner, "Germany")
  expect_equal(vc$outcome, "solo")
  expect_true(vc$over)
})

test_that("the threshold is configurable", {
  g <- dp_new_game()
  vc <- dp_victory_check(g, threshold = 4L)
  expect_equal(vc$winner, "Russia")
})

test_that("a lone survivor wins", {
  units <- data.frame(power = "Italy", type = "army", loc = "rom",
                      stringsAsFactors = FALSE)
  g <- dp_game_from_units(units, sc_owner = c(rom = "Italy"))
  vc <- dp_victory_check(g)
  expect_equal(vc$winner, "Italy")
  expect_true(vc$over)
})

test_that("counts reconcile with the board", {
  g <- dp_new_game()
  counts <- dp_power_counts(g)
  expect_equal(sum(counts$units), 22L)
  expect_equal(sum(counts$centres), 22L)
  expect_true(all(counts$delta == 0L))
  expect_equal(nrow(dp_supply_centres(g)), 34L)
  expect_equal(sum(!is.na(dp_supply_centres(g)$owner)), 22L)
})
