# The conformance suite. Expected outcomes come from the Diplomacy Adjudicator
# Test Cases (DATC) by Lucas B. Kruijswijk, encoded under inst/extdata/datc.

test_that("the DATC cases are shipped and readable", {
  expect_true(nzchar(datc_file()))
  expect_true(nzchar(datc_file("datc_6h_6j.json")))
  expect_gt(length(datc_cases()), 100L)
})

test_that("every movement-phase DATC section is covered", {
  sections <- vapply(datc_cases(), function(x) x$section, character(1))
  expect_setequal(
    unique(sections),
    c("6.A", "6.B", "6.C", "6.D", "6.E", "6.F", "6.G")
  )
})

local({
  map <- dp_map()
  for (section in c("6.A", "6.B", "6.C", "6.D", "6.E", "6.F", "6.G")) {
    cases <- datc_cases(section)
    test_that(paste("DATC", section, "passes", length(cases), "cases"), {
      for (case in cases) expect_datc(case, map)
    })
  }
  for (section in c("6.H", "6.I", "6.J")) {
    cases <- datc_cases(section, file = "datc_6h_6j.json")
    test_that(paste("DATC", section, "passes", length(cases), "cases"), {
      for (case in cases) expect_datc(case, map)
    })
  }
})
