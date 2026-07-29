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
      shiny::actionButton(ns("run"), "Run simulation",
                          class = "btn-primary w-100")
    ),
    bslib::layout_columns(
      col_widths = c(6, 6, 12),
      bslib::card(
        bslib::card_header("Solo win rate"),
        shiny::plotOutput(ns("winrates"), height = "340px")
      ),
      bslib::card(
        bslib::card_header("Where the fighting happens"),
        shiny::plotOutput(ns("heatmap"), height = "340px")
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

    output$winrates <- shiny::renderPlot({
      s <- sim()
      if (is.null(s)) return(dp_placeholder_plot("Run a simulation"))
      diplomacyR::dp_plot_winrates(s)
    })

    output$heatmap <- shiny::renderPlot({
      s <- sim()
      if (is.null(s)) return(dp_placeholder_plot("Run a simulation"))
      diplomacyR::dp_plot_supply_heatmap(s)
    })

    output$stats <- DT::renderDT({
      s <- sim()
      shiny::req(s)
      DT::datatable(
        as.data.frame(diplomacyR::dp_stats(s, "power")), rownames = FALSE,
        options = list(pageLength = 8, dom = "t")
      )
    })
  })
}
