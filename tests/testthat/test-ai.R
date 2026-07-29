bots <- c("random", "hold", "greedy", "negotiator")

order_key <- function(o) {
  paste(o$power, o$type, o$unit_type, o$loc, o$target, o$aux_type, o$aux_loc,
        o$aux_target, o$via_convoy)
}

test_that("every bot emits only legal movement orders", {
  set.seed(42)
  g <- dp_new_game()
  for (bot in bots) {
    for (power in g$powers) {
      o <- dp_ai_orders(g, power, bot = bot)
      expect_s3_class(o, "dp_orders")
      expect_true(all(o$power == power), info = bot)
      legal <- dp_legal_orders(g, power)
      expect_true(all(order_key(o) %in% order_key(legal)),
                  info = paste(bot, power))
      expect_equal(nrow(o), sum(g$units$power == power), info = bot)
      expect_false(anyDuplicated(o$loc) > 0L, info = bot)
    }
  }
})

test_that("every bot emits only legal retreat orders", {
  set.seed(7)
  g <- dp_example_game("retreat")
  for (bot in bots) {
    o <- dp_ai_orders(g, "Austria", bot = bot)
    legal <- dp_legal_orders(g, "Austria")
    expect_true(all(order_key(o) %in% order_key(legal)), info = bot)
    expect_lte(nrow(o), nrow(g$dislodged))
  }
})

test_that("every bot respects the build entitlement", {
  set.seed(11)
  g <- dp_example_game("build")
  for (bot in bots) {
    b <- dp_ai_orders(g, "Germany", bot = bot)
    expect_lte(sum(b$type == "build"), .build_delta(g, "Germany"), label = bot)
    if (nrow(b) > 0L) {
      expect_true(all(.province(b$loc[b$type == "build"]) %in%
                        .build_sites(g, "Germany")), info = bot)
    }
    d <- dp_ai_orders(g, "Russia", bot = bot)
    expect_lte(nrow(d), abs(.build_delta(g, "Russia")), label = bot)
  }
})

test_that("bot orders adjudicate without error", {
  set.seed(3)
  g <- dp_new_game()
  for (bot in bots) {
    orders <- dp_ai_all(g, bots = bot)
    expect_equal(nrow(orders), 22L, info = bot)
    res <- dp_adjudicate(g, orders)
    expect_s3_class(res, "dp_result")
  }
})

test_that("the hold bot holds", {
  g <- dp_new_game()
  o <- dp_ai_orders(g, "Italy", bot = "hold")
  expect_true(all(o$type == "hold"))
})

test_that("bot specifications expand", {
  powers <- dp_map()$powers
  expect_equal(unname(.expand_bots("greedy", powers)), rep("greedy", 7L))
  mixed <- .expand_bots(c(France = "random"), powers)
  expect_equal(unname(mixed[["France"]]), "random")
  expect_equal(unname(mixed[["Italy"]]), "greedy")
  expect_error(.expand_bots(1L, powers), "character vector")
})

test_that("unknown bots are rejected", {
  expect_error(dp_ai_orders(dp_new_game(), "France", bot = "napoleon"),
               class = "rlang_error")
})
