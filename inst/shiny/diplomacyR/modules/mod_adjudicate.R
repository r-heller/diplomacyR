# Tab 3 - resolve the turn -----------------------------------------------------

mod_adjudicate_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::selectInput(ns("bot"), "Bot for powers with no orders",
                         choices = .dp_bots),
      shiny::actionButton(ns("resolve"), "Resolve and advance",
                          class = "btn-primary w-100"),
      shiny::hr(),
      shiny::helpText(
        "Resolving fills in any missing orders with the chosen bot, ",
        "adjudicates the phase and steps the season/phase machine."
      ),
      shiny::verbatimTextOutput(ns("summary"))
    ),
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card(
        bslib::card_header("Board after the phase"),
        shiny::plotOutput(ns("map"), height = "680px")
      ),
      bslib::card(
        bslib::card_header("Order results"),
        DT::DTOutput(ns("results"))
      )
    )
  )
}

mod_adjudicate_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(input$resolve, {
      shiny::req(state$game)
      before <- state$game
      out <- tryCatch(
        diplomacyR::dp_step(before, orders = state$orders, bots = input$bot),
        error = function(e) {
          state$message <- conditionMessage(e)
          NULL
        }
      )
      shiny::req(out)
      state$history <- diplomacyR::dp_history_append(
        state$history %||% diplomacyR::dp_history(), before,
        out$last_orders, out$last_result
      )
      state$result <- out$last_result
      state$game <- out
      state$orders <- NULL
      state$message <- paste("Resolved", before$season, before$year,
                             before$phase)
    })

    output$map <- shiny::renderPlot({
      shiny::req(state$game)
      tryCatch(
        diplomacyR::dp_plot_map(state$game),
        error = function(e) dp_placeholder_plot(conditionMessage(e))
      )
    })

    output$results <- DT::renderDT({
      empty <- "Resolve a phase to see how each order fared"
      if (is.null(state$result)) return(dp_table(data.frame(), empty = empty))
      dp_table(dp_orders_table(state$result$orders), page = 12L,
               empty = empty)
    })

    output$summary <- shiny::renderText({
      if (is.null(state$result)) return("No phase resolved yet.")
      res <- state$result
      paste0(
        res$season, " ", res$year, " ", res$phase, "\n",
        sum(res$orders$success, na.rm = TRUE), " of ", nrow(res$orders),
        " orders succeeded\n",
        nrow(res$dislodged), " dislodged\n",
        length(res$contested), " province(s) contested\n",
        if (nrow(res$disbanded) > 0L) {
          paste0(nrow(res$disbanded), " disbanded\n")
        } else "",
        if (nrow(res$built) > 0L) paste0(nrow(res$built), " built\n") else ""
      )
    })
  })
}
