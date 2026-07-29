# Tab 2 - order entry ----------------------------------------------------------

mod_orders_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 340,
      shiny::selectInput(ns("power"), "Power", choices = .dp_powers),
      shiny::selectInput(ns("unit"), "Unit", choices = character(0)),
      shiny::selectInput(ns("order"), "Legal order", choices = character(0)),
      shiny::actionButton(ns("add"), "Add order", class = "btn-primary w-100"),
      shiny::hr(),
      shiny::textAreaInput(
        ns("text"), "Or type orders, one per line",
        placeholder = "France: A Par - Bur\nFrance: A Mar S A Par - Bur",
        height = "120px"
      ),
      shiny::actionButton(ns("parse"), "Add typed orders", class = "w-100"),
      shiny::hr(),
      shiny::selectInput(ns("bot"), "Fill remaining powers with",
                         choices = .dp_bots),
      shiny::actionButton(ns("fill"), "Fill with bot", class = "w-100"),
      shiny::actionButton(ns("clear"), "Clear all orders",
                          class = "btn-outline-secondary w-100 mt-2")
    ),
    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        bslib::card_header("Submitted orders"),
        DT::DTOutput(ns("submitted"))
      ),
      bslib::card(
        bslib::card_header("Legality"),
        shiny::verbatimTextOutput(ns("status"))
      )
    )
  )
}

mod_orders_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    legal <- shiny::reactive({
      shiny::req(state$game, input$power)
      tryCatch(
        diplomacyR::dp_legal_orders(state$game, input$power),
        error = function(e) NULL
      )
    })

    shiny::observe({
      lo <- legal()
      choices <- if (is.null(lo) || nrow(lo) == 0L) {
        character(0)
      } else {
        sort(unique(stats::na.omit(lo$loc)))
      }
      shiny::updateSelectInput(session, "unit", choices = choices)
    })

    shiny::observe({
      lo <- legal()
      shiny::req(input$unit)
      if (is.null(lo) || nrow(lo) == 0L) {
        shiny::updateSelectInput(session, "order", choices = character(0))
        return()
      }
      sub <- lo[!is.na(lo$loc) & lo$loc == input$unit, , drop = FALSE]
      txt <- if (nrow(sub) == 0L) character(0) else format(sub)
      shiny::updateSelectInput(session, "order", choices = txt)
    })

    add_orders <- function(new) {
      if (is.null(new) || nrow(new) == 0L) return(invisible(NULL))
      keep <- if (is.null(state$orders)) {
        new
      } else {
        old <- state$orders
        old <- old[!(old$power %in% new$power &
                       old$loc %in% new$loc), , drop = FALSE]
        diplomacyR::dp_bind_orders(old, new)
      }
      state$orders <- keep
    }

    shiny::observeEvent(input$add, {
      shiny::req(input$order)
      lo <- legal()
      shiny::req(lo)
      hit <- which(format(lo) == input$order)
      shiny::req(length(hit) > 0L)
      add_orders(lo[hit[1], , drop = FALSE])
    })

    shiny::observeEvent(input$parse, {
      shiny::req(state$game, nzchar(input$text))
      parsed <- tryCatch(
        diplomacyR::dp_parse_orders(
          strsplit(input$text, "\n")[[1]],
          power = input$power, phase = state$game$phase,
          map = state$game$map
        ),
        error = function(e) {
          state$message <- conditionMessage(e)
          NULL
        }
      )
      if (!is.null(parsed)) {
        state$message <- paste(nrow(parsed), "order(s) accepted.")
        add_orders(parsed)
      }
    })

    shiny::observeEvent(input$fill, {
      shiny::req(state$game)
      have <- if (is.null(state$orders)) character(0) else
        unique(state$orders$power)
      todo <- setdiff(state$game$powers, have)
      if (length(todo) == 0L) {
        state$message <- "Every power already has orders."
        return()
      }
      parts <- lapply(todo, function(p) {
        diplomacyR::dp_ai_orders(state$game, p, bot = input$bot)
      })
      add_orders(do.call(diplomacyR::dp_bind_orders, parts))
      state$message <- paste("Filled", length(todo), "power(s) with the",
                             input$bot, "bot.")
    })

    shiny::observeEvent(input$clear, {
      state$orders <- NULL
      state$message <- "Orders cleared."
    })

    output$submitted <- DT::renderDT({
      DT::datatable(
        dp_orders_table(state$orders), rownames = FALSE,
        options = list(pageLength = 12, dom = "tp")
      )
    })

    output$status <- shiny::renderText({
      shiny::req(state$game)
      n <- if (is.null(state$orders)) 0L else nrow(state$orders)
      paste0(
        state$game$season, " ", state$game$year, " (", state$game$phase,
        " phase)\n", n, " order(s) submitted\n",
        "Every order offered here comes from dp_legal_orders().\n\n",
        state$message %||% ""
      )
    })
  })
}
