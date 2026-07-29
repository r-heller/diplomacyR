# global.R --------------------------------------------------------------------
# Shared setup for the diplomacyR application. No library() calls: every
# reference is namespace-qualified.

.dp_required <- c("shiny", "bslib", "DT", "ggplot2", "diplomacyR")
.dp_missing <- .dp_required[
  !vapply(.dp_required, requireNamespace, logical(1), quietly = TRUE)
]
if (length(.dp_missing) > 0L) {
  stop(
    "The diplomacyR app needs these packages: ",
    paste(.dp_missing, collapse = ", "),
    call. = FALSE
  )
}

.dp_has_plotly <- requireNamespace("plotly", quietly = TRUE)
.dp_has_widgets <- requireNamespace("shinyWidgets", quietly = TRUE)

.dp_accent_css <- "#5E2C8E"
.dp_powers <- c("Austria", "England", "France", "Germany", "Italy", "Russia",
                "Turkey")
.dp_bots <- c("greedy", "random", "hold", "negotiator")

.dp_theme_bs <- bslib::bs_theme(
  version = 5,
  primary = .dp_accent_css,
  base_font = bslib::font_google("Source Sans 3", local = FALSE),
  heading_font = bslib::font_google("Source Sans 3", local = FALSE)
)

# A blank plot used whenever a panel has nothing to show yet. Every plot output
# routes through this when it has nothing to draw, so that no panel of the app
# is ever simply blank.
dp_placeholder_plot <- function(message = "Nothing to show yet") {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = message,
                      colour = "grey45", size = 4.6, lineheight = 1.3) +
    ggplot2::theme_void()
}

# Column names straight off a tibble are lower-case and underscored, which is
# right for code and wrong for a table someone is reading.
dp_pretty_names <- function(df) {
  nm <- gsub("_", " ", names(df))
  names(df) <- paste0(toupper(substr(nm, 1L, 1L)), substr(nm, 2L, nchar(nm)))
  df
}

# One table style for the whole app, with an empty state that says something
# useful instead of DataTables' stock "No data available in table".
dp_table <- function(df, page = 8L, empty = "Nothing to show yet") {
  df <- as.data.frame(df)
  # A frame with no columns at all draws nothing whatsoever -- not even the
  # empty-table message -- which is how the simulate tab ended up showing a
  # blank card. One nameless column is enough to give the message a home.
  if (ncol(df) == 0L) {
    df <- data.frame(` ` = character(0), check.names = FALSE)
  }
  DT::datatable(
    dp_pretty_names(df),
    rownames = FALSE,
    options = list(
      pageLength = page, dom = "tp",
      language = list(emptyTable = empty, zeroRecords = empty)
    )
  )
}

# Render an orders tibble as a data table.
dp_orders_table <- function(orders) {
  if (is.null(orders) || nrow(orders) == 0L) {
    return(data.frame(Order = character(0), stringsAsFactors = FALSE))
  }
  out <- data.frame(
    Power = orders$power,
    Order = sub("^[^:]*: ", "", format(orders)),
    stringsAsFactors = FALSE
  )
  if ("success" %in% names(orders)) {
    out$Result <- ifelse(is.na(orders$success), "-",
                         ifelse(orders$success, "succeeded", "failed"))
  }
  if ("note" %in% names(orders)) out$Note <- orders$note
  out
}
