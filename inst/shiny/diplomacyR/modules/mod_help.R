# Tab 7 - help -----------------------------------------------------------------

mod_help_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_columns(
    col_widths = c(6, 6),
    bslib::card(
      bslib::card_header("The game in one panel"),
      shiny::tags$ul(
        shiny::tags$li(
          "Seven powers, 75 provinces, 34 supply centres. Control 18 to win."
        ),
        shiny::tags$li(
          "Armies hold land, fleets hold sea and coast. One unit per province."
        ),
        shiny::tags$li(
          "All orders resolve simultaneously. No dice: equal strength bounces."
        ),
        shiny::tags$li(
          "A year runs Spring movement, Spring retreats, Fall movement, ",
          "Fall retreats, then Winter adjustments."
        ),
        shiny::tags$li(
          "Supply centres change hands only after the Fall retreats."
        ),
        shiny::tags$li(
          "You may never dislodge your own unit, and your support cannot ",
          "help anyone else dislodge it either."
        )
      )
    ),
    bslib::card(
      bslib::card_header("Order notation"),
      shiny::tags$pre(
        paste(
          "A Par - Bur           move",
          "A Bur H               hold",
          "F Lon S A Wal - Yor   support a move",
          "F Lon S A Wal         support a hold",
          "F Nth C A Lon - Nwy   convoy",
          "A Lon - Bel via convoy",
          "A Tri R Alb           retreat",
          "Build A Par           build",
          "Remove F Bre          disband",
          "Waive                 decline a build",
          sep = "\n"
        )
      ),
      shiny::helpText(
        "Prefix with the power, as in \"France: A Par - Bur\". Full province ",
        "names work too. Fleets on Spain, Bulgaria and St Petersburg must ",
        "name a coast: \"F Spa/nc\"."
      )
    ),
    bslib::card(
      bslib::card_header("Conformance"),
      shiny::p(
        "The adjudicator is validated against the Diplomacy Adjudicator ",
        "Test Cases (DATC) by Lucas B. Kruijswijk, the community standard ",
        "conformance suite. It passes every movement-phase case in sections ",
        "6.A through 6.G: basic checks, coastal issues, supports and ",
        "dislodges, head-to-head battles, convoys, and convoying to an ",
        "adjacent place."
      ),
      shiny::p(
        "Cycles of mutually dependent orders are broken as circular ",
        "movement where every mover advances, and by the Szykman rule where ",
        "a convoy is involved."
      )
    ),
    bslib::card(
      bslib::card_header("Using this app"),
      shiny::tags$ol(
        shiny::tags$li("Board: load a position."),
        shiny::tags$li(
          "Orders: pick legal orders unit by unit, or type them; fill the ",
          "rest with a bot."
        ),
        shiny::tags$li("Adjudicate: resolve the phase and step forward."),
        shiny::tags$li("History: scrub back through the turns."),
        shiny::tags$li("Analysis: chart the supply-centre race."),
        shiny::tags$li("Simulate: run bot matchups in batch.")
      )
    )
  )
}

mod_help_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    invisible(NULL)
  })
}
