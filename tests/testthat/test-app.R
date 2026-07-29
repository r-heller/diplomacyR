app_dir <- system.file("shiny", "diplomacyR", package = "diplomacyR")

test_that("the application is installed with its modules and assets", {
  skip_if(!nzchar(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(file.exists(file.path(app_dir, "global.R")))
  expect_true(file.exists(file.path(app_dir, "www", "custom.css")))
  expect_true(file.exists(file.path(app_dir, "www", "logo.png")))
  mods <- list.files(file.path(app_dir, "modules"), pattern = "[.]R$")
  expect_setequal(
    mods,
    c("mod_adjudicate.R", "mod_analysis.R", "mod_board.R", "mod_help.R",
      "mod_history.R", "mod_orders.R", "mod_simulate.R")
  )
})

test_that("no application file calls library() or require()", {
  skip_if(!nzchar(app_dir))
  files <- list.files(app_dir, pattern = "[.]R$", recursive = TRUE,
                      full.names = TRUE)
  for (f in files) {
    txt <- readLines(f, warn = FALSE)
    expect_false(any(grepl("^\\s*(library|require)\\s*\\(", txt)), info = f)
  }
})

test_that("the accent colour reaches the stylesheet", {
  skip_if(!nzchar(app_dir))
  css <- readLines(file.path(app_dir, "www", "custom.css"), warn = FALSE)
  expect_true(any(grepl("#5E2C8E", css, fixed = TRUE)))
})

test_that("app.R and every module source in a clean session", {
  skip_if(!nzchar(app_dir))
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("DT")
  skip_if_not_installed("withr")

  withr::with_dir(app_dir, {
    env <- new.env(parent = globalenv())
    expect_no_error(source("global.R", local = env))
    for (f in list.files("modules", pattern = "[.]R$", full.names = TRUE)) {
      expect_no_error(source(f, local = env))
    }
    for (m in c("board", "orders", "adjudicate", "history", "analysis",
                "simulate", "help")) {
      ui <- get(paste0("mod_", m, "_ui"), envir = env)(m)
      expect_true(inherits(ui, "shiny.tag") || inherits(ui, "shiny.tag.list") ||
                    inherits(ui, "bslib_fragment"), info = m)
      expect_true(is.function(get(paste0("mod_", m, "_server"), envir = env)))
    }
    app <- source("app.R", local = new.env(parent = globalenv()))$value
    expect_s3_class(app, "shiny.appobj")
  })
})

test_that("the app plays a phase through its adjudicate module", {
  skip_if(!nzchar(app_dir))
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("DT")
  skip_if_not_installed("withr")

  withr::with_dir(app_dir, {
    env <- new.env(parent = globalenv())
    source("global.R", local = env)
    for (f in list.files("modules", pattern = "[.]R$", full.names = TRUE)) {
      source(f, local = env)
    }
    state <- shiny::reactiveValues(
      game = dp_example_game(), orders = NULL, result = NULL,
      history = dp_history(), message = NULL
    )
    shiny::testServer(
      get("mod_adjudicate_server", envir = env),
      args = list(id = "adjudicate", state = state),
      {
        session$setInputs(bot = "hold", resolve = 1)
        expect_equal(state$game$season, "Fall")
        expect_equal(length(state$history), 1L)
        expect_s3_class(state$result, "dp_result")
      }
    )
  })
})
