# Tab 5 - analysis -------------------------------------------------------------

mod_analysis_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_columns(
    col_widths = c(12, 6, 6),
    bslib::card(
      bslib::card_header("Supply centres over the game"),
      shiny::plotOutput(ns("sc"), height = "360px")
    ),
    bslib::card(
      bslib::card_header("Power summary"),
      DT::DTOutput(ns("powers"))
    ),
    bslib::card(
      bslib::card_header("Current standing"),
      DT::DTOutput(ns("standing"))
    )
  )
}

mod_analysis_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    output$sc <- shiny::renderPlot({
      h <- state$history
      if (is.null(h) || length(h) == 0L) {
        return(dp_placeholder_plot("Resolve a turn to build a history"))
      }
      tryCatch(
        diplomacyR::dp_plot_sc_history(h),
        error = function(e) dp_placeholder_plot(conditionMessage(e))
      )
    })

    output$powers <- DT::renderDT({
      h <- state$history
      # `req()` here left the card completely blank until a turn was resolved.
      # An empty table with a message at least says why it is empty.
      empty <- "Resolve a turn to build a history"
      if (is.null(h) || length(h) == 0L) {
        return(dp_table(data.frame(), empty = empty))
      }
      dp_table(diplomacyR::dp_power_summary(h), empty = empty)
    })

    output$standing <- DT::renderDT({
      shiny::req(state$game)
      dp_table(diplomacyR::dp_power_summary(state$game),
               empty = "No game loaded")
    })
  })
}
