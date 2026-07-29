# diplomacyR - interactive Diplomacy ------------------------------------------
# Launched with diplomacyR::dp_run_app(). No library() calls anywhere: every
# reference is namespace-qualified.

source("global.R", local = TRUE)
for (.f in list.files("modules", pattern = "[.][Rr]$", full.names = TRUE)) {
  source(.f, local = TRUE)
}

ui <- bslib::page_navbar(
  title = shiny::tags$span(
    shiny::tags$img(src = "logo.png", height = "34px",
                    style = "margin-right:10px;"),
    "diplomacyR"
  ),
  theme = .dp_theme_bs,
  header = shiny::tags$head(
    shiny::tags$link(rel = "stylesheet", type = "text/css",
                     href = "custom.css")
  ),
  bslib::nav_panel("Board", mod_board_ui("board")),
  bslib::nav_panel("Orders", mod_orders_ui("orders")),
  bslib::nav_panel("Adjudicate", mod_adjudicate_ui("adjudicate")),
  bslib::nav_panel("History", mod_history_ui("history")),
  bslib::nav_panel("Analysis", mod_analysis_ui("analysis")),
  bslib::nav_panel("Simulate", mod_simulate_ui("simulate")),
  bslib::nav_panel("Help", mod_help_ui("help")),
  bslib::nav_spacer(),
  bslib::nav_item(
    shiny::tags$a(
      "Documentation", href = "https://r-heller.github.io/diplomacyR/",
      target = "_blank", rel = "noopener"
    )
  )
)

server <- function(input, output, session) {
  state <- shiny::reactiveValues(
    game = diplomacyR::dp_new_game(),
    orders = NULL,
    result = NULL,
    history = diplomacyR::dp_history(),
    message = NULL
  )
  mod_board_server("board", state)
  mod_orders_server("orders", state)
  mod_adjudicate_server("adjudicate", state)
  mod_history_server("history", state)
  mod_analysis_server("analysis", state)
  mod_simulate_server("simulate", state)
  mod_help_server("help", state)
}

shiny::shinyApp(ui, server)
