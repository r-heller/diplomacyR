# Tab 4 - replay ---------------------------------------------------------------

mod_history_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::uiOutput(ns("scrubber")),
      shiny::helpText(
        "Drag the scrubber to replay the board as it stood before each ",
        "recorded turn."
      )
    ),
    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        bslib::card_header("Board at this turn"),
        shiny::plotOutput(ns("map"), height = "680px")
      ),
      bslib::card(
        bslib::card_header("Orders of this turn"),
        DT::DTOutput(ns("orders"))
      )
    )
  )
}

mod_history_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    output$scrubber <- shiny::renderUI({
      n <- length(state$history %||% diplomacyR::dp_history())
      if (n == 0L) return(shiny::helpText("No turns recorded yet."))
      shiny::sliderInput(session$ns("turn"), "Turn", min = 1L, max = n,
                         value = n, step = 1L, ticks = FALSE)
    })

    turn <- shiny::reactive({
      h <- state$history
      shiny::req(h, length(h) > 0L, input$turn)
      h$turns[[min(input$turn, length(h))]]
    })

    output$map <- shiny::renderPlot({
      tn <- turn()
      shiny::req(tn)
      snapshot <- tryCatch(
        diplomacyR::dp_game_from_units(
          tn$units, season = tn$season, year = tn$year,
          phase = if (tn$phase == "retreat") "movement" else tn$phase,
          sc_owner = tn$sc_owner
        ),
        error = function(e) NULL
      )
      if (is.null(snapshot)) return(dp_placeholder_plot("Cannot replay turn"))
      diplomacyR::dp_plot_map(
        snapshot,
        title = paste("Replay -", tn$season, tn$year, tn$phase)
      )
    })

    output$orders <- DT::renderDT({
      tn <- turn()
      empty <- "Resolve a turn to build a history"
      if (is.null(tn)) return(dp_table(data.frame(), empty = empty))
      dp_table(dp_orders_table(tn$result$orders), page = 12L, empty = empty)
    })
  })
}
