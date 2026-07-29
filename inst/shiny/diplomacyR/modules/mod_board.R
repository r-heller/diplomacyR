# Tab 1 - the board ------------------------------------------------------------

mod_board_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::selectInput(
        ns("start"), "Start from",
        choices = c("New game" = "opening", "Mid-game" = "midgame",
                    "Retreat phase" = "retreat", "Adjustment phase" = "build"),
        selected = "opening"
      ),
      shiny::actionButton(ns("load"), "Load position",
                          class = "btn-primary w-100"),
      shiny::hr(),
      shiny::checkboxInput(ns("labels"), "Show province codes", TRUE),
      shiny::helpText(
        "The board is schematic: provinces sit at fixed coordinates rather ",
        "than on a drawn coastline."
      )
    ),
    # The board is a shade taller than it is wide, so a full-width card
    # letterboxes it into an unreadable thumbnail. Giving it seven columns and a
    # tall plot makes the drawing area close to square, and the tables move up
    # beside it instead of sitting under a half-empty row.
    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        bslib::card_header("Board"),
        shiny::plotOutput(ns("map"), height = "800px")
      ),
      bslib::layout_columns(
        col_widths = 12,
        bslib::card(
          bslib::card_header("Units"),
          DT::DTOutput(ns("units"))
        ),
        bslib::card(
          bslib::card_header("Supply centres"),
          DT::DTOutput(ns("centres"))
        )
      )
    )
  )
}

mod_board_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(input$load, {
      state$game <- diplomacyR::dp_example_game(input$start)
      state$history <- diplomacyR::dp_history()
      state$result <- NULL
      state$orders <- NULL
    })

    output$map <- shiny::renderPlot({
      shiny::req(state$game)
      tryCatch(
        diplomacyR::dp_plot_map(state$game, labels = isTRUE(input$labels)),
        error = function(e) dp_placeholder_plot(conditionMessage(e))
      )
    })

    output$units <- DT::renderDT({
      shiny::req(state$game)
      dp_table(diplomacyR::dp_units(state$game),
               empty = "No units on the board")
    })

    output$centres <- DT::renderDT({
      shiny::req(state$game)
      dp_table(diplomacyR::dp_supply_centres(state$game),
               empty = "No supply centres on this board")
    })
  })
}
