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

# A blank plot used whenever a panel has nothing to show yet.
dp_placeholder_plot <- function(message = "Nothing to show yet") {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = message,
                      colour = "grey40", size = 5) +
    ggplot2::theme_void()
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
