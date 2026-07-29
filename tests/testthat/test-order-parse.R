test_that("every notation form parses", {
  o <- dp_parse_orders(c(
    "France: A Par - Bur",
    "France: A Bur H",
    "England: F Lon S A Wal - Yor",
    "England: F Lon S A Wal",
    "England: F Nth C A Lon - Nwy",
    "England: A Lon - Bel via convoy",
    "Austria: A Tri R Alb",
    "Germany: Build A Ber",
    "Germany: Remove F Kie",
    "Italy: Waive"
  ))
  expect_s3_class(o, "dp_orders")
  expect_equal(nrow(o), 10L)
  expect_equal(
    o$type,
    c("move", "hold", "support", "support", "convoy", "move", "retreat",
      "build", "disband", "waive")
  )
  expect_true(o$via_convoy[6])
  expect_equal(o$aux_target[3], "yor")
  expect_true(is.na(o$aux_target[4]))
})

test_that("alternative spellings and full names parse the same way", {
  a <- dp_parse_orders("France: A Par-Bur")
  b <- dp_parse_orders("France: a paris to burgundy")
  c <- dp_parse_orders("FRANCE: A PAR - BUR")
  expect_equal(a$loc, b$loc)
  expect_equal(a$target, b$target)
  expect_equal(a$target, c$target)

  s1 <- dp_parse_orders("England: F Lon Supports A Wal - Yor")
  s2 <- dp_parse_orders("England: F lon s a wal-yor")
  expect_equal(s1$aux_loc, s2$aux_loc)
  expect_equal(s1$aux_target, s2$aux_target)
})

test_that("coasts parse in either notation", {
  a <- dp_parse_orders("Russia: F Stp/sc - Bot")
  b <- dp_parse_orders("Russia: F Stp(sc) - Bot")
  expect_equal(a$loc, "stp/sc")
  expect_equal(a$loc, b$loc)
  expect_equal(a$target, "bot")
})

test_that("the power prefix is optional when power is supplied", {
  o <- dp_parse_orders("A Par - Bur", power = "France")
  expect_equal(o$power, "France")
  expect_error(dp_parse_orders("A Par - Bur"), "No power given")
})

test_that("format round-trips through the parser", {
  txt <- c(
    "France: A Par - Bur",
    "France: A Bur H",
    "England: F Lon S A Wal - Yor",
    "England: F Lon S A Wal",
    "England: F Nth C A Lon - Nwy",
    "England: A Lon - Bel via Convoy",
    "Austria: A Tri R Alb",
    "Russia: F Stp/sc - Bot",
    "Germany: Build A Ber",
    "Germany: Remove F Kie",
    "Italy: Waive"
  )
  o <- dp_parse_orders(txt)
  expect_equal(format(o), txt)
  expect_equal(as.character(o), txt)
  again <- dp_parse_orders(format(o))
  expect_equal(as_tibble(again), as_tibble(o))
})

test_that("malformed input aborts with an actionable message", {
  expect_error(dp_parse_orders("France: A Par >> Bur"), "Could not parse")
  expect_error(dp_parse_orders("France: A Zzz - Bur"), "not a province")
  expect_error(dp_parse_orders("Freedonia: A Par - Bur"), "Unknown power")
  expect_error(dp_parse_orders(42), "must be a character vector")
})

test_that("dp_order builds one row per order", {
  o <- dp_order("France", "move", "par", target = "bur")
  expect_equal(nrow(o), 1L)
  expect_equal(format(o), "France: A Par - Bur")
  s <- dp_order("England", "support", "lon", aux = c("wal", "yor"))
  expect_equal(s$aux_loc, "wal")
  expect_equal(s$aux_target, "yor")
  c1 <- dp_order("England", "convoy", "nth", aux = "lon-nwy")
  expect_equal(c1$aux_target, "nwy")
  expect_error(dp_order("France", "move", "par"), "target")
  expect_error(dp_order("France", "support", "par"), "aux")
  expect_error(dp_order("France", "teleport", "par"), class = "rlang_error")
})

test_that("orders bind and stay type stable", {
  a <- dp_order("France", "move", "par", target = "bur")
  b <- dp_order("France", "hold", "mar")
  both <- dp_bind_orders(a, b)
  expect_equal(nrow(both), 2L)
  expect_equal(names(both), names(dp_bind_orders()))
  expect_equal(nrow(dp_bind_orders()), 0L)
  expect_true(is_dp_orders(both))
})

test_that("dp_legal_orders never offers an illegal order", {
  g <- dp_new_game()
  lo <- dp_legal_orders(g, "France")
  expect_s3_class(lo, "dp_orders")
  expect_gt(nrow(lo), 0L)
  expect_true(all(lo$power == "France"))
  expect_true(all(.province(lo$loc) %in% .province(g$units$loc)))

  moves <- lo[lo$type == "move", ]
  for (i in seq_len(nrow(moves))) {
    if (isTRUE(moves$via_convoy[i])) next
    expect_true(
      moves$target[i] %in% dp_adjacent(g$map, moves$loc[i],
                                       moves$unit_type[i]),
      info = format(moves[i, ])
    )
  }
  # No order refers to an empty province as the supported unit.
  sup <- lo[lo$type == "support", ]
  expect_true(all(sup$aux_loc %in% .province(g$units$loc)))
})

test_that("legal orders adapt to the phase", {
  r <- dp_legal_orders(dp_example_game("retreat"), "Austria")
  expect_true(all(r$type %in% c("retreat", "disband")))
  b <- dp_legal_orders(dp_example_game("build"), "Germany")
  expect_true(all(b$type %in% c("build", "waive")))
})
