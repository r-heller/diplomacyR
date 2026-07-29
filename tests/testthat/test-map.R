test_that("the standard board has the documented shape", {
  m <- dp_map()
  expect_s3_class(m, "dp_map")
  expect_true(is_dp_map(m))
  prov <- dp_provinces(m)
  expect_equal(nrow(prov), 75L)
  expect_equal(sum(prov$type == "sea"), 19L)
  expect_equal(sum(prov$type %in% c("land", "coast")), 56L)
  expect_equal(sum(prov$supply_centre), 34L)
  expect_equal(nrow(m$start_units), 22L)
  expect_equal(length(m$powers), 7L)
})

test_that("army adjacency is symmetric and free of sea provinces", {
  m <- dp_map()
  seas <- m$provinces$code[m$provinces$type == "sea"]
  for (p in names(m$army_adj)) {
    nb <- m$army_adj[[p]]
    expect_false(any(nb %in% seas), info = p)
    for (q in nb) expect_true(p %in% m$army_adj[[q]], info = paste(p, q))
  }
})

test_that("fleet adjacency is symmetric and free of inland provinces", {
  m <- dp_map()
  inland <- m$provinces$code[m$provinces$type == "land"]
  for (l in names(m$fleet_adj)) {
    nb <- m$fleet_adj[[l]]
    expect_false(any(.province(nb) %in% inland), info = l)
    for (q in nb) expect_true(l %in% m$fleet_adj[[q]], info = paste(l, q))
  }
})

test_that("every split-coast province carries per-coast adjacency", {
  m <- dp_map()
  split <- names(m$coasts)[lengths(m$coasts) > 0L]
  expect_setequal(split, c("bul", "spa", "stp"))
  for (p in split) {
    expect_false(p %in% names(m$fleet_adj), info = p)
    for (l in .coasts_of(m, p)) {
      expect_true(l %in% names(m$fleet_adj), info = l)
      expect_gt(length(m$fleet_adj[[l]]), 0L)
    }
  }
})

test_that("the starting position sits in home supply centres", {
  m <- dp_map()
  su <- m$start_units
  hc <- dp_home_centres(m)
  expect_true(all(.province(su$loc) %in% hc$centre))
  for (i in seq_len(nrow(su))) {
    owner <- hc$power[match(.province(su$loc[i]), hc$centre)]
    expect_equal(su$power[i], owner)
  }
  expect_equal(nrow(hc), 22L)
})

test_that("accessors are type stable", {
  m <- dp_map()
  expect_s3_class(dp_provinces(m), "tbl_df")
  expect_equal(nrow(dp_provinces(m, "sea")), 19L)
  expect_s3_class(dp_supply_centres(m), "tbl_df")
  expect_equal(nrow(dp_supply_centres(m)), 34L)
  expect_type(dp_adjacent(m, "par", "army"), "character")
  expect_setequal(dp_adjacent(m, "par", "army"), c("bre", "bur", "gas", "pic"))
  expect_setequal(dp_adjacent(m, "spa/nc", "fleet"), c("gas", "mao", "por"))
  expect_equal(dp_adjacent(m, "adr", "army"), character(0))
  expect_equal(nrow(dp_home_centres(m, "France")), 3L)
})

test_that("unknown boards and provinces error informatively", {
  expect_error(dp_map("hasbro"), class = "rlang_error")
  expect_error(dp_adjacent(dp_map(), "zzz", "army"), "Unknown province")
})
