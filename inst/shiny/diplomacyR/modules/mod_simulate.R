# Tab 6 - batch simulation -----------------------------------------------------

mod_simulate_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 320,
      shiny::numericInput(ns("n"), "Games", value = 5, min = 1, max = 200,
                          step = 1),
      shiny::numericInput(ns("years"), "Turn cap (years)", value = 5, min = 1,
                          max = 30, step = 1),
      shiny::numericInput(ns("seed"), "Seed", value = 1, min = 1, step = 1),
      shiny::hr(),
      shiny::helpText("Bot for each power"),
      lapply(.dp_powers, function(p) {
        shiny::selectInput(ns(paste0("bot_", p)), p, choices = .dp_bots,
                           selected = "greedy")
      }),
      shiny::div(
        class = "dp-sticky-action",
        shiny::actionButton(ns("run"), "Run simulation",
                            class = "btn-primary w-100")
      )
    ),
    # The win-rate bars want a wide, short panel; the standoff map is square and
    # needs a narrow, tall one, or coord_equal shrinks it to a thumbnail.
    bslib::layout_columns(
      col_widths = c(7, 5, 12),
      bslib::card(
        bslib::card_header("Solo win rate"),
        shiny::plotOutput(ns("winrates"), height = "440px")
      ),
      bslib::card(
        bslib::card_header("Where the fighting happens"),
        shiny::plotOutput(ns("heatmap"), height = "620px")
      ),
      bslib::card(
        bslib::card_header("Statistics"),
        DT::DTOutput(ns("stats"))
      )
    )
  )
}

mod_simulate_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    sim <- shiny::eventReactive(input$run, {
      bots <- vapply(.dp_powers,
                     function(p) input[[paste0("bot_", p)]] %||% "greedy",
                     character(1))
      names(bots) <- .dp_powers
      shiny::withProgress(message = "Simulating games", value = 0.2, {
        tryCatch(
          diplomacyR::dp_simulate(
            n = max(1L, as.integer(input$n)),
            bots = bots,
            max_years = max(1L, as.integer(input$years)),
            seed = as.integer(input$seed),
            verbose = FALSE
          ),
          error = function(e) {
            state$message <- conditionMessage(e)
            NULL
          }
        )
      })
    })

    # `sim()` is an eventReactive, so reading it before the button has ever been
    # pressed aborts the observer silently and leaves the panel blank. Each
    # output therefore checks the button first and draws a prompt instead.
    not_yet <- function() is.null(input$run) || input$run == 0L

    output$winrates <- shiny::renderPlot({
      if (not_yet()) {
        return(dp_placeholder_plot(
          "Choose the bots and the number of games,\nthen press Run simulation."
        ))
      }
      s <- sim()
      if (is.null(s)) return(dp_placeholder_plot("That simulation failed"))
      diplomacyR::dp_plot_winrates(s)
    })

    output$heatmap <- shiny::renderPlot({
      if (not_yet()) {
        return(dp_placeholder_plot(
          "Standoffs across the simulated games\nwill be mapped here."
        ))
      }
      s <- sim()
      if (is.null(s)) return(dp_placeholder_plot("That simulation failed"))
      diplomacyR::dp_plot_supply_heatmap(s)
    })

    output$stats <- DT::renderDT({
      if (not_yet()) {
        return(dp_table(data.frame(), empty = "No simulation has been run yet"))
      }
      s <- sim()
      shiny::req(s)
      dp_table(diplomacyR::dp_stats(s, "power"),
               empty = "No simulation has been run yet")
    })
  })
}
